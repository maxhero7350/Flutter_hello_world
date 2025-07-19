import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';
import 'screen_a1.dart';
import 'screen_a2.dart';

/// A頁面 - 導航練習
/// 提供兩層跳轉頁面功能，練習Flutter頁面導航
class ScreenA extends StatefulWidget {
  const ScreenA({super.key});

  @override
  State<ScreenA> createState() => _ScreenAState();
}

class _ScreenAState extends State<ScreenA> {
  int _navigationCount = 0;
  String _lastVisitedPage = '無';

  /// STEP 01: 導航到A1頁面
  Future<void> _navigateToA1() async {
    // STEP 01.01: 增加導航計數
    setState(() {
      _navigationCount++;
    });

    // STEP 01.02: 導航到A1頁面並等待返回結果
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ScreenA1(
          fromPage: 'A頁面',
          navigationCount: _navigationCount,
        ),
      ),
    );

    // STEP 01.03: 處理返回結果
    if (result != null && mounted) {
      setState(() {
        _lastVisitedPage = result.toString();
      });
    }
  }

  /// STEP 02: 直接導航到A2頁面
  Future<void> _navigateDirectlyToA2() async {
    setState(() {
      _navigationCount++;
    });

    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ScreenA2(
          fromPage: 'A頁面 (直接)',
          navigationCount: _navigationCount,
          message: '這是從A頁面直接跳轉到A2頁面的示例',
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _lastVisitedPage = result.toString();
      });
    }
  }

  /// STEP 03: 重置導航狀態
  void _resetNavigationState() {
    setState(() {
      _navigationCount = 0;
      _lastVisitedPage = '無';
    });
  }

  /// STEP 04: 建立功能卡片
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color? cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: Constants.SPACING_MEDIUM),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(Constants.SPACING_LARGE),
          decoration: BoxDecoration(
            color: cardColor ?? CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // STEP 04.01: 圖標區域
              Container(
                padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
                ),
                child: Icon(
                  icon,
                  size: Constants.ICON_SIZE_LARGE,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(width: Constants.SPACING_MEDIUM),
              
              // STEP 04.02: 文字區域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: Constants.FONT_SIZE_LARGE,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: Constants.SPACING_SMALL),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: Constants.FONT_SIZE_MEDIUM,
                        color: CupertinoColors.secondaryLabel,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // STEP 04.03: 箭頭指示
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey3,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// STEP 05: 建立狀態資訊卡片
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: CupertinoColors.systemBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: CupertinoColors.systemBlue,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              SizedBox(width: Constants.SPACING_SMALL),
              Text(
                '導航狀態',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          _buildStatusRow('導航次數', '$_navigationCount 次'),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildStatusRow('最後訪問', _lastVisitedPage),
        ],
      ),
    );
  }

  /// STEP 06: 建立狀態行
  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: Constants.FONT_SIZE_MEDIUM,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: Constants.FONT_SIZE_MEDIUM,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Constants.SPACING_LARGE),
          children: [
            // STEP 08.01: 頁面介紹
            const Text(
              '歡迎來到A頁面！',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_EXTRA_LARGE,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: Constants.SPACING_SMALL),
            const Text(
              '這裡可以練習Flutter的頁面導航功能，體驗兩層跳轉頁面的導航流程。',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.secondaryLabel,
                height: 1.5,
              ),
            ),
            const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
            
            // STEP 08.02: 導航功能卡片
            _buildFeatureCard(
              title: '前往A1頁面',
              description: '導航到第一層頁面，然後可以繼續前往A2頁面',
              icon: CupertinoIcons.arrow_right_circle,
              onTap: _navigateToA1,
            ),
            
            _buildFeatureCard(
              title: '直接前往A2頁面',
              description: '跳過A1頁面，直接導航到第二層頁面',
              icon: CupertinoIcons.arrow_right_square,
              onTap: _navigateDirectlyToA2,
            ),
            
            const SizedBox(height: Constants.SPACING_LARGE),
            
            // STEP 08.03: 狀態資訊
            _buildStatusCard(),
            
            const SizedBox(height: Constants.SPACING_LARGE),
            
            // STEP 08.04: 重置按鈕
            CupertinoButton(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
              onPressed: _resetNavigationState,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.refresh,
                    color: CupertinoColors.label,
                    size: Constants.ICON_SIZE_MEDIUM,
                  ),
                  SizedBox(width: Constants.SPACING_SMALL),
                  Text(
                    '重置導航狀態',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: Constants.FONT_SIZE_MEDIUM,
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
} 