// ===== FLUTTER CORE =====
import 'package:flutter/foundation.dart' as foundation;

/// 載入狀態管理提供者
/// 負責管理全域載入狀態和載入訊息
class LoadingProvider extends foundation.ChangeNotifier {
  // STEP 01: 定義載入狀態變數
  bool _isLoading = false;
  String _loadingMessage = "載入中...";

  /// 取得當前載入狀態
  bool get isLoading => _isLoading;

  /// 取得當前載入訊息
  String get loadingMessage => _loadingMessage;

  /// 顯示載入狀態
  /// [message] 可選的載入訊息，預設為 "載入中..."
  void showLoading([String? message]) {
    // STEP 02: 設定載入狀態為 true
    _isLoading = true;
    // STEP 03: 設定載入訊息
    _loadingMessage = message ?? "載入中...";
    // STEP 04: 通知監聽者狀態已變更
    notifyListeners();
  }

  /// 隱藏載入狀態
  void hideLoading() {
    // STEP 05: 設定載入狀態為 false
    _isLoading = false;
    // STEP 06: 通知監聽者狀態已變更
    notifyListeners();
  }

  /// 更新載入訊息
  /// [message] 新的載入訊息
  void updateMessage(String message) {
    // STEP 07: 更新載入訊息
    _loadingMessage = message;
    // STEP 08: 通知監聽者狀態已變更
    notifyListeners();
  }
}
