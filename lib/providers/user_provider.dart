import 'package:flutter/foundation.dart' as foundation;

/// 用戶狀態管理
class UserProvider extends foundation.ChangeNotifier {
  // STEP 01: 用戶基本資訊
  String? _username;
  bool _isLoggedIn = false;
  String _userPreference = 'default';
  DateTime? _lastLoginTime;

  // STEP 02: Getters - 取得用戶狀態
  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  String get userPreference => _userPreference;
  DateTime? get lastLoginTime => _lastLoginTime;

  // STEP 03: 用戶登入
  void login(String username) {
    // STEP 03.01: 設定用戶名稱
    _username = username;
    // STEP 03.02: 更新登入狀態
    _isLoggedIn = true;
    // STEP 03.03: 記錄登入時間
    _lastLoginTime = DateTime.now();
    // STEP 03.04: 通知監聽者狀態變更
    notifyListeners();
  }

  // STEP 04: 用戶登出
  void logout() {
    // STEP 04.01: 清除用戶名稱
    _username = null;
    // STEP 04.02: 更新登入狀態
    _isLoggedIn = false;
    // STEP 04.03: 清除登入時間
    _lastLoginTime = null;
    // STEP 04.04: 重置用戶偏好
    _userPreference = 'default';
    // STEP 04.05: 通知監聽者狀態變更
    notifyListeners();
  }

  // STEP 05: 更新用戶偏好設定
  void updatePreference(String preference) {
    // STEP 05.01: 更新用戶偏好
    _userPreference = preference;
    // STEP 05.02: 通知監聽者狀態變更
    notifyListeners();
  }

  // STEP 06: 取得用戶顯示名稱
  String getDisplayName() {
    // STEP 06.01: 如果有用戶名稱則返回，否則返回預設值
    return _username ?? '訪客';
  }

  // STEP 07: 檢查用戶是否有效
  bool isValidUser() {
    // STEP 07.01: 檢查是否登入且有用戶名稱
    return _isLoggedIn && _username != null && _username!.isNotEmpty;
  }
}
