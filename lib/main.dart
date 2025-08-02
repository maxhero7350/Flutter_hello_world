// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== THIRD PARTY =====
import 'package:provider/provider.dart' as provider;

// ===== CUSTOM PROVIDERS =====
import 'providers/providers.dart' as providers;

// ===== CUSTOM SCREENS =====
import 'screens/login_screen.dart' as login_screen;
import 'screens/main_screen.dart' as main_screen;

// ===== CUSTOM UTILS =====
import 'utils/constants.dart' as constants;

/// HelloWorld應用程式入口點
///
/// 這個檔案是整個Flutter應用程式的起始點，負責：
/// 1. 初始化應用程式
/// 2. 設置狀態管理架構
/// 3. 配置路由系統
/// 4. 設定響應式設計
/// 5. 應用程式主題配置
void main() {
  // STEP 01: 啟動應用程式並設置Provider架構
  // 這是Flutter應用程式的唯一入口點
  // runApp() 會建立應用程式的根Widget並開始渲染
  cupertino.runApp(const HelloWorldApp());
}

/// HelloWorld應用程式根Widget
///
/// 這個類別是整個應用程式的根元件，負責：
/// - 建立Provider狀態管理架構
/// - 配置CupertinoApp（iOS風格應用程式）
/// - 設定路由系統
/// - 配置響應式設計
/// - 管理應用程式主題
class HelloWorldApp extends cupertino.StatelessWidget {
  const HelloWorldApp({super.key});

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    // STEP 01: 使用MultiProvider包裝整個應用程式
    // MultiProvider允許我們在應用程式層級提供多個Provider
    // 這樣所有子Widget都能存取到這些Provider管理的狀態
    return provider.MultiProvider(
      providers: [
        // STEP 01.01: 應用程式狀態Provider
        // 負責管理應用程式的全域狀態，如：
        // - 載入狀態 (isLoading)
        // - 錯誤狀態 (error)
        // - 當前頁面 (currentPage)
        // - 是否為首次執行 (isFirstRun)
        provider.ChangeNotifierProvider(
          create: (_) => providers.AppStateProvider(),
        ),

        // STEP 01.02: 用戶狀態Provider
        // 負責管理用戶相關的狀態，如：
        // - 用戶名稱 (username)
        // - 登入狀態 (isLoggedIn)
        // - 用戶偏好設定
        provider.ChangeNotifierProvider(
          create: (_) => providers.UserProvider(),
        ),

        // STEP 01.03: 導航狀態Provider
        // 負責管理應用程式的導航狀態，如：
        // - 當前選中的導航索引
        // - 導航歷史記錄
        // - 頁面切換動畫設定
        provider.ChangeNotifierProvider(
          create: (_) => providers.NavigationProvider(),
        ),

        // STEP 01.04: 主題狀態Provider
        // 負責管理應用程式的主題設定，如：
        // - 亮色/暗色主題切換
        // - 自訂主題色彩
        // - 字體大小設定
        provider.ChangeNotifierProvider(
          create: (_) => providers.ThemeProvider(),
        ),

        // STEP 01.05: 載入狀態Provider
        // 負責管理全域載入狀態，如：
        // - 載入狀態 (isLoading)
        // - 載入訊息 (loadingMessage)
        // - 顯示/隱藏載入遮罩
        provider.ChangeNotifierProvider(
          create: (_) => providers.LoadingProvider(),
        ),
      ],

      // STEP 02: 使用Consumer監聽ThemeProvider變化
      // Consumer會監聽ThemeProvider的狀態變化
      // 當主題發生變化時，會自動重建UI
      child: provider.Consumer<providers.ThemeProvider>(
        builder: (context, themeProvider, child) {
          // STEP 02.01: 使用ThemeProvider來設定應用程式主題
          // CupertinoApp是iOS風格的應用程式根Widget
          // 提供iOS風格的導航、對話框、按鈕等元件
          return cupertino.CupertinoApp(
            // 應用程式標題，會顯示在任務切換器中
            title: constants.Constants.appName,

            // 使用ThemeProvider提供的當前主題
            // 支援動態主題切換（亮色/暗色模式）
            theme: themeProvider.currentTheme,

            // 設定初始路由為登入頁面
            // 應用程式啟動時會首先顯示這個頁面
            initialRoute: '/',

            // 定義應用程式的路由表
            // 每個路由對應一個頁面Widget
            routes: {
              // 根路由 '/' 對應登入頁面
              '/': (context) => const login_screen.LoginScreen(),
              // '/main' 路由對應主頁面
              '/main': (context) => const main_screen.MainScreen(),
            },

            // 關閉Debug模式下的檢查標記
            // 讓應用程式在開發模式下看起來更乾淨
            debugShowCheckedModeBanner: false,

            // STEP 03: 響應式設計包裝器
            // builder參數允許我們在應用程式根層級包裝額外的Widget
            // 這裡用來實現響應式設計和無障礙功能
            builder: (context, child) {
              // STEP 03.01: 響應式設計包裝器
              // MediaQuery提供裝置資訊，如螢幕尺寸、方向等
              return cupertino.MediaQuery(
                data: cupertino.MediaQuery.of(context).copyWith(
                  // STEP 03.01.01: 限制文字縮放比例範圍
                  // 確保文字大小在合理範圍內（0.8-1.3倍）
                  // 避免因系統設定導致文字過大或過小
                  // 提升應用程式的可讀性和使用體驗
                  textScaler: cupertino.TextScaler.noScaling,
                ),
                // 將原始的子Widget傳遞給MediaQuery
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
