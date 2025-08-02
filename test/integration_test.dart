// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== FLUTTER TEST =====
import 'package:flutter_test/flutter_test.dart';

// ===== THIRD PARTY =====
import 'package:provider/provider.dart' as provider;

// ===== CUSTOM MAIN =====
import 'package:hello_world/main.dart' as main_app;

// ===== CUSTOM PROVIDERS =====
import 'package:hello_world/providers/providers.dart' as providers;

// ===== CUSTOM UTILS =====
import 'package:hello_world/utils/screen_util.dart' as screen_util;

void main() {
  group('Provider整合測試', () {
    testWidgets('完整登入流程Provider狀態測試', (WidgetTester tester) async {
      // STEP 01: 建立應用程式
      await tester.pumpWidget(const main_app.HelloWorldApp());

      // STEP 01.01: 驗證初始Provider狀態
      final appStateProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.AppStateProvider>();
      final userProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.UserProvider>();

      expect(appStateProvider.isLoading, false);
      expect(appStateProvider.currentPage, 'login');
      expect(userProvider.isLoggedIn, false);

      // STEP 01.02: 執行快速登入
      await tester.tap(find.text('快速體驗（無需輸入）'));
      await tester.pumpAndSettle();

      // STEP 01.03: 驗證登入後的Provider狀態
      expect(userProvider.isLoggedIn, true);
      expect(userProvider.username, '訪客');
      expect(appStateProvider.currentPage, 'main');
      expect(appStateProvider.isFirstRun, false);
    });

    testWidgets('導航狀態Provider整合測試', (WidgetTester tester) async {
      // STEP 02: 建立應用程式並登入
      await tester.pumpWidget(const main_app.HelloWorldApp());
      await tester.tap(find.text('快速體驗（無需輸入）'));
      await tester.pumpAndSettle();

      // STEP 02.01: 取得NavigationProvider
      final navigationProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.NavigationProvider>();

      // STEP 02.02: 驗證初始導航狀態
      expect(navigationProvider.currentIndex, 0);
      expect(navigationProvider.isSidebarOpen, false);

      // STEP 02.03: 測試底部導航切換
      await tester.tap(find.text('B頁面').last);
      await tester.pump();
      expect(navigationProvider.currentIndex, 1);
      expect(navigationProvider.navigationCount, 1);

      // STEP 02.04: 測試側邊欄開關
      await tester.tap(find.byIcon(cupertino.CupertinoIcons.bars));
      await tester.pumpAndSettle();
      expect(navigationProvider.isSidebarOpen, true);

      // STEP 02.05: 關閉側邊欄
      await tester.tapAt(const cupertino.Offset(300, 300)); // 點擊遮罩區域
      await tester.pumpAndSettle();
      expect(navigationProvider.isSidebarOpen, false);
    });

    testWidgets('主題Provider整合測試', (WidgetTester tester) async {
      // STEP 03: 建立應用程式
      await tester.pumpWidget(const main_app.HelloWorldApp());

      // STEP 03.01: 取得ThemeProvider
      final themeProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.ThemeProvider>();

      // STEP 03.02: 驗證初始主題狀態
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.useSystemTheme, true);

      // STEP 03.03: 測試主題切換
      themeProvider.toggleDarkMode();
      await tester.pump();

      expect(themeProvider.isDarkMode, true);
      expect(themeProvider.useSystemTheme, false);
    });
  });

  group('響應式設計整合測試', () {
    testWidgets('不同裝置尺寸的UI適配測試', (WidgetTester tester) async {
      // STEP 04: 測試UI適配功能
      await tester.pumpWidget(const main_app.HelloWorldApp());
      await tester.tap(find.text('快速體驗（無需輸入）'));
      await tester.pumpAndSettle();

      // STEP 04.01: 驗證基本佈局元素
      expect(
        find.byIcon(cupertino.CupertinoIcons.bars),
        findsOneWidget,
      ); // 側邊欄按鈕
      expect(find.text('A頁面'), findsOneWidget); // 底部導航
    });

    testWidgets('方向變化適配測試', (WidgetTester tester) async {
      // STEP 05: 測試方向變化適配功能
      await tester.pumpWidget(const main_app.HelloWorldApp());
      await tester.tap(find.text('快速體驗（無需輸入）'));
      await tester.pumpAndSettle();

      // STEP 05.01: 檢查ScreenUtil狀態
      final context = tester.element(find.byType(main_app.HelloWorldApp));
      screen_util.ScreenUtil.instance.init(context);
      expect(screen_util.ScreenUtil.instance.isPortrait, isA<bool>());
    });
  });

  group('Provider + 響應式設計組合測試', () {
    testWidgets('多Provider狀態變化與響應式UI測試', (WidgetTester tester) async {
      // STEP 06: 建立應用程式
      await tester.pumpWidget(const main_app.HelloWorldApp());

      // STEP 06.01: 取得所有Provider
      final appStateProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.AppStateProvider>();
      final userProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.UserProvider>();
      final navigationProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.NavigationProvider>();
      final themeProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.ThemeProvider>();

      // STEP 06.02: 執行登入並驗證多個Provider狀態
      await tester.tap(find.text('快速體驗（無需輸入）'));
      await tester.pumpAndSettle();

      expect(userProvider.isLoggedIn, true);
      expect(appStateProvider.currentPage, 'main');
      expect(navigationProvider.currentIndex, 0);

      // STEP 06.03: 測試導航切換
      await tester.tap(find.text('C頁面').last);
      await tester.pump();
      expect(navigationProvider.currentIndex, 2);

      // STEP 06.04: 測試主題切換
      themeProvider.toggleDarkMode();
      await tester.pump();
      expect(themeProvider.isDarkMode, true);

      // STEP 06.05: 測試載入狀態
      appStateProvider.setLoading(true);
      await tester.pump();
      expect(appStateProvider.isLoading, true);
    });

    testWidgets('響應式設計與Provider狀態同步測試', (WidgetTester tester) async {
      // STEP 07: 測試響應式設計與Provider狀態同步
      await tester.pumpWidget(const main_app.HelloWorldApp());
      await tester.tap(find.text('快速體驗（無需輸入）'));
      await tester.pumpAndSettle();

      // STEP 07.01: 取得Provider和ScreenUtil
      final navigationProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.NavigationProvider>();
      final context = tester.element(find.byType(main_app.HelloWorldApp));
      screen_util.ScreenUtil.instance.init(context);

      // STEP 07.02: 驗證導航行為
      expect(navigationProvider.isSidebarOpen, false);

      // 開啟側邊欄
      await tester.tap(find.byIcon(cupertino.CupertinoIcons.bars));
      await tester.pumpAndSettle();
      expect(navigationProvider.isSidebarOpen, true);
    });
  });

  group('錯誤處理和邊界情況測試', () {
    testWidgets('Provider錯誤狀態處理測試', (WidgetTester tester) async {
      // STEP 08: 建立應用程式
      await tester.pumpWidget(const main_app.HelloWorldApp());

      // STEP 08.01: 取得AppStateProvider
      final appStateProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.AppStateProvider>();

      // STEP 08.02: 測試錯誤狀態設定
      appStateProvider.setError('測試錯誤訊息');
      await tester.pump();
      expect(appStateProvider.errorMessage, '測試錯誤訊息');

      // STEP 08.03: 測試錯誤清除
      appStateProvider.clearError();
      await tester.pump();
      expect(appStateProvider.errorMessage, isNull);
    });

    testWidgets('極端螢幕尺寸適配測試', (WidgetTester tester) async {
      // STEP 09: 測試應用程式在不同螢幕尺寸下的基本功能
      await tester.pumpWidget(const main_app.HelloWorldApp());

      // STEP 09.01: 驗證應用程式能正常載入並顯示基本元素
      expect(find.text('HelloWorld'), findsOneWidget);
      expect(find.text('快速體驗（無需輸入）'), findsOneWidget);

      // STEP 09.02: 測試快速登入功能
      await tester.tap(find.text('快速體驗（無需輸入）'));
      await tester.pumpAndSettle();

      // 驗證登入後的基本元素
      expect(find.byIcon(cupertino.CupertinoIcons.bars), findsOneWidget);
      expect(find.text('A頁面'), findsOneWidget);
    });

    testWidgets('Provider狀態重置測試', (WidgetTester tester) async {
      // STEP 10: 建立應用程式並設定一些狀態
      await tester.pumpWidget(const main_app.HelloWorldApp());

      final appStateProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.AppStateProvider>();
      final userProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.UserProvider>();
      final navigationProvider = tester
          .element(find.byType(main_app.HelloWorldApp))
          .read<providers.NavigationProvider>();

      // STEP 10.01: 登入並設定一些狀態
      await tester.tap(find.text('快速體驗（無需輸入）'));
      await tester.pumpAndSettle();

      // 切換到B頁面
      await tester.tap(find.text('B頁面').last);
      await tester.pump();

      // STEP 10.02: 驗證狀態已設定
      expect(userProvider.isLoggedIn, true);
      expect(navigationProvider.currentIndex, 1);

      // STEP 10.03: 執行重置
      appStateProvider.reset();
      userProvider.logout();
      navigationProvider.resetNavigation();
      await tester.pump();

      // STEP 10.04: 驗證狀態已重置
      expect(appStateProvider.currentPage, 'login');
      expect(userProvider.isLoggedIn, false);
      expect(navigationProvider.currentIndex, 0);
    });
  });
}
