import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart' as material;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

/// 導航狀態管理提供者
///
/// 負責管理應用程式的導航狀態，包含：
/// - 當前頁面索引追蹤
/// - 側邊欄開關狀態管理
/// - 導航歷史記錄
/// - 側邊欄動畫控制
/// - 頁面切換統計
///
/// 使用 ChangeNotifier 模式來通知 UI 更新，
/// 支援多個 Widget 同時監聽導航狀態變化
class NavigationProvider extends foundation.ChangeNotifier {
  // ===== 導航基本狀態變數 =====

  /// 當前選中的導航索引
  ///
  /// 用於追蹤用戶當前所在的頁面，
  /// 對應底部導航列和側邊欄的選中狀態
  int _currentIndex = 0;

  /// 側邊欄開關狀態
  ///
  /// 控制側邊欄的顯示/隱藏狀態，
  /// true 表示側邊欄開啟，false 表示關閉
  bool _isSidebarOpen = false;

  /// 導航歷史記錄列表
  ///
  /// 記錄用戶訪問過的頁面順序，
  /// 用於追蹤用戶的瀏覽行為和提供導航統計
  final List<String> _navigationHistory = [];

  /// 導航次數計數器
  ///
  /// 統計用戶進行頁面切換的總次數，
  /// 用於分析用戶使用行為
  int _navigationCount = 0;

  /// 最後訪問的頁面名稱
  ///
  /// 記錄用戶上一次訪問的頁面，
  /// 用於導航統計和用戶行為分析
  String _lastVisitedPage = '';

  // ===== 動畫控制變數 =====

  /// 側邊欄動畫控制器
  ///
  /// 控制側邊欄的滑動動畫效果，
  /// 管理動畫的播放、暫停、重置等操作
  material.AnimationController? _sidebarAnimationController;

  /// 側邊欄滑動動畫
  ///
  /// 定義側邊欄的滑動軌跡和動畫效果，
  /// 從螢幕左側外滑入到正常位置
  material.Animation<material.Offset>? _sidebarAnimation;

  // ===== 公開狀態 Getters =====

  /// 取得當前選中的導航索引
  ///
  /// @return 當前頁面的索引值（0-2）
  int get currentIndex => _currentIndex;

  /// 取得側邊欄開關狀態
  ///
  /// @return true 表示側邊欄開啟，false 表示關閉
  bool get isSidebarOpen => _isSidebarOpen;

  /// 取得導航歷史記錄的唯讀副本
  ///
  /// 返回不可修改的歷史記錄列表，防止外部直接修改
  /// @return 導航歷史記錄的唯讀列表
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);

  /// 取得導航次數統計
  ///
  /// @return 用戶進行頁面切換的總次數
  int get navigationCount => _navigationCount;

  /// 取得最後訪問的頁面名稱
  ///
  /// @return 用戶上一次訪問的頁面名稱
  String get lastVisitedPage => _lastVisitedPage;

  // ===== 動畫相關 Getters =====

  /// 取得側邊欄動畫控制器
  ///
  /// 提供給 UI 層使用，用於控制動畫播放
  /// @return 動畫控制器實例，可能為 null
  material.AnimationController? get sidebarAnimationController =>
      _sidebarAnimationController;

  /// 取得側邊欄滑動動畫
  ///
  /// 提供給 UI 層使用，用於建立動畫效果
  /// @return 滑動動畫實例，可能為 null
  material.Animation<material.Offset>? get sidebarAnimation =>
      _sidebarAnimation;

  /// 初始化側邊欄動畫控制器
  ///
  /// 建立並設定側邊欄的動畫控制器和動畫效果，
  /// 必須在 Widget 的 initState 中呼叫
  ///
  /// @param vsync - TickerProvider 實例，用於動畫同步
  void initializeAnimation(material.TickerProvider vsync) {
    // STEP 01: 建立動畫控制器，設定動畫持續時間
    _sidebarAnimationController = material.AnimationController(
      duration: Duration(
        milliseconds: constants.Constants.sidebarAnimationDuration,
      ),
      vsync: vsync,
    );

    // STEP 02: 建立滑動動畫，定義從左側滑入的效果
    _sidebarAnimation =
        material.Tween<material.Offset>(
          begin: const material.Offset(-1.0, 0.0), // 起始位置：完全隱藏在螢幕左側外
          end: material.Offset.zero, // 結束位置：正常顯示位置
        ).animate(
          material.CurvedAnimation(
            parent: _sidebarAnimationController!,
            curve: material.Curves.easeInOut, // 使用 easeInOut 曲線讓動畫更自然
          ),
        );
  }

  /// 釋放動畫控制器資源
  ///
  /// 清理動畫相關資源，防止記憶體洩漏，
  /// 必須在 Widget 的 dispose 中呼叫
  void disposeAnimation() {
    // STEP 01: 釋放動畫控制器並清空引用
    _sidebarAnimationController?.dispose();
    _sidebarAnimationController = null;
    _sidebarAnimation = null;
  }

  /// 設定當前選中的導航索引
  ///
  /// 切換到指定的頁面，並更新相關的導航統計資訊，
  /// 會自動記錄導航歷史和更新計數器
  ///
  /// @param index - 要切換到的頁面索引（0-2）
  void setCurrentIndex(int index) {
    // STEP 01: 記錄當前頁面作為最後訪問頁面
    _lastVisitedPage = _getPageNameByIndex(_currentIndex);

    // STEP 02: 更新當前選中的索引
    _currentIndex = index;

    // STEP 03: 增加導航次數計數器
    _navigationCount++;

    // STEP 04: 將新頁面添加到導航歷史記錄
    _addToHistory(_getPageNameByIndex(index));

    // STEP 05: 通知所有監聽者狀態已變更
    notifyListeners();
  }

  /// 切換側邊欄開關狀態
  ///
  /// 在開啟和關閉狀態之間切換側邊欄，
  /// 並執行對應的滑動動畫效果
  void toggleSidebar() {
    // STEP 01: 切換側邊欄的開關狀態
    _isSidebarOpen = !_isSidebarOpen;

    // STEP 02: 根據新狀態執行對應的動畫
    if (_isSidebarOpen) {
      // STEP 03: 側邊欄開啟，執行滑入動畫
      _sidebarAnimationController?.forward();
    } else {
      // STEP 04: 側邊欄關閉，執行滑出動畫
      _sidebarAnimationController?.reverse();
    }

    // STEP 05: 通知所有監聽者狀態已變更
    notifyListeners();
  }

  /// 關閉側邊欄
  ///
  /// 強制關閉側邊欄（如果當前是開啟狀態），
  /// 並執行關閉動畫
  void closeSidebar() {
    // STEP 01: 檢查側邊欄是否為開啟狀態
    if (_isSidebarOpen) {
      // STEP 02: 設定側邊欄為關閉狀態
      _isSidebarOpen = false;

      // STEP 03: 執行側邊欄關閉動畫
      _sidebarAnimationController?.reverse();

      // STEP 04: 通知所有監聽者狀態已變更
      notifyListeners();
    }
  }

  /// 添加頁面到導航歷史記錄
  ///
  /// 將訪問的頁面名稱添加到歷史記錄中，
  /// 並維護歷史記錄的最大長度限制
  ///
  /// @param pageName - 要添加的頁面名稱
  void _addToHistory(String pageName) {
    // STEP 01: 將頁面名稱添加到歷史記錄列表
    _navigationHistory.add(pageName);

    // STEP 02: 檢查並限制歷史記錄長度（最多保留20個記錄）
    if (_navigationHistory.length > 20) {
      // STEP 03: 移除最舊的歷史記錄（列表開頭的元素）
      _navigationHistory.removeAt(0);
    }
  }

  /// 根據索引取得對應的頁面名稱
  ///
  /// 將數字索引轉換為可讀的頁面名稱，
  /// 用於導航歷史記錄和統計資訊
  ///
  /// @param index - 頁面索引（0-2）
  /// @return 對應的頁面名稱
  String _getPageNameByIndex(int index) {
    // STEP 01: 根據索引返回對應的頁面名稱
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

  /// 重置所有導航狀態
  ///
  /// 將所有導航相關的狀態重置為初始值，
  /// 包括索引、側邊欄狀態、歷史記錄等
  void resetNavigation() {
    // STEP 01: 重置所有導航基本狀態
    _currentIndex = 0;
    _isSidebarOpen = false;
    _navigationHistory.clear();
    _navigationCount = 0;
    _lastVisitedPage = '';

    // STEP 02: 重置動畫控制器狀態
    _sidebarAnimationController?.reset();

    // STEP 03: 通知所有監聽者狀態已變更
    notifyListeners();
  }

  /// 取得導航統計資訊
  ///
  /// 返回包含各種導航統計資料的 Map，
  /// 用於分析用戶使用行為和除錯
  ///
  /// @return 包含統計資訊的 Map
  Map<String, dynamic> getNavigationStats() {
    // STEP 01: 返回包含所有統計資訊的 Map
    return {
      'totalNavigations': _navigationCount, // 總導航次數
      'historyLength': _navigationHistory.length, // 歷史記錄長度
      'currentPage': _getPageNameByIndex(_currentIndex), // 當前頁面名稱
      'lastPage': _lastVisitedPage, // 最後訪問的頁面名稱
    };
  }
}
