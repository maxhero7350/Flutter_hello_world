import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;
import 'package:http/http.dart' as http;
import '../models/time_data_model.dart' as time_data_model;
import '../providers/loading_provider.dart' as loading_provider;
import '../services/offline_storage_service.dart' as offline_storage;
import '../utils/constants.dart' as constants;
import '../utils/logger_util.dart' as logger_util;

/// API 服務類別（使用日誌框架版本）
/// 負責處理所有網路請求和 API 呼叫
class ApiServiceWithLogger {
  final http.Client _httpClient;
  final connectivity.Connectivity _connectivity;
  final loading_provider.LoadingProvider? _loadingProvider;
  final offline_storage.OfflineStorageService? _offlineStorage;

  /// 建構函式
  ApiServiceWithLogger({
    http.Client? httpClient,
    connectivity.Connectivity? connectivityClient,
    loading_provider.LoadingProvider? loadingProvider,
    offline_storage.OfflineStorageService? offlineStorage,
  }) : _httpClient = httpClient ?? http.Client(),
       _connectivity = connectivityClient ?? connectivity.Connectivity(),
       _loadingProvider = loadingProvider,
       _offlineStorage = offlineStorage;

  /// STEP 01: 檢查網路連線狀態
  Future<bool> isConnected() async {
    try {
      // STEP 01.01: 檢查網路連線
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult.isNotEmpty &&
          !connectivityResult.contains(connectivity.ConnectivityResult.none);

      // STEP 01.02: 記錄網路狀態
      final networkTypes = connectivityResult
          .map((result) => result.name)
          .join(', ');
      logger_util.LoggerUtil.network('網路連線狀態: $networkTypes');

      return isConnected;
    } catch (e) {
      // STEP 01.03: 記錄網路檢查錯誤
      logger_util.LoggerUtil.error('檢查網路連線失敗', e);
      return false;
    }
  }

  /// STEP 02: 獲取當前時間資料（支援離線模式）
  Future<time_data_model.TimeDataModel> fetchCurrentTime({
    bool forceOnline = false,
  }) async {
    // STEP 02.01: 顯示載入狀態
    _loadingProvider?.showLoading("呼叫時間API中...");
    logger_util.LoggerUtil.info('開始獲取當前時間資料，強制線上模式: $forceOnline');

    try {
      // STEP 02.02: 檢查網路連線
      final connected = await isConnected();

      // STEP 02.03: 如果離線且沒有強制線上模式，嘗試載入快取資料
      if (!connected && !forceOnline) {
        logger_util.LoggerUtil.info('離線模式：嘗試載入快取資料');
        final cachedData = await _loadCachedTimeData();
        if (cachedData != null) {
          logger_util.LoggerUtil.info('成功載入快取資料: ${cachedData.datetime}');
          return cachedData;
        } else {
          logger_util.LoggerUtil.warning('無可用的快取資料');
          throw Exception('${constants.Constants.errorNetwork}，且無可用的快取資料');
        }
      }

      // STEP 02.04: 發送HTTP請求
      if (!connected) {
        logger_util.LoggerUtil.error('網路未連線，無法發送請求');
        throw Exception(constants.Constants.errorNetwork);
      }

      logger_util.LoggerUtil.network(
        '正在呼叫時間API: ${constants.Constants.timeApiFullUrl}',
      );

      // STEP 02.05: 嘗試主要API
      http.Response? response;
      try {
        response = await _httpClient
            .get(
              Uri.parse(constants.Constants.timeApiFullUrl),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(Duration(seconds: constants.Constants.apiTimeoutSeconds));

        logger_util.LoggerUtil.network('主要API呼叫成功，狀態碼: ${response.statusCode}');
      } catch (e) {
        logger_util.LoggerUtil.warning('主要API呼叫失敗: $e，嘗試備用API');

        // STEP 02.06: 嘗試備用API
        try {
          response = await _httpClient
              .get(
                Uri.parse(constants.Constants.backupTimeApiUrl),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              )
              .timeout(
                Duration(seconds: constants.Constants.apiTimeoutSeconds),
              );
          logger_util.LoggerUtil.network(
            '備用API呼叫成功，狀態碼: ${response.statusCode}',
          );
        } catch (backupError) {
          logger_util.LoggerUtil.error('備用API也失敗: $backupError');
          throw e; // 拋出原始錯誤
        }
      }

      // STEP 02.07: 檢查回應狀態
      if (response.statusCode == 200) {
        // STEP 02.08: 解析JSON回應
        final Map<String, dynamic> jsonData = json.decode(response.body);
        logger_util.LoggerUtil.debug('API回應內容: $jsonData');

        final timeData = time_data_model.TimeDataModel.fromApiResponse(
          jsonData,
        );
        logger_util.LoggerUtil.info('時間資料解析成功: ${timeData.datetime}');

        // STEP 02.09: 儲存到快取
        await _saveTimeDataToCache(timeData);
        logger_util.LoggerUtil.database('時間資料已儲存到快取');

        return timeData;
      } else {
        logger_util.LoggerUtil.error('API回應錯誤，狀態碼: ${response.statusCode}');
        throw Exception('API回應錯誤: ${response.statusCode}');
      }
    } catch (e) {
      logger_util.LoggerUtil.error('獲取時間資料失敗', e);
      rethrow;
    } finally {
      // STEP 02.10: 隱藏載入狀態
      _loadingProvider?.hideLoading();
    }
  }

  /// STEP 03: 載入快取的時間資料
  Future<time_data_model.TimeDataModel?> _loadCachedTimeData() async {
    try {
      // STEP 03.01: 從離線儲存載入資料
      final cachedData = await _offlineStorage?.getLastTimeData();
      if (cachedData != null) {
        logger_util.LoggerUtil.database('成功載入快取時間資料');
        return cachedData;
      } else {
        logger_util.LoggerUtil.database('快取中無時間資料');
        return null;
      }
    } catch (e) {
      logger_util.LoggerUtil.error('載入快取時間資料失敗', e);
      return null;
    }
  }

  /// STEP 04: 儲存時間資料到快取
  Future<void> _saveTimeDataToCache(
    time_data_model.TimeDataModel timeData,
  ) async {
    try {
      // STEP 04.01: 儲存到離線儲存
      await _offlineStorage?.saveLastTimeData(timeData);
      logger_util.LoggerUtil.database('時間資料已儲存到離線儲存');
    } catch (e) {
      logger_util.LoggerUtil.error('儲存時間資料到快取失敗', e);
    }
  }

  /// STEP 05: 釋放資源
  void dispose() {
    // STEP 05.01: 關閉 HTTP 客戶端
    _httpClient.close();
    logger_util.LoggerUtil.info('API服務資源已釋放');
  }

  /// STEP 06: 獲取快取統計資訊
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      // STEP 06.01: 從離線儲存獲取快取統計
      final stats = await _offlineStorage?.getCacheStats();
      logger_util.LoggerUtil.database('快取統計資訊獲取成功');
      return stats ?? {};
    } catch (e) {
      logger_util.LoggerUtil.error('獲取快取統計資訊失敗', e);
      return {};
    }
  }

  /// STEP 07: 清除所有快取
  Future<void> clearAllCache() async {
    try {
      // STEP 07.01: 清除離線儲存中的所有快取
      await _offlineStorage?.clearAllCache();
      logger_util.LoggerUtil.database('所有快取已清除');
    } catch (e) {
      logger_util.LoggerUtil.error('清除快取失敗', e);
    }
  }

  /// STEP 08: 獲取離線設定
  Future<Map<String, dynamic>> getOfflineSettings() async {
    try {
      // STEP 08.01: 從離線儲存獲取設定
      final settings = await _offlineStorage?.getOfflineSettings();
      logger_util.LoggerUtil.database('離線設定獲取成功');
      return settings ?? {};
    } catch (e) {
      logger_util.LoggerUtil.error('獲取離線設定失敗', e);
      return {};
    }
  }

  /// STEP 09: 儲存離線設定
  Future<void> saveOfflineSettings({
    required bool autoSync,
    required int cacheMaxAge,
    required bool showOfflineIndicator,
  }) async {
    try {
      // STEP 09.01: 儲存設定到離線儲存
      await _offlineStorage?.saveOfflineSettings(
        autoSync: autoSync,
        cacheMaxAge: cacheMaxAge,
        showOfflineIndicator: showOfflineIndicator,
      );
      logger_util.LoggerUtil.database('離線設定儲存成功');
    } catch (e) {
      logger_util.LoggerUtil.error('儲存離線設定失敗', e);
    }
  }

  /// STEP 10: 獲取API呼叫歷史
  Future<List<Map<String, dynamic>>> getApiCallHistory({int limit = 20}) async {
    try {
      // STEP 10.01: 從離線儲存獲取API呼叫歷史
      final history = await _offlineStorage?.getApiCallHistory(limit: limit);
      logger_util.LoggerUtil.database(
        'API呼叫歷史獲取成功，共 ${history?.length ?? 0} 筆記錄',
      );
      return history ?? [];
    } catch (e) {
      logger_util.LoggerUtil.error('獲取API呼叫歷史失敗', e);
      return [];
    }
  }

  /// STEP 11: 同步離線資料（當網路恢復時）
  Future<void> syncOfflineData() async {
    try {
      logger_util.LoggerUtil.info('開始同步離線資料...');

      // STEP 11.01: 檢查網路連線
      final connected = await isConnected();
      if (!connected) {
        logger_util.LoggerUtil.warning('無網路連線，無法同步');
        return;
      }

      // STEP 11.02: 獲取離線訊息佇列
      final offlineQueue =
          await _offlineStorage?.getOfflineMessageQueue() ?? [];
      if (offlineQueue.isNotEmpty) {
        logger_util.LoggerUtil.info('發現 ${offlineQueue.length} 筆離線訊息，開始同步...');

        // STEP 11.03: 清空離線訊息佇列
        await _offlineStorage?.clearOfflineMessageQueue();
        logger_util.LoggerUtil.info('離線訊息同步完成');
      }

      // STEP 11.04: 刷新時間資料
      await fetchCurrentTime(forceOnline: true);

      // STEP 11.05: 記錄同步事件
      await _offlineStorage?.saveApiCallHistory({
        'type': 'syncOfflineData',
        'success': true,
        'syncedMessages': offlineQueue.length,
      });

      logger_util.LoggerUtil.info('離線資料同步完成');
    } catch (e) {
      logger_util.LoggerUtil.error('同步離線資料錯誤', e);

      // STEP 11.06: 記錄同步失敗事件
      await _offlineStorage?.saveApiCallHistory({
        'type': 'syncOfflineData',
        'success': false,
        'error': e.toString(),
      });
    }
  }

  /// STEP 12: 監聽網路狀態變化
  Stream<List<connectivity.ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  /// STEP 13: 獲取網路連線類型
  Future<String> getNetworkType() async {
    try {
      // STEP 13.01: 檢查網路連線類型
      final connectivityResult = await _connectivity.checkConnectivity();
      String networkType;

      if (connectivityResult.isEmpty) {
        networkType = '無網路連線';
      } else if (connectivityResult.contains(connectivity.ConnectivityResult.none)) {
        networkType = '無網路連線';
      } else if (connectivityResult.contains(connectivity.ConnectivityResult.wifi)) {
        networkType = 'WiFi';
      } else if (connectivityResult.contains(connectivity.ConnectivityResult.mobile)) {
        networkType = '行動網路';
      } else if (connectivityResult.contains(connectivity.ConnectivityResult.ethernet)) {
        networkType = '有線網路';
      } else if (connectivityResult.contains(connectivity.ConnectivityResult.bluetooth)) {
        networkType = '藍牙';
      } else {
        networkType = '未知';
      }

      logger_util.LoggerUtil.network('網路連線類型: $networkType');
      return networkType;
    } catch (e) {
      logger_util.LoggerUtil.error('獲取網路連線類型失敗', e);
      return '檢查失敗';
    }
  }

  /// STEP 14: 測試API連線
  Future<Map<String, dynamic>> testApiConnection() async {
    final startTime = DateTime.now();

    try {
      // STEP 14.01: 檢查網路狀態
      final connected = await isConnected();
      final connectivityResult = await _connectivity.checkConnectivity();

      if (!connected) {
        logger_util.LoggerUtil.warning('測試API連線失敗：無網路連線');
        final networkTypes = connectivityResult
            .map((result) => result.name)
            .join(', ');
        return {
          'success': false,
          'error': constants.Constants.errorNetwork,
          'networkStatus': networkTypes,
          'responseTime': 0,
        };
      }

      // STEP 14.02: 發送測試請求
      logger_util.LoggerUtil.network('開始測試API連線...');
      final response = await _httpClient
          .get(
            Uri.parse(constants.Constants.timeApiFullUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: constants.Constants.apiTimeoutSeconds));

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      // STEP 14.03: 記錄測試結果
      final success = response.statusCode == 200;
      logger_util.LoggerUtil.network(
        'API連線測試完成，狀態碼: ${response.statusCode}，回應時間: ${responseTime}ms',
      );

      final networkTypes = connectivityResult
          .map((result) => result.name)
          .join(', ');
      return {
        'success': success,
        'statusCode': response.statusCode,
        'responseTime': responseTime,
        'networkStatus': networkTypes,
        'apiUrl': constants.Constants.timeApiFullUrl,
        'responseSize': response.body.length,
      };
    } catch (e) {
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      logger_util.LoggerUtil.error('API連線測試失敗', e);
      return {
        'success': false,
        'error': e.toString(),
        'responseTime': responseTime,
        'networkStatus': 'unknown',
      };
    }
  }
}
