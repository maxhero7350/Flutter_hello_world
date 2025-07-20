import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/providers/providers.dart';

void main() {
  group('AppStateProvider 測試', () {
    late AppStateProvider appStateProvider;

    setUp(() {
      // STEP 01: 每個測試前建立新的Provider實例
      appStateProvider = AppStateProvider();
    });

    test('初始狀態測試', () {
      // STEP 01.01: 驗證初始狀態
      expect(appStateProvider.isLoading, false);
      expect(appStateProvider.errorMessage, isNull);
      expect(appStateProvider.isFirstRun, true);
      expect(appStateProvider.currentPage, 'login');
    });

    test('設定載入狀態', () {
      // STEP 01.02: 測試載入狀態設定
      appStateProvider.setLoading(true);
      expect(appStateProvider.isLoading, true);

      appStateProvider.setLoading(false);
      expect(appStateProvider.isLoading, false);
    });

    test('錯誤訊息管理', () {
      // STEP 01.03: 測試錯誤訊息設定
      const errorMessage = '測試錯誤訊息';
      appStateProvider.setError(errorMessage);
      expect(appStateProvider.errorMessage, errorMessage);

      // STEP 01.04: 測試清除錯誤訊息
      appStateProvider.clearError();
      expect(appStateProvider.errorMessage, isNull);
    });

    test('頁面狀態管理', () {
      // STEP 01.05: 測試頁面狀態設定
      appStateProvider.setCurrentPage('main');
      expect(appStateProvider.currentPage, 'main');

      appStateProvider.setCurrentPage('settings');
      expect(appStateProvider.currentPage, 'settings');
    });

    test('首次執行狀態', () {
      // STEP 01.06: 測試首次執行狀態設定
      appStateProvider.setFirstRun(false);
      expect(appStateProvider.isFirstRun, false);

      appStateProvider.setFirstRun(true);
      expect(appStateProvider.isFirstRun, true);
    });

    test('重置所有狀態', () {
      // STEP 01.07: 設定一些非預設狀態
      appStateProvider.setLoading(true);
      appStateProvider.setError('測試錯誤');
      appStateProvider.setCurrentPage('main');
      appStateProvider.setFirstRun(false);

      // STEP 01.08: 執行重置
      appStateProvider.reset();

      // STEP 01.09: 驗證所有狀態回到初始值
      expect(appStateProvider.isLoading, false);
      expect(appStateProvider.errorMessage, isNull);
      expect(appStateProvider.isFirstRun, true);
      expect(appStateProvider.currentPage, 'login');
    });
  });

  group('UserProvider 測試', () {
    late UserProvider userProvider;

    setUp(() {
      // STEP 02: 每個測試前建立新的Provider實例
      userProvider = UserProvider();
    });

    test('初始狀態測試', () {
      // STEP 02.01: 驗證初始狀態
      expect(userProvider.username, isNull);
      expect(userProvider.isLoggedIn, false);
      expect(userProvider.userPreference, 'default');
      expect(userProvider.lastLoginTime, isNull);
    });

    test('用戶登入', () {
      // STEP 02.02: 測試用戶登入
      const testUsername = '測試用戶';
      userProvider.login(testUsername);

      expect(userProvider.username, testUsername);
      expect(userProvider.isLoggedIn, true);
      expect(userProvider.lastLoginTime, isNotNull);
    });

    test('用戶登出', () {
      // STEP 02.03: 先登入用戶
      userProvider.login('測試用戶');
      userProvider.updatePreference('custom');

      // STEP 02.04: 執行登出
      userProvider.logout();

      // STEP 02.05: 驗證登出後的狀態
      expect(userProvider.username, isNull);
      expect(userProvider.isLoggedIn, false);
      expect(userProvider.lastLoginTime, isNull);
      expect(userProvider.userPreference, 'default');
    });

    test('更新用戶偏好', () {
      // STEP 02.06: 測試偏好設定更新
      userProvider.updatePreference('dark_mode');
      expect(userProvider.userPreference, 'dark_mode');

      userProvider.updatePreference('light_mode');
      expect(userProvider.userPreference, 'light_mode');
    });

    test('取得顯示名稱', () {
      // STEP 02.07: 測試未登入時的顯示名稱
      expect(userProvider.getDisplayName(), '訪客');

      // STEP 02.08: 測試登入後的顯示名稱
      userProvider.login('John');
      expect(userProvider.getDisplayName(), 'John');
    });

    test('檢查用戶有效性', () {
      // STEP 02.09: 測試未登入時無效
      expect(userProvider.isValidUser(), false);

      // STEP 02.10: 測試空字串用戶名無效
      userProvider.login('');
      expect(userProvider.isValidUser(), false);

      // STEP 02.11: 測試有效用戶
      userProvider.login('ValidUser');
      expect(userProvider.isValidUser(), true);
    });
  });

  group('NavigationProvider 測試', () {
    late NavigationProvider navigationProvider;

    setUp(() {
      // STEP 03: 每個測試前建立新的Provider實例
      navigationProvider = NavigationProvider();
    });

    test('初始狀態測試', () {
      // STEP 03.01: 驗證初始狀態
      expect(navigationProvider.currentIndex, 0);
      expect(navigationProvider.isSidebarOpen, false);
      expect(navigationProvider.navigationHistory, isEmpty);
      expect(navigationProvider.navigationCount, 0);
      expect(navigationProvider.lastVisitedPage, '');
    });

    test('設定當前索引', () {
      // STEP 03.02: 測試索引設定
      navigationProvider.setCurrentIndex(1);
      
      expect(navigationProvider.currentIndex, 1);
      expect(navigationProvider.navigationCount, 1);
      expect(navigationProvider.navigationHistory, contains('Screen B'));
      expect(navigationProvider.lastVisitedPage, 'Screen A');
    });

    test('側邊欄狀態管理', () {
      // STEP 03.03: 測試側邊欄切換
      navigationProvider.toggleSidebar();
      expect(navigationProvider.isSidebarOpen, true);

      navigationProvider.toggleSidebar();
      expect(navigationProvider.isSidebarOpen, false);

      // STEP 03.04: 測試關閉側邊欄
      navigationProvider.toggleSidebar(); // 開啟
      navigationProvider.closeSidebar();
      expect(navigationProvider.isSidebarOpen, false);
    });

    test('導航歷史記錄', () {
      // STEP 03.05: 測試導航歷史建立
      navigationProvider.setCurrentIndex(0); // Screen A
      navigationProvider.setCurrentIndex(1); // Screen B
      navigationProvider.setCurrentIndex(2); // Screen C

      expect(navigationProvider.navigationHistory.length, 3);
      expect(navigationProvider.navigationHistory, ['Screen A', 'Screen B', 'Screen C']);
      expect(navigationProvider.navigationCount, 3);
    });

    test('重置導航狀態', () {
      // STEP 03.06: 設定一些狀態
      navigationProvider.setCurrentIndex(2);
      navigationProvider.toggleSidebar();

      // STEP 03.07: 執行重置
      navigationProvider.resetNavigation();

      // STEP 03.08: 驗證重置結果
      expect(navigationProvider.currentIndex, 0);
      expect(navigationProvider.isSidebarOpen, false);
      expect(navigationProvider.navigationHistory, isEmpty);
      expect(navigationProvider.navigationCount, 0);
      expect(navigationProvider.lastVisitedPage, '');
    });

    test('取得導航統計資訊', () {
      // STEP 03.09: 設定一些導航狀態
      navigationProvider.setCurrentIndex(1);
      navigationProvider.setCurrentIndex(2);

      // STEP 03.10: 取得統計資訊
      final stats = navigationProvider.getNavigationStats();

      expect(stats['totalNavigations'], 2);
      expect(stats['historyLength'], 2);
      expect(stats['currentPage'], 'Screen C');
      expect(stats['lastPage'], 'Screen B');
    });
  });

  group('ThemeProvider 測試', () {
    late ThemeProvider themeProvider;

    setUp(() {
      // STEP 04: 每個測試前建立新的Provider實例
      themeProvider = ThemeProvider();
    });

    test('初始狀態測試', () {
      // STEP 04.01: 驗證初始狀態
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.textScaleFactor, 1.0);
      expect(themeProvider.fontFamily, 'system');
      expect(themeProvider.useSystemTheme, true);
    });

    test('深色模式切換', () {
      // STEP 04.02: 測試深色模式切換
      themeProvider.toggleDarkMode();
      expect(themeProvider.isDarkMode, true);
      expect(themeProvider.useSystemTheme, false); // 手動切換後停用系統主題

      themeProvider.toggleDarkMode();
      expect(themeProvider.isDarkMode, false);
    });

    test('設定深色模式', () {
      // STEP 04.03: 測試直接設定深色模式
      themeProvider.setDarkMode(true);
      expect(themeProvider.isDarkMode, true);
      expect(themeProvider.useSystemTheme, false);

      // STEP 04.04: 測試設定相同值不會觸發變更
      themeProvider.setDarkMode(true);
      expect(themeProvider.isDarkMode, true);
    });

    test('文字縮放比例設定', () {
      // STEP 04.05: 測試有效範圍內的縮放
      themeProvider.setTextScaleFactor(1.2);
      expect(themeProvider.textScaleFactor, 1.2);

      // STEP 04.06: 測試邊界值
      themeProvider.setTextScaleFactor(0.8);
      expect(themeProvider.textScaleFactor, 0.8);

      themeProvider.setTextScaleFactor(2.0);
      expect(themeProvider.textScaleFactor, 2.0);

      // STEP 04.07: 測試超出範圍的值不會被設定
      themeProvider.setTextScaleFactor(0.5); // 小於0.8
      expect(themeProvider.textScaleFactor, 2.0); // 應該保持之前的值

      themeProvider.setTextScaleFactor(3.0); // 大於2.0
      expect(themeProvider.textScaleFactor, 2.0); // 應該保持之前的值
    });

    test('字體家族設定', () {
      // STEP 04.08: 測試字體家族設定
      themeProvider.setFontFamily('Roboto');
      expect(themeProvider.fontFamily, 'Roboto');

      themeProvider.setFontFamily('Arial');
      expect(themeProvider.fontFamily, 'Arial');
    });

    test('系統主題跟隨', () {
      // STEP 04.09: 測試系統主題切換
      themeProvider.toggleSystemTheme();
      expect(themeProvider.useSystemTheme, false);

      themeProvider.toggleSystemTheme();
      expect(themeProvider.useSystemTheme, true);
    });

    test('主題重置', () {
      // STEP 04.10: 設定一些非預設值
      themeProvider.setDarkMode(true);
      themeProvider.setTextScaleFactor(1.5);
      themeProvider.setFontFamily('Custom');
      themeProvider.toggleSystemTheme();

      // STEP 04.11: 執行重置
      themeProvider.resetTheme();

      // STEP 04.12: 驗證重置結果
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.textScaleFactor, 1.0);
      expect(themeProvider.fontFamily, 'system');
      expect(themeProvider.useSystemTheme, true);
    });

    test('主題設定摘要', () {
      // STEP 04.13: 設定一些主題值
      themeProvider.setDarkMode(true);
      themeProvider.setTextScaleFactor(1.3);
      themeProvider.setFontFamily('Helvetica');

      // STEP 04.14: 取得主題設定摘要
      final settings = themeProvider.getThemeSettings();

      expect(settings['isDarkMode'], true);
      expect(settings['textScaleFactor'], 1.3);
      expect(settings['fontFamily'], 'Helvetica');
      expect(settings['useSystemTheme'], false);
    });
  });
}