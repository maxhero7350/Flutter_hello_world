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