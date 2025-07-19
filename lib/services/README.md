# Services 資料夾

此資料夾包含所有服務層邏輯。

## 用途
- 處理外部服務的整合
- 封裝資料庫操作
- 提供API呼叫功能
- 管理離線資料同步

## 計劃包含的Service
- **DatabaseService** - SQLite資料庫服務
  - 資料庫初始化
  - CRUD操作封裝
  - 資料庫遷移管理
- **ApiService** - API呼叫服務
  - HTTP請求封裝
  - 錯誤處理
  - 請求/回應攔截器
- **NetworkService** - 網路狀態服務
  - 網路連接監測
  - 離線/線上狀態管理
- **StorageService** - 本地存儲服務
  - SharedPreferences封裝
  - 設定參數管理

## 服務架構
- 使用單例模式（Singleton）
- 提供統一的錯誤處理
- 支援異步操作

## 命名規範
- 檔案名稱：`database_service.dart`
- 類別名稱：`DatabaseService`
- 方法名稱使用動詞開頭：`getData()`, `saveMessage()` 