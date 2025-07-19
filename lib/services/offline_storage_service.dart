import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../models/time_data_model.dart';
import '../models/message_model.dart';

/// 離線儲存服務
/// 提供本地快取和離線資料管理功能
class OfflineStorageService {
  static final OfflineStorageService _instance = OfflineStorageService._internal();
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
      await _prefs!.setString(Constants.PREF_LAST_TIME_DATA, jsonString);
      await _prefs!.setInt('${Constants.PREF_LAST_TIME_DATA}_timestamp', 
          DateTime.now().millisecondsSinceEpoch);
      
      print('離線儲存：時間資料已快取');
    } catch (e) {
      print('離線儲存錯誤：$e');
    }
  }

  /// STEP 03: 獲取最後的時間資料
  Future<TimeDataModel?> getLastTimeData() async {
    await initialize();
    try {
      final jsonString = _prefs!.getString(Constants.PREF_LAST_TIME_DATA);
      if (jsonString != null) {
        final timeData = TimeDataModel.fromJson(jsonString);
        print('離線讀取：找到快取的時間資料');
        return timeData;
      }
    } catch (e) {
      print('離線讀取錯誤：$e');
    }
    return null;
  }

  /// STEP 04: 獲取快取資料的時間戳
  Future<DateTime?> getLastTimeDataTimestamp() async {
    await initialize();
    final timestamp = _prefs!.getInt('${Constants.PREF_LAST_TIME_DATA}_timestamp');
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
    
    print('快取檢查：${isValid ? '有效' : '已過期'} (${difference.inMinutes}分鐘前)');
    return isValid;
  }

  /// STEP 06: 儲存離線狀態設定
  Future<void> saveOfflineSettings({
    required bool autoSync,
    required int cacheMaxAge,
    required bool showOfflineIndicator,
  }) async {
    await initialize();
    await _prefs!.setBool('${Constants.PREF_OFFLINE_SETTINGS}_auto_sync', autoSync);
    await _prefs!.setInt('${Constants.PREF_OFFLINE_SETTINGS}_cache_max_age', cacheMaxAge);
    await _prefs!.setBool('${Constants.PREF_OFFLINE_SETTINGS}_show_indicator', showOfflineIndicator);
  }

  /// STEP 07: 獲取離線狀態設定
  Future<Map<String, dynamic>> getOfflineSettings() async {
    await initialize();
    return {
      'autoSync': _prefs!.getBool('${Constants.PREF_OFFLINE_SETTINGS}_auto_sync') ?? true,
      'cacheMaxAge': _prefs!.getInt('${Constants.PREF_OFFLINE_SETTINGS}_cache_max_age') ?? 30,
      'showOfflineIndicator': _prefs!.getBool('${Constants.PREF_OFFLINE_SETTINGS}_show_indicator') ?? true,
    };
  }

  /// STEP 08: 儲存API呼叫歷史記錄
  Future<void> saveApiCallHistory(Map<String, dynamic> callData) async {
    await initialize();
    try {
      final existingHistory = _prefs!.getStringList('${Constants.PREF_API_HISTORY}') ?? [];
      
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
      
      await _prefs!.setStringList('${Constants.PREF_API_HISTORY}', existingHistory);
      print('API歷史記錄已儲存');
    } catch (e) {
      print('儲存API歷史記錄錯誤：$e');
    }
  }

  /// STEP 09: 獲取API呼叫歷史記錄
  Future<List<Map<String, dynamic>>> getApiCallHistory({int limit = 20}) async {
    await initialize();
    try {
      final historyList = _prefs!.getStringList('${Constants.PREF_API_HISTORY}') ?? [];
      
      final history = historyList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
      
      // 按時間排序（最新的在前）
      history.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      
      // 限制返回數量
      return history.take(limit).toList();
    } catch (e) {
      print('讀取API歷史記錄錯誤：$e');
      return [];
    }
  }

  /// STEP 10: 儲存離線訊息佇列（當網路斷線時）
  Future<void> saveOfflineMessageQueue(List<MessageModel> messages) async {
    await initialize();
    try {
      final jsonList = messages.map((msg) => msg.toJson()).toList();
      await _prefs!.setStringList('${Constants.PREF_OFFLINE_QUEUE}', jsonList);
      print('離線訊息佇列已儲存：${messages.length}筆');
    } catch (e) {
      print('儲存離線訊息佇列錯誤：$e');
    }
  }

  /// STEP 11: 獲取離線訊息佇列
  Future<List<MessageModel>> getOfflineMessageQueue() async {
    await initialize();
    try {
      final jsonList = _prefs!.getStringList('${Constants.PREF_OFFLINE_QUEUE}') ?? [];
      final messages = jsonList
          .map((json) => MessageModel.fromJson(json))
          .toList();
      
      print('離線訊息佇列讀取：${messages.length}筆');
      return messages;
    } catch (e) {
      print('讀取離線訊息佇列錯誤：$e');
      return [];
    }
  }

  /// STEP 12: 清空離線訊息佇列
  Future<void> clearOfflineMessageQueue() async {
    await initialize();
    await _prefs!.remove('${Constants.PREF_OFFLINE_QUEUE}');
    print('離線訊息佇列已清空');
  }

  /// STEP 13: 儲存網路狀態變化歷史
  Future<void> saveNetworkStatusChange(String status, String networkType) async {
    await initialize();
    try {
      final statusHistory = _prefs!.getStringList('${Constants.PREF_NETWORK_HISTORY}') ?? [];
      
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
      
      await _prefs!.setStringList('${Constants.PREF_NETWORK_HISTORY}', statusHistory);
    } catch (e) {
      print('儲存網路狀態歷史錯誤：$e');
    }
  }

  /// STEP 14: 獲取網路狀態變化歷史
  Future<List<Map<String, dynamic>>> getNetworkStatusHistory({int limit = 10}) async {
    await initialize();
    try {
      final historyList = _prefs!.getStringList('${Constants.PREF_NETWORK_HISTORY}') ?? [];
      
      final history = historyList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
      
      // 按時間排序（最新的在前）
      history.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      
      return history.take(limit).toList();
    } catch (e) {
      print('讀取網路狀態歷史錯誤：$e');
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
      await _prefs!.remove(Constants.PREF_LAST_TIME_DATA);
      await _prefs!.remove('${Constants.PREF_LAST_TIME_DATA}_timestamp');
      await _prefs!.remove('${Constants.PREF_API_HISTORY}');
      await _prefs!.remove('${Constants.PREF_OFFLINE_QUEUE}');
      await _prefs!.remove('${Constants.PREF_NETWORK_HISTORY}');
      
      print('所有快取資料已清除');
    } catch (e) {
      print('清除快取錯誤：$e');
    }
  }

  /// STEP 17: 重置所有離線設定
  Future<void> resetOfflineSettings() async {
    await initialize();
    try {
      await _prefs!.remove('${Constants.PREF_OFFLINE_SETTINGS}_auto_sync');
      await _prefs!.remove('${Constants.PREF_OFFLINE_SETTINGS}_cache_max_age');
      await _prefs!.remove('${Constants.PREF_OFFLINE_SETTINGS}_show_indicator');
      
      print('離線設定已重置為預設值');
    } catch (e) {
      print('重置離線設定錯誤：$e');
    }
  }
} 