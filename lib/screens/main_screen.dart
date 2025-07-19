import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';
import '../widgets/custom_sidebar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'screen_a.dart';
import 'screen_b.dart';
import 'screen_c.dart';

/// 主頁面
/// 包含標頭列、側邊欄、底部導航的完整主架構
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = Constants.NAV_INDEX_A;
  bool _isSidebarOpen = false;

  /// STEP 01: 處理底部導航點擊
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// STEP 02: 切換側邊欄狀態
  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  /// STEP 03: 建立當前頁面內容
  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case Constants.NAV_INDEX_A:
        return const ScreenA();
      case Constants.NAV_INDEX_B:
        return const ScreenB();
      case Constants.NAV_INDEX_C:
        return const ScreenC();
      default:
        return _buildPagePlaceholder('未知頁面', CupertinoIcons.question, '');
    }
  }

  /// STEP 04: 建立頁面占位符
  Widget _buildPagePlaceholder(String title, IconData icon, String description) {
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // STEP 04.01: 主要圖標
          Container(
            padding: const EdgeInsets.all(Constants.SPACING_LARGE),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: Constants.ICON_SIZE_EXTRA_LARGE * 2,
              color: CupertinoColors.systemBlue,
            ),
          ),
          const SizedBox(height: Constants.SPACING_LARGE),
          
          // STEP 04.02: 標題
          Text(
            title,
            style: const TextStyle(
              fontSize: Constants.FONT_SIZE_EXTRA_LARGE,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          // STEP 04.03: 描述
          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.secondaryLabel,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
          
          // STEP 04.04: 狀態指示
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.SPACING_MEDIUM,
              vertical: Constants.SPACING_SMALL,
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.systemYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
              border: Border.all(
                color: CupertinoColors.systemYellow.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.hammer,
                  color: CupertinoColors.systemYellow,
                  size: Constants.ICON_SIZE_SMALL,
                ),
                SizedBox(width: Constants.SPACING_SMALL),
                Text(
                  '開發中...',
                  style: TextStyle(
                    color: CupertinoColors.systemYellow,
                    fontSize: Constants.FONT_SIZE_SMALL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// STEP 05: 建立側邊欄背景遮罩
  Widget _buildSidebarOverlay() {
    if (!_isSidebarOpen) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: _toggleSidebar,
      child: Container(
        color: CupertinoColors.black.withOpacity(0.3),
        child: Row(
          children: [
            // 側邊欄區域
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onTabTapped,
            ),
            // 空白區域（點擊關閉）
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // STEP 06: 改進的導航欄
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.bars,
            size: Constants.ICON_SIZE_MEDIUM,
          ),
          onPressed: _toggleSidebar,
        ),
        middle: Text(
          Constants.APP_NAME,
          style: const TextStyle(
            fontSize: Constants.FONT_SIZE_LARGE,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      
      // STEP 07: 主要內容
      child: Stack(
        children: [
          // STEP 07.01: 主頁面內容
          SafeArea(
            child: Column(
              children: [
                // 頁面內容區域
                Expanded(
                  child: _buildCurrentPage(),
                ),
                
                // 自定義底部導航列
                CustomBottomNavBar(
                  currentIndex: _selectedIndex,
                  onTap: _onTabTapped,
                ),
              ],
            ),
          ),
          
          // STEP 07.02: 側邊欄覆蓋層
          _buildSidebarOverlay(),
        ],
      ),
    );
  }
} 