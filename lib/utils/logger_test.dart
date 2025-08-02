import 'logger_util.dart' as logger_util;

/// 日誌工具測試類別
/// 用於測試各種日誌功能
class LoggerTest {
  /// 測試所有日誌級別
  static void testAllLogLevels() {
    // STEP 01: 測試除錯日誌
    logger_util.LoggerUtil.debug('這是一個除錯訊息');

    // STEP 02: 測試資訊日誌
    logger_util.LoggerUtil.info('這是一個資訊訊息');

    // STEP 03: 測試警告日誌
    logger_util.LoggerUtil.warning('這是一個警告訊息');

    // STEP 04: 測試錯誤日誌
    logger_util.LoggerUtil.error('這是一個錯誤訊息');

    // STEP 05: 測試致命錯誤日誌
    logger_util.LoggerUtil.fatal('這是一個致命錯誤訊息');
  }

  /// 測試特殊用途日誌
  static void testSpecialLogs() {
    // STEP 01: 測試網路日誌
    logger_util.LoggerUtil.network('發送 API 請求到 /api/users');

    // STEP 02: 測試資料庫日誌
    logger_util.LoggerUtil.database('插入新記錄到 messages 表');

    // STEP 03: 測試使用者操作日誌
    logger_util.LoggerUtil.user('使用者點擊登入按鈕');
  }

  /// 測試錯誤和堆疊追蹤
  static void testErrorLogging() {
    try {
      // STEP 01: 模擬一個錯誤
      throw Exception('這是一個測試錯誤');
    } catch (e, stackTrace) {
      // STEP 02: 記錄錯誤和堆疊追蹤
      logger_util.LoggerUtil.error('捕獲到錯誤', e, stackTrace);
    }
  }

  /// 執行所有測試
  static void runAllTests() {
    // STEP 01: 執行基本日誌測試
    testAllLogLevels();

    // STEP 02: 執行特殊用途日誌測試
    testSpecialLogs();

    // STEP 03: 執行錯誤日誌測試
    testErrorLogging();
  }
}
