# Utils 資料夾

此資料夾包含通用的工具函式和常數。

## 用途
- 提供通用的輔助函式
- 定義應用程式常數
- 封裝常用的操作

## 計劃包含的工具
- **Constants** - 應用程式常數
  - API端點URL
  - 資料庫表名和欄位
  - UI相關常數（間距、字體大小等）
- **Validators** - 輸入驗證工具
  - 表單輸入驗證
  - 資料格式驗證
- **DateTimeHelper** - 日期時間工具
  - 日期格式化
  - 時間計算
- **NavigationHelper** - 導航輔助工具
  - 頁面跳轉封裝
  - 返回邏輯處理
- **DebugHelper** - 除錯輔助工具
  - 日誌輸出
  - 效能監測

## 工具設計原則
- 純函式：無副作用
- 靜態方法：無需實例化
- 可測試：易於單元測試

## 命名規範
- 檔案名稱：`constants.dart`
- 類別名稱：`Constants`
- 常數使用大寫：`const String API_BASE_URL`
- 函式使用駝峰式：`validateEmail()` 