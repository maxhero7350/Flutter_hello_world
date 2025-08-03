// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;

// ===== THIRD PARTY =====
import 'package:provider/provider.dart' as provider;

// ===== CUSTOM PROVIDERS =====
import '../providers/providers.dart' as providers;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;
import '../utils/screen_util.dart' as screen_util;

// ===== CUSTOM WIDGETS =====
import '../widgets/custom_sidebar.dart' as custom_sidebar;
import '../widgets/custom_bottom_nav_bar.dart' as custom_bottom_nav;
import '../widgets/responsive_layout.dart' as responsive_widgets;
import '../widgets/loading_spinner.dart' as loading_widgets;

// ===== CUSTOM SCREENS =====
import 'screen_a.dart' as screen_a;
import 'screen_b.dart' as screen_b;
import 'screen_c.dart' as screen_c;

/// 主頁面元件
///
/// 這是應用程式的主要頁面，負責管理整個應用程式的佈局結構。
/// 包含以下主要功能：
/// - 響應式導航列（標題欄）
/// - 側邊欄導航（手機版為覆蓋式，平板版為固定式）
/// - 底部導航列
/// - 頁面內容區域
/// - 全域載入遮罩
///
/// 支援多種裝置類型：
/// - 手機版：側邊欄為覆蓋式，底部導航
/// - 平板版：側邊欄為固定式，底部導航
/// - 桌面版：使用平板版佈局
class MainScreen extends cupertino.StatefulWidget {
  /// 建構子
  ///
  /// @param key - Widget 的鍵值，用於識別和重建
  const MainScreen({super.key});

  @override
  cupertino.State<MainScreen> createState() => _MainScreenState();
}

/// 主頁面的狀態類別
///
/// 負責管理主頁面的狀態和生命週期，包含：
/// - 側邊欄動畫控制
/// - 頁面導航邏輯
/// - 響應式佈局管理
/// - 載入狀態處理
///
/// 使用 TickerProviderStateMixin 來支援動畫功能
class _MainScreenState extends cupertino.State<MainScreen>
    with cupertino.TickerProviderStateMixin {
  /// 元件初始化方法
  ///
  /// 在元件首次建立時呼叫，負責初始化側邊欄動畫控制器
  @override
  void initState() {
    super.initState();
    // STEP 01: 初始化側邊欄動畫控制器
    _initializeSidebarAnimation();
  }

  /// 元件銷毀方法
  ///
  /// 在元件被銷毀時呼叫，負責清理動畫資源，防止記憶體洩漏
  @override
  void dispose() {
    // STEP 01: 釋放側邊欄動畫資源
    _disposeSidebarAnimation();
    super.dispose();
  }

  /// 初始化側邊欄動畫控制器
  ///
  /// 從 NavigationProvider 取得實例並初始化動畫控制器，
  /// 設定動畫的持續時間和曲線
  void _initializeSidebarAnimation() {
    // STEP 01: 取得 NavigationProvider 實例並初始化動畫控制器
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);
    navigationProvider.initializeAnimation(this);
  }

  /// 釋放側邊欄動畫資源
  ///
  /// 清理動畫控制器，防止記憶體洩漏和效能問題
  void _disposeSidebarAnimation() {
    // STEP 01: 取得 NavigationProvider 實例並釋放動畫資源
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);
    navigationProvider.disposeAnimation();
  }

  /// 根據選中的索引建立對應的頁面內容
  ///
  /// 根據導航索引返回對應的頁面元件，如果索引無效則顯示占位符頁面
  ///
  /// @param selectedIndex - 當前選中的導航索引
  /// @return 對應的頁面元件
  cupertino.Widget _buildCurrentPage(int selectedIndex) {
    // STEP 01: 根據選中的索引返回對應頁面
    switch (selectedIndex) {
      case constants.Constants.navIndexA:
        return const screen_a.ScreenA();
      case constants.Constants.navIndexB:
        return const screen_b.ScreenB();
      case constants.Constants.navIndexC:
        return const screen_c.ScreenC();
      default:
        return _buildPagePlaceholder(
          '未知頁面',
          cupertino.CupertinoIcons.question,
          '',
        );
    }
  }

  /// 建立響應式頁面占位符
  ///
  /// 當頁面不存在或開發中時顯示的占位符頁面，
  /// 包含圖標、標題、描述和狀態指示器
  ///
  /// @param title - 頁面標題
  /// @param icon - 頁面圖標
  /// @param description - 頁面描述文字
  /// @return 響應式占位符頁面元件
  cupertino.Widget _buildPagePlaceholder(
    String title,
    cupertino.IconData icon,
    String description,
  ) {
    // STEP 01: 返回響應式頁面占位符UI
    return responsive_widgets.ResponsiveContainer(
      padding: screen_util.ScreenUtil.instance.responsivePadding(all: 24),
      child: cupertino.Column(
        mainAxisAlignment: cupertino.MainAxisAlignment.center,
        children: [
          // STEP 02: 響應式主要圖標容器
          responsive_widgets.ResponsiveContainer(
            padding: screen_util.ScreenUtil.instance.responsivePadding(all: 24),
            decoration: cupertino.BoxDecoration(
              color: cupertino.CupertinoColors.systemBlue.withValues(
                alpha: 0.1,
              ),
              shape: cupertino.BoxShape.circle,
            ),
            child: cupertino.Icon(
              icon,
              size: screen_util.ScreenUtil.instance.responsiveIconSize(64),
              color: cupertino.CupertinoColors.systemBlue,
            ),
          ),
          responsive_widgets.ResponsiveSpacing(spacing: 24),

          // STEP 03: 響應式標題文字
          responsive_widgets.ResponsiveText(
            title,
            fontSize: 24,
            fontWeight: cupertino.FontWeight.bold,
            color: cupertino.CupertinoColors.label,
            textAlign: cupertino.TextAlign.center,
          ),
          responsive_widgets.ResponsiveSpacing(spacing: 16),

          // STEP 04: 響應式描述文字（僅在有描述時顯示）
          if (description.isNotEmpty)
            responsive_widgets.ResponsiveText(
              description,
              fontSize: 16,
              color: cupertino.CupertinoColors.secondaryLabel,
              textAlign: cupertino.TextAlign.center,
              lineHeight: 1.5,
            ),

          responsive_widgets.ResponsiveSpacing(spacing: 32),

          // STEP 05: 響應式開發狀態指示器
          responsive_widgets.ResponsiveContainer(
            padding: screen_util.ScreenUtil.instance.responsivePadding(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: cupertino.BoxDecoration(
              color: cupertino.CupertinoColors.systemYellow.withValues(
                alpha: 0.2,
              ),
              borderRadius: screen_util.ScreenUtil.instance
                  .responsiveBorderRadius(16),
              border: cupertino.Border.all(
                color: cupertino.CupertinoColors.systemYellow.withValues(
                  alpha: 0.5,
                ),
                width: 1,
              ),
            ),
            child: cupertino.Row(
              mainAxisSize: cupertino.MainAxisSize.min,
              children: [
                cupertino.Icon(
                  cupertino.CupertinoIcons.hammer,
                  color: cupertino.CupertinoColors.systemYellow,
                  size: screen_util.ScreenUtil.instance.responsiveIconSize(16),
                ),
                responsive_widgets.ResponsiveSpacing(
                  spacing: 8,
                  direction: cupertino.Axis.horizontal,
                ),
                responsive_widgets.ResponsiveText(
                  '開發中...',
                  fontSize: 14,
                  fontWeight: cupertino.FontWeight.w600,
                  color: cupertino.CupertinoColors.systemYellow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 建立響應式側邊欄背景遮罩（含動畫效果）
  ///
  /// 在手機版顯示側邊欄時，建立覆蓋整個螢幕的遮罩層，
  /// 包含側邊欄內容和背景遮罩，支援滑動動畫和點擊關閉功能
  ///
  /// @param context - 建構上下文
  /// @param isSidebarOpen - 側邊欄是否開啟
  /// @param selectedIndex - 當前選中的導航索引
  /// @return 側邊欄遮罩元件
  cupertino.Widget _buildSidebarOverlay(
    cupertino.BuildContext context,
    bool isSidebarOpen,
    int selectedIndex,
  ) {
    // STEP 01: 取得NavigationProvider來處理點擊事件和動畫控制
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);

    // STEP 02: 取得動畫控制器和動畫實例
    final animationController = navigationProvider.sidebarAnimationController;
    final animation = navigationProvider.sidebarAnimation;

    // STEP 03: 如果動畫未初始化，返回空widget避免錯誤
    if (animationController == null || animation == null) {
      return const cupertino.SizedBox.shrink();
    }

    // STEP 04: 返回響應式側邊欄遮罩UI（含動畫效果）
    return cupertino.AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return cupertino.GestureDetector(
          onTap: () {
            // STEP 05: 點擊遮罩區域關閉側邊欄
            navigationProvider.toggleSidebar();
          },
          child: cupertino.Container(
            color: cupertino.CupertinoColors.black.withValues(
              alpha: animationController.value * 0.3,
            ),
            child: cupertino.Row(
              children: [
                // STEP 06: 響應式側邊欄區域（含滑動動畫）
                material.SlideTransition(
                  position: animation,
                  child: responsive_widgets.ResponsiveContainer(
                    widthPercentage:
                        screen_util.ScreenUtil.instance.deviceType ==
                            screen_util.DeviceType.mobile
                        ? 70
                        : null,
                    child: custom_sidebar.CustomSidebar(
                      selectedIndex: selectedIndex,
                      onItemTapped: (index) {
                        // STEP 07: 處理側邊欄項目點擊，切換頁面並關閉側邊欄
                        navigationProvider.setCurrentIndex(index);
                        navigationProvider.closeSidebar();
                      },
                    ),
                  ),
                ),
                // STEP 08: 空白區域（點擊此區域可關閉側邊欄）
                const cupertino.Expanded(child: cupertino.SizedBox()),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 建立響應式導航列
  ///
  /// 建立應用程式的頂部導航列，包含：
  /// - 側邊欄切換按鈕
  /// - 應用程式標題
  /// - 響應式設計支援
  ///
  /// @param context - 建構上下文
  /// @return 響應式導航列元件
  cupertino.CupertinoNavigationBar _buildResponsiveNavBar(
    cupertino.BuildContext context,
  ) {
    // STEP 01: 取得NavigationProvider來處理側邊欄切換
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);

    // STEP 02: 建立響應式導航列UI
    return cupertino.CupertinoNavigationBar(
      leading: cupertino.CupertinoButton(
        padding: cupertino.EdgeInsets.zero,
        child: cupertino.Icon(
          cupertino.CupertinoIcons.bars,
          size: screen_util.ScreenUtil.instance.responsiveIconSize(24),
        ),
        onPressed: () {
          // STEP 03: 點擊漢堡選單按鈕切換側邊欄狀態
          navigationProvider.toggleSidebar();
        },
      ),
      middle: responsive_widgets.ResponsiveText(
        constants.Constants.appName,
        fontSize: 18,
        fontWeight: cupertino.FontWeight.w600,
      ),
      backgroundColor: cupertino.CupertinoColors.systemBackground.resolveFrom(
        context,
      ),
      border: const cupertino.Border(
        bottom: cupertino.BorderSide(
          color: cupertino.CupertinoColors.systemGrey4,
          width: 0.5,
        ),
      ),
    );
  }

  /// 建立手機版佈局
  ///
  /// 為手機裝置建立垂直佈局，包含：
  /// - 頁面內容區域（可滾動）
  /// - 底部導航列
  /// - 響應式設計支援
  ///
  /// @param context - 建構上下文
  /// @param selectedIndex - 當前選中的導航索引
  /// @return 手機版佈局元件
  cupertino.Widget _buildMobileLayout(
    cupertino.BuildContext context,
    int selectedIndex,
  ) {
    // STEP 01: 取得NavigationProvider來處理導航邏輯
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);

    // STEP 02: 構建手機版垂直佈局
    return cupertino.SafeArea(
      child: cupertino.Column(
        children: [
          // STEP 03: 頁面內容區域（佔據剩餘空間）
          cupertino.Expanded(child: _buildCurrentPage(selectedIndex)),

          // STEP 04: 自定義底部導航列
          custom_bottom_nav.CustomBottomNavBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              // STEP 05: 處理底部導航點擊，切換到對應頁面
              navigationProvider.setCurrentIndex(index);
            },
          ),
        ],
      ),
    );
  }

  /// 建立平板版佈局
  ///
  /// 為平板和桌面裝置建立水平佈局，包含：
  /// - 左側固定側邊欄（平板/桌面模式）
  /// - 右側主內容區域
  /// - 底部導航列
  /// - 響應式設計支援
  ///
  /// @param context - 建構上下文
  /// @param selectedIndex - 當前選中的導航索引
  /// @return 平板版佈局元件
  cupertino.Widget _buildTabletLayout(
    cupertino.BuildContext context,
    int selectedIndex,
  ) {
    // STEP 01: 取得NavigationProvider來處理導航邏輯
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);

    // STEP 02: 構建平板版水平佈局
    return cupertino.SafeArea(
      child: cupertino.Row(
        children: [
          // STEP 03: 左側固定側邊欄（僅在非手機版顯示）
          if (screen_util.ScreenUtil.instance.deviceType !=
              screen_util.DeviceType.mobile)
            responsive_widgets.ResponsiveContainer(
              widthPercentage: null,
              child: custom_sidebar.CustomSidebar(
                selectedIndex: selectedIndex,
                onItemTapped: (index) {
                  // STEP 04: 處理側邊欄項目點擊，切換到對應頁面
                  navigationProvider.setCurrentIndex(index);
                },
              ),
            ),

          // STEP 05: 右側主內容區域（佔據剩餘空間）
          cupertino.Expanded(
            child: cupertino.Column(
              children: [
                // STEP 06: 頁面內容區域（佔據剩餘空間）
                cupertino.Expanded(child: _buildCurrentPage(selectedIndex)),

                // STEP 07: 底部導航列（平板版也保留）
                custom_bottom_nav.CustomBottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    // STEP 08: 處理底部導航點擊，切換到對應頁面
                    navigationProvider.setCurrentIndex(index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 建構主頁面UI
  ///
  /// 這是主頁面的核心建構方法，負責：
  /// - 初始化響應式設計
  /// - 監聽狀態變化（導航、載入）
  /// - 建立完整的頁面佈局
  /// - 管理側邊欄遮罩和載入遮罩
  ///
  /// @param context - 建構上下文
  /// @return 完整的主頁面元件
  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    // STEP 01: 初始化響應式設計系統
    screen_util.ScreenUtil.instance.init(context);

    // STEP 02: 使用Consumer監聽NavigationProvider和LoadingProvider狀態變化
    return provider.Consumer2<
      providers.NavigationProvider,
      providers.LoadingProvider
    >(
      builder: (context, navigationProvider, loadingProvider, child) {
        // STEP 03: 從Provider取得當前狀態
        final selectedIndex = navigationProvider.currentIndex;
        final isSidebarOpen = navigationProvider.isSidebarOpen;

        // STEP 04: 建立主要內容區域
        final mainContent = cupertino.OrientationBuilder(
          builder: (context, orientation) {
            return cupertino.CupertinoPageScaffold(
              // STEP 05: 設定響應式導航列
              navigationBar: _buildResponsiveNavBar(context),

              // STEP 06: 根據裝置類型選擇對應的佈局
              child: responsive_widgets.ResponsiveLayout(
                // STEP 07: 手機版佈局（垂直排列）
                mobile: _buildMobileLayout(context, selectedIndex),
                // STEP 08: 平板版佈局（水平排列，固定側邊欄）
                tablet: _buildTabletLayout(context, selectedIndex),
                // STEP 09: 桌面版佈局（使用平板版佈局作為fallback）
                desktop: _buildTabletLayout(context, selectedIndex),
              ),
            );
          },
        );

        // STEP 10: 建立堆疊容器，包含主要內容、側邊欄遮罩和載入遮罩
        return cupertino.Stack(
          children: [
            // STEP 11: 主要內容區域（最底層）
            mainContent,

            // STEP 12: 側邊欄遮罩（僅在手機版顯示，覆蓋在主要內容上方）
            if (screen_util.ScreenUtil.instance.deviceType ==
                screen_util.DeviceType.mobile)
              _buildSidebarOverlay(context, isSidebarOpen, selectedIndex),

            // STEP 13: 全域載入遮罩（最上層，僅在載入時顯示）
            if (loadingProvider.isLoading)
              loading_widgets.LoadingSpinner(
                message: loadingProvider.loadingMessage,
              ),
          ],
        );
      },
    );
  }
}
