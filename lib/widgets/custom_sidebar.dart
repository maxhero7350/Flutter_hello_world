import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/screen_util.dart';
import '../widgets/responsive_layout.dart';

/// 自定義側邊欄
/// 提供導航功能和設定選項
class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  /// STEP 01: 建立響應式標頭
  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // STEP 01.01: 取得用戶資訊
        final displayName = userProvider.getDisplayName();
        final isLoggedIn = userProvider.isLoggedIn;
        
        // STEP 01.02: 構建響應式標頭
        return ResponsiveContainer(
          padding: ScreenUtil.instance.responsivePadding(all: 20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STEP 01.03: 用戶頭像
              ResponsiveContainer(
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                padding: ScreenUtil.instance.responsivePadding(all: 12),
                child: Icon(
                  CupertinoIcons.person_fill,
                  color: CupertinoColors.white,
                  size: ScreenUtil.instance.responsiveIconSize(32),
                ),
              ),
              ResponsiveSpacing(spacing: 12),
              
              // STEP 01.04: 用戶名稱
              ResponsiveText(
                displayName,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
              ResponsiveSpacing(spacing: 4),
              
              // STEP 01.05: 狀態指示
              ResponsiveText(
                isLoggedIn ? '已登入' : '訪客模式',
                fontSize: 14,
                color: CupertinoColors.white.withOpacity(0.8),
              ),
            ],
          ),
        );
      },
    );
  }

  /// STEP 02: 建立響應式導航項目
  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required int index,
    required VoidCallback onTap,
  }) {
    // STEP 02.01: 檢查是否為選中狀態
    final isSelected = selectedIndex == index;
    
    // STEP 02.02: 構建響應式導航項目
    return ResponsiveContainer(
      margin: ScreenUtil.instance.responsivePadding(
        horizontal: 12,
        vertical: 4,
      ),
      child: CupertinoButton(
        padding: ScreenUtil.instance.responsivePadding(
          horizontal: 16,
          vertical: 12,
        ),
        color: isSelected 
            ? CupertinoColors.systemBlue.withOpacity(0.1) 
            : null,
        borderRadius: ScreenUtil.instance.responsiveBorderRadius(8),
        onPressed: onTap,
        child: Row(
          children: [
            // STEP 02.03: 響應式圖標
            Icon(
              icon,
              color: isSelected 
                  ? CupertinoColors.systemBlue 
                  : CupertinoColors.label,
              size: ScreenUtil.instance.responsiveIconSize(24),
            ),
            ResponsiveSpacing(spacing: 12, direction: Axis.horizontal),
            
            // STEP 02.04: 響應式標題
            Expanded(
              child: ResponsiveText(
                title,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? CupertinoColors.systemBlue 
                    : CupertinoColors.label,
              ),
            ),
            
            // STEP 02.05: 選中指示器
            if (isSelected)
              Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemBlue,
                size: ScreenUtil.instance.responsiveIconSize(16),
              ),
          ],
        ),
      ),
    );
  }

  /// STEP 03: 建立響應式設定項目
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    // STEP 03.01: 構建響應式設定項目
    return ResponsiveContainer(
      margin: ScreenUtil.instance.responsivePadding(
        horizontal: 12,
        vertical: 4,
      ),
      child: CupertinoButton(
        padding: ScreenUtil.instance.responsivePadding(
          horizontal: 16,
          vertical: 12,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            // STEP 03.02: 響應式圖標
            Icon(
              icon,
              color: iconColor ?? CupertinoColors.secondaryLabel,
              size: ScreenUtil.instance.responsiveIconSize(24),
            ),
            ResponsiveSpacing(spacing: 12, direction: Axis.horizontal),
            
            // STEP 03.03: 響應式標題
            Expanded(
              child: ResponsiveText(
                title,
                fontSize: 16,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            
            // STEP 03.04: 箭頭圖標
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.tertiaryLabel,
              size: ScreenUtil.instance.responsiveIconSize(16),
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
          title: ResponsiveText(
            '關於 ${Constants.APP_NAME}',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveSpacing(spacing: 8),
              ResponsiveText(
                'Version ${Constants.APP_VERSION}',
                fontSize: 16,
              ),
              ResponsiveSpacing(spacing: 8),
              ResponsiveText(
                '這是我的第一個Flutter專案，用於學習和實踐Flutter開發技術。',
                fontSize: 14,
                lineHeight: 1.4,
              ),
            ],
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
          title: ResponsiveText(
            '確認登出',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          content: ResponsiveText(
            '您確定要登出嗎？',
            fontSize: 16,
          ),
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
                // STEP 05.01: 執行登出操作
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
                final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
                
                // STEP 05.02: 重置所有狀態
                userProvider.logout();
                appStateProvider.reset();
                navigationProvider.resetNavigation();
                
                // STEP 05.03: 關閉對話框
                Navigator.of(context).pop();
                
                // STEP 05.04: 導航到登入頁面並清除所有路由
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
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
    // STEP 06: 初始化響應式設計
    ScreenUtil.instance.init(context);
    
    // STEP 06.01: 計算側邊欄寬度
    double sidebarWidth = ScreenUtil.instance.getSidebarWidth();
    
    // STEP 06.02: 構建響應式側邊欄
    return ResponsiveContainer(
      widthPercentage: ScreenUtil.instance.deviceType == DeviceType.mobile ? 70 : null,
      child: Container(
        width: ScreenUtil.instance.deviceType != DeviceType.mobile ? sidebarWidth : null,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border(
            right: BorderSide(
              color: CupertinoColors.systemGrey4,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // STEP 06.03: 標頭區域
              _buildHeader(context),
              ResponsiveSpacing(spacing: 16),
              
              // STEP 06.04: 導航項目區域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // STEP 06.05: 主要導航項目
                      _buildNavigationItem(
                        icon: CupertinoIcons.square_grid_2x2,
                        title: 'Screen A',
                        index: Constants.NAV_INDEX_A,
                        onTap: () => onItemTapped(Constants.NAV_INDEX_A),
                      ),
                      _buildNavigationItem(
                        icon: CupertinoIcons.doc_text,
                        title: 'Screen B',
                        index: Constants.NAV_INDEX_B,
                        onTap: () => onItemTapped(Constants.NAV_INDEX_B),
                      ),
                      _buildNavigationItem(
                        icon: CupertinoIcons.time,
                        title: 'Screen C',
                        index: Constants.NAV_INDEX_C,
                        onTap: () => onItemTapped(Constants.NAV_INDEX_C),
                      ),
                      
                      ResponsiveSpacing(spacing: 24),
                      
                      // STEP 06.06: 分隔線
                      Container(
                        height: 0.5,
                        color: CupertinoColors.systemGrey4,
                        margin: ScreenUtil.instance.responsivePadding(horizontal: 16),
                      ),
                      
                      ResponsiveSpacing(spacing: 16),
                      
                      // STEP 06.07: 設定項目
                      _buildSettingItem(
                        icon: CupertinoIcons.info_circle,
                        title: '關於',
                        onTap: () => _showAboutDialog(context),
                      ),
                      _buildSettingItem(
                        icon: CupertinoIcons.square_arrow_right,
                        title: '登出',
                        iconColor: CupertinoColors.systemRed,
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