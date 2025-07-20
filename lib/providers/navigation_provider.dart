import 'package:flutter/foundation.dart';

/// 導航狀態管理
class NavigationProvider extends ChangeNotifier {
  // STEP 01: 導航基本狀態
  int _currentIndex = 0;
  bool _isSidebarOpen = false;
  List<String> _navigationHistory = [];
  int _navigationCount = 0;
  String _lastVisitedPage = '';
  
  // STEP 02: Getters - 取得導航狀態
  int get currentIndex => _currentIndex;
  bool get isSidebarOpen => _isSidebarOpen;
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
  int get navigationCount => _navigationCount;
  String get lastVisitedPage => _lastVisitedPage;
  
  // STEP 03: 設定當前選中的索引
  void setCurrentIndex(int index) {
    // STEP 03.01: 記錄上一個頁面
    _lastVisitedPage = _getPageNameByIndex(_currentIndex);
    // STEP 03.02: 更新當前索引
    _currentIndex = index;
    // STEP 03.03: 增加導航計數
    _navigationCount++;
    // STEP 03.04: 添加到導航歷史
    _addToHistory(_getPageNameByIndex(index));
    // STEP 03.05: 通知監聽者狀態變更
    notifyListeners();
  }
  
  // STEP 04: 切換側邊欄狀態
  void toggleSidebar() {
    // STEP 04.01: 切換側邊欄開關狀態
    _isSidebarOpen = !_isSidebarOpen;
    // STEP 04.02: 通知監聽者狀態變更
    notifyListeners();
  }
  
  // STEP 05: 關閉側邊欄
  void closeSidebar() {
    // STEP 05.01: 檢查側邊欄是否開啟
    if (_isSidebarOpen) {
      // STEP 05.02: 關閉側邊欄
      _isSidebarOpen = false;
      // STEP 05.03: 通知監聽者狀態變更
      notifyListeners();
    }
  }
  
  // STEP 06: 添加到導航歷史
  void _addToHistory(String pageName) {
    // STEP 06.01: 添加頁面到歷史記錄
    _navigationHistory.add(pageName);
    // STEP 06.02: 限制歷史記錄長度（最多保留20個）
    if (_navigationHistory.length > 20) {
      // STEP 06.03: 移除最舊的記錄
      _navigationHistory.removeAt(0);
    }
  }
  
  // STEP 07: 根據索引取得頁面名稱
  String _getPageNameByIndex(int index) {
    // STEP 07.01: 根據索引返回對應的頁面名稱
    switch (index) {
      case 0:
        return 'Screen A';
      case 1:
        return 'Screen B';
      case 2:
        return 'Screen C';
      default:
        return 'Unknown';
    }
  }
  
  // STEP 08: 重置導航狀態
  void resetNavigation() {
    // STEP 08.01: 重置所有導航相關狀態
    _currentIndex = 0;
    _isSidebarOpen = false;
    _navigationHistory.clear();
    _navigationCount = 0;
    _lastVisitedPage = '';
    // STEP 08.02: 通知監聽者狀態變更
    notifyListeners();
  }
  
  // STEP 09: 取得導航統計資訊
  Map<String, dynamic> getNavigationStats() {
    // STEP 09.01: 返回導航統計資訊
    return {
      'totalNavigations': _navigationCount,
      'historyLength': _navigationHistory.length,
      'currentPage': _getPageNameByIndex(_currentIndex),
      'lastPage': _lastVisitedPage,
    };
  }
}