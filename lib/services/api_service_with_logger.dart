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
    connectivity.Connectivity? connectivity,
    loading_provider.LoadingProvider? loadingProvider,
    offline_storage.OfflineStorageService? offlineStorage,
  }) : _httpClient = httpClient ?? http.Client(),
       _connectivity = connectivity ?? connectivity.Connectivity(),
       _loadingProvider = loadingProvider,
       _offlineStorage = offlineStorage;

  /// STEP 01: 檢查網路連線狀態
  Future<bool> isConnected() async {
    try {
      // STEP 01.01: 檢查網路連線
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected =
          connectivityResult != connectivity.ConnectivityResult.none;

      // STEP 01.02: 記錄網路狀態
      logger_util.LoggerUtil.network('網路連線狀態: ${connectivityResult.name}');

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
          throw Exception('${constants.Constants.ERROR_NETWORK}，且無可用的快取資料');
        }
      }

      // STEP 02.04: 發送HTTP請求
      if (!connected) {
        logger_util.LoggerUtil.error('網路未連線，無法發送請求');
        throw Exception(constants.Constants.ERROR_NETWORK);
      }

      logger_util.LoggerUtil.network(
        '正在呼叫時間API: ${constants.Constants.TIME_API_FULL_URL}',
      );

      // STEP 02.05: 嘗試主要API
      http.Response? response;
      try {
        response = await _httpClient
            .get(
              Uri.parse(constants.Constants.TIME_API_FULL_URL),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(
              Duration(seconds: constants.Constants.API_TIMEOUT_SECONDS),
            );

        logger_util.LoggerUtil.network('主要API呼叫成功，狀態碼: ${response.statusCode}');
      } catch (e) {
        logger_util.LoggerUtil.warning('主要API呼叫失敗: $e，嘗試備用API');

        // STEP 02.06: 嘗試備用API
        try {
          response = await _httpClient
              .get(
                Uri.parse(constants.Constants.BACKUP_TIME_API_URL),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              )
              .timeout(
                Duration(seconds: constants.Constants.API_TIMEOUT_SECONDS),
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
      throw e;
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
}
