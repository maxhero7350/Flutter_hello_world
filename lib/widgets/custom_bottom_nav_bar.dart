import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';
import '../utils/screen_util.dart';
import '../widgets/responsive_layout.dart';

/// 自定義底部導航列
/// 提供主要的頁面導航功能
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// STEP 01: 建立響應式導航項目
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    // STEP 01.01: 檢查是否為選中狀態
    final isSelected = currentIndex == index;
    
    // STEP 01.02: 構建響應式導航項目
    return Expanded(
      child: CupertinoButton(
        padding: ScreenUtil.instance.responsivePadding(vertical: 8),
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // STEP 01.03: 響應式圖標
            Icon(
              icon,
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.inactiveGray,
              size: ScreenUtil.instance.responsiveIconSize(24),
            ),
            ResponsiveSpacing(spacing: 4),
            
            // STEP 01.04: 響應式標籤
            ResponsiveText(
              label,
              fontSize: 12,
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.inactiveGray,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // STEP 02: 初始化響應式設計
    ScreenUtil.instance.init(context);
    
    // STEP 02.01: 構建響應式底部導航列
    return ResponsiveContainer(
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: ScreenUtil.instance.bottomBarHeight,
      ),
      child: SafeArea(
        top: false,
        child: ResponsiveContainer(
          heightPercentage: ScreenUtil.instance.deviceType == DeviceType.mobile ? 8 : 7,
          child: Row(
            children: [
              // STEP 02.02: Screen A 導航項目
              _buildNavItem(
                icon: CupertinoIcons.square_grid_2x2,
                label: 'A頁面',
                index: Constants.NAV_INDEX_A,
                onTap: () => onTap(Constants.NAV_INDEX_A),
              ),
              
              // STEP 02.03: Screen B 導航項目
              _buildNavItem(
                icon: CupertinoIcons.doc_text,
                label: 'B頁面',
                index: Constants.NAV_INDEX_B,
                onTap: () => onTap(Constants.NAV_INDEX_B),
              ),
              
              // STEP 02.04: Screen C 導航項目
              _buildNavItem(
                icon: CupertinoIcons.time,
                label: 'C頁面',
                index: Constants.NAV_INDEX_C,
                onTap: () => onTap(Constants.NAV_INDEX_C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}