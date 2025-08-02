// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

// ===== CUSTOM SCREENS =====
import 'screen_a2.dart' as screen_a2;

/// A1頁面 - 第一層跳轉頁面
/// 展示頁面間參數傳遞和繼續導航功能
class ScreenA1 extends cupertino.StatefulWidget {
  final String fromPage;
  final int navigationCount;

  const ScreenA1({
    super.key,
    required this.fromPage,
    required this.navigationCount,
  });

  @override
  cupertino.State<ScreenA1> createState() => _ScreenA1State();
}

class _ScreenA1State extends cupertino.State<ScreenA1> {
  String _userInput = '';
  late DateTime _arrivedTime;

  @override
  void initState() {
    super.initState();
    // STEP 01: 記錄到達時間
    _arrivedTime = DateTime.now();
  }

  /// STEP 02: 導航到A2頁面
  Future<void> _navigateToA2() async {
    final result = await cupertino.Navigator.push(
      context,
      cupertino.CupertinoPageRoute(
        builder: (context) => screen_a2.ScreenA2(
          fromPage: 'A1頁面',
          navigationCount: widget.navigationCount + 1,
          message: _userInput.isNotEmpty
              ? '從A1頁面帶來的訊息：$_userInput'
              : '來自A1頁面的預設訊息',
          previousPage: widget.fromPage,
        ),
      ),
    );

    // STEP 02.01: 處理A2頁面的返回結果
    if (result != null && mounted) {
      // 將結果傳回A頁面
      cupertino.Navigator.pop(context, 'A1→A2→A1 (${result.toString()})');
    }
  }

  /// STEP 03: 直接返回A頁面
  void _returnToA() {
    cupertino.Navigator.pop(context, 'A1頁面 (停留${_calculateStayDuration()})');
  }

  /// STEP 04: 計算停留時間
  String _calculateStayDuration() {
    final now = DateTime.now();
    final duration = now.difference(_arrivedTime);
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分${duration.inSeconds % 60}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  /// STEP 05: 顯示頁面資訊對話框
  void _showPageInfo() {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: const cupertino.Text('頁面資訊'),
          content: cupertino.Column(
            crossAxisAlignment: cupertino.CrossAxisAlignment.start,
            mainAxisSize: cupertino.MainAxisSize.min,
            children: [
              cupertino.Text('來源頁面：${widget.fromPage}'),
              cupertino.Text('導航次數：${widget.navigationCount}'),
              cupertino.Text(
                '到達時間：${_arrivedTime.hour.toString().padLeft(2, '0')}:${_arrivedTime.minute.toString().padLeft(2, '0')}:${_arrivedTime.second.toString().padLeft(2, '0')}',
              ),
              cupertino.Text('停留時間：${_calculateStayDuration()}'),
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

  /// STEP 06: 建立資訊卡片
  cupertino.Widget _buildInfoCard() {
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(constants.Constants.spacingLarge),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemGreen.withValues(alpha: 0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.borderRadiusLarge,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          const cupertino.Row(
            children: [
              cupertino.Icon(
                cupertino.CupertinoIcons.location,
                color: cupertino.CupertinoColors.systemGreen,
                size: constants.Constants.iconSizeMedium,
              ),
              cupertino.SizedBox(width: constants.Constants.spacingSmall),
              cupertino.Text(
                '當前位置：第一層',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.fontSizeLarge,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.spacingMedium),

          _buildInfoRow('來源', widget.fromPage),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildInfoRow('導航計數', '第 ${widget.navigationCount} 次'),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildInfoRow('停留時間', _calculateStayDuration()),
        ],
      ),
    );
  }

  /// STEP 07: 建立資訊行
  cupertino.Widget _buildInfoRow(String label, String value) {
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

  /// STEP 08: 建立操作按鈕
  cupertino.Widget _buildActionButton({
    required String title,
    required cupertino.IconData icon,
    required cupertino.VoidCallback onPressed,
    required cupertino.Color color,
    bool isSecondary = false,
  }) {
    return cupertino.CupertinoButton(
      color: isSecondary ? cupertino.CupertinoColors.systemGrey5 : color,
      borderRadius: cupertino.BorderRadius.circular(
        constants.Constants.borderRadiusMedium,
      ),
      onPressed: onPressed,
      child: cupertino.Row(
        mainAxisAlignment: cupertino.MainAxisAlignment.center,
        children: [
          cupertino.Icon(
            icon,
            color: isSecondary
                ? cupertino.CupertinoColors.label
                : cupertino.CupertinoColors.white,
            size: constants.Constants.iconSizeMedium,
          ),
          const cupertino.SizedBox(width: constants.Constants.spacingSmall),
          cupertino.Text(
            title,
            style: cupertino.TextStyle(
              color: isSecondary
                  ? cupertino.CupertinoColors.label
                  : cupertino.CupertinoColors.white,
              fontSize: constants.Constants.fontSizeMedium,
              fontWeight: cupertino.FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    return cupertino.CupertinoPageScaffold(
      // STEP 09: 導航欄
      navigationBar: cupertino.CupertinoNavigationBar(
        middle: const cupertino.Text(
          'A1頁面 - 第一層',
          style: cupertino.TextStyle(
            fontSize: constants.Constants.fontSizeLarge,
            fontWeight: cupertino.FontWeight.w600,
          ),
        ),
        trailing: cupertino.CupertinoButton(
          padding: cupertino.EdgeInsets.zero,
          onPressed: _showPageInfo,
          child: const cupertino.Icon(cupertino.CupertinoIcons.info),
        ),
        backgroundColor: cupertino.CupertinoColors.systemBackground,
      ),

      // STEP 10: 主要內容
      child: cupertino.SafeArea(
        child: cupertino.ListView(
          padding: const cupertino.EdgeInsets.all(
            constants.Constants.spacingLarge,
          ),
          children: [
            // STEP 10.01: 頁面標題
            const cupertino.Text(
              '第一層跳轉頁面',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeExtraLarge,
                fontWeight: cupertino.FontWeight.bold,
                color: cupertino.CupertinoColors.label,
              ),
            ),
            const cupertino.SizedBox(height: constants.Constants.spacingSmall),
            cupertino.Text(
              '從「${widget.fromPage}」導航而來',
              style: const cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeMedium,
                color: cupertino.CupertinoColors.secondaryLabel,
              ),
            ),
            const cupertino.SizedBox(
              height: constants.Constants.spacingExtraLarge,
            ),

            // STEP 10.02: 資訊卡片
            _buildInfoCard(),
            const cupertino.SizedBox(
              height: constants.Constants.spacingExtraLarge,
            ),

            // STEP 10.03: 輸入區域
            const cupertino.Text(
              '傳遞給A2頁面的訊息',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeLarge,
                fontWeight: cupertino.FontWeight.bold,
                color: cupertino.CupertinoColors.label,
              ),
            ),
            const cupertino.SizedBox(height: constants.Constants.spacingMedium),

            cupertino.CupertinoTextField(
              placeholder: '請輸入要傳遞的訊息...',
              onChanged: (value) {
                setState(() {
                  _userInput = value;
                });
              },
              decoration: cupertino.BoxDecoration(
                color: cupertino.CupertinoColors.systemBackground,
                border: cupertino.Border.all(
                  color: cupertino.CupertinoColors.systemGrey4,
                  width: 1,
                ),
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.borderRadiusMedium,
                ),
              ),
              padding: const cupertino.EdgeInsets.all(
                constants.Constants.spacingMedium,
              ),
              maxLines: 3,
              style: const cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeMedium,
              ),
            ),
            const cupertino.SizedBox(
              height: constants.Constants.spacingExtraLarge,
            ),

            // STEP 10.04: 操作按鈕
            _buildActionButton(
              title: '繼續前往A2頁面',
              icon: cupertino.CupertinoIcons.arrow_right_circle_fill,
              onPressed: _navigateToA2,
              color: cupertino.CupertinoColors.systemBlue,
            ),
            const cupertino.SizedBox(height: constants.Constants.spacingMedium),

            _buildActionButton(
              title: '返回A頁面',
              icon: cupertino.CupertinoIcons.arrow_left_circle,
              onPressed: _returnToA,
              color: cupertino.CupertinoColors.systemGrey,
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }
}
