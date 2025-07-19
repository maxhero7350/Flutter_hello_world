import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';

/// A2頁面 - 第二層跳轉頁面
/// 展示深層導航和複雜的參數傳遞功能
class ScreenA2 extends StatefulWidget {
  final String fromPage;
  final int navigationCount;
  final String message;
  final String? previousPage;

  const ScreenA2({
    super.key,
    required this.fromPage,
    required this.navigationCount,
    required this.message,
    this.previousPage,
  });

  @override
  State<ScreenA2> createState() => _ScreenA2State();
}

class _ScreenA2State extends State<ScreenA2> {
  late DateTime _arrivedTime;
  String _userFeedback = '';
  int _likeCount = 0;
  bool _hasLiked = false;
  
  // 模擬的頁面訪問歷史
  late List<String> _navigationHistory;

  @override
  void initState() {
    super.initState();
    // STEP 01: 初始化狀態
    _arrivedTime = DateTime.now();
    _navigationHistory = _buildNavigationHistory();
  }

  /// STEP 02: 建立導航歷史
  List<String> _buildNavigationHistory() {
    final history = <String>[];
    
    if (widget.previousPage != null) {
      history.add(widget.previousPage!);
    }
    
    history.add(widget.fromPage);
    history.add('A2頁面 (當前)');
    
    return history;
  }

  /// STEP 03: 處理點讚
  void _handleLike() {
    setState(() {
      if (_hasLiked) {
        _likeCount--;
        _hasLiked = false;
      } else {
        _likeCount++;
        _hasLiked = true;
      }
    });
  }

  /// STEP 04: 返回上一頁
  void _goBack() {
    final result = {
      'page': 'A2頁面',
      'stayDuration': _calculateStayDuration(),
      'feedback': _userFeedback.isNotEmpty ? _userFeedback : '無回饋',
      'liked': _hasLiked,
      'likeCount': _likeCount,
    };
    
    Navigator.pop(context, result);
  }

  /// STEP 05: 返回到根頁面（A頁面）
  void _goBackToRoot() {
    // 彈出所有頁面直到A頁面
    Navigator.popUntil(context, (route) {
      return route.settings.name == '/' || route.isFirst;
    });
  }

  /// STEP 06: 計算停留時間
  String _calculateStayDuration() {
    final now = DateTime.now();
    final duration = now.difference(_arrivedTime);
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分${duration.inSeconds % 60}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  /// STEP 07: 顯示導航路徑對話框
  void _showNavigationPath() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('導航路徑'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('導航歷史：'),
              const SizedBox(height: 8),
              ..._navigationHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final page = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text('${index + 1}. '),
                      Expanded(
                        child: Text(
                          page,
                          style: TextStyle(
                            fontWeight: page.contains('當前') 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
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

  /// STEP 08: 建立頁面資訊卡片
  Widget _buildPageInfoCard() {
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: CupertinoColors.systemPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: CupertinoColors.systemPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.location_fill,
                color: CupertinoColors.systemPurple,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              SizedBox(width: Constants.SPACING_SMALL),
              Text(
                '當前位置：第二層',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          _buildInfoRow('來源頁面', widget.fromPage),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildInfoRow('導航深度', '第 ${widget.navigationCount} 層'),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildInfoRow('停留時間', _calculateStayDuration()),
          const SizedBox(height: Constants.SPACING_SMALL),
          _buildInfoRow('導航層數', '${_navigationHistory.length} 層'),
        ],
      ),
    );
  }

  /// STEP 09: 建立訊息卡片
  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.mail,
                color: CupertinoColors.systemBlue,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              SizedBox(width: Constants.SPACING_SMALL),
              Text(
                '傳遞的訊息',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          Container(
            padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
            ),
            child: Text(
              widget.message,
              style: const TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.label,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STEP 10: 建立互動區域
  Widget _buildInteractionArea() {
    return Container(
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '互動功能',
            style: TextStyle(
              fontSize: Constants.FONT_SIZE_LARGE,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          // 點讚功能
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.SPACING_MEDIUM,
                  vertical: Constants.SPACING_SMALL,
                ),
                color: _hasLiked ? CupertinoColors.systemRed : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
                onPressed: _handleLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      color: _hasLiked ? CupertinoColors.white : CupertinoColors.label,
                      size: Constants.ICON_SIZE_MEDIUM,
                    ),
                    const SizedBox(width: Constants.SPACING_SMALL),
                    Text(
                      '喜歡 ($_likeCount)',
                      style: TextStyle(
                        color: _hasLiked ? CupertinoColors.white : CupertinoColors.label,
                        fontSize: Constants.FONT_SIZE_MEDIUM,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Constants.SPACING_MEDIUM),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.SPACING_MEDIUM,
                  vertical: Constants.SPACING_SMALL,
                ),
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
                onPressed: _showNavigationPath,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.map,
                      color: CupertinoColors.white,
                      size: Constants.ICON_SIZE_MEDIUM,
                    ),
                    SizedBox(width: Constants.SPACING_SMALL),
                    Text(
                      '導航路徑',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: Constants.FONT_SIZE_MEDIUM,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: Constants.SPACING_LARGE),
          
          // 回饋輸入
          const Text(
            '回饋意見',
            style: TextStyle(
              fontSize: Constants.FONT_SIZE_MEDIUM,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: Constants.SPACING_SMALL),
          
          CupertinoTextField(
            placeholder: '請分享您對導航體驗的想法...',
            onChanged: (value) {
              setState(() {
                _userFeedback = value;
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
        ],
      ),
    );
  }

  /// STEP 11: 建立資訊行
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

  /// STEP 12: 建立操作按鈕
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
      // STEP 13: 導航欄
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'A2頁面 - 第二層',
          style: TextStyle(
            fontSize: Constants.FONT_SIZE_LARGE,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.map),
          onPressed: _showNavigationPath,
        ),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      
      // STEP 14: 主要內容
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Constants.SPACING_LARGE),
          children: [
            // STEP 14.01: 頁面標題
            const Text(
              '第二層跳轉頁面',
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
            
            // STEP 14.02: 頁面資訊
            _buildPageInfoCard(),
            const SizedBox(height: Constants.SPACING_LARGE),
            
            // STEP 14.03: 傳遞的訊息
            _buildMessageCard(),
            const SizedBox(height: Constants.SPACING_LARGE),
            
            // STEP 14.04: 互動區域
            _buildInteractionArea(),
            const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
            
            // STEP 14.05: 操作按鈕
            _buildActionButton(
              title: '返回上一頁',
              icon: CupertinoIcons.arrow_left_circle,
              onPressed: _goBack,
              color: CupertinoColors.activeBlue,
            ),
            const SizedBox(height: Constants.SPACING_MEDIUM),
            
            _buildActionButton(
              title: '返回A頁面',
              icon: CupertinoIcons.house,
              onPressed: _goBackToRoot,
              color: CupertinoColors.systemGrey,
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }
} 