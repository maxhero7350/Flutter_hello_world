# 📝 日誌框架遷移指南

## 🎯 目標
將專案中的 `print` 語句替換為結構化的日誌框架，提升程式碼品質和除錯能力。

## 📦 已安裝的套件
- **logger**: ^2.0.2+1 - 提供結構化日誌功能

## 🔧 日誌工具類別

### 檔案位置
- `lib/utils/logger_util.dart` - 主要日誌工具類別
- `lib/utils/logger_test.dart` - 日誌功能測試
- `lib/utils/logger_example.dart` - 使用範例

### 可用的日誌方法

#### 基本日誌級別
```dart
// 除錯資訊（僅在開發模式顯示）
LoggerUtil.debug('詳細的除錯資訊');

// 一般資訊
LoggerUtil.info('應用程式正常運作資訊');

// 警告資訊
LoggerUtil.warning('可能導致問題但不影響運作的情況');

// 錯誤資訊
LoggerUtil.error('錯誤但不影響應用程式繼續運作');

// 致命錯誤
LoggerUtil.fatal('導致應用程式無法繼續運作的嚴重錯誤');
```

#### 特殊用途日誌
```dart
// 網路相關
LoggerUtil.network('發送 API 請求到 /api/users');

// 資料庫相關
LoggerUtil.database('插入新記錄到 messages 表');

// 使用者操作相關
LoggerUtil.user('使用者點擊登入按鈕');
```

## 🔄 遷移步驟

### 步驟 1：導入日誌工具
```dart
import '../utils/logger_util.dart' as logger_util;
```

### 步驟 2：替換 print 語句

#### 舊方式（使用 print）
```dart
print('開始處理使用者資料');
try {
  // 處理邏輯
  print('處理完成');
} catch (e) {
  print('發生錯誤: $e');
}
```

#### 新方式（使用日誌框架）
```dart
logger_util.LoggerUtil.info('開始處理使用者資料');
try {
  // 處理邏輯
  logger_util.LoggerUtil.info('處理完成');
} catch (e) {
  logger_util.LoggerUtil.error('處理使用者資料時發生錯誤', e);
}
```

### 步驟 3：根據用途選擇適當的日誌級別

#### 網路請求
```dart
// 替換前
print('正在呼叫時間API: $url');

// 替換後
logger_util.LoggerUtil.network('正在呼叫時間API: $url');
```

#### 資料庫操作
```dart
// 替換前
print('插入新記錄到 messages 表');

// 替換後
logger_util.LoggerUtil.database('插入新記錄到 messages 表');
```

#### 使用者操作
```dart
// 替換前
print('使用者點擊登入按鈕');

// 替換後
logger_util.LoggerUtil.user('使用者點擊登入按鈕');
```

#### 錯誤處理
```dart
// 替換前
print('API 呼叫失敗: $error');

// 替換後
logger_util.LoggerUtil.error('API 呼叫失敗', error);
```

## 📊 日誌級別說明

| 級別 | 用途 | 範例 |
|------|------|------|
| `debug` | 詳細的除錯資訊 | 變數值、函式參數 |
| `info` | 一般資訊 | 操作開始/完成、狀態變更 |
| `warning` | 警告資訊 | 非關鍵錯誤、效能警告 |
| `error` | 錯誤資訊 | 操作失敗、異常情況 |
| `fatal` | 致命錯誤 | 應用程式崩潰、嚴重錯誤 |
| `network` | 網路相關 | API 請求、回應狀態 |
| `database` | 資料庫相關 | 查詢、插入、更新操作 |
| `user` | 使用者操作 | 按鈕點擊、表單提交 |

## 🎨 日誌輸出格式

日誌框架提供美化的輸出格式，包含：
- **時間戳**：顯示日誌記錄的時間
- **日誌級別**：用顏色區分不同級別
- **表情符號**：快速識別日誌類型
- **堆疊追蹤**：錯誤時顯示詳細的呼叫堆疊
- **方法資訊**：顯示呼叫日誌的方法名稱

### 輸出範例
```
[2024-01-15 10:30:45.123] INFO 🌐 NETWORK: 發送 API 請求到 /api/users
[2024-01-15 10:30:46.456] INFO 🌐 NETWORK: 收到回應，狀態碼: 200
[2024-01-15 10:30:46.789] ERROR ❌ 處理回應時發生錯誤
```

## 🔍 除錯技巧

### 1. 使用適當的日誌級別
```dart
// 開發階段：詳細資訊
logger_util.LoggerUtil.debug('變數值: $value');

// 生產階段：重要資訊
logger_util.LoggerUtil.info('操作完成');
```

### 2. 包含上下文資訊
```dart
// 好的做法
logger_util.LoggerUtil.error('API 呼叫失敗，URL: $url, 狀態碼: $statusCode', error);

// 不好的做法
logger_util.LoggerUtil.error('API 呼叫失敗', error);
```

### 3. 使用特殊用途日誌
```dart
// 網路相關使用 network
logger_util.LoggerUtil.network('發送請求到 $endpoint');

// 資料庫相關使用 database
logger_util.LoggerUtil.database('查詢使用者資料，條件: $condition');
```

## 🚀 效能考量

### 1. 除錯日誌
```dart
// 使用 assert 確保除錯日誌只在開發模式執行
logger_util.LoggerUtil.debug('詳細資訊: $data');
```

### 2. 字串格式化
```dart
// 好的做法：使用日誌框架的延遲評估
logger_util.LoggerUtil.debug('複雜計算結果: ${expensiveCalculation()}');

// 更好的做法：先檢查是否為除錯模式
if (logger_util.LoggerUtil.isDebugMode) {
  logger_util.LoggerUtil.debug('複雜計算結果: ${expensiveCalculation()}');
}
```

## 📋 遷移檢查清單

- [ ] 導入日誌工具類別
- [ ] 替換所有 `print` 語句
- [ ] 根據用途選擇適當的日誌級別
- [ ] 添加錯誤和堆疊追蹤資訊
- [ ] 測試日誌輸出格式
- [ ] 檢查效能影響
- [ ] 更新文件說明

## 🎯 預期效果

### 改善前
- 無法區分日誌級別
- 難以過濾和搜尋
- 缺乏結構化資訊
- 生產環境效能影響

### 改善後
- 清晰的日誌級別分類
- 易於過濾和搜尋
- 結構化的日誌輸出
- 可配置的日誌級別
- 美化的輸出格式
- 更好的除錯體驗

## 📚 相關檔案

- `lib/utils/logger_util.dart` - 日誌工具類別
- `lib/utils/logger_test.dart` - 功能測試
- `lib/utils/logger_example.dart` - 使用範例
- `pubspec.yaml` - 套件依賴配置 