import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../models/time_data_model.dart';
import '../models/message_model.dart';

// ===== CUSTOM UTILS =====
import '../utils/logger_util.dart' as logger_util;

/// 離線儲存服務
/// 提供本地快取和離線資料管理功能
class OfflineStorageService {
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  SharedPreferences? _prefs;

  /// STEP 01: 初始化服務
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// STEP 02: 儲存最後的時間資料
  Future<void> saveLastTimeData(TimeDataModel timeData) async {
    await initialize();
    try {
      final jsonString = timeData.toJson();
      await _prefs!.setString(Constants.prefLastTimeData, jsonString);
      await _prefs!.setInt(
        '${Constants.prefLastTimeData}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      logger_util.LoggerUtil.database('離線儲存：時間資料已快取');
    } catch (e) {
      logger_util.LoggerUtil.error('離線儲存錯誤：$e');
    }
  }

  /// STEP 03: 獲取最後的時間資料
  Future<TimeDataModel?> getLastTimeData() async {
    await initialize();
    try {
      final jsonString = _prefs!.getString(Constants.prefLastTimeData);
      if (jsonString != null) {
        final timeData = TimeDataModel.fromJson(jsonString);
        logger_util.LoggerUtil.database('離線讀取：找到快取的時間資料');
        return timeData;
      }
    } catch (e) {
      logger_util.LoggerUtil.error('離線讀取錯誤：$e');
    }
    return null;
  }

  /// STEP 04: 獲取快取資料的時間戳
  Future<DateTime?> getLastTimeDataTimestamp() async {
    await initialize();
    final timestamp = _prefs!.getInt('${Constants.prefLastTimeData}_timestamp');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// STEP 05: 檢查快取資料是否有效（未過期）
  Future<bool> isCacheValid({int maxAgeMinutes = 30}) async {
    final cacheTime = await getLastTimeDataTimestamp();
    if (cacheTime == null) return false;

    final now = DateTime.now();
    final difference = now.difference(cacheTime);
    final isValid = difference.inMinutes < maxAgeMinutes;

    logger_util.LoggerUtil.database(
      '快取檢查：${isValid ? '有效' : '已過期'} (${difference.inMinutes}分鐘前)',
    );
    return isValid;
  }

  /// STEP 06: 儲存離線狀態設定
  Future<void> saveOfflineSettings({
    required bool autoSync,
    required int cacheMaxAge,
    required bool showOfflineIndicator,
  }) async {
    await initialize();
    await _prefs!.setBool(
      '${Constants.prefOfflineSettings}_auto_sync',
      autoSync,
    );
    await _prefs!.setInt(
      '${Constants.prefOfflineSettings}_cache_max_age',
      cacheMaxAge,
    );
    await _prefs!.setBool(
      '${Constants.prefOfflineSettings}_show_indicator',
      showOfflineIndicator,
    );
  }

  /// STEP 07: 獲取離線狀態設定
  Future<Map<String, dynamic>> getOfflineSettings() async {
    await initialize();
    return {
      'autoSync':
          _prefs!.getBool('${Constants.prefOfflineSettings}_auto_sync') ?? true,
      'cacheMaxAge':
          _prefs!.getInt('${Constants.prefOfflineSettings}_cache_max_age') ??
          30,
      'showOfflineIndicator':
          _prefs!.getBool('${Constants.prefOfflineSettings}_show_indicator') ??
          true,
    };
  }

  /// STEP 08: 儲存API呼叫歷史記錄
  Future<void> saveApiCallHistory(Map<String, dynamic> callData) async {
    await initialize();
    try {
      final existingHistory =
          _prefs!.getStringList(Constants.prefApiHistory) ?? [];

      // 添加新記錄
      final newRecord = json.encode({
        ...callData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      existingHistory.add(newRecord);

      // 保持最多100筆記錄
      if (existingHistory.length > 100) {
        existingHistory.removeAt(0);
      }

      await _prefs!.setStringList(Constants.prefApiHistory, existingHistory);
      logger_util.LoggerUtil.database('API歷史記錄已儲存');
    } catch (e) {
      logger_util.LoggerUtil.error('儲存API歷史記錄錯誤：$e');
    }
  }

  /// STEP 09: 獲取API呼叫歷史記錄
  Future<List<Map<String, dynamic>>> getApiCallHistory({int limit = 20}) async {
    await initialize();
    try {
      final historyList = _prefs!.getStringList(Constants.prefApiHistory) ?? [];

      final history = historyList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();

      // 按時間排序（最新的在前）
      history.sort(
        (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int),
      );

      // 限制返回數量
      return history.take(limit).toList();
    } catch (e) {
      logger_util.LoggerUtil.error('讀取API歷史記錄錯誤：$e');
      return [];
    }
  }

  /// STEP 10: 儲存離線訊息佇列（當網路斷線時）
  Future<void> saveOfflineMessageQueue(List<MessageModel> messages) async {
    await initialize();
    try {
      final jsonList = messages.map((msg) => msg.toJson()).toList();
      await _prefs!.setStringList(Constants.prefOfflineQueue, jsonList);
      logger_util.LoggerUtil.database('離線訊息佇列已儲存：${messages.length}筆');
    } catch (e) {
      logger_util.LoggerUtil.error('儲存離線訊息佇列錯誤：$e');
    }
  }

  /// STEP 11: 獲取離線訊息佇列
  Future<List<MessageModel>> getOfflineMessageQueue() async {
    await initialize();
    try {
      final jsonList = _prefs!.getStringList(Constants.prefOfflineQueue) ?? [];
      final messages = jsonList
          .map((json) => MessageModel.fromJson(json))
          .toList();

      logger_util.LoggerUtil.database('離線訊息佇列讀取：${messages.length}筆');
      return messages;
    } catch (e) {
      logger_util.LoggerUtil.error('讀取離線訊息佇列錯誤：$e');
      return [];
    }
  }

  /// STEP 12: 清空離線訊息佇列
  Future<void> clearOfflineMessageQueue() async {
    await initialize();
    await _prefs!.remove(Constants.prefOfflineQueue);
    logger_util.LoggerUtil.database('離線訊息佇列已清空');
  }

  /// STEP 13: 儲存網路狀態變化歷史
  Future<void> saveNetworkStatusChange(
    String status,
    String networkType,
  ) async {
    await initialize();
    try {
      final statusHistory =
          _prefs!.getStringList(Constants.prefNetworkHistory) ?? [];

      final newStatus = json.encode({
        'status': status,
        'networkType': networkType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      statusHistory.add(newStatus);

      // 保持最多50筆記錄
      if (statusHistory.length > 50) {
        statusHistory.removeAt(0);
      }

      await _prefs!.setStringList(Constants.prefNetworkHistory, statusHistory);
    } catch (e) {
      logger_util.LoggerUtil.error('儲存網路狀態歷史錯誤：$e');
    }
  }

  /// STEP 14: 獲取網路狀態變化歷史
  Future<List<Map<String, dynamic>>> getNetworkStatusHistory({
    int limit = 10,
  }) async {
    await initialize();
    try {
      final historyList =
          _prefs!.getStringList(Constants.prefNetworkHistory) ?? [];

      final history = historyList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();

      // 按時間排序（最新的在前）
      history.sort(
        (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int),
      );

      return history.take(limit).toList();
    } catch (e) {
      logger_util.LoggerUtil.error('讀取網路狀態歷史錯誤：$e');
      return [];
    }
  }

  /// STEP 15: 獲取快取統計資訊
  Future<Map<String, dynamic>> getCacheStats() async {
    await initialize();

    final lastTimeData = await getLastTimeData();
    final cacheTimestamp = await getLastTimeDataTimestamp();
    final apiHistory = await getApiCallHistory();
    final offlineQueue = await getOfflineMessageQueue();
    final networkHistory = await getNetworkStatusHistory();

    return {
      'hasTimeDataCache': lastTimeData != null,
      'cacheAge': cacheTimestamp != null
          ? DateTime.now().difference(cacheTimestamp).inMinutes
          : null,
      'apiCallCount': apiHistory.length,
      'offlineQueueSize': offlineQueue.length,
      'networkHistorySize': networkHistory.length,
      'isValidCache': await isCacheValid(),
      'lastCacheTime': cacheTimestamp?.toIso8601String(),
    };
  }

  /// STEP 16: 清除所有快取資料
  Future<void> clearAllCache() async {
    await initialize();
    try {
      await _prefs!.remove(Constants.prefLastTimeData);
      await _prefs!.remove('${Constants.prefLastTimeData}_timestamp');
      await _prefs!.remove(Constants.prefApiHistory);
      await _prefs!.remove(Constants.prefOfflineQueue);
      await _prefs!.remove(Constants.prefNetworkHistory);

      logger_util.LoggerUtil.database('所有快取資料已清除');
    } catch (e) {
      logger_util.LoggerUtil.error('清除快取錯誤：$e');
    }
  }

  /// STEP 17: 重置所有離線設定
  Future<void> resetOfflineSettings() async {
    await initialize();
    try {
      await _prefs!.remove('${Constants.prefOfflineSettings}_auto_sync');
      await _prefs!.remove('${Constants.prefOfflineSettings}_cache_max_age');
      await _prefs!.remove('${Constants.prefOfflineSettings}_show_indicator');

      logger_util.LoggerUtil.database('離線設定已重置為預設值');
    } catch (e) {
      logger_util.LoggerUtil.error('重置離線設定錯誤：$e');
    }
  }
}
