// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

// ===== CUSTOM SCREENS =====
import 'screen_a1.dart' as screen_a1;
import 'screen_a2.dart' as screen_a2;

/// A頁面 - 導航練習
/// 提供兩層跳轉頁面功能，練習Flutter頁面導航
class ScreenA extends cupertino.StatefulWidget {
  const ScreenA({super.key});

  @override
  cupertino.State<ScreenA> createState() => _ScreenAState();
}

class _ScreenAState extends cupertino.State<ScreenA> {
  int _navigationCount = 0;
  String _lastVisitedPage = '無';

  /// STEP 01: 導航到A1頁面
  Future<void> _navigateToA1() async {
    // STEP 01.01: 增加導航計數
    setState(() {
      _navigationCount++;
    });

    // STEP 01.02: 導航到A1頁面並等待返回結果
    final result = await cupertino.Navigator.push(
      context,
      cupertino.CupertinoPageRoute(
        builder: (context) => screen_a1.ScreenA1(
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

    final result = await cupertino.Navigator.push(
      context,
      cupertino.CupertinoPageRoute(
        builder: (context) => screen_a2.ScreenA2(
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
  cupertino.Widget _buildFeatureCard({
    required String title,
    required String description,
    required cupertino.IconData icon,
    required cupertino.VoidCallback onTap,
    cupertino.Color? cardColor,
  }) {
    return cupertino.Container(
      margin: const cupertino.EdgeInsets.only(
        bottom: constants.Constants.spacingMedium,
      ),
      child: cupertino.CupertinoButton(
        padding: cupertino.EdgeInsets.zero,
        onPressed: onTap,
        child: cupertino.Container(
          padding: const cupertino.EdgeInsets.all(
            constants.Constants.spacingLarge,
          ),
          decoration: cupertino.BoxDecoration(
            color: cardColor ?? cupertino.CupertinoColors.systemBackground,
            borderRadius: cupertino.BorderRadius.circular(
              constants.Constants.borderRadiusLarge,
            ),
            border: cupertino.Border.all(
              color: cupertino.CupertinoColors.systemGrey4,
              width: 1,
            ),
            boxShadow: [
              cupertino.BoxShadow(
                color: cupertino.CupertinoColors.systemGrey.withValues(
                  alpha: 0.1,
                ),
                blurRadius: 8,
                offset: const cupertino.Offset(0, 2),
              ),
            ],
          ),
          child: cupertino.Row(
            children: [
              // STEP 04.01: 圖標區域
              cupertino.Container(
                padding: const cupertino.EdgeInsets.all(
                  constants.Constants.spacingMedium,
                ),
                decoration: cupertino.BoxDecoration(
                  color: cupertino.CupertinoColors.systemBlue.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: cupertino.BorderRadius.circular(
                    constants.Constants.borderRadiusMedium,
                  ),
                ),
                child: cupertino.Icon(
                  icon,
                  size: constants.Constants.iconSizeLarge,
                  color: cupertino.CupertinoColors.systemBlue,
                ),
              ),
              const cupertino.SizedBox(
                width: constants.Constants.spacingMedium,
              ),

              // STEP 04.02: 文字區域
              cupertino.Expanded(
                child: cupertino.Column(
                  crossAxisAlignment: cupertino.CrossAxisAlignment.start,
                  children: [
                    cupertino.Text(
                      title,
                      style: const cupertino.TextStyle(
                        fontSize: constants.Constants.fontSizeLarge,
                        fontWeight: cupertino.FontWeight.bold,
                        color: cupertino.CupertinoColors.label,
                      ),
                    ),
                    const cupertino.SizedBox(
                      height: constants.Constants.spacingSmall,
                    ),
                    cupertino.Text(
                      description,
                      style: const cupertino.TextStyle(
                        fontSize: constants.Constants.fontSizeMedium,
                        color: cupertino.CupertinoColors.secondaryLabel,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // STEP 04.03: 箭頭指示
              const cupertino.Icon(
                cupertino.CupertinoIcons.chevron_right,
                color: cupertino.CupertinoColors.systemGrey3,
                size: constants.Constants.iconSizeMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// STEP 05: 建立狀態資訊卡片
  cupertino.Widget _buildStatusCard() {
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(constants.Constants.spacingLarge),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemBlue.withValues(alpha: 0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.borderRadiusLarge,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          const cupertino.Row(
            children: [
              cupertino.Icon(
                cupertino.CupertinoIcons.info_circle,
                color: cupertino.CupertinoColors.systemBlue,
                size: constants.Constants.iconSizeMedium,
              ),
              cupertino.SizedBox(width: constants.Constants.spacingSmall),
              cupertino.Text(
                '導航狀態',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.fontSizeLarge,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.systemBlue,
                ),
              ),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.spacingMedium),

          _buildStatusRow('導航次數', '$_navigationCount 次'),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildStatusRow('最後訪問', _lastVisitedPage),
        ],
      ),
    );
  }

  /// STEP 06: 建立狀態行
  cupertino.Widget _buildStatusRow(String label, String value) {
    return cupertino.Row(
      mainAxisAlignment: cupertino.MainAxisAlignment.spaceBetween,
      children: [
        cupertino.Text(
          label,
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.fontSizeMedium,
            color: cupertino.CupertinoColors.secondaryLabel,
          ),
        ),
        cupertino.Text(
          value,
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.fontSizeMedium,
            fontWeight: cupertino.FontWeight.w600,
            color: cupertino.CupertinoColors.label,
          ),
        ),
      ],
    );
  }

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    return cupertino.SafeArea(
      child: cupertino.ListView(
        padding: const cupertino.EdgeInsets.all(
          constants.Constants.spacingLarge,
        ),
        children: [
          // STEP 08.01: 頁面介紹
          const cupertino.Text(
            '歡迎來到A頁面！',
            style: cupertino.TextStyle(
              fontSize: constants.Constants.fontSizeExtraLarge,
              fontWeight: cupertino.FontWeight.bold,
              color: cupertino.CupertinoColors.label,
            ),
          ),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          const cupertino.Text(
            '這裡可以練習Flutter的頁面導航功能，體驗兩層跳轉頁面的導航流程。',
            style: cupertino.TextStyle(
              fontSize: constants.Constants.fontSizeMedium,
              color: cupertino.CupertinoColors.secondaryLabel,
              height: 1.5,
            ),
          ),
          const cupertino.SizedBox(
            height: constants.Constants.spacingExtraLarge,
          ),

          // STEP 08.02: 導航功能卡片
          _buildFeatureCard(
            title: '前往A1頁面',
            description: '導航到第一層頁面，然後可以繼續前往A2頁面',
            icon: cupertino.CupertinoIcons.arrow_right_circle,
            onTap: _navigateToA1,
          ),

          _buildFeatureCard(
            title: '直接前往A2頁面',
            description: '跳過A1頁面，直接導航到第二層頁面',
            icon: cupertino.CupertinoIcons.arrow_right_square,
            onTap: _navigateDirectlyToA2,
          ),

          const cupertino.SizedBox(height: constants.Constants.spacingLarge),

          // STEP 08.03: 狀態資訊
          _buildStatusCard(),

          const cupertino.SizedBox(height: constants.Constants.spacingLarge),

          // STEP 08.04: 重置按鈕
          cupertino.CupertinoButton(
            color: cupertino.CupertinoColors.systemGrey5,
            borderRadius: cupertino.BorderRadius.circular(
              constants.Constants.borderRadiusMedium,
            ),
            onPressed: _resetNavigationState,
            child: const cupertino.Row(
              mainAxisAlignment: cupertino.MainAxisAlignment.center,
              children: [
                cupertino.Icon(
                  cupertino.CupertinoIcons.refresh,
                  color: cupertino.CupertinoColors.label,
                  size: constants.Constants.iconSizeMedium,
                ),
                cupertino.SizedBox(width: constants.Constants.spacingSmall),
                cupertino.Text(
                  '重置導航狀態',
                  style: cupertino.TextStyle(
                    color: cupertino.CupertinoColors.label,
                    fontSize: constants.Constants.fontSizeMedium,
                    fontWeight: cupertino.FontWeight.w600,
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
