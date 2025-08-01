# Flutter Import 別名規則

## 基本原則
在 Flutter 開發中，所有 import 都應該加上適當的別名，以便清楚區分每個物件的來源。

## Import 別名命名規則

### 1. Flutter Core 別名
```dart
import 'package:flutter/material.dart' as material;
import 'package:flutter/cupertino.dart' as cupertino;
```

### 2. Third Party 別名
```dart
import 'package:provider/provider.dart' as provider;
```

### 3. Custom Widgets 別名
```dart
import '../widgets/responsive_layout.dart' as responsive_widgets;
```

### 4. Custom Utils 別名
```dart
import '../utils/constants.dart' as constants;
import '../utils/screen_util.dart' as screen_util;
```

### 5. Custom Providers 別名
```dart
import '../providers/providers.dart' as providers;
```

### 6. Screens 別名
```dart
import 'main_screen.dart' as main_screen;
```

## 程式碼使用規則

### Provider 類別使用
- `AppStateProvider` → `providers.AppStateProvider`
- `UserProvider` → `providers.UserProvider`

### 常數使用
- `Constants` → `constants.Constants`

### 響應式元件使用
- `ResponsiveContainer` → `responsive_widgets.ResponsiveContainer`
- `ResponsiveText` → `responsive_widgets.ResponsiveText`
- `ResponsiveSpacing` → `responsive_widgets.ResponsiveSpacing`
- `ResponsiveLayout` → `responsive_widgets.ResponsiveLayout`

### 工具類別使用
- `ScreenUtil` → `screen_util.ScreenUtil`
- `DeviceType` → `screen_util.DeviceType`

### 方向監聽使用
- `OrientationListener` → `material.OrientationBuilder`

## 好處
1. **清晰性**: 每個物件都有明確的來源標識
2. **可維護性**: 容易追蹤依賴關係
3. **避免衝突**: 防止不同模組間的命名衝突
4. **程式碼組織**: 更好的程式碼結構和可讀性

## 注意事項
- 別名應該具有描述性，清楚表達模組的用途
- 保持別名命名的一致性
- 在整個專案中統一使用這些別名規則

## 實際範例
參考 `lib/screens/login_screen.dart` 檔案，該檔案已經完整實施了這些規則。

## 實施步驟
1. 為所有 import 加上適當的別名
2. 修改程式碼中所有使用這些 import 的地方
3. 確保所有別名都有一致的命名規範
4. 測試程式碼確保功能正常運作

## 📋 更新記錄

### 2024年8月2日 - 全面實施引用規範
- ✅ **已完成**: 所有檔案已更新為使用命名空間別名
- ✅ **已完成**: 統一使用 `cupertino.` 前綴引用 Flutter Cupertino 元件
- ✅ **已完成**: 改善程式碼可讀性和維護性
- ✅ **已完成**: 避免命名衝突，提升程式碼品質

### 更新的檔案範圍
- `lib/main.dart` - 主要應用程式入口點
- `lib/providers/` - 所有狀態管理提供者
- `lib/screens/` - 所有頁面檔案
- `lib/services/` - API 和資料庫服務
- `lib/utils/` - 工具類別和常數
- `lib/widgets/` - 自訂元件

### 技術改進
- 使用 `withValues(alpha: value)` 替代已棄用的 `withOpacity()`
- 改善錯誤處理和測試覆蓋率
- 加入網路呼叫 spinner 功能提升使用者體驗 