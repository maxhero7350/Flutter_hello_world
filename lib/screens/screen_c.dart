// ===== DART CORE =====
import 'dart:async';

// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== THIRD PARTY =====
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;
import 'package:provider/provider.dart' as provider;

// ===== CUSTOM PROVIDERS =====
import '../providers/providers.dart' as providers;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

// ===== CUSTOM MODELS =====
import '../models/time_data_model.dart' as time_data_model;

// ===== CUSTOM SERVICES =====
import '../services/api_service_with_logger.dart' as api_service;
import '../services/offline_storage_service.dart' as offline_storage_service;

// ===== CUSTOM UTILS =====
import '../utils/logger_util.dart' as logger_util;

/// C頁面 - API呼叫
/// 提供時間API呼叫功能和網路狀態監控
class ScreenC extends cupertino.StatefulWidget {
  const ScreenC({super.key});

  @override
  cupertino.State<ScreenC> createState() => _ScreenCState();
}

class _ScreenCState extends cupertino.State<ScreenC> {
  late final api_service.ApiServiceWithLogger _apiService;
  final offline_storage_service.OfflineStorageService _offlineStorage =
      offline_storage_service.OfflineStorageService();

  time_data_model.TimeDataModel? _currentTimeData;
  String? _errorMessage;
  String _networkType = '檢查中...';
  bool _isConnected = false;
  bool _isOfflineMode = false;

  StreamSubscription<List<connectivity.ConnectivityResult>>?
  _connectivitySubscription;
  Timer? _autoRefreshTimer;
  int _apiCallCount = 0;
  DateTime? _lastUpdateTime;
  Map<String, dynamic> _offlineSettings = {};
  Map<String, dynamic> _cacheStats = {};

  @override
  void initState() {
    super.initState();
    // STEP 01: 初始化API服務
    final loadingProvider = provider.Provider.of<providers.LoadingProvider>(
      context,
      listen: false,
    );
    _apiService = api_service.ApiServiceWithLogger(
      loadingProvider: loadingProvider,
    );

    // STEP 02: 初始化離線功能
    _initializeOfflineFeatures();

    // STEP 03: 監聽網路狀態變化
    _connectivitySubscription = _apiService.connectivityStream.listen(
      _onConnectivityChanged,
    );
  }

  /// 初始化離線功能
  Future<void> _initializeOfflineFeatures() async {
    // STEP 01: 初始化離線儲存服務
    await _offlineStorage.initialize();
    // STEP 02: 載入離線設定
    await _loadOfflineSettings();
    // STEP 03: 載入快取統計
    await _loadCacheStats();
    // STEP 04: 檢查網路狀態
    await _checkNetworkStatus();
    // STEP 05: 載入快取資料（如果可用）
    await _loadCachedDataIfAvailable();
  }

  @override
  void dispose() {
    // STEP 01: 取消網路狀態監聽
    _connectivitySubscription?.cancel();
    // STEP 02: 取消自動刷新計時器
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// 檢查網路狀態
  Future<void> _checkNetworkStatus() async {
    // STEP 01: 檢查網路連線狀態
    final connected = await _apiService.isConnected();
    // STEP 02: 取得網路類型
    final networkType = await _apiService.getNetworkType();

    // STEP 03: 更新UI狀態
    if (mounted) {
      setState(() {
        _isConnected = connected;
        _networkType = networkType;
      });
    }
  }

  /// 處理網路狀態變化
  void _onConnectivityChanged(List<connectivity.ConnectivityResult> results) {
    // STEP 01: 重新檢查網路狀態
    _checkNetworkStatus();

    // STEP 02: 如果網路恢復連線且開啟自動同步，進行資料同步
    if (results.isNotEmpty &&
        !results.contains(connectivity.ConnectivityResult.none) &&
        _offlineSettings['autoSync'] == true) {
      _syncOfflineData();
    }
  }

  /// 載入離線設定
  Future<void> _loadOfflineSettings() async {
    // STEP 01: 從API服務取得離線設定
    final settings = await _apiService.getOfflineSettings();
    // STEP 02: 更新UI狀態
    if (mounted) {
      setState(() {
        _offlineSettings = settings;
      });
    }
  }

  /// 載入快取統計
  Future<void> _loadCacheStats() async {
    // STEP 01: 從API服務取得快取統計
    final stats = await _apiService.getCacheStats();
    // STEP 02: 更新UI狀態
    if (mounted) {
      setState(() {
        _cacheStats = stats;
      });
    }
  }

  /// 載入快取資料（如果可用）
  Future<void> _loadCachedDataIfAvailable() async {
    try {
      // STEP 01: 從離線儲存取得最後的時間資料
      final cachedData = await _offlineStorage.getLastTimeData();
      // STEP 02: 如果有快取資料且元件仍然掛載，更新狀態
      if (cachedData != null && mounted) {
        setState(() {
          _currentTimeData = cachedData;
          _isOfflineMode = true;
        });
      }
    } catch (e) {
      // STEP 03: 錯誤處理
      logger_util.LoggerUtil.error('載入快取資料錯誤: $e');
    }
  }

  /// 呼叫時間API
  Future<void> _fetchCurrentTime({bool forceOnline = false}) async {
    // STEP 01: 清除錯誤訊息
    setState(() {
      _errorMessage = null;
    });

    try {
      // STEP 02: 呼叫API服務取得時間資料
      final timeData = await _apiService.fetchCurrentTime(
        forceOnline: forceOnline,
      );

      // STEP 03: 更新UI狀態
      if (mounted) {
        setState(() {
          _currentTimeData = timeData;
          _apiCallCount++;
          _lastUpdateTime = DateTime.now();
          _isOfflineMode = !_isConnected && !forceOnline;
        });

        // STEP 04: 更新快取統計
        await _loadCacheStats();

        // STEP 05: 顯示成功訊息
        if (_isOfflineMode) {
          _showSuccessMessage(constants.Constants.successOfflineDataLoaded);
        } else {
          _showSuccessMessage(constants.Constants.successTimeFetched);
        }
      }
    } catch (e) {
      // STEP 06: 錯誤處理
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });

        // STEP 07: 如果是離線錯誤且有快取資料，不顯示錯誤對話框
        if (e.toString().contains(constants.Constants.errorNetwork) &&
            _currentTimeData != null) {
          logger_util.LoggerUtil.info('離線模式：使用快取資料');
        } else {
          _showErrorDialog('API呼叫失敗', e.toString());
        }
      }
    }
  }

  /// 同步離線資料
  Future<void> _syncOfflineData() async {
    try {
      // STEP 01: 同步離線資料
      await _apiService.syncOfflineData();
      // STEP 02: 重新載入快取統計
      await _loadCacheStats();

      // STEP 03: 顯示成功訊息
      if (mounted) {
        _showSuccessMessage(constants.Constants.successCacheSync);
      }
    } catch (e) {
      // STEP 04: 錯誤處理
      logger_util.LoggerUtil.error('同步離線資料錯誤: $e');
    }
  }

  /// 測試API連線
  Future<void> _testApiConnection() async {
    try {
      // STEP 01: 執行API連線測試
      final testResult = await _apiService.testApiConnection();

      // STEP 02: 顯示測試結果
      if (mounted) {
        _showTestResultDialog(testResult);
      }
    } catch (e) {
      // STEP 03: 錯誤處理
      if (mounted) {
        _showErrorDialog('連線測試失敗', e.toString());
      }
    }
  }

  /// 啟用自動刷新
  void _toggleAutoRefresh() {
    if (_autoRefreshTimer != null) {
      // STEP 01: 停止自動刷新
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
      setState(() {});
    } else {
      // STEP 02: 啟用自動刷新（每30秒）
      _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (_isConnected) {
          _fetchCurrentTime();
        }
      });
      setState(() {});
    }
  }

  /// 顯示成功訊息
  void _showSuccessMessage([String? message]) {
    // STEP 01: 顯示成功對話框
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: const cupertino.Text('成功'),
          content: cupertino.Text(
            message ?? constants.Constants.successTimeFetched,
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

  /// 顯示錯誤對話框
  void _showErrorDialog(String title, String message) {
    // STEP 01: 顯示錯誤對話框
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

  /// 顯示測試結果對話框
  void _showTestResultDialog(Map<String, dynamic> result) {
    // STEP 01: 顯示測試結果對話框
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

  /// 建立網路狀態卡片
  cupertino.Widget _buildNetworkStatusCard() {
    // STEP 01: 取得快取狀態資訊
    final hasCache = _cacheStats['hasTimeDataCache'] ?? false;
    final cacheAge = _cacheStats['cacheAge'];

    // STEP 02: 建立網路狀態容器
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(constants.Constants.spacingLarge),
      decoration: cupertino.BoxDecoration(
        color: _isConnected
            ? cupertino.CupertinoColors.systemGreen.withValues(alpha: 0.1)
            : (hasCache
                  ? cupertino.CupertinoColors.systemOrange.withValues(
                      alpha: 0.1,
                    )
                  : cupertino.CupertinoColors.systemRed.withValues(alpha: 0.1)),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.borderRadiusLarge,
        ),
        border: cupertino.Border.all(
          color: _isConnected
              ? cupertino.CupertinoColors.systemGreen.withValues(alpha: 0.3)
              : (hasCache
                    ? cupertino.CupertinoColors.systemOrange.withValues(
                        alpha: 0.3,
                      )
                    : cupertino.CupertinoColors.systemRed.withValues(
                        alpha: 0.3,
                      )),
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
                size: constants.Constants.iconSizeMedium,
              ),
              const cupertino.SizedBox(
                width: constants.Constants.spacingMedium,
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
                            fontSize: constants.Constants.fontSizeLarge,
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
                            width: constants.Constants.spacingSmall,
                          ),
                          cupertino.Container(
                            padding: const cupertino.EdgeInsets.symmetric(
                              horizontal: constants.Constants.spacingSmall / 2,
                              vertical: 2,
                            ),
                            decoration: cupertino.BoxDecoration(
                              color: cupertino.CupertinoColors.systemOrange,
                              borderRadius: cupertino.BorderRadius.circular(
                                constants.Constants.borderRadiusSmall,
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
                      height: constants.Constants.spacingSmall,
                    ),
                    cupertino.Text(
                      _isConnected ? _networkType : '使用本地快取資料',
                      style: const cupertino.TextStyle(
                        fontSize: constants.Constants.fontSizeMedium,
                        color: cupertino.CupertinoColors.label,
                      ),
                    ),
                    if (!_isConnected && hasCache && cacheAge != null) ...[
                      const cupertino.SizedBox(
                        height: constants.Constants.spacingSmall / 2,
                      ),
                      cupertino.Text(
                        '快取時間：$cacheAge分鐘前',
                        style: const cupertino.TextStyle(
                          fontSize: constants.Constants.fontSizeSmall,
                          color: cupertino.CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              cupertino.CupertinoButton(
                padding: const cupertino.EdgeInsets.symmetric(
                  horizontal: constants.Constants.spacingMedium,
                  vertical: constants.Constants.spacingSmall,
                ),
                color: _isConnected
                    ? cupertino.CupertinoColors.systemGreen
                    : cupertino.CupertinoColors.systemGrey,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.borderRadiusMedium,
                ),
                onPressed: _testApiConnection,
                child: const cupertino.Text(
                  '測試連線',
                  style: cupertino.TextStyle(
                    color: cupertino.CupertinoColors.white,
                    fontSize: constants.Constants.fontSizeSmall,
                  ),
                ),
              ),
            ],
          ),

          // 如果有快取資料，顯示快取操作按鈕
          if (hasCache) ...[
            const cupertino.SizedBox(height: constants.Constants.spacingMedium),
            cupertino.Row(
              children: [
                cupertino.Expanded(
                  child: cupertino.CupertinoButton(
                    padding: const cupertino.EdgeInsets.symmetric(
                      vertical: constants.Constants.spacingSmall,
                    ),
                    color: cupertino.CupertinoColors.systemBlue,
                    borderRadius: cupertino.BorderRadius.circular(
                      constants.Constants.borderRadiusSmall,
                    ),
                    onPressed: _isConnected
                        ? () => _fetchCurrentTime(forceOnline: true)
                        : null,
                    child: const cupertino.Text(
                      '強制更新',
                      style: cupertino.TextStyle(
                        color: cupertino.CupertinoColors.white,
                        fontSize: constants.Constants.fontSizeSmall,
                      ),
                    ),
                  ),
                ),
                const cupertino.SizedBox(
                  width: constants.Constants.spacingSmall,
                ),
                cupertino.Expanded(
                  child: cupertino.CupertinoButton(
                    padding: const cupertino.EdgeInsets.symmetric(
                      vertical: constants.Constants.spacingSmall,
                    ),
                    color: cupertino.CupertinoColors.systemRed,
                    borderRadius: cupertino.BorderRadius.circular(
                      constants.Constants.borderRadiusSmall,
                    ),
                    onPressed: _clearCache,
                    child: const cupertino.Text(
                      '清除快取',
                      style: cupertino.TextStyle(
                        color: cupertino.CupertinoColors.white,
                        fontSize: constants.Constants.fontSizeSmall,
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

  /// 清除快取
  Future<void> _clearCache() async {
    try {
      // STEP 01: 清除所有快取
      await _apiService.clearAllCache();
      // STEP 02: 重新載入快取統計
      await _loadCacheStats();

      // STEP 03: 更新UI狀態
      if (mounted) {
        setState(() {
          _currentTimeData = null;
          _isOfflineMode = false;
        });

        _showSuccessMessage('快取已清除');
      }
    } catch (e) {
      // STEP 04: 錯誤處理
      _showErrorDialog('清除快取失敗', e.toString());
    }
  }

  /// 建立操作按鈕區域
  cupertino.Widget _buildActionButtons() {
    // STEP 01: 建立按鈕容器
    return cupertino.Column(
      children: [
        // 主要呼叫按鈕
        cupertino.SizedBox(
          width: double.infinity,
          child: cupertino.CupertinoButton(
            color: _isConnected
                ? cupertino.CupertinoColors.systemBlue
                : cupertino.CupertinoColors.systemGrey,
            borderRadius: cupertino.BorderRadius.circular(
              constants.Constants.borderRadiusLarge,
            ),
            onPressed: _isConnected ? _fetchCurrentTime : null,
            child: cupertino.Row(
              mainAxisAlignment: cupertino.MainAxisAlignment.center,
              children: [
                // 載入狀態由 Provider 控制，這裡不需要顯示載入指示器
                cupertino.Icon(
                  cupertino.CupertinoIcons.refresh_bold,
                  color: cupertino.CupertinoColors.white,
                  size: constants.Constants.iconSizeMedium,
                ),
                const cupertino.SizedBox(
                  width: constants.Constants.spacingSmall,
                ),
                cupertino.Text(
                  '獲取當前時間',
                  style: const cupertino.TextStyle(
                    color: cupertino.CupertinoColors.white,
                    fontSize: constants.Constants.fontSizeLarge,
                    fontWeight: cupertino.FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const cupertino.SizedBox(height: constants.Constants.spacingMedium),

        // 次要按鈕行
        cupertino.Row(
          children: [
            cupertino.Expanded(
              child: cupertino.CupertinoButton(
                color: cupertino.CupertinoColors.systemGrey5,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.borderRadiusMedium,
                ),
                onPressed: _checkNetworkStatus,
                child: const cupertino.Row(
                  mainAxisAlignment: cupertino.MainAxisAlignment.center,
                  children: [
                    cupertino.Icon(
                      cupertino.CupertinoIcons.antenna_radiowaves_left_right,
                      color: cupertino.CupertinoColors.label,
                      size: constants.Constants.iconSizeSmall,
                    ),
                    cupertino.SizedBox(width: constants.Constants.spacingSmall),
                    cupertino.Text(
                      '檢查網路',
                      style: cupertino.TextStyle(
                        color: cupertino.CupertinoColors.label,
                        fontSize: constants.Constants.fontSizeMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const cupertino.SizedBox(width: constants.Constants.spacingMedium),

            cupertino.Expanded(
              child: cupertino.CupertinoButton(
                color: _autoRefreshTimer != null
                    ? cupertino.CupertinoColors.systemOrange
                    : cupertino.CupertinoColors.systemGrey5,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.borderRadiusMedium,
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
                      size: constants.Constants.iconSizeSmall,
                    ),
                    const cupertino.SizedBox(
                      width: constants.Constants.spacingSmall,
                    ),
                    cupertino.Text(
                      _autoRefreshTimer != null ? '停止自動' : '自動刷新',
                      style: cupertino.TextStyle(
                        color: _autoRefreshTimer != null
                            ? cupertino.CupertinoColors.white
                            : cupertino.CupertinoColors.label,
                        fontSize: constants.Constants.fontSizeMedium,
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

  /// 建立時間資料顯示卡片
  cupertino.Widget _buildTimeDataCard() {
    // STEP 01: 檢查是否有時間資料或錯誤訊息
    if (_currentTimeData == null && _errorMessage == null) {
      // STEP 02: 顯示空狀態容器
      return cupertino.Container(
        padding: const cupertino.EdgeInsets.all(
          constants.Constants.spacingExtraLarge,
        ),
        decoration: cupertino.BoxDecoration(
          color: cupertino.CupertinoColors.systemGrey6,
          borderRadius: cupertino.BorderRadius.circular(
            constants.Constants.borderRadiusLarge,
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
              size: constants.Constants.iconSizeExtraLarge * 2,
              color: cupertino.CupertinoColors.systemGrey3,
            ),
            cupertino.SizedBox(height: constants.Constants.spacingMedium),
            cupertino.Text(
              '還沒有獲取時間資料',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeLarge,
                fontWeight: cupertino.FontWeight.bold,
                color: cupertino.CupertinoColors.secondaryLabel,
              ),
            ),
            cupertino.SizedBox(height: constants.Constants.spacingSmall),
            cupertino.Text(
              '點擊按鈕呼叫時間API',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeMedium,
                color: cupertino.CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    // STEP 03: 檢查是否有錯誤訊息
    if (_errorMessage != null) {
      // STEP 04: 顯示錯誤狀態容器
      return cupertino.Container(
        padding: const cupertino.EdgeInsets.all(
          constants.Constants.spacingLarge,
        ),
        decoration: cupertino.BoxDecoration(
          color: cupertino.CupertinoColors.systemRed.withValues(alpha: 0.1),
          borderRadius: cupertino.BorderRadius.circular(
            constants.Constants.borderRadiusLarge,
          ),
          border: cupertino.Border.all(
            color: cupertino.CupertinoColors.systemRed.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: cupertino.Column(
          children: [
            const cupertino.Icon(
              cupertino.CupertinoIcons.exclamationmark_triangle,
              size: constants.Constants.iconSizeExtraLarge,
              color: cupertino.CupertinoColors.systemRed,
            ),
            const cupertino.SizedBox(height: constants.Constants.spacingMedium),
            const cupertino.Text(
              'API呼叫失敗',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeLarge,
                fontWeight: cupertino.FontWeight.bold,
                color: cupertino.CupertinoColors.systemRed,
              ),
            ),
            const cupertino.SizedBox(height: constants.Constants.spacingSmall),
            cupertino.Text(
              _errorMessage!,
              style: const cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeMedium,
                color: cupertino.CupertinoColors.label,
              ),
              textAlign: cupertino.TextAlign.center,
            ),
          ],
        ),
      );
    }

    // STEP 05: 顯示時間資料容器
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(constants.Constants.spacingLarge),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemBlue.withValues(alpha: 0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.borderRadiusLarge,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemBlue.withValues(alpha: 0.3),
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
                size: constants.Constants.iconSizeMedium,
              ),
              const cupertino.SizedBox(width: constants.Constants.spacingSmall),
              const cupertino.Text(
                '時間資料',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.fontSizeLarge,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.systemBlue,
                ),
              ),
              const cupertino.Spacer(),
              if (_currentTimeData!.isExpired)
                cupertino.Container(
                  padding: const cupertino.EdgeInsets.symmetric(
                    horizontal: constants.Constants.spacingSmall,
                    vertical: constants.Constants.spacingSmall / 2,
                  ),
                  decoration: cupertino.BoxDecoration(
                    color: cupertino.CupertinoColors.systemOrange,
                    borderRadius: cupertino.BorderRadius.circular(
                      constants.Constants.borderRadiusSmall,
                    ),
                  ),
                  child: const cupertino.Text(
                    '已過期',
                    style: cupertino.TextStyle(
                      color: cupertino.CupertinoColors.white,
                      fontSize: constants.Constants.fontSizeSmall,
                      fontWeight: cupertino.FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.spacingLarge),

          // 主要時間顯示
          cupertino.Container(
            padding: const cupertino.EdgeInsets.all(
              constants.Constants.spacingLarge,
            ),
            decoration: cupertino.BoxDecoration(
              color: cupertino.CupertinoColors.systemBackground,
              borderRadius: cupertino.BorderRadius.circular(
                constants.Constants.borderRadiusMedium,
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
                  height: constants.Constants.spacingSmall,
                ),
                cupertino.Text(
                  _currentTimeData!.formattedTimezone,
                  style: const cupertino.TextStyle(
                    fontSize: constants.Constants.fontSizeLarge,
                    color: cupertino.CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),

          const cupertino.SizedBox(height: constants.Constants.spacingLarge),

          // 詳細資訊
          _buildInfoRow('時區', _currentTimeData!.timezone),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildInfoRow('UTC偏移', _currentTimeData!.utcOffset.toString()),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildInfoRow('星期幾', _currentTimeData!.weekDayText),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildInfoRow('一年中第幾天', _currentTimeData!.dayOfYear.toString()),
        ],
      ),
    );
  }

  /// 建立資訊行
  cupertino.Widget _buildInfoRow(String label, String value) {
    // STEP 01: 建立資訊行容器
    return cupertino.Row(
      mainAxisAlignment: cupertino.MainAxisAlignment.spaceBetween,
      children: [
        cupertino.Text(
          label,
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.fontSizeMedium,
            color: cupertino.CupertinoColors.secondaryLabel,
          ),
        ),
        cupertino.Text(
          value,
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.fontSizeMedium,
            fontWeight: cupertino.FontWeight.w600,
            color: cupertino.CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  /// 建立統計資訊卡片
  cupertino.Widget _buildStatsCard() {
    // STEP 01: 建立統計容器
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(constants.Constants.spacingLarge),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemPurple.withValues(alpha: 0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.borderRadiusLarge,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: cupertino.Row(
        children: [
          const cupertino.Icon(
            cupertino.CupertinoIcons.chart_bar_alt_fill,
            color: cupertino.CupertinoColors.systemPurple,
            size: constants.Constants.iconSizeMedium,
          ),
          const cupertino.SizedBox(width: constants.Constants.spacingMedium),
          cupertino.Expanded(
            child: cupertino.Column(
              crossAxisAlignment: cupertino.CrossAxisAlignment.start,
              children: [
                const cupertino.Text(
                  'API使用統計',
                  style: cupertino.TextStyle(
                    fontSize: constants.Constants.fontSizeLarge,
                    fontWeight: cupertino.FontWeight.bold,
                    color: cupertino.CupertinoColors.systemPurple,
                  ),
                ),
                const cupertino.SizedBox(
                  height: constants.Constants.spacingSmall,
                ),
                cupertino.Text(
                  '已呼叫 $_apiCallCount 次 API',
                  style: const cupertino.TextStyle(
                    fontSize: constants.Constants.fontSizeMedium,
                    color: cupertino.CupertinoColors.label,
                  ),
                ),
                if (_lastUpdateTime != null) ...[
                  const cupertino.SizedBox(
                    height: constants.Constants.spacingSmall / 2,
                  ),
                  cupertino.Text(
                    '最後更新：${_lastUpdateTime!.hour.toString().padLeft(2, '0')}:${_lastUpdateTime!.minute.toString().padLeft(2, '0')}:${_lastUpdateTime!.second.toString().padLeft(2, '0')}',
                    style: const cupertino.TextStyle(
                      fontSize: constants.Constants.fontSizeSmall,
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
                horizontal: constants.Constants.spacingSmall,
                vertical: constants.Constants.spacingSmall / 2,
              ),
              decoration: cupertino.BoxDecoration(
                color: cupertino.CupertinoColors.systemOrange,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.borderRadiusSmall,
                ),
              ),
              child: const cupertino.Text(
                '自動刷新中',
                style: cupertino.TextStyle(
                  color: cupertino.CupertinoColors.white,
                  fontSize: constants.Constants.fontSizeSmall,
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
    // STEP 01: 建立主要堆疊容器
    return cupertino.Stack(
      children: [
        // STEP 02: 主要內容區域
        cupertino.SafeArea(
          child: cupertino.ListView(
            padding: const cupertino.EdgeInsets.all(
              constants.Constants.spacingLarge,
            ),
            children: [
              // STEP 03: 頁面標題
              const cupertino.Text(
                'API呼叫功能',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.fontSizeExtraLarge,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.label,
                ),
              ),
              const cupertino.SizedBox(
                height: constants.Constants.spacingSmall,
              ),
              const cupertino.Text(
                '呼叫時間API並顯示即時時間資訊',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.fontSizeMedium,
                  color: cupertino.CupertinoColors.secondaryLabel,
                  height: 1.5,
                ),
              ),
              const cupertino.SizedBox(
                height: constants.Constants.spacingExtraLarge,
              ),

              // STEP 04: 網路狀態卡片
              _buildNetworkStatusCard(),
              const cupertino.SizedBox(
                height: constants.Constants.spacingLarge,
              ),

              // STEP 05: 統計卡片
              _buildStatsCard(),
              const cupertino.SizedBox(
                height: constants.Constants.spacingLarge,
              ),

              // STEP 06: 操作按鈕
              _buildActionButtons(),
              const cupertino.SizedBox(
                height: constants.Constants.spacingExtraLarge,
              ),

              // STEP 07: 時間資料顯示
              _buildTimeDataCard(),
            ],
          ),
        ),
      ],
    );
  }
}
