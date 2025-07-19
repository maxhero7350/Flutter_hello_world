# Providers 資料夾

此資料夾包含所有Provider狀態管理類別。

## 用途
- 管理應用程式的全域狀態
- 提供跨頁面的資料共享
- 處理狀態變更通知

## 計劃包含的Provider
- **AppStateProvider** - 應用程式主要狀態管理
- **MessageProvider** - B頁面訊息資料管理
- **NetworkProvider** - 網路狀態管理（離線支援）
- **NavigationProvider** - 導航狀態管理

## Provider架構
- 使用`ChangeNotifier`作為基底類別
- 每個Provider負責特定功能領域
- 遵循單一職責原則

## 命名規範
- 檔案名稱：`app_state_provider.dart`
- 類別名稱：`AppStateProvider`
- 繼承：`extends ChangeNotifier` 