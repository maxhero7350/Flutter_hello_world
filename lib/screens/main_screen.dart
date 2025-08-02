// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

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

/// 主頁面
/// 包含標頭列、側邊欄、底部導航的完整主架構
class MainScreen extends cupertino.StatelessWidget {
  const MainScreen({super.key});

  /// STEP 01: 建立當前頁面內容
  cupertino.Widget _buildCurrentPage(int selectedIndex) {
    // STEP 01.01: 根據選中的索引返回對應頁面
    switch (selectedIndex) {
      case constants.Constants.NAV_INDEX_A:
        return const screen_a.ScreenA();
      case constants.Constants.NAV_INDEX_B:
        return const screen_b.ScreenB();
      case constants.Constants.NAV_INDEX_C:
        return const screen_c.ScreenC();
      default:
        return _buildPagePlaceholder(
          '未知頁面',
          cupertino.CupertinoIcons.question,
          '',
        );
    }
  }

  /// STEP 02: 建立響應式頁面占位符
  cupertino.Widget _buildPagePlaceholder(
    String title,
    cupertino.IconData icon,
    String description,
  ) {
    // STEP 02.01: 返回響應式頁面占位符UI
    return responsive_widgets.ResponsiveContainer(
      padding: screen_util.ScreenUtil.instance.responsivePadding(all: 24),
      child: cupertino.Column(
        mainAxisAlignment: cupertino.MainAxisAlignment.center,
        children: [
          // STEP 02.02: 響應式主要圖標
          responsive_widgets.ResponsiveContainer(
            padding: screen_util.ScreenUtil.instance.responsivePadding(all: 24),
            decoration: cupertino.BoxDecoration(
              color: cupertino.CupertinoColors.systemBlue.withOpacity(0.1),
              shape: cupertino.BoxShape.circle,
            ),
            child: cupertino.Icon(
              icon,
              size: screen_util.ScreenUtil.instance.responsiveIconSize(64),
              color: cupertino.CupertinoColors.systemBlue,
            ),
          ),
          responsive_widgets.ResponsiveSpacing(spacing: 24),

          // STEP 02.03: 響應式標題
          responsive_widgets.ResponsiveText(
            title,
            fontSize: 24,
            fontWeight: cupertino.FontWeight.bold,
            color: cupertino.CupertinoColors.label,
            textAlign: cupertino.TextAlign.center,
          ),
          responsive_widgets.ResponsiveSpacing(spacing: 16),

          // STEP 02.04: 響應式描述
          if (description.isNotEmpty)
            responsive_widgets.ResponsiveText(
              description,
              fontSize: 16,
              color: cupertino.CupertinoColors.secondaryLabel,
              textAlign: cupertino.TextAlign.center,
              lineHeight: 1.5,
            ),

          responsive_widgets.ResponsiveSpacing(spacing: 32),

          // STEP 02.05: 響應式狀態指示
          responsive_widgets.ResponsiveContainer(
            padding: screen_util.ScreenUtil.instance.responsivePadding(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: cupertino.BoxDecoration(
              color: cupertino.CupertinoColors.systemYellow.withOpacity(0.2),
              borderRadius: screen_util.ScreenUtil.instance
                  .responsiveBorderRadius(16),
              border: cupertino.Border.all(
                color: cupertino.CupertinoColors.systemYellow.withOpacity(0.5),
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

  /// STEP 03: 建立響應式側邊欄背景遮罩
  cupertino.Widget _buildSidebarOverlay(
    cupertino.BuildContext context,
    bool isSidebarOpen,
    int selectedIndex,
  ) {
    // STEP 03.01: 如果側邊欄未開啟則返回空widget
    if (!isSidebarOpen) return const cupertino.SizedBox.shrink();

    // STEP 03.02: 取得NavigationProvider來處理點擊事件
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);

    // STEP 03.03: 返回響應式側邊欄遮罩UI
    return cupertino.GestureDetector(
      onTap: () {
        // STEP 03.04: 點擊遮罩關閉側邊欄
        navigationProvider.toggleSidebar();
      },
      child: cupertino.Container(
        color: cupertino.CupertinoColors.black.withValues(alpha: 0.3),
        child: cupertino.Row(
          children: [
            // STEP 03.05: 響應式側邊欄區域
            responsive_widgets.ResponsiveContainer(
              widthPercentage:
                  screen_util.ScreenUtil.instance.deviceType ==
                      screen_util.DeviceType.mobile
                  ? 70
                  : null,
              child: custom_sidebar.CustomSidebar(
                selectedIndex: selectedIndex,
                onItemTapped: (index) {
                  // STEP 03.06: 處理側邊欄項目點擊
                  navigationProvider.setCurrentIndex(index);
                  navigationProvider.closeSidebar();
                },
              ),
            ),
            // STEP 03.07: 空白區域（點擊關閉）
            const cupertino.Expanded(child: cupertino.SizedBox()),
          ],
        ),
      ),
    );
  }

  /// STEP 04: 建立響應式導航列
  cupertino.CupertinoNavigationBar _buildResponsiveNavBar(
    cupertino.BuildContext context,
  ) {
    // STEP 04.01: 取得NavigationProvider
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);

    // STEP 04.02: 根據裝置類型決定導航列樣式
    return cupertino.CupertinoNavigationBar(
      leading: cupertino.CupertinoButton(
        padding: cupertino.EdgeInsets.zero,
        child: cupertino.Icon(
          cupertino.CupertinoIcons.bars,
          size: screen_util.ScreenUtil.instance.responsiveIconSize(24),
        ),
        onPressed: () {
          // STEP 04.03: 切換側邊欄狀態
          navigationProvider.toggleSidebar();
        },
      ),
      middle: responsive_widgets.ResponsiveText(
        constants.Constants.APP_NAME,
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

  /// STEP 05: 建立手機版佈局
  cupertino.Widget _buildMobileLayout(
    cupertino.BuildContext context,
    int selectedIndex,
    bool isSidebarOpen,
  ) {
    // STEP 05.01: 取得NavigationProvider
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);

    // STEP 05.02: 構建手機版佈局
    return cupertino.Stack(
      children: [
        // STEP 05.03: 主頁面內容
        cupertino.SafeArea(
          child: cupertino.Column(
            children: [
              // STEP 05.04: 頁面內容區域
              cupertino.Expanded(child: _buildCurrentPage(selectedIndex)),

              // STEP 05.05: 自定義底部導航列
              custom_bottom_nav.CustomBottomNavBar(
                currentIndex: selectedIndex,
                onTap: (index) {
                  // STEP 05.06: 處理底部導航點擊
                  navigationProvider.setCurrentIndex(index);
                },
              ),
            ],
          ),
        ),

        // STEP 05.07: 側邊欄覆蓋層
        _buildSidebarOverlay(context, isSidebarOpen, selectedIndex),
      ],
    );
  }

  /// STEP 06: 建立平板版佈局
  cupertino.Widget _buildTabletLayout(
    cupertino.BuildContext context,
    int selectedIndex,
    bool isSidebarOpen,
  ) {
    // STEP 06.01: 取得NavigationProvider
    final navigationProvider = provider
        .Provider.of<providers.NavigationProvider>(context, listen: false);

    // STEP 06.02: 構建平板版佈局
    return cupertino.SafeArea(
      child: cupertino.Row(
        children: [
          // STEP 06.03: 左側固定側邊欄（平板模式）
          if (screen_util.ScreenUtil.instance.deviceType !=
              screen_util.DeviceType.mobile)
            responsive_widgets.ResponsiveContainer(
              widthPercentage: null,
              child: custom_sidebar.CustomSidebar(
                selectedIndex: selectedIndex,
                onItemTapped: (index) {
                  // STEP 06.04: 處理側邊欄項目點擊
                  navigationProvider.setCurrentIndex(index);
                },
              ),
            ),

          // STEP 06.05: 右側主內容區域
          cupertino.Expanded(
            child: cupertino.Column(
              children: [
                // STEP 06.06: 頁面內容區域
                cupertino.Expanded(child: _buildCurrentPage(selectedIndex)),

                // STEP 06.07: 底部導航列（平板也保留）
                custom_bottom_nav.CustomBottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    // STEP 06.08: 處理底部導航點擊
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

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    // STEP 07: 初始化響應式設計
    screen_util.ScreenUtil.instance.init(context);

    // STEP 07.01: 使用Consumer監聽NavigationProvider和LoadingProvider
    return provider.Consumer2<
      providers.NavigationProvider,
      providers.LoadingProvider
    >(
      builder: (context, navigationProvider, loadingProvider, child) {
        // STEP 07.02: 從Provider取得當前狀態
        final selectedIndex = navigationProvider.currentIndex;
        final isSidebarOpen = navigationProvider.isSidebarOpen;

        // STEP 07.03: 建立主要內容
        final mainContent = cupertino.OrientationBuilder(
          builder: (context, orientation) {
            return cupertino.CupertinoPageScaffold(
              // STEP 07.04: 響應式導航列
              navigationBar: _buildResponsiveNavBar(context),

              // STEP 07.05: 根據裝置類型選擇佈局
              child: responsive_widgets.ResponsiveLayout(
                // STEP 07.06: 手機版佈局
                mobile: _buildMobileLayout(
                  context,
                  selectedIndex,
                  isSidebarOpen,
                ),
                // STEP 07.07: 平板版佈局
                tablet: _buildTabletLayout(
                  context,
                  selectedIndex,
                  isSidebarOpen,
                ),
                // STEP 07.08: 桌面版佈局（fallback到平板佈局）
                desktop: _buildTabletLayout(
                  context,
                  selectedIndex,
                  isSidebarOpen,
                ),
              ),
            );
          },
        );

        // STEP 07.09: 建立堆疊容器包含主要內容和載入遮罩
        return cupertino.Stack(
          children: [
            // STEP 07.10: 主要內容
            mainContent,

            // STEP 07.11: 全域載入遮罩
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
