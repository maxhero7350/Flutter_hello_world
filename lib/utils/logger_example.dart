import 'logger_util.dart' as logger_util;

/// 日誌框架使用範例
/// 展示如何將 print 語句替換為結構化日誌
class LoggerExample {
  /// 範例：原本使用 print 的程式碼
  static void oldWayWithPrint() {
    print('開始處理使用者資料');

    try {
      // 模擬一些操作
      final userData = {'name': 'John', 'age': 30};
      print('使用者資料: $userData');

      // 模擬錯誤
      if ((userData['age'] as int) < 18) {
        print('錯誤：使用者年齡不足');
      }

      print('處理完成');
    } catch (e) {
      print('發生錯誤: $e');
    }
  }

  /// 範例：使用日誌框架的程式碼
  static void newWayWithLogger() {
    // STEP 01: 記錄操作開始
    logger_util.LoggerUtil.info('開始處理使用者資料');

    try {
      // STEP 02: 記錄詳細資訊
      final userData = {'name': 'John', 'age': 30};
      logger_util.LoggerUtil.debug('使用者資料: $userData');

      // STEP 03: 記錄業務邏輯檢查
      if ((userData['age'] as int) < 18) {
        logger_util.LoggerUtil.warning('使用者年齡不足，可能需要特殊處理');
      }

      // STEP 04: 記錄操作完成
      logger_util.LoggerUtil.info('使用者資料處理完成');
    } catch (e) {
      // STEP 05: 記錄錯誤
      logger_util.LoggerUtil.error('處理使用者資料時發生錯誤', e);
    }
  }

  /// 範例：網路請求日誌
  static void networkRequestExample() {
    // STEP 01: 記錄請求開始
    logger_util.LoggerUtil.network('發送 GET 請求到 /api/users');

    try {
      // 模擬網路請求
      final response = {'status': 'success', 'data': []};

      // STEP 02: 記錄回應
      logger_util.LoggerUtil.network('收到回應，狀態: ${response['status']}');

      if (response['status'] == 'success') {
        logger_util.LoggerUtil.info('網路請求成功');
      } else {
        logger_util.LoggerUtil.warning('網路請求返回非成功狀態');
      }
    } catch (e) {
      // STEP 03: 記錄網路錯誤
      logger_util.LoggerUtil.error('網路請求失敗', e);
    }
  }

  /// 範例：資料庫操作日誌
  static void databaseOperationExample() {
    // STEP 01: 記錄資料庫操作開始
    logger_util.LoggerUtil.database('開始查詢使用者資料');

    try {
      // 模擬資料庫查詢
      final users = [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
      ];

      // STEP 02: 記錄查詢結果
      logger_util.LoggerUtil.database('查詢完成，找到 ${users.length} 筆記錄');

      // STEP 03: 記錄詳細資料（僅在除錯模式）
      logger_util.LoggerUtil.debug('查詢結果: $users');
    } catch (e) {
      // STEP 04: 記錄資料庫錯誤
      logger_util.LoggerUtil.error('資料庫查詢失敗', e);
    }
  }

  /// 範例：使用者操作日誌
  static void userActionExample() {
    // STEP 01: 記錄使用者操作
    logger_util.LoggerUtil.user('使用者點擊登入按鈕');

    try {
      // 模擬登入處理
      final loginResult = {'success': true, 'userId': 123};

      if (loginResult['success'] == true) {
        // STEP 02: 記錄成功操作
        logger_util.LoggerUtil.user('使用者登入成功，ID: ${loginResult['userId']}');
        logger_util.LoggerUtil.info('使用者會話已建立');
      } else {
        // STEP 03: 記錄失敗操作
        logger_util.LoggerUtil.warning('使用者登入失敗');
      }
    } catch (e) {
      // STEP 04: 記錄操作錯誤
      logger_util.LoggerUtil.error('處理使用者登入時發生錯誤', e);
    }
  }

  /// 執行所有範例
  static void runAllExamples() {
    // STEP 01: 展示舊方式 vs 新方式
    print('=== 舊方式（使用 print）===');
    oldWayWithPrint();

    print('\n=== 新方式（使用日誌框架）===');
    newWayWithLogger();

    print('\n=== 網路請求範例 ===');
    networkRequestExample();

    print('\n=== 資料庫操作範例 ===');
    databaseOperationExample();

    print('\n=== 使用者操作範例 ===');
    userActionExample();
  }
}
