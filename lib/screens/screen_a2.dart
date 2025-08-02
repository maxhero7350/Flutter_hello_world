// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

/// A2頁面 - 第二層跳轉頁面
/// 展示深層導航和複雜的參數傳遞功能
class ScreenA2 extends cupertino.StatefulWidget {
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
  cupertino.State<ScreenA2> createState() => _ScreenA2State();
}

class _ScreenA2State extends cupertino.State<ScreenA2> {
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

    cupertino.Navigator.pop(context, result);
  }

  /// STEP 05: 返回到根頁面（A頁面）
  void _goBackToRoot() {
    // 彈出所有頁面直到A頁面
    cupertino.Navigator.popUntil(context, (route) {
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
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: const cupertino.Text('導航路徑'),
          content: cupertino.Column(
            crossAxisAlignment: cupertino.CrossAxisAlignment.start,
            mainAxisSize: cupertino.MainAxisSize.min,
            children: [
              const cupertino.Text('導航歷史：'),
              const cupertino.SizedBox(height: 8),
              ..._navigationHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final page = entry.value;
                return cupertino.Padding(
                  padding: const cupertino.EdgeInsets.only(bottom: 4),
                  child: cupertino.Row(
                    children: [
                      cupertino.Text('${index + 1}. '),
                      cupertino.Expanded(
                        child: cupertino.Text(
                          page,
                          style: cupertino.TextStyle(
                            fontWeight: page.contains('當前')
                                ? cupertino.FontWeight.bold
                                : cupertino.FontWeight.normal,
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

  /// STEP 08: 建立頁面資訊卡片
  cupertino.Widget _buildPageInfoCard() {
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(constants.Constants.spacingLarge),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemPurple.withValues(alpha: 0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.borderRadiusLarge,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          const cupertino.Row(
            children: [
              cupertino.Icon(
                cupertino.CupertinoIcons.location_fill,
                color: cupertino.CupertinoColors.systemPurple,
                size: constants.Constants.iconSizeMedium,
              ),
              cupertino.SizedBox(width: constants.Constants.spacingSmall),
              cupertino.Text(
                '當前位置：第二層',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.fontSizeLarge,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.spacingMedium),

          _buildInfoRow('來源頁面', widget.fromPage),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildInfoRow('導航深度', '第 ${widget.navigationCount} 層'),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildInfoRow('停留時間', _calculateStayDuration()),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),
          _buildInfoRow('導航層數', '${_navigationHistory.length} 層'),
        ],
      ),
    );
  }

  /// STEP 09: 建立訊息卡片
  cupertino.Widget _buildMessageCard() {
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(constants.Constants.spacingLarge),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemBackground,
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.borderRadiusLarge,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          const cupertino.Row(
            children: [
              cupertino.Icon(
                cupertino.CupertinoIcons.mail,
                color: cupertino.CupertinoColors.systemBlue,
                size: constants.Constants.iconSizeMedium,
              ),
              cupertino.SizedBox(width: constants.Constants.spacingSmall),
              cupertino.Text(
                '傳遞的訊息',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.fontSizeLarge,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.label,
                ),
              ),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.spacingMedium),

          cupertino.Container(
            padding: const cupertino.EdgeInsets.all(
              constants.Constants.spacingMedium,
            ),
            decoration: cupertino.BoxDecoration(
              color: cupertino.CupertinoColors.systemGrey6,
              borderRadius: cupertino.BorderRadius.circular(
                constants.Constants.borderRadiusMedium,
              ),
            ),
            child: cupertino.Text(
              widget.message,
              style: const cupertino.TextStyle(
                fontSize: constants.Constants.fontSizeMedium,
                color: cupertino.CupertinoColors.label,
                fontStyle: cupertino.FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STEP 10: 建立互動區域
  cupertino.Widget _buildInteractionArea() {
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(constants.Constants.spacingLarge),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemBackground,
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.borderRadiusLarge,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          const cupertino.Text(
            '互動功能',
            style: cupertino.TextStyle(
              fontSize: constants.Constants.fontSizeLarge,
              fontWeight: cupertino.FontWeight.bold,
              color: cupertino.CupertinoColors.label,
            ),
          ),
          const cupertino.SizedBox(height: constants.Constants.spacingMedium),

          // 點讚功能
          cupertino.Row(
            children: [
              cupertino.CupertinoButton(
                padding: const cupertino.EdgeInsets.symmetric(
                  horizontal: constants.Constants.spacingMedium,
                  vertical: constants.Constants.spacingSmall,
                ),
                color: _hasLiked
                    ? cupertino.CupertinoColors.systemRed
                    : cupertino.CupertinoColors.systemGrey5,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.borderRadiusMedium,
                ),
                onPressed: _handleLike,
                child: cupertino.Row(
                  mainAxisSize: cupertino.MainAxisSize.min,
                  children: [
                    cupertino.Icon(
                      _hasLiked
                          ? cupertino.CupertinoIcons.heart_fill
                          : cupertino.CupertinoIcons.heart,
                      color: _hasLiked
                          ? cupertino.CupertinoColors.white
                          : cupertino.CupertinoColors.label,
                      size: constants.Constants.iconSizeMedium,
                    ),
                    const cupertino.SizedBox(
                      width: constants.Constants.spacingSmall,
                    ),
                    cupertino.Text(
                      '喜歡 ($_likeCount)',
                      style: cupertino.TextStyle(
                        color: _hasLiked
                            ? cupertino.CupertinoColors.white
                            : cupertino.CupertinoColors.label,
                        fontSize: constants.Constants.fontSizeMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const cupertino.SizedBox(
                width: constants.Constants.spacingMedium,
              ),
              cupertino.CupertinoButton(
                padding: const cupertino.EdgeInsets.symmetric(
                  horizontal: constants.Constants.spacingMedium,
                  vertical: constants.Constants.spacingSmall,
                ),
                color: cupertino.CupertinoColors.systemBlue,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.borderRadiusMedium,
                ),
                onPressed: _showNavigationPath,
                child: const cupertino.Row(
                  mainAxisSize: cupertino.MainAxisSize.min,
                  children: [
                    cupertino.Icon(
                      cupertino.CupertinoIcons.map,
                      color: cupertino.CupertinoColors.white,
                      size: constants.Constants.iconSizeMedium,
                    ),
                    cupertino.SizedBox(width: constants.Constants.spacingSmall),
                    cupertino.Text(
                      '導航路徑',
                      style: cupertino.TextStyle(
                        color: cupertino.CupertinoColors.white,
                        fontSize: constants.Constants.fontSizeMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const cupertino.SizedBox(height: constants.Constants.spacingLarge),

          // 回饋輸入
          const cupertino.Text(
            '回饋意見',
            style: cupertino.TextStyle(
              fontSize: constants.Constants.fontSizeMedium,
              fontWeight: cupertino.FontWeight.w600,
              color: cupertino.CupertinoColors.label,
            ),
          ),
          const cupertino.SizedBox(height: constants.Constants.spacingSmall),

          cupertino.CupertinoTextField(
            placeholder: '請分享您對導航體驗的想法...',
            onChanged: (value) {
              setState(() {
                _userFeedback = value;
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
        ],
      ),
    );
  }

  /// STEP 11: 建立資訊行
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

  /// STEP 12: 建立操作按鈕
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
      // STEP 13: 導航欄
      navigationBar: cupertino.CupertinoNavigationBar(
        middle: const cupertino.Text(
          'A2頁面 - 第二層',
          style: cupertino.TextStyle(
            fontSize: constants.Constants.fontSizeLarge,
            fontWeight: cupertino.FontWeight.w600,
          ),
        ),
        trailing: cupertino.CupertinoButton(
          padding: cupertino.EdgeInsets.zero,
          onPressed: _showNavigationPath,
          child: const cupertino.Icon(cupertino.CupertinoIcons.map),
        ),
        backgroundColor: cupertino.CupertinoColors.systemBackground,
      ),

      // STEP 14: 主要內容
      child: cupertino.SafeArea(
        child: cupertino.ListView(
          padding: const cupertino.EdgeInsets.all(
            constants.Constants.spacingLarge,
          ),
          children: [
            // STEP 14.01: 頁面標題
            const cupertino.Text(
              '第二層跳轉頁面',
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

            // STEP 14.02: 頁面資訊
            _buildPageInfoCard(),
            const cupertino.SizedBox(height: constants.Constants.spacingLarge),

            // STEP 14.03: 傳遞的訊息
            _buildMessageCard(),
            const cupertino.SizedBox(height: constants.Constants.spacingLarge),

            // STEP 14.04: 互動區域
            _buildInteractionArea(),
            const cupertino.SizedBox(
              height: constants.Constants.spacingExtraLarge,
            ),

            // STEP 14.05: 操作按鈕
            _buildActionButton(
              title: '返回上一頁',
              icon: cupertino.CupertinoIcons.arrow_left_circle,
              onPressed: _goBack,
              color: cupertino.CupertinoColors.systemBlue,
            ),
            const cupertino.SizedBox(height: constants.Constants.spacingMedium),

            _buildActionButton(
              title: '返回A頁面',
              icon: cupertino.CupertinoIcons.house,
              onPressed: _goBackToRoot,
              color: cupertino.CupertinoColors.systemGrey,
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }
}
