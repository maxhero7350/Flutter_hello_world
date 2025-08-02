# Flutter STEP 註解規則

## 基本原則
在 Flutter 開發中，為函式加上詳細的 STEP 格式註解，以便清楚說明每個函式的執行邏輯。

## STEP 註解編號規則

### 1. 函式級別編號
- **每個函式都從 STEP 01 開始編號**
- 不同函式之間不連續編號
- 每個函式都是獨立的 STEP 01 開始

### 2. 子步驟編號規則
- 使用多階層編號格式：STEP 01.01, STEP 01.02, STEP 01.01.01 等
- 最多支援 4 階層編號：STEP 01.01.01.01
- 根據程式碼的縮排層級增加階層

### 3. 編號範例
```dart
// 函式 A
void functionA() {
  // STEP 01: 第一個步驟
  // STEP 02: 第二個步驟
  if (condition) {
    // STEP 02.01: 條件內的步驟
    // STEP 02.02: 另一個條件步驟
  }
}

// 函式 B（重新從 STEP 01 開始）
void functionB() {
  // STEP 01: 函式 B 的第一個步驟
  // STEP 02: 函式 B 的第二個步驟
}
```

## 註解內容規則

### 1. 語言要求
- 使用繁體中文
- 描述清楚且具體

### 2. 註解內容
- 說明該步驟的功能和目的
- 解釋重要的邏輯判斷
- 說明狀態變更和副作用

### 3. 不適用範圍
- **類別成員變數不需要 STEP 註解**
- **Functional Component 本身不需要 STEP 註解**
- 只有函式內部的程式碼才需要 STEP 註解

## 實際應用範例

### 生命週期函式
```dart
@override
// 元件初始化方法
void initState() {
  super.initState();
  // STEP 01: 初始化時載入所有訊息
  _loadMessages();
  // STEP 02: 添加文字輸入監聽器
  _messageController.addListener(() {
    setState(() {});
  });
}

@override
// 元件銷毀方法
void dispose() {
  // STEP 01: 清理文字控制器資源
  _messageController.dispose();
  super.dispose();
}
```

### 業務邏輯函式
```dart
/// 載入所有訊息的方法
Future<void> _loadMessages() async {
  // STEP 01: 設定載入狀態為 true
  setState(() {
    _isLoading = true;
  });
  
  try {
    // STEP 02: 呼叫資料庫服務取得所有訊息
    final messages = await _databaseService.getAllMessages();
    // STEP 02: 更新狀態並關閉載入中狀態
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
  } catch (e) {
    // STEP 03: 錯誤處理
    setState(() {
      _isLoading = false;
    });
    _showErrorDialog('載入訊息失敗', e.toString());
  }
}
```

### UI 建構函式
```dart
/// 建立輸入區域的方法
cupertino.Widget _buildInputArea() {
  return cupertino.Container(
    // STEP 01: 設定容器的內邊距
    padding: const cupertino.EdgeInsets.all(
      constants.Constants.SPACING_LARGE,
    ),
    // STEP 02: 設定容器的裝飾樣式
    decoration: cupertino.BoxDecoration(
      color: cupertino.CupertinoColors.systemBackground,
      borderRadius: cupertino.BorderRadius.circular(
        constants.Constants.BORDER_RADIUS_LARGE,
      ),
    ),
    child: cupertino.Column(
      children: [
        // STEP 03: 標題列
        cupertino.Row(
          children: [
            // STEP 03.01: 圖示
            cupertino.Icon(cupertino.CupertinoIcons.plus),
            // STEP 03.02: 標題文字
            cupertino.Text('新增訊息'),
          ],
        ),
        // STEP 04: 文字輸入框
        cupertino.CupertinoTextField(
          controller: _messageController,
          placeholder: '請輸入您的訊息...',
        ),
      ],
    ),
  );
}
```

## 常見錯誤與修正

### ❌ 錯誤的編號方式
```dart
void functionA() {
  // STEP 01: 第一個步驟
}

void functionB() {
  // STEP 02: 第二個函式的步驟 ← 錯誤！
}
```

### ✅ 正確的編號方式
```dart
void functionA() {
  // STEP 01: 第一個步驟
}

void functionB() {
  // STEP 01: 第二個函式的步驟 ← 正確！
}
```

## 注意事項
1. 每個函式都是獨立的 STEP 01 開始
2. 保持註解的一致性和可讀性
3. 避免過度註解，重點說明關鍵邏輯
4. 配合 Flutter Import 別名規則使用
5. 使用繁體中文撰寫註解

## 更新記錄
- 2024年8月2日：建立 STEP 註解規則文件
- 修正函式編號規則，確保每個函式都從 STEP 01 開始
- 加入實際應用範例和常見錯誤說明 # Flutter STEP 註解規則