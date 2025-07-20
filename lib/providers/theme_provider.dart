import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// 主題狀態管理
class ThemeProvider extends ChangeNotifier {
  // STEP 01: 主題基本狀態
  bool _isDarkMode = false;
  double _textScaleFactor = 1.0;
  String _fontFamily = 'system';
  bool _useSystemTheme = true;
  
  // STEP 02: Getters - 取得主題狀態
  bool get isDarkMode => _isDarkMode;
  double get textScaleFactor => _textScaleFactor;
  String get fontFamily => _fontFamily;
  bool get useSystemTheme => _useSystemTheme;
  
  // STEP 03: 取得當前主題資料
  CupertinoThemeData get currentTheme {
    // STEP 03.01: 根據深色模式設定返回對應主題
    return _isDarkMode ? _darkTheme : _lightTheme;
  }
  
  // STEP 04: 淺色主題配置
  CupertinoThemeData get _lightTheme {
    // STEP 04.01: 返回淺色主題配置
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
      ),
    );
  }
  
  // STEP 05: 深色主題配置
  CupertinoThemeData get _darkTheme {
    // STEP 05.01: 返回深色主題配置
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
      ),
    );
  }
  
  // STEP 06: 切換深色模式
  void toggleDarkMode() {
    // STEP 06.01: 切換深色模式狀態
    _isDarkMode = !_isDarkMode;
    // STEP 06.02: 如果切換主題則停用系統主題
    _useSystemTheme = false;
    // STEP 06.03: 通知監聽者狀態變更
    notifyListeners();
  }
  
  // STEP 07: 設定深色模式
  void setDarkMode(bool isDark) {
    // STEP 07.01: 檢查是否有變更
    if (_isDarkMode != isDark) {
      // STEP 07.02: 更新深色模式狀態
      _isDarkMode = isDark;
      // STEP 07.03: 停用系統主題
      _useSystemTheme = false;
      // STEP 07.04: 通知監聽者狀態變更
      notifyListeners();
    }
  }
  
  // STEP 08: 設定文字縮放比例
  void setTextScaleFactor(double scale) {
    // STEP 08.01: 限制縮放比例範圍
    if (scale >= 0.8 && scale <= 2.0) {
      // STEP 08.02: 更新文字縮放比例
      _textScaleFactor = scale;
      // STEP 08.03: 通知監聽者狀態變更
      notifyListeners();
    }
  }
  
  // STEP 09: 設定字體家族
  void setFontFamily(String family) {
    // STEP 09.01: 更新字體家族
    _fontFamily = family;
    // STEP 09.02: 通知監聽者狀態變更
    notifyListeners();
  }
  
  // STEP 10: 切換系統主題跟隨
  void toggleSystemTheme() {
    // STEP 10.01: 切換系統主題跟隨狀態
    _useSystemTheme = !_useSystemTheme;
    // STEP 10.02: 通知監聽者狀態變更
    notifyListeners();
  }
  
  // STEP 11: 根據系統亮度更新主題
  void updateFromSystemBrightness(Brightness brightness) {
    // STEP 11.01: 檢查是否使用系統主題
    if (_useSystemTheme) {
      // STEP 11.02: 根據系統亮度設定深色模式
      bool shouldBeDark = brightness == Brightness.dark;
      // STEP 11.03: 檢查是否需要更新
      if (_isDarkMode != shouldBeDark) {
        // STEP 11.04: 更新深色模式狀態
        _isDarkMode = shouldBeDark;
        // STEP 11.05: 通知監聽者狀態變更
        notifyListeners();
      }
    }
  }
  
  // STEP 12: 重置主題設定
  void resetTheme() {
    // STEP 12.01: 重置所有主題設定到預設值
    _isDarkMode = false;
    _textScaleFactor = 1.0;
    _fontFamily = 'system';
    _useSystemTheme = true;
    // STEP 12.02: 通知監聽者狀態變更
    notifyListeners();
  }
  
  // STEP 13: 取得主題設定摘要
  Map<String, dynamic> getThemeSettings() {
    // STEP 13.01: 返回當前主題設定
    return {
      'isDarkMode': _isDarkMode,
      'textScaleFactor': _textScaleFactor,
      'fontFamily': _fontFamily,
      'useSystemTheme': _useSystemTheme,
    };
  }
}