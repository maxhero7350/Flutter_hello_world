import 'package:flutter_test/flutter_test.dart';

// ===== CUSTOM UTILS =====
import 'package:hello_world/utils/logger_util.dart' as logger_util;

// 導入所有測試檔案
import 'widget_test.dart' as widget_tests;
import 'database_test.dart' as database_tests;
import 'providers_test.dart' as provider_tests;
import 'responsive_test.dart' as responsive_tests;
import 'integration_test.dart' as integration_tests;

/// 測試運行器
/// 統一執行所有測試並提供測試報告
void main() {
  // STEP 01: 初始化日誌系統
  // 使用專案內建的日誌系統

  group('🧪 HelloWorld 完整測試套件', () {
    group('📦 資料模型測試', () {
      // STEP 02: 執行資料庫和模型相關測試
      database_tests.main();
    });

    group('🎭 Provider狀態管理測試', () {
      // STEP 03: 執行所有Provider相關測試
      provider_tests.main();
    });

    group('📱 響應式設計測試', () {
      // STEP 04: 執行響應式設計相關測試
      responsive_tests.main();
    });

    group('🖼️ Widget UI測試', () {
      // STEP 05: 執行Widget和UI相關測試
      widget_tests.main();
    });

    group('🔗 整合測試', () {
      // STEP 06: 執行整合測試
      integration_tests.main();
    });

    // STEP 07: 測試完成後的摘要資訊
    setUpAll(() {
      logger_util.LoggerUtil.info('🚀 開始執行HelloWorld測試套件...');
      logger_util.LoggerUtil.info('📊 測試範圍：');
      logger_util.LoggerUtil.info('   - Provider狀態管理');
      logger_util.LoggerUtil.info('   - 響應式設計');
      logger_util.LoggerUtil.info('   - UI組件');
      logger_util.LoggerUtil.info('   - 資料模型');
      logger_util.LoggerUtil.info('   - 整合功能');
    });

    tearDownAll(() {
      logger_util.LoggerUtil.info('✅ HelloWorld測試套件執行完成！');
      logger_util.LoggerUtil.info('📈 測試統計：');
      logger_util.LoggerUtil.info('   - 資料模型測試：12個');
      logger_util.LoggerUtil.info('   - Provider測試：24個');
      logger_util.LoggerUtil.info('   - 響應式設計測試：15個');
      logger_util.LoggerUtil.info('   - Widget測試：5個');
      logger_util.LoggerUtil.info('   - 整合測試：8個');
      logger_util.LoggerUtil.info('   - 總計：64個測試案例');
    });
  });
}
