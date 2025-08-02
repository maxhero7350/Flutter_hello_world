import 'package:logger/logger.dart' as logger;

/// 日誌工具類別
/// 提供統一的日誌記錄功能，支援不同級別的日誌輸出
class LoggerUtil {
  static final logger.Logger _logger = logger.Logger(
    // STEP 01: 設定日誌輸出格式
    printer: logger.PrettyPrinter(
      methodCount: 2, // 顯示的堆疊追蹤行數
      errorMethodCount: 8, // 錯誤時顯示的堆疊追蹤行數
      lineLength: 120, // 每行最大長度
      colors: true, // 啟用顏色
      printEmojis: true, // 啟用表情符號
      dateTimeFormat: logger.DateTimeFormat.onlyTimeAndSinceStart, // 顯示時間戳
    ),
    // STEP 02: 設定日誌級別（可根據環境調整）
    level: logger.Level.debug,
  );

  /// 記錄詳細的除錯資訊
  /// 用於開發階段的詳細追蹤
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    // STEP 01: 檢查是否為除錯模式
    assert(() {
      _logger.d(message, error: error, stackTrace: stackTrace);
      return true;
    }());
  }

  /// 記錄一般資訊
  /// 用於記錄應用程式的正常運作資訊
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    // STEP 01: 記錄資訊級別日誌
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 記錄警告資訊
  /// 用於記錄可能導致問題但不影響運作的情況
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    // STEP 01: 記錄警告級別日誌
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 記錄錯誤資訊
  /// 用於記錄錯誤但不影響應用程式繼續運作
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // STEP 01: 記錄錯誤級別日誌
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 記錄致命錯誤
  /// 用於記錄導致應用程式無法繼續運作的嚴重錯誤
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    // STEP 01: 記錄致命錯誤級別日誌
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 記錄網路請求相關日誌
  /// 專門用於記錄 API 請求和回應
  static void network(String message, [dynamic error, StackTrace? stackTrace]) {
    // STEP 01: 使用特殊標籤記錄網路相關日誌
    _logger.i('🌐 NETWORK: $message', error: error, stackTrace: stackTrace);
  }

  /// 記錄資料庫操作相關日誌
  /// 專門用於記錄資料庫操作
  static void database(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    // STEP 01: 使用特殊標籤記錄資料庫相關日誌
    _logger.i('💾 DATABASE: $message', error: error, stackTrace: stackTrace);
  }

  /// 記錄使用者操作相關日誌
  /// 專門用於記錄使用者互動
  static void user(String message, [dynamic error, StackTrace? stackTrace]) {
    // STEP 01: 使用特殊標籤記錄使用者操作日誌
    _logger.i('👤 USER: $message', error: error, stackTrace: stackTrace);
  }

  /// 檢查是否為除錯模式
  static bool get isDebugMode {
    // STEP 01: 檢查是否為除錯模式
    return true; // 在開發階段預設為除錯模式
  }
}
