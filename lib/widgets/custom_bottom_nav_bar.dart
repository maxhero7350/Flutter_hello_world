import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';

/// 自定義底部導航欄
/// 提供A、B、C三個頁面的導航功能
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// STEP 01: 建立導航項目
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: Constants.SPACING_SMALL),
        onPressed: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Constants.ICON_SIZE_MEDIUM,
              color: isSelected 
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey,
            ),
            const SizedBox(height: Constants.SPACING_SMALL / 2),
            Text(
              label,
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_SMALL,
                color: isSelected 
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.SPACING_SMALL,
            vertical: Constants.SPACING_SMALL,
          ),
          child: Row(
            children: [
              // STEP 02: A頁面導航
              _buildNavItem(
                icon: CupertinoIcons.square_grid_2x2,
                label: 'A頁面',
                index: Constants.NAV_INDEX_A,
                context: context,
              ),
              
              // STEP 03: B頁面導航
              _buildNavItem(
                icon: CupertinoIcons.textformat,
                label: 'B頁面',
                index: Constants.NAV_INDEX_B,
                context: context,
              ),
              
              // STEP 04: C頁面導航
              _buildNavItem(
                icon: CupertinoIcons.clock,
                label: 'C頁面',
                index: Constants.NAV_INDEX_C,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 