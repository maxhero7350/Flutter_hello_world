// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;
import '../utils/screen_util.dart' as screen_util;

// ===== CUSTOM WIDGETS =====
import '../widgets/responsive_layout.dart' as responsive_widgets;

/// 自定義底部導航列
/// 提供主要的頁面導航功能
class CustomBottomNavBar extends cupertino.StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// STEP 01: 建立響應式導航項目
  cupertino.Widget _buildNavItem({
    required cupertino.IconData icon,
    required String label,
    required int index,
    required cupertino.VoidCallback onTap,
  }) {
    // STEP 01.01: 檢查是否為選中狀態
    final isSelected = currentIndex == index;

    // STEP 01.02: 構建響應式導航項目
    return cupertino.Expanded(
      child: cupertino.CupertinoButton(
        padding: screen_util.ScreenUtil.instance.responsivePadding(vertical: 8),
        onPressed: onTap,
        child: cupertino.Column(
          mainAxisSize: cupertino.MainAxisSize.min,
          children: [
            // STEP 01.03: 響應式圖標
            cupertino.Icon(
              icon,
              color: isSelected
                  ? cupertino.CupertinoColors.activeBlue
                  : cupertino.CupertinoColors.inactiveGray,
              size: screen_util.ScreenUtil.instance.responsiveIconSize(24),
            ),
            responsive_widgets.ResponsiveSpacing(spacing: 4),

            // STEP 01.04: 響應式標籤
            responsive_widgets.ResponsiveText(
              label,
              fontSize: 12,
              color: isSelected
                  ? cupertino.CupertinoColors.activeBlue
                  : cupertino.CupertinoColors.inactiveGray,
              textAlign: cupertino.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    // STEP 02: 初始化響應式設計
    screen_util.ScreenUtil.instance.init(context);

    // STEP 02.01: 構建響應式底部導航列
    return responsive_widgets.ResponsiveContainer(
      decoration: const cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemBackground,
        border: cupertino.Border(
          top: cupertino.BorderSide(
            color: cupertino.CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      padding: cupertino.EdgeInsets.only(
        bottom: screen_util.ScreenUtil.instance.bottomBarHeight,
      ),
      child: cupertino.SafeArea(
        top: false,
        child: responsive_widgets.ResponsiveContainer(
          heightPercentage:
              screen_util.ScreenUtil.instance.deviceType ==
                  screen_util.DeviceType.mobile
              ? 8
              : 7,
          child: cupertino.Row(
            children: [
              // STEP 02.02: Screen A 導航項目
              _buildNavItem(
                icon: cupertino.CupertinoIcons.square_grid_2x2,
                label: 'A頁面',
                index: constants.Constants.NAV_INDEX_A,
                onTap: () => onTap(constants.Constants.NAV_INDEX_A),
              ),

              // STEP 02.03: Screen B 導航項目
              _buildNavItem(
                icon: cupertino.CupertinoIcons.doc_text,
                label: 'B頁面',
                index: constants.Constants.NAV_INDEX_B,
                onTap: () => onTap(constants.Constants.NAV_INDEX_B),
              ),

              // STEP 02.04: Screen C 導航項目
              _buildNavItem(
                icon: cupertino.CupertinoIcons.time,
                label: 'C頁面',
                index: constants.Constants.NAV_INDEX_C,
                onTap: () => onTap(constants.Constants.NAV_INDEX_C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
