// ===== FLUTTER CORE =====
// 導入 Flutter Cupertino 設計風格的 UI 元件，使用 cupertino 別名避免命名衝突
import 'package:flutter/cupertino.dart' as cupertino;

// ===== CUSTOM UTILS =====
// 導入自定義常數類別，包含應用程式中的固定值設定
import '../utils/constants.dart' as constants;

// ===== CUSTOM MODELS =====
// 導入訊息資料模型，定義訊息的資料結構
import '../models/message_model.dart' as message_model;

// ===== CUSTOM SERVICES =====
// 導入資料庫服務類別，提供 SQLite 資料庫操作功能
import '../services/database_service.dart' as database_service;

/// B頁面 - 資料儲存
/// 提供完整的本地端資料庫CRUD操作功能
/// 包含新增、讀取、更新、刪除訊息的完整功能
class ScreenB extends cupertino.StatefulWidget {
  // 建構函式，接收可選的 key 參數
  const ScreenB({super.key});

  @override
  // 建立對應的 State 物件，管理頁面的狀態
  cupertino.State<ScreenB> createState() => _ScreenBState();
}

/// ScreenB 的狀態管理類別
/// 負責管理頁面的所有狀態和業務邏輯
class _ScreenBState extends cupertino.State<ScreenB> {
  // 初始化資料庫服務實例，用於執行所有資料庫相關操作（CRUD）
  final database_service.DatabaseService _databaseService =
      database_service.DatabaseService();

  // 初始化文字輸入控制器，用於管理訊息輸入框的文字內容和狀態
  final cupertino.TextEditingController _messageController =
      cupertino.TextEditingController();

  // 訊息列表狀態變數，儲存從資料庫載入的所有訊息資料
  List<message_model.MessageModel> _messages = [];

  // 載入狀態標記，控制是否顯示載入中的 UI 狀態
  bool _isLoading = false;

  // 編輯中的訊息 ID，記錄目前正在編輯的訊息 ID，null 表示沒有在編輯
  int? _editingMessageId;

  @override
  // STEP 01: 元件初始化方法
  // 在元件建立時執行一次，用於設定初始狀態
  void initState() {
    super.initState();
    // STEP 01.01: 初始化時載入所有訊息
    _loadMessages();

    // STEP 01.02: 添加文字輸入監聽器
    // 當輸入框內容改變時觸發重繪，更新字數統計顯示
    _messageController.addListener(() {
      setState(() {
        // 觸發重繪以更新字數統計
      });
    });
  }

  @override
  // STEP 01: 元件銷毀方法
  // 在元件被銷毀時執行，用於清理資源避免記憶體洩漏
  void dispose() {
    // STEP 01.01: 清理文字控制器資源
    _messageController.dispose();
    super.dispose();
  }

  /// STEP 01: 載入所有訊息的方法
  /// 從資料庫中取得所有儲存的訊息並更新 UI
  Future<void> _loadMessages() async {
    // STEP 01.01: 設定載入狀態為 true，顯示載入中 UI
    setState(() {
      _isLoading = true;
    });

    try {
      // STEP 01.02: 呼叫資料庫服務取得所有訊息
      final messages = await _databaseService.getAllMessages();

      // STEP 01.03: 更新狀態並關閉載入中狀態
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      // STEP 01.04: 錯誤處理：關閉載入狀態並顯示錯誤訊息
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('載入訊息失敗', e.toString());
    }
  }

  /// STEP 01: 儲存新訊息的方法
  /// 處理新增和更新訊息的邏輯
  Future<void> _saveMessage() async {
    // STEP 01.01: 取得並清理輸入的文字內容
    final content = _messageController.text.trim();

    // STEP 01.02: 驗證輸入內容是否為空
    if (content.isEmpty) {
      _showErrorDialog('輸入錯誤', '請輸入訊息內容');
      return;
    }

    // STEP 01.03: 驗證訊息長度是否達到最小要求
    if (content.length < constants.Constants.MIN_MESSAGE_LENGTH) {
      _showErrorDialog(
        '輸入錯誤',
        '訊息長度至少需要 ${constants.Constants.MIN_MESSAGE_LENGTH} 個字元',
      );
      return;
    }

    // STEP 01.04: 驗證訊息長度是否超過最大限制
    if (content.length > constants.Constants.MAX_MESSAGE_LENGTH) {
      _showErrorDialog(
        '輸入錯誤',
        '訊息長度不能超過 ${constants.Constants.MAX_MESSAGE_LENGTH} 個字元',
      );
      return;
    }

    // STEP 01.05: 設定載入狀態
    setState(() {
      _isLoading = true;
    });

    try {
      if (_editingMessageId != null) {
        // STEP 01.06: 更新現有訊息的邏輯
        // 找到要編輯的訊息
        final existingMessage = _messages.firstWhere(
          (msg) => msg.id == _editingMessageId,
        );

        // 建立更新後的訊息物件
        final updatedMessage = existingMessage.copyWith(
          content: content,
          updatedAt: DateTime.now(),
        );

        // 呼叫資料庫服務更新訊息
        await _databaseService.updateMessage(updatedMessage);
        _showSuccessMessage(constants.Constants.SUCCESS_MESSAGE_UPDATED);

        // 重置編輯狀態
        _editingMessageId = null;
      } else {
        // STEP 01.07: 儲存新訊息的邏輯
        // 建立新的訊息物件
        final newMessage = message_model.MessageModel(
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 呼叫資料庫服務插入新訊息
        await _databaseService.insertMessage(newMessage);
        _showSuccessMessage(constants.Constants.SUCCESS_MESSAGE_SAVED);
      }

      // STEP 01.08: 清理輸入框並重新載入訊息列表
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      // STEP 01.09: 錯誤處理
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('儲存失敗', e.toString());
    }
  }

  /// STEP 01: 刪除訊息的方法
  /// 處理訊息刪除的邏輯，包含確認對話框
  Future<void> _deleteMessage(int messageId) async {
    // STEP 01.01: 顯示刪除確認對話框
    final shouldDelete = await _showDeleteConfirmation();
    if (!shouldDelete) return;

    // STEP 01.02: 設定載入狀態
    setState(() {
      _isLoading = true;
    });

    try {
      // STEP 01.03: 呼叫資料庫服務刪除訊息
      await _databaseService.deleteMessage(messageId);
      _showSuccessMessage(constants.Constants.SUCCESS_MESSAGE_DELETED);

      // STEP 01.04: 重新載入訊息列表
      await _loadMessages();
    } catch (e) {
      // STEP 01.05: 錯誤處理
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('刪除失敗', e.toString());
    }
  }

  /// STEP 01: 編輯訊息的方法
  /// 設定編輯狀態並將訊息內容填入輸入框
  void _editMessage(message_model.MessageModel message) {
    setState(() {
      // STEP 01.01: 設定正在編輯的訊息 ID
      _editingMessageId = message.id;

      // STEP 01.02: 將訊息內容填入輸入框
      _messageController.text = message.content;
    });
  }

  /// STEP 01: 取消編輯的方法
  /// 清除編輯狀態並清空輸入框
  void _cancelEdit() {
    setState(() {
      // STEP 01.01: 清除編輯中的訊息 ID
      _editingMessageId = null;

      // STEP 01.02: 清空輸入框內容
      _messageController.clear();
    });
  }

  /// STEP 01: 顯示刪除確認對話框的方法
  /// 顯示 Cupertino 風格的確認對話框
  Future<bool> _showDeleteConfirmation() async {
    return await cupertino.showCupertinoDialog<bool>(
          context: context,
          builder: (cupertino.BuildContext context) {
            return cupertino.CupertinoAlertDialog(
              title: const cupertino.Text('確認刪除'),
              content: const cupertino.Text('確定要刪除這條訊息嗎？此操作無法撤銷。'),
              actions: [
                // STEP 01.01: 取消按鈕
                cupertino.CupertinoDialogAction(
                  child: const cupertino.Text('取消'),
                  onPressed: () {
                    cupertino.Navigator.of(context).pop(false);
                  },
                ),
                // STEP 01.02: 刪除按鈕（危險操作）
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

  /// STEP 01: 顯示錯誤對話框的方法
  /// 顯示錯誤訊息的 Cupertino 對話框
  void _showErrorDialog(String title, String message) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: cupertino.Text(title),
          content: cupertino.Text(message),
          actions: [
            // STEP 01.01: 確定按鈕
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

  /// STEP 01: 顯示成功訊息的方法
  /// 顯示成功訊息的 Cupertino 對話框
  void _showSuccessMessage(String message) {
    cupertino.showCupertinoDialog(
      context: context,
      builder: (cupertino.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: const cupertino.Text('成功'),
          content: cupertino.Text(message),
          actions: [
            // STEP 01.01: 確定按鈕
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

  /// STEP 01: 建立輸入區域的方法
  /// 建立包含輸入框和按鈕的輸入區域 UI
  cupertino.Widget _buildInputArea() {
    return cupertino.Container(
      // STEP 01.01: 設定容器的內邊距
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      // STEP 01.02: 設定容器的裝飾樣式
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
          // STEP 01.03: 標題列
          cupertino.Row(
            children: [
              // STEP 01.03.01: 圖示（編輯或新增）
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
              // STEP 01.03.02: 標題文字
              cupertino.Text(
                _editingMessageId != null ? '編輯訊息' : '新增訊息',
                style: const cupertino.TextStyle(
                  fontSize: constants.Constants.FONT_SIZE_LARGE,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.label,
                ),
              ),
              // STEP 01.03.03: 編輯模式下的取消按鈕
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

          // STEP 01.04: 文字輸入框
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

          // STEP 01.05: 字數統計和儲存按鈕列
          cupertino.Row(
            children: [
              // STEP 01.05.01: 字數統計顯示
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
              // STEP 01.05.02: 儲存/更新按鈕
              cupertino.CupertinoButton(
                color: cupertino.CupertinoColors.activeBlue,
                borderRadius: cupertino.BorderRadius.circular(
                  constants.Constants.BORDER_RADIUS_MEDIUM,
                ),
                onPressed: _isLoading ? null : _saveMessage,
                child: cupertino.Row(
                  mainAxisSize: cupertino.MainAxisSize.min,
                  children: [
                    // STEP 01.05.02.01: 載入中的活動指示器
                    if (_isLoading) ...[
                      const cupertino.CupertinoActivityIndicator(
                        radius: 8,
                        color: cupertino.CupertinoColors.white,
                      ),
                      const cupertino.SizedBox(
                        width: constants.Constants.SPACING_SMALL,
                      ),
                    ],
                    // STEP 01.05.02.02: 按鈕圖示
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
                    // STEP 01.05.02.03: 按鈕文字
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

  /// STEP 01: 建立訊息列表的方法
  /// 根據不同狀態顯示相應的 UI（載入中、空狀態、訊息列表）
  cupertino.Widget _buildMessagesList() {
    // STEP 01.01: 載入中且沒有訊息的狀態
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

    // STEP 01.02: 沒有訊息的空狀態
    if (_messages.isEmpty) {
      return cupertino.Center(
        child: cupertino.Column(
          children: [
            // STEP 01.02.01: 空狀態圖示
            cupertino.Icon(
              cupertino.CupertinoIcons.chat_bubble_text,
              size: constants.Constants.ICON_SIZE_EXTRA_LARGE * 2,
              color: cupertino.CupertinoColors.systemGrey3,
            ),
            const cupertino.SizedBox(
              height: constants.Constants.SPACING_MEDIUM,
            ),
            // STEP 01.02.02: 空狀態標題
            const cupertino.Text(
              '還沒有任何訊息',
              style: cupertino.TextStyle(
                fontSize: constants.Constants.FONT_SIZE_LARGE,
                fontWeight: cupertino.FontWeight.bold,
                color: cupertino.CupertinoColors.secondaryLabel,
              ),
            ),
            const cupertino.SizedBox(height: constants.Constants.SPACING_SMALL),
            // STEP 01.02.03: 空狀態描述
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

    // STEP 01.03: 訊息列表
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

  /// STEP 01: 建立訊息卡片的方法
  /// 建立單個訊息的卡片 UI，包含內容、操作按鈕和時間資訊
  cupertino.Widget _buildMessageCard(message_model.MessageModel message) {
    // STEP 01.01: 判斷是否為正在編輯的訊息
    final isEditing = _editingMessageId == message.id;

    return cupertino.Container(
      // STEP 01.02: 設定卡片的外邊距
      margin: const cupertino.EdgeInsets.only(
        bottom: constants.Constants.SPACING_MEDIUM,
      ),
      // STEP 01.03: 設定卡片的內邊距
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      // STEP 01.04: 設定卡片的裝飾樣式
      decoration: cupertino.BoxDecoration(
        color: isEditing
            ? cupertino.CupertinoColors.systemBlue.withValues(alpha: 0.1)
            : cupertino.CupertinoColors.systemBackground,
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.BORDER_RADIUS_LARGE,
        ),
        border: cupertino.Border.all(
          color: isEditing
              ? cupertino.CupertinoColors.systemBlue.withValues(alpha: 0.3)
              : cupertino.CupertinoColors.systemGrey4,
          width: isEditing ? 2 : 1,
        ),
        boxShadow: isEditing
            ? [
                cupertino.BoxShadow(
                  color: cupertino.CupertinoColors.systemBlue.withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 8,
                  offset: const cupertino.Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: cupertino.Column(
        crossAxisAlignment: cupertino.CrossAxisAlignment.start,
        children: [
          // STEP 01.05: 訊息標頭（包含 ID、編輯和刪除按鈕）
          cupertino.Row(
            children: [
              // STEP 01.05.01: 訊息圖示
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
              // STEP 01.05.02: 訊息 ID 顯示
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
              // STEP 01.05.03: 編輯按鈕
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
              // STEP 01.05.04: 刪除按鈕
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

          // STEP 01.06: 訊息內容區域
          cupertino.Container(
            padding: const cupertino.EdgeInsets.all(
              constants.Constants.SPACING_MEDIUM,
            ),
            decoration: cupertino.BoxDecoration(
              color: isEditing
                  ? cupertino.CupertinoColors.systemBlue.withValues(alpha: 0.05)
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

          // STEP 01.07: 時間資訊區域
          cupertino.Row(
            children: [
              // STEP 01.07.01: 建立時間
              _buildTimeInfo('建立', message.createdAt),
              const cupertino.SizedBox(
                width: constants.Constants.SPACING_LARGE,
              ),
              // STEP 01.07.02: 更新時間
              _buildTimeInfo('更新', message.updatedAt ?? message.createdAt),
            ],
          ),
        ],
      ),
    );
  }

  /// STEP 01: 建立時間資訊的方法
  /// 建立時間標籤和時間值的顯示元件
  cupertino.Widget _buildTimeInfo(String label, DateTime dateTime) {
    return cupertino.Column(
      crossAxisAlignment: cupertino.CrossAxisAlignment.start,
      children: [
        // STEP 01.01: 時間標籤
        cupertino.Text(
          label,
          style: const cupertino.TextStyle(
            fontSize: constants.Constants.FONT_SIZE_SMALL,
            color: cupertino.CupertinoColors.tertiaryLabel,
          ),
        ),
        // STEP 01.02: 時間值（格式化顯示）
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

  /// STEP 01: 建立統計資訊卡片的方法
  /// 顯示資料庫統計資訊和重新載入按鈕
  cupertino.Widget _buildStatsCard() {
    return cupertino.Container(
      // STEP 01.01: 設定統計卡片的內邊距
      padding: const cupertino.EdgeInsets.all(
        constants.Constants.SPACING_LARGE,
      ),
      // STEP 01.02: 設定統計卡片的裝飾樣式
      decoration: cupertino.BoxDecoration(
        color: cupertino.CupertinoColors.systemGreen.withValues(alpha: 0.1),
        borderRadius: cupertino.BorderRadius.circular(
          constants.Constants.BORDER_RADIUS_LARGE,
        ),
        border: cupertino.Border.all(
          color: cupertino.CupertinoColors.systemGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: cupertino.Row(
        children: [
          // STEP 01.03: 統計圖示
          const cupertino.Icon(
            cupertino.CupertinoIcons.chart_bar,
            color: cupertino.CupertinoColors.systemGreen,
            size: constants.Constants.ICON_SIZE_MEDIUM,
          ),
          const cupertino.SizedBox(width: constants.Constants.SPACING_MEDIUM),
          // STEP 01.04: 統計資訊文字區域
          cupertino.Expanded(
            child: cupertino.Column(
              crossAxisAlignment: cupertino.CrossAxisAlignment.start,
              children: [
                // STEP 01.04.01: 統計標題
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
                // STEP 01.04.02: 統計內容
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
          // STEP 01.05: 重新載入按鈕
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
  // STEP 01: 主要的 build 方法
  // 建立整個頁面的 UI 結構
  cupertino.Widget build(cupertino.BuildContext context) {
    return cupertino.SafeArea(
      child: cupertino.ListView(
        // STEP 01.01: 設定頁面的內邊距
        padding: const cupertino.EdgeInsets.all(
          constants.Constants.SPACING_LARGE,
        ),
        children: [
          // STEP 01.02: 頁面標題區域
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

          // STEP 01.03: 統計卡片
          _buildStatsCard(),
          const cupertino.SizedBox(height: constants.Constants.SPACING_LARGE),

          // STEP 01.04: 輸入區域
          _buildInputArea(),
          const cupertino.SizedBox(
            height: constants.Constants.SPACING_EXTRA_LARGE,
          ),

          // STEP 01.05: 訊息列表標題
          cupertino.Row(
            children: [
              // STEP 01.05.01: 列表圖示
              const cupertino.Icon(
                cupertino.CupertinoIcons.list_bullet,
                color: cupertino.CupertinoColors.systemBlue,
                size: constants.Constants.ICON_SIZE_MEDIUM,
              ),
              const cupertino.SizedBox(
                width: constants.Constants.SPACING_SMALL,
              ),
              // STEP 01.05.02: 列表標題
              const cupertino.Text(
                '儲存的訊息',
                style: cupertino.TextStyle(
                  fontSize: constants.Constants.FONT_SIZE_LARGE,
                  fontWeight: cupertino.FontWeight.bold,
                  color: cupertino.CupertinoColors.label,
                ),
              ),
              const cupertino.Spacer(),
              // STEP 01.05.03: 載入中的活動指示器
              if (_isLoading && _messages.isNotEmpty)
                const cupertino.CupertinoActivityIndicator(radius: 10),
            ],
          ),
          const cupertino.SizedBox(height: constants.Constants.SPACING_MEDIUM),

          // STEP 01.06: 訊息列表
          _buildMessagesList(),
        ],
      ),
    );
  }
}
