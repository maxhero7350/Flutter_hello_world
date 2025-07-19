import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';
import '../models/message_model.dart';
import '../services/database_service.dart';

/// B頁面 - 資料儲存
/// 提供完整的本地端資料庫CRUD操作功能
class ScreenB extends StatefulWidget {
  const ScreenB({super.key});

  @override
  State<ScreenB> createState() => _ScreenBState();
}

class _ScreenBState extends State<ScreenB> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _messageController = TextEditingController();
  
  List<MessageModel> _messages = [];
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
    
    if (content.length < Constants.MIN_MESSAGE_LENGTH) {
      _showErrorDialog('輸入錯誤', '訊息長度至少需要 ${Constants.MIN_MESSAGE_LENGTH} 個字元');
      return;
    }
    
    if (content.length > Constants.MAX_MESSAGE_LENGTH) {
      _showErrorDialog('輸入錯誤', '訊息長度不能超過 ${Constants.MAX_MESSAGE_LENGTH} 個字元');
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
        _showSuccessMessage(Constants.SUCCESS_MESSAGE_UPDATED);
        
        // 重置編輯狀態
        _editingMessageId = null;
      } else {
        // STEP 04.03: 儲存新訊息
        final newMessage = MessageModel(
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _databaseService.insertMessage(newMessage);
        _showSuccessMessage(Constants.SUCCESS_MESSAGE_SAVED);
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
      _showSuccessMessage(Constants.SUCCESS_MESSAGE_DELETED);
      await _loadMessages();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('刪除失敗', e.toString());
    }
  }

  /// STEP 06: 編輯訊息
  void _editMessage(MessageModel message) {
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
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('確認刪除'),
          content: const Text('確定要刪除這條訊息嗎？此操作無法撤銷。'),
          actions: [
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('刪除'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// STEP 09: 顯示錯誤對話框
  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
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

  /// STEP 10: 顯示成功訊息
  void _showSuccessMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('成功'),
          content: Text(message),
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

  /// STEP 11: 建立輸入區域
  Widget _buildInputArea() {
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
          Row(
            children: [
              Icon(
                _editingMessageId != null ? CupertinoIcons.pencil : CupertinoIcons.plus,
                color: CupertinoColors.systemBlue,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              const SizedBox(width: Constants.SPACING_SMALL),
              Text(
                _editingMessageId != null ? '編輯訊息' : '新增訊息',
                style: const TextStyle(
                  fontSize: Constants.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              if (_editingMessageId != null) ...[
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: Constants.FONT_SIZE_MEDIUM,
                    ),
                  ),
                  onPressed: _cancelEdit,
                ),
              ],
            ],
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          CupertinoTextField(
            controller: _messageController,
            placeholder: '請輸入您的訊息...',
            maxLines: 4,
            maxLength: Constants.MAX_MESSAGE_LENGTH,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
            ),
            padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
            style: const TextStyle(
              fontSize: Constants.FONT_SIZE_MEDIUM,
            ),
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          Row(
            children: [
              Text(
                '${_messageController.text.length}/${Constants.MAX_MESSAGE_LENGTH}',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_SMALL,
                  color: _messageController.text.length > Constants.MAX_MESSAGE_LENGTH 
                      ? CupertinoColors.systemRed 
                      : CupertinoColors.secondaryLabel,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
                onPressed: _isLoading ? null : _saveMessage,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading) ...[
                      const CupertinoActivityIndicator(
                        radius: 8,
                        color: CupertinoColors.white,
                      ),
                      const SizedBox(width: Constants.SPACING_SMALL),
                    ],
                    Icon(
                      _editingMessageId != null ? CupertinoIcons.check_mark : CupertinoIcons.add,
                      color: CupertinoColors.white,
                      size: Constants.ICON_SIZE_SMALL,
                    ),
                    const SizedBox(width: Constants.SPACING_SMALL),
                    Text(
                      _editingMessageId != null ? '更新' : '儲存',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: Constants.FONT_SIZE_MEDIUM,
                        fontWeight: FontWeight.w600,
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
  Widget _buildMessagesList() {
    if (_isLoading && _messages.isEmpty) {
      return const Center(
        child: Column(
          children: [
            CupertinoActivityIndicator(radius: 20),
            SizedBox(height: Constants.SPACING_MEDIUM),
            Text(
              '載入中...',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.chat_bubble_text,
              size: Constants.ICON_SIZE_EXTRA_LARGE * 2,
              color: CupertinoColors.systemGrey3,
            ),
            const SizedBox(height: Constants.SPACING_MEDIUM),
            const Text(
              '還沒有任何訊息',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_LARGE,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: Constants.SPACING_SMALL),
            const Text(
              '開始輸入您的第一條訊息吧！',
              style: TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  /// STEP 13: 建立訊息卡片
  Widget _buildMessageCard(MessageModel message) {
    final isEditing = _editingMessageId == message.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: Constants.SPACING_MEDIUM),
      padding: const EdgeInsets.all(Constants.SPACING_LARGE),
      decoration: BoxDecoration(
        color: isEditing 
            ? CupertinoColors.systemBlue.withOpacity(0.1)
            : CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
        border: Border.all(
          color: isEditing 
              ? CupertinoColors.systemBlue.withOpacity(0.3)
              : CupertinoColors.systemGrey4,
          width: isEditing ? 2 : 1,
        ),
        boxShadow: isEditing ? [
          BoxShadow(
            color: CupertinoColors.systemBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STEP 13.01: 訊息標頭
          Row(
            children: [
              Icon(
                CupertinoIcons.chat_bubble,
                color: isEditing ? CupertinoColors.systemBlue : CupertinoColors.systemGrey,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              const SizedBox(width: Constants.SPACING_SMALL),
              Text(
                'ID: ${message.id ?? '新建'}',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_SMALL,
                  color: isEditing ? CupertinoColors.systemBlue : CupertinoColors.secondaryLabel,
                  fontWeight: isEditing ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.pencil,
                  color: isEditing ? CupertinoColors.systemBlue : CupertinoColors.systemGrey,
                  size: Constants.ICON_SIZE_SMALL,
                ),
                onPressed: () => _editMessage(message),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                  size: Constants.ICON_SIZE_SMALL,
                ),
                onPressed: message.id != null ? () => _deleteMessage(message.id!) : null,
              ),
            ],
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          // STEP 13.02: 訊息內容
          Container(
            padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
            decoration: BoxDecoration(
              color: isEditing 
                  ? CupertinoColors.systemBlue.withOpacity(0.05)
                  : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
            ),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: Constants.FONT_SIZE_MEDIUM,
                color: CupertinoColors.label,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          // STEP 13.03: 時間資訊
          Row(
            children: [
              _buildTimeInfo('建立', message.createdAt),
              const SizedBox(width: Constants.SPACING_LARGE),
              _buildTimeInfo('更新', message.updatedAt ?? message.createdAt),
            ],
          ),
        ],
      ),
    );
  }

  /// STEP 14: 建立時間資訊
  Widget _buildTimeInfo(String label, DateTime dateTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: Constants.FONT_SIZE_SMALL,
            color: CupertinoColors.tertiaryLabel,
          ),
        ),
        Text(
          '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: Constants.FONT_SIZE_SMALL,
            color: CupertinoColors.secondaryLabel,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// STEP 15: 建立統計資訊
  Widget _buildStatsCard() {
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
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.chart_bar,
            color: CupertinoColors.systemGreen,
            size: Constants.ICON_SIZE_MEDIUM,
          ),
          const SizedBox(width: Constants.SPACING_MEDIUM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '資料庫統計',
                  style: TextStyle(
                    fontSize: Constants.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemGreen,
                  ),
                ),
                const SizedBox(height: Constants.SPACING_SMALL),
                Text(
                  '總共儲存了 ${_messages.length} 條訊息',
                  style: const TextStyle(
                    fontSize: Constants.FONT_SIZE_MEDIUM,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.SPACING_MEDIUM,
              vertical: Constants.SPACING_SMALL,
            ),
            color: CupertinoColors.systemGreen,
            borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
            onPressed: _loadMessages,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.refresh,
                  color: CupertinoColors.white,
                  size: Constants.ICON_SIZE_SMALL,
                ),
                SizedBox(width: Constants.SPACING_SMALL),
                Text(
                  '重新載入',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: Constants.FONT_SIZE_SMALL,
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(Constants.SPACING_LARGE),
        children: [
          // STEP 16.01: 頁面標題
          const Text(
            '資料儲存功能',
            style: TextStyle(
              fontSize: Constants.FONT_SIZE_EXTRA_LARGE,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: Constants.SPACING_SMALL),
          const Text(
            '使用本地端SQLite資料庫儲存和管理您的訊息',
            style: TextStyle(
              fontSize: Constants.FONT_SIZE_MEDIUM,
              color: CupertinoColors.secondaryLabel,
              height: 1.5,
            ),
          ),
          const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
          
          // STEP 16.02: 統計卡片
          _buildStatsCard(),
          const SizedBox(height: Constants.SPACING_LARGE),
          
          // STEP 16.03: 輸入區域
          _buildInputArea(),
          const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
          
          // STEP 16.04: 訊息列表標題
          Row(
            children: [
              const Icon(
                CupertinoIcons.list_bullet,
                color: CupertinoColors.systemBlue,
                size: Constants.ICON_SIZE_MEDIUM,
              ),
              const SizedBox(width: Constants.SPACING_SMALL),
              const Text(
                '儲存的訊息',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              if (_isLoading && _messages.isNotEmpty)
                const CupertinoActivityIndicator(radius: 10),
            ],
          ),
          const SizedBox(height: Constants.SPACING_MEDIUM),
          
          // STEP 16.05: 訊息列表
          _buildMessagesList(),
        ],
      ),
    );
  }
} 