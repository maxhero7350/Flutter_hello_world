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
import '../widgets/responsive_layout.dart' as responsive_widgets;

/// 自定義側邊欄
/// 提供導航功能和設定選項
class CustomSidebar extends cupertino.StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  /// STEP 01: 建立響應式標頭
  cupertino.Widget _buildHeader(cupertino.BuildContext context) {
    return provider.Consumer<providers.UserProvider>(
      builder: (context, userProvider, child) {
        // STEP 01.01: 取得用戶資訊
        final displayName = userProvider.getDisplayName();
        final isLoggedIn = userProvider.isLoggedIn;

        // STEP 01.02: 構建響應式標頭
        return responsive_widgets.ResponsiveContainer(
          padding: screen_util.ScreenUtil.instance.responsivePadding(all: 20),
          decoration: cupertino.BoxDecoration(
            color: cupertino.CupertinoColors.systemBlue,
            borderRadius: cupertino.BorderRadius.only(
              bottomLeft: cupertino.Radius.circular(16.r),
              bottomRight: cupertino.Radius.circular(16.r),
            ),
          ),
          child: cupertino.Column(
            crossAxisAlignment: cupertino.CrossAxisAlignment.start,
            children: [
              // STEP 01.03: 用戶頭像
              responsive_widgets.ResponsiveContainer(
                decoration: cupertino.BoxDecoration(
                  color: cupertino.CupertinoColors.white.withOpacity(0.2),
                  shape: cupertino.BoxShape.circle,
                ),
                padding: screen_util.ScreenUtil.instance.responsivePadding(
                  all: 12,
                ),
                child: cupertino.Icon(
                  cupertino.CupertinoIcons.person_fill,
                  color: cupertino.CupertinoColors.white,
                  size: screen_util.ScreenUtil.instance.responsiveIconSize(32),
                ),
              ),
              responsive_widgets.ResponsiveSpacing(spacing: 12),

              // STEP 01.04: 用戶名稱
              responsive_widgets.ResponsiveText(
                displayName,
                fontSize: 18,
                fontWeight: cupertino.FontWeight.w600,
                color: cupertino.CupertinoColors.white,
              ),
              responsive_widgets.ResponsiveSpacing(spacing: 4),

              // STEP 01.05: 狀態指示
              responsive_widgets.ResponsiveText(
                isLoggedIn ? '已登入' : '訪客模式',
                fontSize: 14,
                color: cupertino.CupertinoColors.white.withOpacity(0.8),
              ),
            ],
          ),
        );
      },
    );
  }

  /// STEP 02: 建立響應式導航項目
  cupertino.Widget _buildNavigationItem({
    required cupertino.IconData icon,
    required String title,
    required int index,
    required cupertino.VoidCallback onTap,
  }) {
    // STEP 02.01: 檢查是否為選中狀態
    final isSelected = selectedIndex == index;

    // STEP 02.02: 構建響應式導航項目
    return responsive_widgets.ResponsiveContainer(
      margin: screen_util.ScreenUtil.instance.responsivePadding(
        horizontal: 12,
        vertical: 4,
      ),
      child: cupertino.CupertinoButton(
        padding: screen_util.ScreenUtil.instance.responsivePadding(
          horizontal: 16,
          vertical: 12,
        ),
        color: isSelected
            ? cupertino.CupertinoColors.systemBlue.withOpacity(0.1)
            : null,
        borderRadius: screen_util.ScreenUtil.instance.responsiveBorderRadius(8),
        onPressed: onTap,
        child: cupertino.Row(
          children: [
            // STEP 02.03: 響應式圖標
            cupertino.Icon(
              icon,
              color: isSelected
                  ? cupertino.CupertinoColors.systemBlue
                  : cupertino.CupertinoColors.label,
              size: screen_util.ScreenUtil.instance.responsiveIconSize(24),
            ),
            responsive_widgets.ResponsiveSpacing(
              spacing: 12,
              direction: cupertino.Axis.horizontal,
            ),

            // STEP 02.04: 響應式標題
            cupertino.Expanded(
              child: responsive_widgets.ResponsiveText(
                title,
                fontSize: 16,
                fontWeight: isSelected
                    ? cupertino.FontWeight.w600
                    : cupertino.FontWeight.normal,
                color: isSelected
                    ? cupertino.CupertinoColors.systemBlue
                    : cupertino.CupertinoColors.label,
              ),
            ),

            // STEP 02.05: 選中指示器
            if (isSelected)
              cupertino.Icon(
                cupertino.CupertinoIcons.chevron_right,
                color: cupertino.CupertinoColors.systemBlue,
                size: screen_util.ScreenUtil.instance.responsiveIconSize(16),
              ),
          ],
        ),
      ),
    );
  }

  /// STEP 03: 建立響應式設定項目
  cupertino.Widget _buildSettingItem({
    required cupertino.IconData icon,
    required String title,
    required cupertino.VoidCallback onTap,
    cupertino.Color? iconColor,
  }) {
    // STEP 03.01: 構建響應式設定項目
    return responsive_widgets.ResponsiveContainer(
      margin: screen_util.ScreenUtil.instance.responsivePadding(
        horizontal: 12,
        vertical: 4,
      ),
      child: cupertino.CupertinoButton(
        padding: screen_util.ScreenUtil.instance.responsivePadding(
          horizontal: 16,
          vertical: 12,
        ),
        onPressed: onTap,
        child: cupertino.Row(
          children: [
            // STEP 03.02: 響應式圖標
            cupertino.Icon(
              icon,
              color: iconColor ?? cupertino.CupertinoColors.secondaryLabel,
              size: screen_util.ScreenUtil.instance.responsiveIconSize(24),
            ),
            responsive_widgets.ResponsiveSpacing(
              spacing: 12,
              direction: cupertino.Axis.horizontal,
            ),

            // STEP 03.03: 響應式標題
            cupertino.Expanded(
              child: responsive_widgets.ResponsiveText(
                title,
                fontSize: 16,
                color: cupertino.CupertinoColors.secondaryLabel,
              ),
            ),

            // STEP 03.04: 箭頭圖標
            cupertino.Icon(
              cupertino.CupertinoIcons.chevron_right,
              color: cupertino.CupertinoColors.tertiaryLabel,
              size: screen_util.ScreenUtil.instance.responsiveIconSize(16),
            ),
          ],
        ),
      ),
    );
  }

  /// STEP 04: 顯示關於對話框
  void _showAboutDialog(cupertino.BuildContext context) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: responsive_widgets.ResponsiveText(
            '關於 ${constants.Constants.APP_NAME}',
            fontSize: 18,
            fontWeight: cupertino.FontWeight.w600,
          ),
          content: cupertino.Column(
            mainAxisSize: cupertino.MainAxisSize.min,
            children: [
              responsive_widgets.ResponsiveSpacing(spacing: 8),
              responsive_widgets.ResponsiveText(
                'Version ${constants.Constants.APP_VERSION}',
                fontSize: 16,
              ),
              responsive_widgets.ResponsiveSpacing(spacing: 8),
              responsive_widgets.ResponsiveText(
                '這是我的第一個Flutter專案，用於學習和實踐Flutter開發技術。',
                fontSize: 14,
                lineHeight: 1.4,
              ),
            ],
          ),
          actions: [
            cupertino.CupertinoDialogAction(
              child: const cupertino.Text('確定'),
              onPressed: () {
                cupertino.Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 05: 顯示登出確認對話框
  void _showLogoutConfirmation(cupertino.BuildContext context) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: responsive_widgets.ResponsiveText(
            '確認登出',
            fontSize: 18,
            fontWeight: cupertino.FontWeight.w600,
          ),
          content: responsive_widgets.ResponsiveText('您確定要登出嗎？', fontSize: 16),
          actions: [
            cupertino.CupertinoDialogAction(
              child: const cupertino.Text('取消'),
              onPressed: () {
                cupertino.Navigator.of(context).pop();
              },
            ),
            cupertino.CupertinoDialogAction(
              isDestructiveAction: true,
              child: const cupertino.Text('登出'),
              onPressed: () {
                // STEP 05.01: 執行登出操作
                final userProvider =
                    provider.Provider.of<providers.UserProvider>(
                      context,
                      listen: false,
                    );
                final appStateProvider =
                    provider.Provider.of<providers.AppStateProvider>(
                      context,
                      listen: false,
                    );
                final navigationProvider =
                    provider.Provider.of<providers.NavigationProvider>(
                      context,
                      listen: false,
                    );

                // STEP 05.02: 重置所有狀態
                userProvider.logout();
                appStateProvider.reset();
                navigationProvider.resetNavigation();

                // STEP 05.03: 關閉對話框
                cupertino.Navigator.of(context).pop();

                // STEP 05.04: 導航到登入頁面並清除所有路由
                cupertino.Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    // STEP 06: 初始化響應式設計
    screen_util.ScreenUtil.instance.init(context);

    // STEP 06.01: 計算側邊欄寬度
    double sidebarWidth = screen_util.ScreenUtil.instance.getSidebarWidth();

    // STEP 06.02: 構建響應式側邊欄
    return responsive_widgets.ResponsiveContainer(
      widthPercentage:
          screen_util.ScreenUtil.instance.deviceType ==
              screen_util.DeviceType.mobile
          ? 70
          : null,
      child: cupertino.Container(
        width:
            screen_util.ScreenUtil.instance.deviceType !=
                screen_util.DeviceType.mobile
            ? sidebarWidth
            : null,
        decoration: const cupertino.BoxDecoration(
          color: cupertino.CupertinoColors.systemBackground,
          border: cupertino.Border(
            right: cupertino.BorderSide(
              color: cupertino.CupertinoColors.systemGrey4,
              width: 0.5,
            ),
          ),
        ),
        child: cupertino.SafeArea(
          child: cupertino.Column(
            children: [
              // STEP 06.03: 標頭區域
              _buildHeader(context),
              responsive_widgets.ResponsiveSpacing(spacing: 16),

              // STEP 06.04: 導航項目區域
              cupertino.Expanded(
                child: cupertino.SingleChildScrollView(
                  child: cupertino.Column(
                    children: [
                      // STEP 06.05: 主要導航項目
                      _buildNavigationItem(
                        icon: cupertino.CupertinoIcons.square_grid_2x2,
                        title: 'Screen A',
                        index: constants.Constants.NAV_INDEX_A,
                        onTap: () =>
                            onItemTapped(constants.Constants.NAV_INDEX_A),
                      ),
                      _buildNavigationItem(
                        icon: cupertino.CupertinoIcons.doc_text,
                        title: 'Screen B',
                        index: constants.Constants.NAV_INDEX_B,
                        onTap: () =>
                            onItemTapped(constants.Constants.NAV_INDEX_B),
                      ),
                      _buildNavigationItem(
                        icon: cupertino.CupertinoIcons.time,
                        title: 'Screen C',
                        index: constants.Constants.NAV_INDEX_C,
                        onTap: () =>
                            onItemTapped(constants.Constants.NAV_INDEX_C),
                      ),

                      responsive_widgets.ResponsiveSpacing(spacing: 24),

                      // STEP 06.06: 分隔線
                      cupertino.Container(
                        height: 0.5,
                        color: cupertino.CupertinoColors.systemGrey4,
                        margin: screen_util.ScreenUtil.instance
                            .responsivePadding(horizontal: 16),
                      ),

                      responsive_widgets.ResponsiveSpacing(spacing: 16),

                      // STEP 06.07: 設定項目
                      _buildSettingItem(
                        icon: cupertino.CupertinoIcons.info_circle,
                        title: '關於',
                        onTap: () => _showAboutDialog(context),
                      ),
                      _buildSettingItem(
                        icon: cupertino.CupertinoIcons.square_arrow_right,
                        title: '登出',
                        iconColor: cupertino.CupertinoColors.systemRed,
                        onTap: () => _showLogoutConfirmation(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
