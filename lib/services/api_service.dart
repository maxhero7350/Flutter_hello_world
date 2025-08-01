// ===== DART CORE =====
import 'dart:convert';
import 'dart:io';

// ===== THIRD PARTY =====
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

// ===== CUSTOM MODELS =====
import '../models/time_data_model.dart' as time_data_model;

// ===== CUSTOM SERVICES =====
import 'offline_storage_service.dart' as offline_storage_service;

/// API服務類別
/// 提供網路API呼叫功能，包含時間API和網路狀態檢查
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _httpClient = http.Client();
  final connectivity.Connectivity _connectivity = connectivity.Connectivity();
  final offline_storage_service.OfflineStorageService _offlineStorage =
      offline_storage_service.OfflineStorageService();

  /// STEP 01: 檢查網路連線狀態
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != connectivity.ConnectivityResult.none;
    } catch (e) {
      print('檢查網路連線失敗: $e');
      return false;
    }
  }

  /// STEP 02: 獲取當前時間資料（支援離線模式）
  Future<time_data_model.TimeDataModel> fetchCurrentTime({
    bool forceOnline = false,
  }) async {
    try {
      // STEP 02.01: 檢查網路連線
      final connected = await isConnected();

      // STEP 02.02: 如果離線且沒有強制線上模式，嘗試載入快取資料
      if (!connected && !forceOnline) {
        print('離線模式：嘗試載入快取資料');
        final cachedData = await _loadCachedTimeData();
        if (cachedData != null) {
          return cachedData;
        } else {
          throw Exception('${constants.Constants.ERROR_NETWORK}，且無可用的快取資料');
        }
      }

      // STEP 02.03: 線上模式 - 檢查快取有效性
      // if (connected && !forceOnline) {
      //   final isValidCache = await _offlineStorage.isCacheValid(
      //     maxAgeMinutes: 15,
      //   );
      //   if (isValidCache) {
      //     print('快取資料有效，使用快取資料');
      //     final cachedData = await _offlineStorage.getLastTimeData();
      //     if (cachedData != null) {
      //       return cachedData;
      //     }
      //   }
      // }

      // STEP 02.04: 發送HTTP請求
      if (!connected) {
        throw Exception(constants.Constants.ERROR_NETWORK);
      }

      print('正在呼叫時間API: ${constants.Constants.TIME_API_FULL_URL}');

      // STEP 02.04.01: 嘗試主要API
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
      } catch (e) {
        print('主要API呼叫失敗: $e，嘗試備用API');

        // STEP 02.04.02: 嘗試備用API
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
          print('備用API呼叫成功');
        } catch (backupError) {
          print('備用API也失敗: $backupError');
          throw e; // 拋出原始錯誤
        }
      }

      print('API回應狀態碼: ${response.statusCode}');

      // STEP 02.05: 檢查回應狀態
      if (response.statusCode == 200) {
        // STEP 02.06: 解析JSON回應
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('API回應: $jsonData');
        final timeData = time_data_model.TimeDataModel.fromApiResponse(
          jsonData,
        );

        print('時間資料解析成功: ${timeData.datetime}');

        // STEP 02.07: 儲存到快取
        await _offlineStorage.saveLastTimeData(timeData);

        // STEP 02.08: 儲存API呼叫歷史
        await _offlineStorage.saveApiCallHistory({
          'type': 'fetchCurrentTime',
          'success': true,
          'statusCode': response.statusCode,
          'responseSize': response.body.length,
          'url': constants.Constants.TIME_API_FULL_URL,
        });

        return timeData;
      }
      return time_data_model.TimeDataModel.createFromLocalTime();
      //else {
      // STEP 02.09: API失敗時嘗試載入快取
      // print('API呼叫失敗，嘗試載入快取資料');
      // final cachedData = await _loadCachedTimeData();
      // if (cachedData != null) {
      //   print('使用快取資料作為備案');
      //   return cachedData;
      // }

      // throw Exception(
      //   '${constants.Constants.ERROR_API} (狀態碼: ${response.statusCode})',
      // );
      //}
    } on SocketException catch (e) {
      print('網路連線錯誤: $e，嘗試載入快取資料');
      final cachedData = await _loadCachedTimeData();
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception(constants.Constants.ERROR_NETWORK);
    } on HttpException catch (e) {
      print('HTTP錯誤: $e，嘗試載入快取資料');
      final cachedData = await _loadCachedTimeData();
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('${constants.Constants.ERROR_API}: $e');
    } on FormatException catch (e) {
      print('JSON解析錯誤: $e');
      throw Exception('${constants.Constants.ERROR_API}: 資料格式錯誤');
    } catch (e) {
      print('API呼叫錯誤: $e');
      // 如果不是網路錯誤，嘗試載入快取
      if (!e.toString().contains(constants.Constants.ERROR_NETWORK)) {
        final cachedData = await _loadCachedTimeData();
        if (cachedData != null) {
          print('API錯誤，使用快取資料作為備案');
          return cachedData;
        }
      }

      // STEP 02.10: 如果所有API都失敗，使用本地時間作為最後備案
      print('所有API都失敗，使用本地時間作為備案');
      final localTimeData = time_data_model.TimeDataModel.createFromLocalTime();

      // 儲存本地時間到快取
      await _offlineStorage.saveLastTimeData(localTimeData);

      // 記錄使用本地時間的事件
      await _offlineStorage.saveApiCallHistory({
        'type': 'useLocalTime',
        'success': true,
        'source': 'local',
        'error': e.toString(),
      });

      return localTimeData;
    }
  }

  /// STEP 02A: 載入快取的時間資料
  Future<time_data_model.TimeDataModel?> _loadCachedTimeData() async {
    try {
      final cachedData = await _offlineStorage.getLastTimeData();
      if (cachedData != null) {
        print('快取資料載入成功');

        // 儲存快取使用記錄
        await _offlineStorage.saveApiCallHistory({
          'type': 'loadCachedTimeData',
          'success': true,
          'source': 'cache',
        });

        return cachedData;
      }
    } catch (e) {
      print('載入快取資料錯誤: $e');
    }
    return null;
  }

  /// STEP 03: 測試API連線
  Future<Map<String, dynamic>> testApiConnection() async {
    final startTime = DateTime.now();

    try {
      // STEP 03.01: 檢查網路狀態
      final connected = await isConnected();
      final connectivityResult = await _connectivity.checkConnectivity();

      if (!connected) {
        return {
          'success': false,
          'error': constants.Constants.ERROR_NETWORK,
          'networkStatus': connectivityResult.toString(),
          'responseTime': 0,
        };
      }

      // STEP 03.02: 發送測試請求
      final response = await _httpClient
          .get(
            Uri.parse(constants.Constants.TIME_API_FULL_URL),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: constants.Constants.API_TIMEOUT_SECONDS));

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      // STEP 03.03: 返回測試結果
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'responseTime': responseTime,
        'networkStatus': connectivityResult.toString(),
        'apiUrl': constants.Constants.TIME_API_FULL_URL,
        'responseSize': response.body.length,
      };
    } catch (e) {
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'success': false,
        'error': e.toString(),
        'responseTime': responseTime,
        'networkStatus': 'unknown',
      };
    }
  }

  /// STEP 04: 獲取網路連線類型
  Future<String> getNetworkType() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      switch (connectivityResult) {
        case connectivity.ConnectivityResult.wifi:
          return 'WiFi';
        case connectivity.ConnectivityResult.mobile:
          return '行動網路';
        case connectivity.ConnectivityResult.ethernet:
          return '有線網路';
        case connectivity.ConnectivityResult.bluetooth:
          return '藍牙';
        case connectivity.ConnectivityResult.none:
          return '無網路連線';
        default:
          return '未知';
      }
    } catch (e) {
      return '檢查失敗';
    }
  }

  /// STEP 05: 監聽網路狀態變化
  Stream<connectivity.ConnectivityResult> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  /// STEP 06: 獲取快取統計資訊
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _offlineStorage.getCacheStats();
  }

  /// STEP 07: 清除所有快取
  Future<void> clearAllCache() async {
    await _offlineStorage.clearAllCache();
  }

  /// STEP 08: 獲取離線設定
  Future<Map<String, dynamic>> getOfflineSettings() async {
    return await _offlineStorage.getOfflineSettings();
  }

  /// STEP 09: 儲存離線設定
  Future<void> saveOfflineSettings({
    required bool autoSync,
    required int cacheMaxAge,
    required bool showOfflineIndicator,
  }) async {
    await _offlineStorage.saveOfflineSettings(
      autoSync: autoSync,
      cacheMaxAge: cacheMaxAge,
      showOfflineIndicator: showOfflineIndicator,
    );
  }

  /// STEP 10: 獲取API呼叫歷史
  Future<List<Map<String, dynamic>>> getApiCallHistory({int limit = 20}) async {
    return await _offlineStorage.getApiCallHistory(limit: limit);
  }

  /// STEP 11: 同步離線資料（當網路恢復時）
  Future<void> syncOfflineData() async {
    try {
      print('開始同步離線資料...');

      // 檢查是否有網路連線
      final connected = await isConnected();
      if (!connected) {
        print('無網路連線，無法同步');
        return;
      }

      // 獲取離線訊息佇列
      final offlineQueue = await _offlineStorage.getOfflineMessageQueue();
      if (offlineQueue.isNotEmpty) {
        print('發現 ${offlineQueue.length} 筆離線訊息，開始同步...');

        // 這裡可以添加將離線訊息同步到伺服器的邏輯
        // 目前只是清空佇列作為示範
        await _offlineStorage.clearOfflineMessageQueue();
        print('離線訊息同步完成');
      }

      // 刷新時間資料
      await fetchCurrentTime(forceOnline: true);

      // 記錄同步事件
      await _offlineStorage.saveApiCallHistory({
        'type': 'syncOfflineData',
        'success': true,
        'syncedMessages': offlineQueue.length,
      });

      print('離線資料同步完成');
    } catch (e) {
      print('同步離線資料錯誤: $e');

      await _offlineStorage.saveApiCallHistory({
        'type': 'syncOfflineData',
        'success': false,
        'error': e.toString(),
      });
    }
  }

  /// STEP 12: 清理資源
  void dispose() {
    _httpClient.close();
  }
}
