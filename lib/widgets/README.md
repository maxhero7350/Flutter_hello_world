# Widgets 資料夾

此資料夾包含可重用的UI組件。

## 用途
- 定義可在多個頁面使用的UI元件
- 提高程式碼重用性
- 保持UI一致性

## 計劃包含的Widget
- **CustomAppBar** - 自定義標頭列
- **CustomSidebar** - 自定義側邊欄
- **CustomBottomNavBar** - 自定義底部導航列
- **MessageCard** - 訊息卡片（B頁面使用）
- **TimeDisplay** - 時間顯示組件（C頁面使用）
- **LoadingIndicator** - 載入指示器
- **ErrorWidget** - 錯誤提示組件

## Widget設計原則
- 單一職責：每個Widget只負責一個功能
- 可配置：通過參數自定義外觀和行為
- 可重用：可在不同頁面中使用

## 命名規範
- 檔案名稱：`custom_app_bar.dart`
- 類別名稱：`CustomAppBar`
- 繼承：`StatelessWidget` 或 `StatefulWidget` 