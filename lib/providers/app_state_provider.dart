import 'package:flutter/foundation.dart' as foundation;

/// 應用程式全域狀態管理
class AppStateProvider extends foundation.ChangeNotifier {
  // STEP 01: 應用程式基本狀態
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFirstRun = true;
  String _currentPage = 'login';

  // STEP 02: Getters - 取得當前狀態
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFirstRun => _isFirstRun;
  String get currentPage => _currentPage;

  // STEP 03: 設定載入狀態
  void setLoading(bool loading) {
    // STEP 03.01: 更新載入狀態
    _isLoading = loading;
    // STEP 03.02: 通知監聽者狀態變更
    notifyListeners();
  }

  // STEP 04: 設定錯誤訊息
  void setError(String? error) {
    // STEP 04.01: 更新錯誤訊息
    _errorMessage = error;
    // STEP 04.02: 通知監聽者狀態變更
    notifyListeners();
  }

  // STEP 05: 清除錯誤訊息
  void clearError() {
    // STEP 05.01: 清空錯誤訊息
    _errorMessage = null;
    // STEP 05.02: 通知監聽者狀態變更
    notifyListeners();
  }

  // STEP 06: 設定當前頁面
  void setCurrentPage(String page) {
    // STEP 06.01: 更新當前頁面
    _currentPage = page;
    // STEP 06.02: 通知監聽者狀態變更
    notifyListeners();
  }

  // STEP 07: 設定是否為首次執行
  void setFirstRun(bool isFirst) {
    // STEP 07.01: 更新首次執行狀態
    _isFirstRun = isFirst;
    // STEP 07.02: 通知監聽者狀態變更
    notifyListeners();
  }

  // STEP 08: 重置應用程式狀態
  void reset() {
    // STEP 08.01: 重置所有狀態到初始值
    _isLoading = false;
    _errorMessage = null;
    _isFirstRun = true;
    _currentPage = 'login';
    // STEP 08.02: 通知監聽者狀態變更
    notifyListeners();
  }
}
