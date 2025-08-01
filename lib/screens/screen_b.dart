// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

// ===== CUSTOM MODELS =====
import '../models/message_model.dart' as message_model;

// ===== CUSTOM SERVICES =====
import '../services/database_service.dart' as database_service;

/// B頁面 - 資料儲存
/// 提供完整的本地端資料庫CRUD操作功能
class ScreenB extends cupertino.StatefulWidget {
  const ScreenB({super.key});

  @override
  cupertino.State<ScreenB> createState() => _ScreenBState();
}

class _ScreenBState extends cupertino.State<ScreenB> {
  final database_service.DatabaseService _databaseService =
      database_service.DatabaseService();
  final cupertino.TextEditingController _messageController =
      cupertino.TextEditingController();

  List<message_model.MessageModel> _messages = [];
  bool _isLoading = false;
  int? _editingMessageId;

  @override
  void initState() {
    super.initState();
    // STEP 01: 初始化時載入所有訊息
    _loadMessages();

    // STEP 01.01: 添加文字輸入監聽器
    _messageController.addListener(() {
      setState(() {
        // 觸發重繪以更新字數統計
      });
    });
  }

  @override
  void dispose() {
    // STEP 02: 清理資源
    _messageController.dispose();
    super.dispose();
  }

  /// STEP 03: 載入所有訊息
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _databaseService.getAllMessages();
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('載入訊息失敗', e.toString());
    }
  }

  /// STEP 04: 儲存新訊息
  Future<void> _saveMessage() async {
    final content = _messageController.text.trim();

    // STEP 04.01: 驗證輸入
    if (content.isEmpty) {
      _showErrorDialog('輸入錯誤', '請輸入訊息內容');
      return;
    }

    if (content.length < constants.Constants.MIN_MESSAGE_LENGTH) {
      _showErrorDialog(
        '輸入錯誤',
        '訊息長度至少需要 ${constants.Constants.MIN_MESSAGE_LENGTH} 個字元',
      );
      return;
    }

    if (content.length > constants.Constants.MAX_MESSAGE_LENGTH) {
      _showErrorDialog(
        '輸入錯誤',
        '訊息長度不能超過 ${constants.Constants.MAX_MESSAGE_LENGTH} 個字元',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_editingMessageId != null) {
        // STEP 04.02: 更新現有訊息
        final existingMessage = _messages.firstWhere(
          (msg) => msg.id == _editingMessageId,
        );

        final updatedMessage = existingMessage.copyWith(
          content: content,
          updatedAt: DateTime.now(),
        );

        await _databaseService.updateMessage(updatedMessage);
        _showSuccessMessage(constants.Constants.SUCCESS_MESSAGE_UPDATED);

        // 重置編輯狀態
        _editingMessageId = null;
      } else {
        // STEP 04.03: 儲存新訊息
        final newMessage = message_model.MessageModel(
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _databaseService.insertMessage(newMessage);
        _showSuccessMessage(constants.Constants.SUCCESS_MESSAGE_SAVED);
      }

      // STEP 04.04: 清理輸入框並重新載入
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('儲存失敗', e.toString());
    }
  }

  /// STEP 05: 刪除訊息
  Future<void> _deleteMessage(int messageId) async {
    // STEP 05.01: 顯示確認對話框
    final shouldDelete = await _showDeleteConfirmation();
    if (!shouldDelete) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseService.deleteMessage(messageId);
      _showSuccessMessage(constants.Constants.SUCCESS_MESSAGE_DELETED);
      await _loadMessages();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('刪除失敗', e.toString());
    }
  }

  /// STEP 06: 編輯訊息
  void _editMessage(message_model.MessageModel message) {
    setState(() {
      _editingMessageId = message.id;
      _messageController.text = message.content;
    });
  }

  /// STEP 07: 取消編輯
  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  /// STEP 08: 顯示刪除確認對話框
  Future<bool> _showDeleteConfirmation() async {
    return await cupertino.showCupertinoDialog<bool>(
          context: context,
          builder: (cupertino.BuildContext context) {
            return cupertino.CupertinoAlertDialog(
              title: const cupertino.Text('確認刪除'),
              content: const cupertino.Text('確定要刪除這條訊息嗎？此操作無法撤銷。'),
              actions: [
                cupertino.CupertinoDialogAction(
                  child: const cupertino.Text('取消'),
                  onPressed: () {
                    cupertino.Navigator.of(context).pop(false);
                  },
                ),
                cupertino.CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const cupertino.Text('刪除'),
                  onPressed: () {
                    cupertino.Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// STEP 09: 顯示錯誤對話框
  void _showErrorDialog(String title, String message) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: cupertino.Text(title),
          content: cupertino.Text(message),
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

  /// STEP 10: 顯示成功訊息
  void _showSuccessMessage(String message) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: const cupertino.Text('成功'),
          content: cupertino.Text(message),
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

  /// STEP 11: 建立輸入區域
  cupertino.Widget _buildInputArea() {
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemBackground,
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.BORDER_RADIUS_LARGE,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          cupertino.Row(
            children: [
              cupertino.Icon(
                _editingMessageId != null
                    ? cupertino.CupertinoIcons.pencil
                    : cupertino.CupertinoIcons.plus,
                color: cupertino.CupertinoColors.systemBlue,
                size: constants.Constants.ICON_SIZE_MEDIUM,
              ),
              const cupertino.SizedBox(
                width: constants.Constants.SPACING_SMALL,
              ),
              cupertino.Text(
                _editingMessageId != null ? '編輯訊息' : '新增訊息',
                style: const cupertino.TextStyle(
                  fontSize: constants.Constants.FONT_SIZE_LARGE,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.label,
                ),
              ),
              if (_editingMessageId != null) ...[
                const cupertino.Spacer(),
                cupertino.CupertinoButton(
                  padding: cupertino.EdgeInsets.zero,
                  onPressed: _cancelEdit,
                  child: const cupertino.Text(
                    '取消',
                    style: cupertino.TextStyle(
                      color: cupertino.CupertinoColors.systemRed,
                      fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),

          cupertino.CupertinoTextField(
            controller: _messageController,
            placeholder: '請輸入您的訊息...',
            maxLines: 4,
            maxLength: constants.Constants.MAX_MESSAGE_LENGTH,
            decoration: cupertino.BoxDecoration(
              color: cupertino.CupertinoColors.systemGrey6,
              border: cupertino.Border.all(
                color: cupertino.CupertinoColors.systemGrey4,
                width: 1,
              ),
              borderRadius: cupertino.BorderRadius.circular(
                constants.Constants.BORDER_RADIUS_MEDIUM,
              ),
            ),
            padding: const cupertino.EdgeInsets.all(
              constants.Constants.SPACING_MEDIUM,
            ),
            style: const cupertino.TextStyle(
              fontSize: constants.Constants.FONT_SIZE_MEDIUM,
            ),
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),

          cupertino.Row(
            children: [
              cupertino.Text(
                '${_messageController.text.length}/${constants.Constants.MAX_MESSAGE_LENGTH}',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.FONT_SIZE_SMALL,
                  color:
                      _messageController.text.length >
                          constants.Constants.MAX_MESSAGE_LENGTH
                      ? cupertino.CupertinoColors.systemRed
                      : cupertino.CupertinoColors.secondaryLabel,
                ),
              ),
              const cupertino.Spacer(),
              cupertino.CupertinoButton(
                color: cupertino.CupertinoColors.activeBlue,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.BORDER_RADIUS_MEDIUM,
                ),
                onPressed: _isLoading ? null : _saveMessage,
                child: cupertino.Row(
                  mainAxisSize: cupertino.MainAxisSize.min,
                  children: [
                    if (_isLoading) ...[
                      const cupertino.CupertinoActivityIndicator(
                        radius: 8,
                        color: cupertino.CupertinoColors.white,
                      ),
                      const cupertino.SizedBox(
                        width: constants.Constants.SPACING_SMALL,
                      ),
                    ],
                    cupertino.Icon(
                      _editingMessageId != null
                          ? cupertino.CupertinoIcons.check_mark
                          : cupertino.CupertinoIcons.add,
                      color: cupertino.CupertinoColors.white,
                      size: constants.Constants.ICON_SIZE_SMALL,
                    ),
                    const cupertino.SizedBox(
                      width: constants.Constants.SPACING_SMALL,
                    ),
                    cupertino.Text(
                      _editingMessageId != null ? '更新' : '儲存',
                      style: const cupertino.TextStyle(
                        color: cupertino.CupertinoColors.white,
                        fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                        fontWeight: cupertino.FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// STEP 12: 建立訊息列表
  cupertino.Widget _buildMessagesList() {
    if (_isLoading && _messages.isEmpty) {
      return const cupertino.Center(
        child: cupertino.Column(
          children: [
            cupertino.CupertinoActivityIndicator(radius: 20),
            cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),
            cupertino.Text(
              '載入中...',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                color: cupertino.CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return cupertino.Center(
        child: cupertino.Column(
          children: [
            cupertino.Icon(
              cupertino.CupertinoIcons.chat_bubble_text,
              size: constants.Constants.ICON_SIZE_EXTRA_LARGE * 2,
              color: cupertino.CupertinoColors.systemGrey3,
            ),
            const cupertino.SizedBox(
              height: constants.Constants.SPACING_MEDIUM,
            ),
            const cupertino.Text(
              '還沒有任何訊息',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_LARGE,
                fontWeight: cupertino.FontWeight.bold,
                color: cupertino.CupertinoColors.secondaryLabel,
              ),
            ),
            const cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
            const cupertino.Text(
              '開始輸入您的第一條訊息吧！',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                color: cupertino.CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return cupertino.ListView.builder(
      shrinkWrap: true,
      physics: const cupertino.NeverScrollableScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  /// STEP 13: 建立訊息卡片
  cupertino.Widget _buildMessageCard(message_model.MessageModel message) {
    final isEditing = _editingMessageId == message.id;

    return cupertino.Container(
      margin: const cupertino.EdgeInsets.only(
        bottom: constants.Constants.SPACING_MEDIUM,
      ),
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      decoration: cupertino.BoxDecoration(
        color: isEditing
            ? cupertino.CupertinoColors.systemBlue.withOpacity(0.1)
            : cupertino.CupertinoColors.systemBackground,
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.BORDER_RADIUS_LARGE,
        ),
        border: cupertino.Border.all(
          color: isEditing
              ? cupertino.CupertinoColors.systemBlue.withOpacity(0.3)
              : cupertino.CupertinoColors.systemGrey4,
          width: isEditing ? 2 : 1,
        ),
        boxShadow: isEditing
            ? [
                cupertino.BoxShadow(
                  color: cupertino.CupertinoColors.systemBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const cupertino.Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          // STEP 13.01: 訊息標頭
          cupertino.Row(
            children: [
              cupertino.Icon(
                cupertino.CupertinoIcons.chat_bubble,
                color: isEditing
                    ? cupertino.CupertinoColors.systemBlue
                    : cupertino.CupertinoColors.systemGrey,
                size: constants.Constants.ICON_SIZE_MEDIUM,
              ),
              const cupertino.SizedBox(
                width: constants.Constants.SPACING_SMALL,
              ),
              cupertino.Text(
                'ID: ${message.id ?? '新建'}',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.FONT_SIZE_SMALL,
                  color: isEditing
                      ? cupertino.CupertinoColors.systemBlue
                      : cupertino.CupertinoColors.secondaryLabel,
                  fontWeight: isEditing
                      ? cupertino.FontWeight.w600
                      : cupertino.FontWeight.normal,
                ),
              ),
              const cupertino.Spacer(),
              cupertino.CupertinoButton(
                padding: cupertino.EdgeInsets.zero,
                child: cupertino.Icon(
                  cupertino.CupertinoIcons.pencil,
                  color: isEditing
                      ? cupertino.CupertinoColors.systemBlue
                      : cupertino.CupertinoColors.systemGrey,
                  size: constants.Constants.ICON_SIZE_SMALL,
                ),
                onPressed: () => _editMessage(message),
              ),
              cupertino.CupertinoButton(
                padding: cupertino.EdgeInsets.zero,
                onPressed: message.id != null
                    ? () => _deleteMessage(message.id!)
                    : null,
                child: const cupertino.Icon(
                  cupertino.CupertinoIcons.delete,
                  color: cupertino.CupertinoColors.systemRed,
                  size: constants.Constants.ICON_SIZE_SMALL,
                ),
              ),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),

          // STEP 13.02: 訊息內容
          cupertino.Container(
            padding: const cupertino.EdgeInsets.all(
              constants.Constants.SPACING_MEDIUM,
            ),
            decoration: cupertino.BoxDecoration(
              color: isEditing
                  ? cupertino.CupertinoColors.systemBlue.withOpacity(0.05)
                  : cupertino.CupertinoColors.systemGrey6,
              borderRadius: cupertino.BorderRadius.circular(
                constants.Constants.BORDER_RADIUS_MEDIUM,
              ),
            ),
            child: cupertino.Text(
              message.content,
              style: const cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                color: cupertino.CupertinoColors.label,
                height: 1.4,
              ),
            ),
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),

          // STEP 13.03: 時間資訊
          cupertino.Row(
            children: [
              _buildTimeInfo('建立', message.createdAt),
              const cupertino.SizedBox(
                width: constants.Constants.SPACING_LARGE,
              ),
              _buildTimeInfo('更新', message.updatedAt ?? message.createdAt),
            ],
          ),
        ],
      ),
    );
  }

  /// STEP 14: 建立時間資訊
  cupertino.Widget _buildTimeInfo(String label, DateTime dateTime) {
    return cupertino.Column(
      crossAxisAlignment: cupertino.CrossAxisAlignment.start,
      children: [
        cupertino.Text(
          label,
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.FONT_SIZE_SMALL,
            color: cupertino.CupertinoColors.tertiaryLabel,
          ),
        ),
        cupertino.Text(
          '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.FONT_SIZE_SMALL,
            color: cupertino.CupertinoColors.secondaryLabel,
            fontWeight: cupertino.FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// STEP 15: 建立統計資訊
  cupertino.Widget _buildStatsCard() {
    return cupertino.Container(
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemGreen.withOpacity(0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.BORDER_RADIUS_LARGE,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: cupertino.Row(
        children: [
          const cupertino.Icon(
            cupertino.CupertinoIcons.chart_bar,
            color: cupertino.CupertinoColors.systemGreen,
            size: constants.Constants.ICON_SIZE_MEDIUM,
          ),
          const cupertino.SizedBox(width: constants.Constants.SPACING_MEDIUM),
          cupertino.Expanded(
            child: cupertino.Column(
              crossAxisAlignment: cupertino.CrossAxisAlignment.start,
              children: [
                const cupertino.Text(
                  '資料庫統計',
                  style: cupertino.TextStyle(
                    fontSize: constants.Constants.FONT_SIZE_LARGE,
                    fontWeight: cupertino.FontWeight.bold,
                    color: cupertino.CupertinoColors.systemGreen,
                  ),
                ),
                const cupertino.SizedBox(
                  height: constants.Constants.SPACING_SMALL,
                ),
                cupertino.Text(
                  '總共儲存了 ${_messages.length} 條訊息',
                  style: const cupertino.TextStyle(
                    fontSize: constants.Constants.FONT_SIZE_MEDIUM,
                    color: cupertino.CupertinoColors.label,
                  ),
                ),
              ],
            ),
          ),
          cupertino.CupertinoButton(
            padding: const cupertino.EdgeInsets.symmetric(
              horizontal: constants.Constants.SPACING_MEDIUM,
              vertical: constants.Constants.SPACING_SMALL,
            ),
            color: cupertino.CupertinoColors.systemGreen,
            borderRadius: cupertino.BorderRadius.circular(
              constants.Constants.BORDER_RADIUS_MEDIUM,
            ),
            onPressed: _loadMessages,
            child: const cupertino.Row(
              mainAxisSize: cupertino.MainAxisSize.min,
              children: [
                cupertino.Icon(
                  cupertino.CupertinoIcons.refresh,
                  color: cupertino.CupertinoColors.white,
                  size: constants.Constants.ICON_SIZE_SMALL,
                ),
                cupertino.SizedBox(width: constants.Constants.SPACING_SMALL),
                cupertino.Text(
                  '重新載入',
                  style: cupertino.TextStyle(
                    color: cupertino.CupertinoColors.white,
                    fontSize: constants.Constants.FONT_SIZE_SMALL,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    return cupertino.SafeArea(
      child: cupertino.ListView(
        padding: const cupertino.EdgeInsets.all(
          constants.Constants.SPACING_LARGE,
        ),
        children: [
          // STEP 16.01: 頁面標題
          const cupertino.Text(
            '資料儲存功能',
            style: cupertino.TextStyle(
              fontSize: constants.Constants.FONT_SIZE_EXTRA_LARGE,
              fontWeight: cupertino.FontWeight.bold,
              color: cupertino.CupertinoColors.label,
            ),
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
          const cupertino.Text(
            '使用本地端SQLite資料庫儲存和管理您的訊息',
            style: cupertino.TextStyle(
              fontSize: constants.Constants.FONT_SIZE_MEDIUM,
              color: cupertino.CupertinoColors.secondaryLabel,
              height: 1.5,
            ),
          ),
          const cupertino.SizedBox(
            height: constants.Constants.SPACING_EXTRA_LARGE,
          ),

          // STEP 16.02: 統計卡片
          _buildStatsCard(),
          const cupertino.SizedBox(height: constants.Constants.SPACING_LARGE),

          // STEP 16.03: 輸入區域
          _buildInputArea(),
          const cupertino.SizedBox(
            height: constants.Constants.SPACING_EXTRA_LARGE,
          ),

          // STEP 16.04: 訊息列表標題
          cupertino.Row(
            children: [
              const cupertino.Icon(
                cupertino.CupertinoIcons.list_bullet,
                color: cupertino.CupertinoColors.systemBlue,
                size: constants.Constants.ICON_SIZE_MEDIUM,
              ),
              const cupertino.SizedBox(
                width: constants.Constants.SPACING_SMALL,
              ),
              const cupertino.Text(
                '儲存的訊息',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.FONT_SIZE_LARGE,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.label,
                ),
              ),
              const cupertino.Spacer(),
              if (_isLoading && _messages.isNotEmpty)
                const cupertino.CupertinoActivityIndicator(radius: 10),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),

          // STEP 16.05: 訊息列表
          _buildMessagesList(),
        ],
      ),
    );
  }
}
