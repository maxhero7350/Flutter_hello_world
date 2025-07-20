# Provider 狀態管理架構

## 📋 概述

本專案使用 Provider 來實現全域狀態管理，將應用程式的狀態邏輯從 UI 組件中分離出來，實現更好的程式碼組織和可維護性。

## 🏗️ Provider 架構

### 1. AppStateProvider
**用途**：管理應用程式全域狀態
- `isLoading`: 全域載入狀態
- `errorMessage`: 錯誤訊息
- `isFirstRun`: 是否為首次執行
- `currentPage`: 當前頁面

**使用範例**：
```dart
// 取得狀態
final appState = context.watch<AppStateProvider>();
final isLoading = appState.isLoading;

// 更新狀態
context.read<AppStateProvider>().setLoading(true);
context.read<AppStateProvider>().setError('錯誤訊息');
```

### 2. UserProvider
**用途**：管理用戶相關狀態
- `username`: 用戶名稱
- `isLoggedIn`: 登入狀態
- `userPreference`: 用戶偏好設定
- `lastLoginTime`: 最後登入時間

**使用範例**：
```dart
// 用戶登入
context.read<UserProvider>().login('使用者名稱');

// 用戶登出
context.read<UserProvider>().logout();

// 取得用戶資訊
final user = context.watch<UserProvider>();
final displayName = user.getDisplayName();
```

### 3. NavigationProvider
**用途**：管理導航和頁面狀態
- `currentIndex`: 當前選中的頁面索引
- `isSidebarOpen`: 側邊欄開啟狀態
- `navigationHistory`: 導航歷史記錄
- `navigationCount`: 導航次數統計

**使用範例**：
```dart
// 切換頁面
context.read<NavigationProvider>().setCurrentIndex(1);

// 切換側邊欄
context.read<NavigationProvider>().toggleSidebar();

// 取得導航狀態
final nav = context.watch<NavigationProvider>();
final currentIndex = nav.currentIndex;
```

### 4. ThemeProvider
**用途**：管理主題和視覺設定
- `isDarkMode`: 深色模式狀態
- `textScaleFactor`: 文字縮放比例
- `fontFamily`: 字體家族
- `useSystemTheme`: 是否跟隨系統主題

**使用範例**：
```dart
// 切換深色模式
context.read<ThemeProvider>().toggleDarkMode();

// 設定文字縮放
context.read<ThemeProvider>().setTextScaleFactor(1.2);

// 取得當前主題
final theme = context.watch<ThemeProvider>();
final currentTheme = theme.currentTheme;
```

## 🔄 Consumer 模式

### 基本使用
```dart
Consumer<AppStateProvider>(
  builder: (context, appState, child) {
    return Text('載入狀態: ${appState.isLoading}');
  },
)
```

### 多個Provider監聽
```dart
Consumer2<UserProvider, NavigationProvider>(
  builder: (context, user, navigation, child) {
    return Text('用戶: ${user.username}, 頁面: ${navigation.currentIndex}');
  },
)
```

### 選擇性重新建構
```dart
Selector<AppStateProvider, bool>(
  selector: (context, appState) => appState.isLoading,
  builder: (context, isLoading, child) {
    return isLoading ? CircularProgressIndicator() : child!;
  },
  child: MyWidget(),
)
```

## 📱 已實作的頁面

### ✅ 已完成
- **MainScreen**: 使用NavigationProvider管理導航狀態
- **LoginScreen**: 使用AppStateProvider和UserProvider管理載入和用戶狀態

### 🔄 進行中
- **Screen A/B/C**: 部分狀態仍使用StatefulWidget，需要逐步遷移

## 🚀 下一步計畫

1. **完成所有頁面的Provider整合**
   - Screen A/B/C 的狀態遷移
   - 自定義Widget的Provider支援

2. **新增進階功能**
   - 狀態持久化（SharedPreferences整合）
   - 錯誤處理統一化
   - 載入狀態統一管理

3. **效能優化**
   - 使用Selector避免不必要的重新建構
   - Provider的依賴注入優化

## 📝 最佳實踐

1. **狀態讀取**：使用 `context.watch<T>()` 或 `Consumer<T>`
2. **狀態更新**：使用 `context.read<T>()` 避免不必要的重新建構
3. **一次性讀取**：使用 `Provider.of<T>(context, listen: false)`
4. **複雜狀態**：將相關狀態組合在同一個Provider中
5. **效能考量**：使用Selector進行選擇性監聽

## 🔧 除錯技巧

```dart
// 1. 除錯模式下列印狀態變化
class MyProvider extends ChangeNotifier {
  void updateState() {
    // ... 更新邏輯
    notifyListeners();
    if (kDebugMode) {
      print('State updated: $state');
    }
  }
}

// 2. 使用ProxyProvider進行依賴注入
ProxyProvider<UserProvider, NotificationProvider>(
  update: (context, userProvider, previous) =>
    NotificationProvider(userProvider.userId),
)
```