# HelloWorld Flutter 專案結構

本文檔說明HelloWorld Flutter專案的整體資料夾結構和組織原則。

## 📁 專案結構總覽

```
lib/
├── main.dart                    # 應用程式入口點
├── models/                      # 資料模型
│   └── README.md               # 模型使用說明
├── providers/                   # 狀態管理
│   └── README.md               # Provider使用說明
├── screens/                     # 頁面畫面
│   └── README.md               # 頁面架構說明
├── widgets/                     # 可重用UI組件
│   └── README.md               # Widget組件說明
├── services/                    # 服務層
│   └── README.md               # 服務架構說明
└── utils/                       # 工具函式和常數
    └── README.md               # 工具使用說明
```

## 🎯 架構設計原則

### 1. 分層架構 (Layered Architecture)
- **Presentation Layer**: `screens/` + `widgets/`
- **Business Logic Layer**: `providers/`
- **Data Layer**: `models/` + `services/`
- **Utility Layer**: `utils/`

### 2. 單一職責原則 (Single Responsibility Principle)
- 每個資料夾負責特定的功能領域
- 每個檔案只包含相關的邏輯
- 避免過度耦合

### 3. 依賴注入 (Dependency Injection)
- 使用Provider進行依賴管理
- Service層提供統一的介面
- 便於測試和模組化

## 🔄 資料流向

```
UI Layer (screens/widgets)
    ↕
State Management (providers)
    ↕
Service Layer (services)
    ↕
Data Models (models)
    ↕
External Sources (API/Database)
```

## 📋 開發指南

### 添加新功能時的步驟：
1. **定義資料模型** → `models/`
2. **建立服務層** → `services/`
3. **實作狀態管理** → `providers/`
4. **設計UI組件** → `widgets/`
5. **組合頁面** → `screens/`

### 命名規範：
- **檔案名稱**: 小寫加底線 `user_model.dart`
- **類別名稱**: 大寫開頭 `UserModel`
- **方法名稱**: 駝峰式 `getUserData()`
- **常數名稱**: 大寫加底線 `API_BASE_URL`

## 🧪 測試策略

- **單元測試**: 測試`models/`, `services/`, `utils/`
- **Widget測試**: 測試`widgets/`
- **整合測試**: 測試完整的功能流程
- **Provider測試**: 測試狀態管理邏輯

## 📦 相關依賴

此專案結構配合以下主要套件：
- `provider` - 狀態管理
- `sqflite` - 本地資料庫
- `http` - API呼叫
- `shared_preferences` - 本地存儲
- `connectivity_plus` - 網路狀態檢測

---

**建立日期**: 2024年  
**版本**: v1.0  
**維護者**: HelloWorld開發團隊 