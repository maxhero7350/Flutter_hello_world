import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/constants.dart';
import '../models/time_data_model.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';

/// C頁面 - API呼叫
/// 提供時間API呼叫功能和網路狀態監控
class ScreenC extends StatefulWidget {
  const ScreenC({super.key});

  @override
  State<ScreenC> createState() => _ScreenCState();
}

class _ScreenCState extends State<ScreenC> {
  final ApiService _apiService = ApiService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  
  TimeDataModel? _currentTimeData;
  bool _isLoading = false;
  String? _errorMessage;
  String _networkType = '檢查中...';
  bool _isConnected = false;
  bool _isOfflineMode = false;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _autoRefreshTimer;
  int _apiCallCount = 0;
  DateTime? _lastUpdateTime;
  Map<String, dynamic> _offlineSettings = {};
  Map<String, dynamic> _cacheStats = {};

  @override
  void initState() {
    super.initState();
    // STEP 01: 初始化離線功能
    _initializeOfflineFeatures();
    
    // STEP 01.01: 監聽網路狀態變化
    _connectivitySubscription = _apiService.connectivityStream.listen(
      _onConnectivityChanged,
    );
  }

  /// STEP 01A: 初始化離線功能
  Future<void> _initializeOfflineFeatures() async {
    await _offlineStorage.initialize();
    await _loadOfflineSettings();
    await _loadCacheStats();
    await _checkNetworkStatus();
    await _loadCachedDataIfAvailable();
  }

  @override
  void dispose() {
    // STEP 02: 清理資源
    _connectivitySubscription?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// STEP 03: 檢查網路狀態
  Future<void> _checkNetworkStatus() async {
    final connected = await _apiService.isConnected();
    final networkType = await _apiService.getNetworkType();
    
    if (mounted) {
      setState(() {
        _isConnected = connected;
        _networkType = networkType;
      });
    }
  }

  /// STEP 04: 處理網路狀態變化
  void _onConnectivityChanged(ConnectivityResult result) {
    _checkNetworkStatus();
    
    // 如果網路恢復連線且開啟自動同步，進行資料同步
    if (result != ConnectivityResult.none && _offlineSettings['autoSync'] == true) {
      _syncOfflineData();
    }
  }

  /// STEP 04A: 載入離線設定
  Future<void> _loadOfflineSettings() async {
    final settings = await _apiService.getOfflineSettings();
    if (mounted) {
      setState(() {
        _offlineSettings = settings;
      });
    }
  }

  /// STEP 04B: 載入快取統計
  Future<void> _loadCacheStats() async {
    final stats = await _apiService.getCacheStats();
    if (mounted) {
      setState(() {
        _cacheStats = stats;
      });
    }
  }

  /// STEP 04C: 載入快取資料（如果可用）
  Future<void> _loadCachedDataIfAvailable() async {
    try {
      final cachedData = await _offlineStorage.getLastTimeData();
      if (cachedData != null && mounted) {
        setState(() {
          _currentTimeData = cachedData;
          _isOfflineMode = true;
        });
      }
    } catch (e) {
      print('載入快取資料錯誤: $e');
    }
  }

  /// STEP 05: 呼叫時間API
  Future<void> _fetchCurrentTime({bool forceOnline = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final timeData = await _apiService.fetchCurrentTime(forceOnline: forceOnline);
      
      if (mounted) {
        setState(() {
          _currentTimeData = timeData;
          _isLoading = false;
          _apiCallCount++;
          _lastUpdateTime = DateTime.now();
          _isOfflineMode = !_isConnected && !forceOnline;
        });
        
        // 更新快取統計
        await _loadCacheStats();
        
        if (_isOfflineMode) {
          _showSuccessMessage(Constants.SUCCESS_OFFLINE_DATA_LOADED);
        } else {
          _showSuccessMessage(Constants.SUCCESS_TIME_FETCHED);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        
        // 如果是離線錯誤且有快取資料，不顯示錯誤對話框
        if (e.toString().contains(Constants.ERROR_NETWORK) && _currentTimeData != null) {
          print('離線模式：使用快取資料');
        } else {
          _showErrorDialog('API呼叫失敗', e.toString());
        }
      }
    }
  }

  /// STEP 05A: 同步離線資料
  Future<void> _syncOfflineData() async {
    try {
      await _apiService.syncOfflineData();
      await _loadCacheStats();
      
      if (mounted) {
        _showSuccessMessage(Constants.SUCCESS_CACHE_SYNC);
      }
    } catch (e) {
      print('同步離線資料錯誤: $e');
    }
  }

  /// STEP 06: 測試API連線
  Future<void> _testApiConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final testResult = await _apiService.testApiConnection();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showTestResultDialog(testResult);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showErrorDialog('連線測試失敗', e.toString());
      }
    }
  }

  /// STEP 07: 啟用自動刷新
  void _toggleAutoRefresh() {
    if (_autoRefreshTimer != null) {
      // 停止自動刷新
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
      setState(() {});
    } else {
      // 啟用自動刷新（每30秒）
      _autoRefreshTimer = Timer.periodic(
        const Duration(seconds: 30),
        (timer) {
          if (_isConnected && !_isLoading) {
            _fetchCurrentTime();
          }
        },
      );
      setState(() {});
    }
  }

  /// STEP 08: 顯示成功訊息
  void _showSuccessMessage([String? message]) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('成功'),
          content: Text(message ?? Constants.SUCCESS_TIME_FETCHED),
          actions: [
            CupertinoDialogAction(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 09: 顯示錯誤對話框
  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 10: 顯示測試結果對話框
  void _showTestResultDialog(Map<String, dynamic> result) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(result['success'] ? '連線測試成功' : '連線測試失敗'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (result['statusCode'] != null)
                Text('狀態碼: ${result['statusCode']}'),
              Text('回應時間: ${result['responseTime']}ms'),
              Text('網路狀態: ${result['networkStatus']}'),
              if (result['responseSize'] != null)
                Text('回應大小: ${result['responseSize']} bytes'),
              if (result['error'] != null)
                Text('錯誤: ${result['error']}'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 11: 建立網路狀態卡片
  Widget _buildNetworkStatusCard() {
    final hasCache = _cacheStats['hasTimeDataCache'] ?? false;
    final cacheAge = _cacheStats['cacheAge'];
    
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: _isConnected 
            ? CupertinoColors.systemGreen.withOpacity(0.1)
            : (hasCache 
                ? CupertinoColors.systemOrange.withOpacity(0.1)
                : CupertinoColors.systemRed.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: _isConnected 
              ? CupertinoColors.systemGreen.withOpacity(0.3)
              : (hasCache 
                  ? CupertinoColors.systemOrange.withOpacity(0.3)
                  : CupertinoColors.systemRed.withOpacity(0.3)),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isConnected 
                    ? CupertinoIcons.wifi 
                    : (hasCache ? CupertinoIcons.cloud_download : CupertinoIcons.wifi_slash),
                color: _isConnected 
                    ? CupertinoColors.systemGreen 
                    : (hasCache ? CupertinoColors.systemOrange : CupertinoColors.systemRed),
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              const SizedBox(width: Constants.SPACING_MEDIUM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isConnected ? '網路狀態' : '離線模式',
                          style: TextStyle(
                            fontSize: Constants.FONT_SIZE_LARGE,
                            fontWeight: FontWeight.bold,
                            color: _isConnected 
                                ? CupertinoColors.systemGreen 
                                : (hasCache ? CupertinoColors.systemOrange : CupertinoColors.systemRed),
                          ),
                        ),
                        if (!_isConnected && hasCache) ...[
                          const SizedBox(width: Constants.SPACING_SMALL),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Constants.SPACING_SMALL / 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemOrange,
                              borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_SMALL),
                            ),
                            child: const Text(
                              '快取可用',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Constants.SPACING_SMALL),
                    Text(
                      _isConnected ? _networkType : '使用本地快取資料',
                      style: const TextStyle(
                        fontSize: Constants.FONT_SIZE_MEDIUM,
                        color: CupertinoColors.label,
                      ),
                    ),
                    if (!_isConnected && hasCache && cacheAge != null) ...[
                      const SizedBox(height: Constants.SPACING_SMALL / 2),
                      Text(
                        '快取時間：${cacheAge}分鐘前',
                        style: const TextStyle(
                          fontSize: Constants.FONT_SIZE_SMALL,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.SPACING_MEDIUM,
                  vertical: Constants.SPACING_SMALL,
                ),
                color: _isConnected ? CupertinoColors.systemGreen : CupertinoColors.systemGrey,
                borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
                onPressed: _testApiConnection,
                child: const Text(
                  '測試連線',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: Constants.FONT_SIZE_SMALL,
                  ),
                ),
              ),
            ],
          ),
          
          // 如果有快取資料，顯示快取操作按鈕
          if (hasCache) ...[
            const SizedBox(height: Constants.SPACING_MEDIUM),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: Constants.SPACING_SMALL),
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_SMALL),
                    onPressed: _isConnected ? () => _fetchCurrentTime(forceOnline: true) : null,
                    child: const Text(
                      '強制更新',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: Constants.FONT_SIZE_SMALL,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Constants.SPACING_SMALL),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: Constants.SPACING_SMALL),
                    color: CupertinoColors.systemRed,
                    borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_SMALL),
                    onPressed: _clearCache,
                    child: const Text(
                      '清除快取',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: Constants.FONT_SIZE_SMALL,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// STEP 11A: 清除快取
  Future<void> _clearCache() async {
    try {
      await _apiService.clearAllCache();
      await _loadCacheStats();
      
      if (mounted) {
        setState(() {
          _currentTimeData = null;
          _isOfflineMode = false;
        });
        
        _showSuccessMessage('快取已清除');
      }
    } catch (e) {
      _showErrorDialog('清除快取失敗', e.toString());
    }
  }

  /// STEP 12: 建立操作按鈕區域
  Widget _buildActionButtons() {
    return Column(
      children: [
        // 主要呼叫按鈕
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: _isConnected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
            borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
            onPressed: (_isConnected && !_isLoading) ? _fetchCurrentTime : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  const CupertinoActivityIndicator(
                    radius: 10,
                    color: CupertinoColors.white,
                  ),
                  const SizedBox(width: Constants.SPACING_SMALL),
                ],
                Icon(
                  _isLoading ? CupertinoIcons.clock : CupertinoIcons.refresh_bold,
                  color: CupertinoColors.white,
                  size: Constants.ICON_SIZE_MEDIUM,
                ),
                const SizedBox(width: Constants.SPACING_SMALL),
                Text(
                  _isLoading ? '呼叫中...' : '獲取當前時間',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: Constants.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: Constants.SPACING_MEDIUM),
        
        // 次要按鈕行
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
                onPressed: _checkNetworkStatus,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.antenna_radiowaves_left_right,
                      color: CupertinoColors.label,
                      size: Constants.ICON_SIZE_SMALL,
                    ),
                    SizedBox(width: Constants.SPACING_SMALL),
                    Text(
                      '檢查網路',
                      style: TextStyle(
                        color: CupertinoColors.label,
                        fontSize: Constants.FONT_SIZE_MEDIUM,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: Constants.SPACING_MEDIUM),
            
            Expanded(
              child: CupertinoButton(
                color: _autoRefreshTimer != null 
                    ? CupertinoColors.systemOrange 
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
                onPressed: _toggleAutoRefresh,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _autoRefreshTimer != null 
                          ? CupertinoIcons.stop_circle 
                          : CupertinoIcons.play_circle,
                      color: _autoRefreshTimer != null 
                          ? CupertinoColors.white 
                          : CupertinoColors.label,
                      size: Constants.ICON_SIZE_SMALL,
                    ),
                    const SizedBox(width: Constants.SPACING_SMALL),
                    Text(
                      _autoRefreshTimer != null ? '停止自動' : '自動刷新',
                      style: TextStyle(
                        color: _autoRefreshTimer != null 
                            ? CupertinoColors.white 
                            : CupertinoColors.label,
                        fontSize: Constants.FONT_SIZE_MEDIUM,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// STEP 13: 建立時間資料顯示卡片
  Widget _buildTimeDataCard() {
    if (_currentTimeData == null && _errorMessage == null) {
      return Container(
        padding: const EdgeInsets.all(Constants.SPACING_EXTRA_LARGE),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 1,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              CupertinoIcons.clock,
              size: Constants.ICON_SIZE_EXTRA_LARGE * 2,
              color: CupertinoColors.systemGrey3,
            ),
            SizedBox(height: Constants.SPACING_MEDIUM),
            Text(
              '還沒有獲取時間資料',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_LARGE,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            SizedBox(height: Constants.SPACING_SMALL),
            Text(
              '點擊按鈕呼叫時間API',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(Constants.SPACING_LARGE),
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
          border: Border.all(
            color: CupertinoColors.systemRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: Constants.ICON_SIZE_EXTRA_LARGE,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: Constants.SPACING_MEDIUM),
            const Text(
              'API呼叫失敗',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_LARGE,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(height: Constants.SPACING_SMALL),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.label,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: CupertinoColors.systemBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題行
          Row(
            children: [
              const Icon(
                CupertinoIcons.time,
                color: CupertinoColors.systemBlue,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              const SizedBox(width: Constants.SPACING_SMALL),
              const Text(
                '時間資料',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const Spacer(),
              if (_currentTimeData!.isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.SPACING_SMALL,
                    vertical: Constants.SPACING_SMALL / 2,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemOrange,
                    borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_SMALL),
                  ),
                  child: const Text(
                    '已過期',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: Constants.FONT_SIZE_SMALL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Constants.SPACING_LARGE),
          
          // 主要時間顯示
          Container(
            padding: const EdgeInsets.all(Constants.SPACING_LARGE),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
            ),
            child: Column(
              children: [
                Text(
                  _currentTimeData!.formattedDateTime,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                const SizedBox(height: Constants.SPACING_SMALL),
                Text(
                  _currentTimeData!.formattedTimezone,
                  style: const TextStyle(
                    fontSize: Constants.FONT_SIZE_LARGE,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: Constants.SPACING_LARGE),
          
          // 詳細資訊
          _buildInfoRow('時區', _currentTimeData!.timezone),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildInfoRow('UTC偏移', _currentTimeData!.utcOffset.toString()),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildInfoRow('星期幾', _currentTimeData!.weekDayText),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildInfoRow('一年中第幾天', _currentTimeData!.dayOfYear.toString()),
        ],
      ),
    );
  }

  /// STEP 14: 建立資訊行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: Constants.FONT_SIZE_MEDIUM,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: Constants.FONT_SIZE_MEDIUM,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  /// STEP 15: 建立統計資訊卡片
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: CupertinoColors.systemPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: CupertinoColors.systemPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.chart_bar_alt_fill,
            color: CupertinoColors.systemPurple,
            size: Constants.ICON_SIZE_MEDIUM,
          ),
          const SizedBox(width: Constants.SPACING_MEDIUM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'API使用統計',
                  style: TextStyle(
                    fontSize: Constants.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemPurple,
                  ),
                ),
                const SizedBox(height: Constants.SPACING_SMALL),
                Text(
                  '已呼叫 $_apiCallCount 次 API',
                  style: const TextStyle(
                    fontSize: Constants.FONT_SIZE_MEDIUM,
                    color: CupertinoColors.label,
                  ),
                ),
                if (_lastUpdateTime != null) ...[
                  const SizedBox(height: Constants.SPACING_SMALL / 2),
                  Text(
                    '最後更新：${_lastUpdateTime!.hour.toString().padLeft(2, '0')}:${_lastUpdateTime!.minute.toString().padLeft(2, '0')}:${_lastUpdateTime!.second.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: Constants.FONT_SIZE_SMALL,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_autoRefreshTimer != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.SPACING_SMALL,
                vertical: Constants.SPACING_SMALL / 2,
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange,
                borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_SMALL),
              ),
              child: const Text(
                '自動刷新中',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: Constants.FONT_SIZE_SMALL,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(Constants.SPACING_LARGE),
        children: [
          // STEP 16.01: 頁面標題
          const Text(
            'API呼叫功能',
            style: TextStyle(
              fontSize: Constants.FONT_SIZE_EXTRA_LARGE,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: Constants.SPACING_SMALL),
          const Text(
            '呼叫時間API並顯示即時時間資訊',
            style: TextStyle(
              fontSize: Constants.FONT_SIZE_MEDIUM,
              color: CupertinoColors.secondaryLabel,
              height: 1.5,
            ),
          ),
          const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
          
          // STEP 16.02: 網路狀態卡片
          _buildNetworkStatusCard(),
          const SizedBox(height: Constants.SPACING_LARGE),
          
          // STEP 16.03: 統計卡片
          _buildStatsCard(),
          const SizedBox(height: Constants.SPACING_LARGE),
          
          // STEP 16.04: 操作按鈕
          _buildActionButtons(),
          const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
          
          // STEP 16.05: 時間資料顯示
          _buildTimeDataCard(),
        ],
      ),
    );
  }
} 