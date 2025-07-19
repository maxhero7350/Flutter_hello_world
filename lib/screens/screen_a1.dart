import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';
import 'screen_a2.dart';

/// A1頁面 - 第一層跳轉頁面
/// 展示頁面間參數傳遞和繼續導航功能
class ScreenA1 extends StatefulWidget {
  final String fromPage;
  final int navigationCount;

  const ScreenA1({
    super.key,
    required this.fromPage,
    required this.navigationCount,
  });

  @override
  State<ScreenA1> createState() => _ScreenA1State();
}

class _ScreenA1State extends State<ScreenA1> {
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
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ScreenA2(
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
      Navigator.pop(context, 'A1→A2→A1 (${result.toString()})');
    }
  }

  /// STEP 03: 直接返回A頁面
  void _returnToA() {
    Navigator.pop(context, 'A1頁面 (停留${_calculateStayDuration()})');
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
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('頁面資訊'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('來源頁面：${widget.fromPage}'),
              Text('導航次數：${widget.navigationCount}'),
              Text('到達時間：${_arrivedTime.hour.toString().padLeft(2, '0')}:${_arrivedTime.minute.toString().padLeft(2, '0')}:${_arrivedTime.second.toString().padLeft(2, '0')}'),
              Text('停留時間：${_calculateStayDuration()}'),
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

  /// STEP 06: 建立資訊卡片
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: CupertinoColors.systemGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.location,
                color: CupertinoColors.systemGreen,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              SizedBox(width: Constants.SPACING_SMALL),
              Text(
                '當前位置：第一層',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          _buildInfoRow('來源', widget.fromPage),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildInfoRow('導航計數', '第 ${widget.navigationCount} 次'),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildInfoRow('停留時間', _calculateStayDuration()),
        ],
      ),
    );
  }

  /// STEP 07: 建立資訊行
  Widget _buildInfoRow(String label, String value) {
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

  /// STEP 08: 建立操作按鈕
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isSecondary = false,
  }) {
    return CupertinoButton(
      color: isSecondary ? CupertinoColors.systemGrey5 : color,
      borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSecondary ? CupertinoColors.label : CupertinoColors.white,
            size: Constants.ICON_SIZE_MEDIUM,
          ),
          const SizedBox(width: Constants.SPACING_SMALL),
          Text(
            title,
            style: TextStyle(
              color: isSecondary ? CupertinoColors.label : CupertinoColors.white,
              fontSize: Constants.FONT_SIZE_MEDIUM,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // STEP 09: 導航欄
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'A1頁面 - 第一層',
          style: TextStyle(
            fontSize: Constants.FONT_SIZE_LARGE,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.info),
          onPressed: _showPageInfo,
        ),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      
      // STEP 10: 主要內容
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Constants.SPACING_LARGE),
          children: [
            // STEP 10.01: 頁面標題
            const Text(
              '第一層跳轉頁面',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_EXTRA_LARGE,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: Constants.SPACING_SMALL),
            Text(
              '從「${widget.fromPage}」導航而來',
              style: const TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
            
            // STEP 10.02: 資訊卡片
            _buildInfoCard(),
            const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
            
            // STEP 10.03: 輸入區域
            const Text(
              '傳遞給A2頁面的訊息',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_LARGE,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: Constants.SPACING_MEDIUM),
            
            CupertinoTextField(
              placeholder: '請輸入要傳遞的訊息...',
              onChanged: (value) {
                setState(() {
                  _userInput = value;
                });
              },
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
              ),
              padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
              maxLines: 3,
              style: const TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
              ),
            ),
            const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
            
            // STEP 10.04: 操作按鈕
            _buildActionButton(
              title: '繼續前往A2頁面',
              icon: CupertinoIcons.arrow_right_circle_fill,
              onPressed: _navigateToA2,
              color: CupertinoColors.activeBlue,
            ),
            const SizedBox(height: Constants.SPACING_MEDIUM),
            
            _buildActionButton(
              title: '返回A頁面',
              icon: CupertinoIcons.arrow_left_circle,
              onPressed: _returnToA,
              color: CupertinoColors.systemGrey,
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }
} 