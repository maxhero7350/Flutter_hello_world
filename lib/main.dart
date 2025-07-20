import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/providers.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() {
  // STEP 01: 啟動應用程式並設置Provider架構
  runApp(const HelloWorldApp());
}

class HelloWorldApp extends StatelessWidget {
  const HelloWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    // STEP 01: 使用MultiProvider包裝整個應用程式
    return MultiProvider(
      providers: [
        // STEP 01.01: 應用程式狀態Provider
        ChangeNotifierProvider(
          create: (_) => AppStateProvider(),
        ),
        // STEP 01.02: 用戶狀態Provider
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        // STEP 01.03: 導航狀態Provider
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
        // STEP 01.04: 主題狀態Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // STEP 02: 使用ThemeProvider來設定應用程式主題
          return CupertinoApp(
            title: Constants.APP_NAME,
            theme: themeProvider.currentTheme,
            home: const LoginScreen(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              // STEP 03: 響應式設計包裝器
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // STEP 03.01: 限制文字縮放比例範圍
                  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}