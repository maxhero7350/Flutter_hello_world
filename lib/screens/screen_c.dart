// ===== DART CORE =====
import 'dart:async';

// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== THIRD PARTY =====
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

// ===== CUSTOM MODELS =====
import '../models/time_data_model.dart' as time_data_model;

// ===== CUSTOM SERVICES =====
import '../services/api_service.dart' as api_service;
import '../services/offline_storage_service.dart' as offline_storage_service;

/// C頁面 - API呼叫
/// 提供時間API呼叫功能和網路狀態監控
class ScreenC extends cupertino.StatefulWidget {
  const ScreenC({super.key});

  @override
  cupertino.State<ScreenC> createState() => _ScreenCState();
}

class _ScreenCState extends cupertino.State<ScreenC> {
  final api_service.ApiService _apiService = api_service.ApiService();
  final offline_storage_service.OfflineStorageService _offlineStorage =
      offline_storage_service.OfflineStorageService();

  time_data_model.TimeDataModel? _currentTimeData;
  bool _isLoading = false;
  String? _errorMessage;
  String _networkType = '檢查中...';
  bool _isConnected = false;
  bool _isOfflineMode = false;

  StreamSubscription<connectivity.ConnectivityResult>?
  _connectivitySubscription;
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
  void _onConnectivityChanged(connectivity.ConnectivityResult result) {
    _checkNetworkStatus();

    // 如果網路恢復連線且開啟自動同步，進行資料同步
    if (result != connectivity.ConnectivityResult.none &&
        _offlineSettings['autoSync'] == true) {
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
      final timeData = await _apiService.fetchCurrentTime(
        forceOnline: forceOnline,
      );

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
          _showSuccessMessage(constants.Constants.SUCCESS_OFFLINE_DATA_LOADED);
        } else {
          _showSuccessMessage(constants.Constants.SUCCESS_TIME_FETCHED);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });

        // 如果是離線錯誤且有快取資料，不顯示錯誤對話框
        if (e.toString().contains(constants.Constants.ERROR_NETWORK) &&
            _currentTimeData != null) {
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
        _showSuccessMessage(constants.Constants.SUCCESS_CACHE_SYNC);
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
      _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_isConnected && !_isLoading) {
          _fetchCurrentTime();
        }
      });
      setState(() {});
    }
  }

  /// STEP 08: 顯示成功訊息
  void _showSuccessMessage([String? message]) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: const cupertino.Text('成功'),
          content: cupertino.Text(
            message ?? constants.Constants.SUCCESS_TIME_FETCHED,
          ),
          actions: [
            cupertino.CupertinoDialogAction(
              child: const cupertino.Text('確定'),
              onPressed: () {
                cupertino.Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 09: 顯示錯誤對話框
  void _showErrorDialog(String title, String message) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: cupertino.Text(title),
          content: cupertino.Text(message),
          actions: [
            cupertino.CupertinoDialogAction(
              child: const cupertino.Text('確定'),
              onPressed: () {
                cupertino.Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 10: 顯示測試結果對話框
  void _showTestResultDialog(Map<String, dynamic> result) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: cupertino.Text(result['success'] ? '連線測試成功' : '連線測試失敗'),
          content: cupertino.Column(
            crossAxisAlignment: cupertino.CrossAxisAlignment.start,
            mainAxisSize: cupertino.MainAxisSize.min,
            children: [
              if (result['statusCode'] != null)
                cupertino.Text('狀態碼: ${result['statusCode']}'),
              cupertino.Text('回應時間: ${result['responseTime']}ms'),
              cupertino.Text('網路狀態: ${result['networkStatus']}'),
              if (result['responseSize'] != null)
                cupertino.Text('回應大小: ${result['responseSize']} bytes'),
              if (result['error'] != null)
                cupertino.Text('錯誤: ${result['error']}'),
            ],
          ),
          actions: [
            cupertino.CupertinoDialogAction(
              child: const cupertino.Text('確定'),
              onPressed: () {
                cupertino.Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 11: 建立網路狀態卡片
  cupertino.Widget _buildNetworkStatusCard() {
    final hasCache = _cacheStats['hasTimeDataCache'] ?? false;
    final cacheAge = _cacheStats['cacheAge'];

    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      decoration: cupertino.BoxDecoration(
        color: _isConnected
            ? cupertino.CupertinoColors.systemGreen.withOpacity(0.1)
            : (hasCache
                  ? cupertino.CupertinoColors.systemOrange.withOpacity(0.1)
                  : cupertino.CupertinoColors.systemRed.withOpacity(0.1)),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.BORDER_RADIUS_LARGE,
        ),
        border: cupertino.Border.all(
          color: _isConnected
              ? cupertino.CupertinoColors.systemGreen.withOpacity(0.3)
              : (hasCache
                    ? cupertino.CupertinoColors.systemOrange.withOpacity(0.3)
                    : cupertino.CupertinoColors.systemRed.withOpacity(0.3)),
          width: 1,
        ),
      ),
      child: cupertino.Column(
        children: [
          cupertino.Row(
            children: [
              cupertino.Icon(
                _isConnected
                    ? cupertino.CupertinoIcons.wifi
                    : (hasCache
                          ? cupertino.CupertinoIcons.cloud_download
                          : cupertino.CupertinoIcons.wifi_slash),
                color: _isConnected
                    ? cupertino.CupertinoColors.systemGreen
                    : (hasCache
                          ? cupertino.CupertinoColors.systemOrange
                          : cupertino.CupertinoColors.systemRed),
                size: constants.Constants.ICON_SIZE_MEDIUM,
              ),
              const cupertino.SizedBox(
                width: constants.Constants.SPACING_MEDIUM,
              ),
              cupertino.Expanded(
                child: cupertino.Column(
                  crossAxisAlignment: cupertino.CrossAxisAlignment.start,
                  children: [
                    cupertino.Row(
                      children: [
                        cupertino.Text(
                          _isConnected ? '網路狀態' : '離線模式',
                          style: cupertino.TextStyle(
                            fontSize: constants.Constants.FONT_SIZE_LARGE,
                            fontWeight: cupertino.FontWeight.bold,
                            color: _isConnected
                                ? cupertino.CupertinoColors.systemGreen
                                : (hasCache
                                      ? cupertino.CupertinoColors.systemOrange
                                      : cupertino.CupertinoColors.systemRed),
                          ),
                        ),
                        if (!_isConnected && hasCache) ...[
                          const cupertino.SizedBox(
                            width: constants.Constants.SPACING_SMALL,
                          ),
                          cupertino.Container(
                            padding: const cupertino.EdgeInsets.symmetric(
                              horizontal: constants.Constants.SPACING_SMALL / 2,
                              vertical: 2,
                            ),
                            decoration: cupertino.BoxDecoration(
                              color: cupertino.CupertinoColors.systemOrange,
                              borderRadius: cupertino.BorderRadius.circular(
                                constants.Constants.BORDER_RADIUS_SMALL,
                              ),
                            ),
                            child: const cupertino.Text(
                              '快取可用',
                              style: cupertino.TextStyle(
                                color: cupertino.CupertinoColors.white,
                                fontSize: 10,
                                fontWeight: cupertino.FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const cupertino.SizedBox(
                      height: constants.Constants.SPACING_SMALL,
                    ),
                    cupertino.Text(
                      _isConnected ? _networkType : '使用本地快取資料',
                      style: const cupertino.TextStyle(
                        fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                        color: cupertino.CupertinoColors.label,
                      ),
                    ),
                    if (!_isConnected && hasCache && cacheAge != null) ...[
                      const cupertino.SizedBox(
                        height: constants.Constants.SPACING_SMALL / 2,
                      ),
                      cupertino.Text(
                        '快取時間：$cacheAge分鐘前',
                        style: const cupertino.TextStyle(
                          fontSize: constants.Constants.FONT_SIZE_SMALL,
                          color: cupertino.CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              cupertino.CupertinoButton(
                padding: const cupertino.EdgeInsets.symmetric(
                  horizontal: constants.Constants.SPACING_MEDIUM,
                  vertical: constants.Constants.SPACING_SMALL,
                ),
                color: _isConnected
                    ? cupertino.CupertinoColors.systemGreen
                    : cupertino.CupertinoColors.systemGrey,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.BORDER_RADIUS_MEDIUM,
                ),
                onPressed: _testApiConnection,
                child: const cupertino.Text(
                  '測試連線',
                  style: cupertino.TextStyle(
                    color: cupertino.CupertinoColors.white,
                    fontSize: constants.Constants.FONT_SIZE_SMALL,
                  ),
                ),
              ),
            ],
          ),

          // 如果有快取資料，顯示快取操作按鈕
          if (hasCache) ...[
            const cupertino.SizedBox(
              height: constants.Constants.SPACING_MEDIUM,
            ),
            cupertino.Row(
              children: [
                cupertino.Expanded(
                  child: cupertino.CupertinoButton(
                    padding: const cupertino.EdgeInsets.symmetric(
                      vertical: constants.Constants.SPACING_SMALL,
                    ),
                    color: cupertino.CupertinoColors.systemBlue,
                    borderRadius: cupertino.BorderRadius.circular(
                      constants.Constants.BORDER_RADIUS_SMALL,
                    ),
                    onPressed: _isConnected
                        ? () => _fetchCurrentTime(forceOnline: true)
                        : null,
                    child: const cupertino.Text(
                      '強制更新',
                      style: cupertino.TextStyle(
                        color: cupertino.CupertinoColors.white,
                        fontSize: constants.Constants.FONT_SIZE_SMALL,
                      ),
                    ),
                  ),
                ),
                const cupertino.SizedBox(
                  width: constants.Constants.SPACING_SMALL,
                ),
                cupertino.Expanded(
                  child: cupertino.CupertinoButton(
                    padding: const cupertino.EdgeInsets.symmetric(
                      vertical: constants.Constants.SPACING_SMALL,
                    ),
                    color: cupertino.CupertinoColors.systemRed,
                    borderRadius: cupertino.BorderRadius.circular(
                      constants.Constants.BORDER_RADIUS_SMALL,
                    ),
                    onPressed: _clearCache,
                    child: const cupertino.Text(
                      '清除快取',
                      style: cupertino.TextStyle(
                        color: cupertino.CupertinoColors.white,
                        fontSize: constants.Constants.FONT_SIZE_SMALL,
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
  cupertino.Widget _buildActionButtons() {
    return cupertino.Column(
      children: [
        // 主要呼叫按鈕
        cupertino.SizedBox(
          width: double.infinity,
          child: cupertino.CupertinoButton(
            color: _isConnected
                ? cupertino.CupertinoColors.activeBlue
                : cupertino.CupertinoColors.systemGrey,
            borderRadius: cupertino.BorderRadius.circular(
              constants.Constants.BORDER_RADIUS_LARGE,
            ),
            onPressed: (_isConnected && !_isLoading) ? _fetchCurrentTime : null,
            child: cupertino.Row(
              mainAxisAlignment: cupertino.MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  const cupertino.CupertinoActivityIndicator(
                    radius: 10,
                    color: cupertino.CupertinoColors.white,
                  ),
                  const cupertino.SizedBox(
                    width: constants.Constants.SPACING_SMALL,
                  ),
                ],
                cupertino.Icon(
                  _isLoading
                      ? cupertino.CupertinoIcons.clock
                      : cupertino.CupertinoIcons.refresh_bold,
                  color: cupertino.CupertinoColors.white,
                  size: constants.Constants.ICON_SIZE_MEDIUM,
                ),
                const cupertino.SizedBox(
                  width: constants.Constants.SPACING_SMALL,
                ),
                cupertino.Text(
                  _isLoading ? '呼叫中...' : '獲取當前時間',
                  style: const cupertino.TextStyle(
                    color: cupertino.CupertinoColors.white,
                    fontSize: constants.Constants.FONT_SIZE_LARGE,
                    fontWeight: cupertino.FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),

        // 次要按鈕行
        cupertino.Row(
          children: [
            cupertino.Expanded(
              child: cupertino.CupertinoButton(
                color: cupertino.CupertinoColors.systemGrey5,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.BORDER_RADIUS_MEDIUM,
                ),
                onPressed: _checkNetworkStatus,
                child: const cupertino.Row(
                  mainAxisAlignment: cupertino.MainAxisAlignment.center,
                  children: [
                    cupertino.Icon(
                      cupertino.CupertinoIcons.antenna_radiowaves_left_right,
                      color: cupertino.CupertinoColors.label,
                      size: constants.Constants.ICON_SIZE_SMALL,
                    ),
                    cupertino.SizedBox(
                      width: constants.Constants.SPACING_SMALL,
                    ),
                    cupertino.Text(
                      '檢查網路',
                      style: cupertino.TextStyle(
                        color: cupertino.CupertinoColors.label,
                        fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const cupertino.SizedBox(width: constants.Constants.SPACING_MEDIUM),

            cupertino.Expanded(
              child: cupertino.CupertinoButton(
                color: _autoRefreshTimer != null
                    ? cupertino.CupertinoColors.systemOrange
                    : cupertino.CupertinoColors.systemGrey5,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.BORDER_RADIUS_MEDIUM,
                ),
                onPressed: _toggleAutoRefresh,
                child: cupertino.Row(
                  mainAxisAlignment: cupertino.MainAxisAlignment.center,
                  children: [
                    cupertino.Icon(
                      _autoRefreshTimer != null
                          ? cupertino.CupertinoIcons.stop_circle
                          : cupertino.CupertinoIcons.play_circle,
                      color: _autoRefreshTimer != null
                          ? cupertino.CupertinoColors.white
                          : cupertino.CupertinoColors.label,
                      size: constants.Constants.ICON_SIZE_SMALL,
                    ),
                    const cupertino.SizedBox(
                      width: constants.Constants.SPACING_SMALL,
                    ),
                    cupertino.Text(
                      _autoRefreshTimer != null ? '停止自動' : '自動刷新',
                      style: cupertino.TextStyle(
                        color: _autoRefreshTimer != null
                            ? cupertino.CupertinoColors.white
                            : cupertino.CupertinoColors.label,
                        fontSize: constants.Constants.FONT_SIZE_MEDIUM,
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
  cupertino.Widget _buildTimeDataCard() {
    if (_currentTimeData == null && _errorMessage == null) {
      return cupertino.Container(
        padding: const cupertino.EdgeInsets.all(
          constants.Constants.SPACING_EXTRA_LARGE,
        ),
        decoration: cupertino.BoxDecoration(
          color: cupertino.CupertinoColors.systemGrey6,
          borderRadius: cupertino.BorderRadius.circular(
            constants.Constants.BORDER_RADIUS_LARGE,
          ),
          border: cupertino.Border.all(
            color: cupertino.CupertinoColors.systemGrey4,
            width: 1,
          ),
        ),
        child: const cupertino.Column(
          children: [
            cupertino.Icon(
              cupertino.CupertinoIcons.clock,
              size: constants.Constants.ICON_SIZE_EXTRA_LARGE * 2,
              color: cupertino.CupertinoColors.systemGrey3,
            ),
            cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),
            cupertino.Text(
              '還沒有獲取時間資料',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_LARGE,
                fontWeight: cupertino.FontWeight.bold,
                color: cupertino.CupertinoColors.secondaryLabel,
              ),
            ),
            cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
            cupertino.Text(
              '點擊按鈕呼叫時間API',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                color: cupertino.CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return cupertino.Container(
        padding: const cupertino.EdgeInsets.all(
          constants.Constants.SPACING_LARGE,
        ),
        decoration: cupertino.BoxDecoration(
          color: cupertino.CupertinoColors.systemRed.withOpacity(0.1),
          borderRadius: cupertino.BorderRadius.circular(
            constants.Constants.BORDER_RADIUS_LARGE,
          ),
          border: cupertino.Border.all(
            color: cupertino.CupertinoColors.systemRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: cupertino.Column(
          children: [
            const cupertino.Icon(
              cupertino.CupertinoIcons.exclamationmark_triangle,
              size: constants.Constants.ICON_SIZE_EXTRA_LARGE,
              color: cupertino.CupertinoColors.systemRed,
            ),
            const cupertino.SizedBox(
              height: constants.Constants.SPACING_MEDIUM,
            ),
            const cupertino.Text(
              'API呼叫失敗',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_LARGE,
                fontWeight: cupertino.FontWeight.bold,
                color: cupertino.CupertinoColors.systemRed,
              ),
            ),
            const cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
            cupertino.Text(
              _errorMessage!,
              style: const cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                color: cupertino.CupertinoColors.label,
              ),
              textAlign: cupertino.TextAlign.center,
            ),
          ],
        ),
      );
    }

    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.BORDER_RADIUS_LARGE,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          // 標題行
          cupertino.Row(
            children: [
              const cupertino.Icon(
                cupertino.CupertinoIcons.time,
                color: cupertino.CupertinoColors.systemBlue,
                size: constants.Constants.ICON_SIZE_MEDIUM,
              ),
              const cupertino.SizedBox(
                width: constants.Constants.SPACING_SMALL,
              ),
              const cupertino.Text(
                '時間資料',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.FONT_SIZE_LARGE,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.systemBlue,
                ),
              ),
              const cupertino.Spacer(),
              if (_currentTimeData!.isExpired)
                cupertino.Container(
                  padding: const cupertino.EdgeInsets.symmetric(
                    horizontal: constants.Constants.SPACING_SMALL,
                    vertical: constants.Constants.SPACING_SMALL / 2,
                  ),
                  decoration: cupertino.BoxDecoration(
                    color: cupertino.CupertinoColors.systemOrange,
                    borderRadius: cupertino.BorderRadius.circular(
                      constants.Constants.BORDER_RADIUS_SMALL,
                    ),
                  ),
                  child: const cupertino.Text(
                    '已過期',
                    style: cupertino.TextStyle(
                      color: cupertino.CupertinoColors.white,
                      fontSize: constants.Constants.FONT_SIZE_SMALL,
                      fontWeight: cupertino.FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_LARGE),

          // 主要時間顯示
          cupertino.Container(
            padding: const cupertino.EdgeInsets.all(
              constants.Constants.SPACING_LARGE,
            ),
            decoration: cupertino.BoxDecoration(
              color: cupertino.CupertinoColors.systemBackground,
              borderRadius: cupertino.BorderRadius.circular(
                constants.Constants.BORDER_RADIUS_MEDIUM,
              ),
            ),
            child: cupertino.Column(
              children: [
                cupertino.Text(
                  _currentTimeData!.formattedDateTime,
                  style: const cupertino.TextStyle(
                    fontSize: 24,
                    fontWeight: cupertino.FontWeight.bold,
                    color: cupertino.CupertinoColors.systemBlue,
                  ),
                ),
                const cupertino.SizedBox(
                  height: constants.Constants.SPACING_SMALL,
                ),
                cupertino.Text(
                  _currentTimeData!.formattedTimezone,
                  style: const cupertino.TextStyle(
                    fontSize: constants.Constants.FONT_SIZE_LARGE,
                    color: cupertino.CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),

          const cupertino.SizedBox(height: constants.Constants.SPACING_LARGE),

          // 詳細資訊
          _buildInfoRow('時區', _currentTimeData!.timezone),
          const cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
          _buildInfoRow('UTC偏移', _currentTimeData!.utcOffset.toString()),
          const cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
          _buildInfoRow('星期幾', _currentTimeData!.weekDayText),
          const cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
          _buildInfoRow('一年中第幾天', _currentTimeData!.dayOfYear.toString()),
        ],
      ),
    );
  }

  /// STEP 14: 建立資訊行
  cupertino.Widget _buildInfoRow(String label, String value) {
    return cupertino.Row(
      mainAxisAlignment: cupertino.MainAxisAlignment.spaceBetween,
      children: [
        cupertino.Text(
          label,
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.FONT_SIZE_MEDIUM,
            color: cupertino.CupertinoColors.secondaryLabel,
          ),
        ),
        cupertino.Text(
          value,
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.FONT_SIZE_MEDIUM,
            fontWeight: cupertino.FontWeight.w600,
            color: cupertino.CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  /// STEP 15: 建立統計資訊卡片
  cupertino.Widget _buildStatsCard() {
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemPurple.withOpacity(0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.BORDER_RADIUS_LARGE,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: cupertino.Row(
        children: [
          const cupertino.Icon(
            cupertino.CupertinoIcons.chart_bar_alt_fill,
            color: cupertino.CupertinoColors.systemPurple,
            size: constants.Constants.ICON_SIZE_MEDIUM,
          ),
          const cupertino.SizedBox(width: constants.Constants.SPACING_MEDIUM),
          cupertino.Expanded(
            child: cupertino.Column(
              crossAxisAlignment: cupertino.CrossAxisAlignment.start,
              children: [
                const cupertino.Text(
                  'API使用統計',
                  style: cupertino.TextStyle(
                    fontSize: constants.Constants.FONT_SIZE_LARGE,
                    fontWeight: cupertino.FontWeight.bold,
                    color: cupertino.CupertinoColors.systemPurple,
                  ),
                ),
                const cupertino.SizedBox(
                  height: constants.Constants.SPACING_SMALL,
                ),
                cupertino.Text(
                  '已呼叫 $_apiCallCount 次 API',
                  style: const cupertino.TextStyle(
                    fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                    color: cupertino.CupertinoColors.label,
                  ),
                ),
                if (_lastUpdateTime != null) ...[
                  const cupertino.SizedBox(
                    height: constants.Constants.SPACING_SMALL / 2,
                  ),
                  cupertino.Text(
                    '最後更新：${_lastUpdateTime!.hour.toString().padLeft(2, '0')}:${_lastUpdateTime!.minute.toString().padLeft(2, '0')}:${_lastUpdateTime!.second.toString().padLeft(2, '0')}',
                    style: const cupertino.TextStyle(
                      fontSize: constants.Constants.FONT_SIZE_SMALL,
                      color: cupertino.CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_autoRefreshTimer != null)
            cupertino.Container(
              padding: const cupertino.EdgeInsets.symmetric(
                horizontal: constants.Constants.SPACING_SMALL,
                vertical: constants.Constants.SPACING_SMALL / 2,
              ),
              decoration: cupertino.BoxDecoration(
                color: cupertino.CupertinoColors.systemOrange,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.BORDER_RADIUS_SMALL,
                ),
              ),
              child: const cupertino.Text(
                '自動刷新中',
                style: cupertino.TextStyle(
                  color: cupertino.CupertinoColors.white,
                  fontSize: constants.Constants.FONT_SIZE_SMALL,
                  fontWeight: cupertino.FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    return cupertino.SafeArea(
      child: cupertino.ListView(
        padding: const cupertino.EdgeInsets.all(
          constants.Constants.SPACING_LARGE,
        ),
        children: [
          // STEP 16.01: 頁面標題
          const cupertino.Text(
            'API呼叫功能',
            style: cupertino.TextStyle(
              fontSize: constants.Constants.FONT_SIZE_EXTRA_LARGE,
              fontWeight: cupertino.FontWeight.bold,
              color: cupertino.CupertinoColors.label,
            ),
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
          const cupertino.Text(
            '呼叫時間API並顯示即時時間資訊',
            style: cupertino.TextStyle(
              fontSize: constants.Constants.FONT_SIZE_MEDIUM,
              color: cupertino.CupertinoColors.secondaryLabel,
              height: 1.5,
            ),
          ),
          const cupertino.SizedBox(
            height: constants.Constants.SPACING_EXTRA_LARGE,
          ),

          // STEP 16.02: 網路狀態卡片
          _buildNetworkStatusCard(),
          const cupertino.SizedBox(height: constants.Constants.SPACING_LARGE),

          // STEP 16.03: 統計卡片
          _buildStatsCard(),
          const cupertino.SizedBox(height: constants.Constants.SPACING_LARGE),

          // STEP 16.04: 操作按鈕
          _buildActionButtons(),
          const cupertino.SizedBox(
            height: constants.Constants.SPACING_EXTRA_LARGE,
          ),

          // STEP 16.05: 時間資料顯示
          _buildTimeDataCard(),
        ],
      ),
    );
  }
}
