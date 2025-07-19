import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';
import '../screens/login_screen.dart';

/// 自定義側邊欄
/// 包含使用者資訊、導航項目和設定選項
class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  /// STEP 01: 建立側邊欄標題
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: const SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEP 01.01: 用戶頭像
            Icon(
              CupertinoIcons.person_circle_fill,
              size: Constants.ICON_SIZE_EXTRA_LARGE * 1.5,
              color: CupertinoColors.systemBlue,
            ),
            SizedBox(height: Constants.SPACING_MEDIUM),
            
            // STEP 01.02: 用戶名稱
            Text(
              Constants.DEFAULT_USERNAME,
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_LARGE,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
            SizedBox(height: Constants.SPACING_SMALL),
            
            // STEP 01.03: 歡迎訊息
            Text(
              '歡迎使用 ${Constants.APP_NAME}',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// STEP 02: 建立導航項目
  Widget _buildNavigationItem({
    required String title,
    required IconData icon,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.SPACING_MEDIUM,
        vertical: Constants.SPACING_SMALL / 2,
      ),
      decoration: BoxDecoration(
        color: isSelected 
            ? CupertinoColors.activeBlue.withOpacity(0.1)
            : const Color(0x00000000),
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
        onPressed: () {
          onItemTapped(index);
          Navigator.of(context).pop(); // 關閉側邊欄
        },
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey,
              size: Constants.ICON_SIZE_MEDIUM,
            ),
            const SizedBox(width: Constants.SPACING_MEDIUM),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected 
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.label,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: Constants.FONT_SIZE_MEDIUM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// STEP 03: 建立設定項目
  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.SPACING_MEDIUM,
        vertical: Constants.SPACING_SMALL / 2,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? CupertinoColors.systemGrey,
              size: Constants.ICON_SIZE_MEDIUM,
            ),
            const SizedBox(width: Constants.SPACING_MEDIUM),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor ?? CupertinoColors.label,
                  fontSize: Constants.FONT_SIZE_MEDIUM,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
              size: Constants.ICON_SIZE_SMALL,
            ),
          ],
        ),
      ),
    );
  }

  /// STEP 04: 顯示關於對話框
  void _showAboutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('關於 ${Constants.APP_NAME}'),
          content: const Text(
            '這是我的第一個Flutter專案，用於學習基本介面、頁面框架、跳頁和本地端資料庫功能。',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 05: 顯示登出確認對話框
  void _showLogoutConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('登出確認'),
          content: const Text('確定要登出嗎？'),
          actions: [
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('登出'),
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
                Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: CupertinoColors.systemBackground,
      child: Column(
        children: [
          // STEP 06.01: 標題區域
          _buildHeader(),
          
          // STEP 06.02: 導航項目
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: Constants.SPACING_MEDIUM),
              children: [
                // 主要導航
                _buildNavigationItem(
                  title: 'A頁面 - 導航練習',
                  icon: CupertinoIcons.square_grid_2x2,
                  index: Constants.NAV_INDEX_A,
                  context: context,
                ),
                _buildNavigationItem(
                  title: 'B頁面 - 資料儲存',
                  icon: CupertinoIcons.textformat,
                  index: Constants.NAV_INDEX_B,
                  context: context,
                ),
                _buildNavigationItem(
                  title: 'C頁面 - API呼叫',
                  icon: CupertinoIcons.clock,
                  index: Constants.NAV_INDEX_C,
                  context: context,
                ),
                
                const SizedBox(height: Constants.SPACING_LARGE),
                
                // 分隔線
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Constants.SPACING_MEDIUM),
                  height: 0.5,
                  color: CupertinoColors.systemGrey4,
                ),
                
                const SizedBox(height: Constants.SPACING_MEDIUM),
                
                // 設定項目
                _buildSettingItem(
                  title: '關於應用程式',
                  icon: CupertinoIcons.info_circle,
                  onTap: () => _showAboutDialog(context),
                ),
                _buildSettingItem(
                  title: '應用程式設定',
                  icon: CupertinoIcons.settings,
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: 導航到設定頁面
                  },
                ),
              ],
            ),
          ),
          
          // STEP 06.03: 底部區域
          Container(
            padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: CupertinoColors.systemGrey4,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  _buildSettingItem(
                    title: '登出',
                    icon: CupertinoIcons.square_arrow_left,
                    iconColor: CupertinoColors.systemRed,
                    textColor: CupertinoColors.systemRed,
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                  const SizedBox(height: Constants.SPACING_SMALL),
                  Text(
                    'Version ${Constants.APP_VERSION}',
                    style: const TextStyle(
                      fontSize: Constants.FONT_SIZE_SMALL,
                      color: CupertinoColors.tertiaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 