# Screens 資料夾

此資料夾包含所有頁面畫面。

## 用途
- 定義應用程式的各個頁面
- 包含頁面特定的UI邏輯
- 整合Provider和Widget組件

## 計劃包含的頁面
- **LoginScreen** - 登入頁面
- **MainScreen** - 主頁面（包含標頭列、側邊欄、底部導航）
- **ScreenA** - A頁面
  - **ScreenA1** - A頁面第一層跳轉
  - **ScreenA2** - A頁面第二層跳轉
- **ScreenB** - B頁面（輸入框與資料儲存）
- **ScreenC** - C頁面（API呼叫與時間顯示）

## 頁面架構
- 使用`CupertinoPageScaffold`作為基底
- 每個頁面都是獨立的Widget
- 遵循Cupertino設計規範

## 命名規範
- 檔案名稱：`login_screen.dart`
- 類別名稱：`LoginScreen`
- 繼承：`StatelessWidget` 或 `StatefulWidget` 