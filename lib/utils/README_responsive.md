# 響應式設計實作說明

## 📱 概述

本專案實作了完整的響應式設計架構，支援不同螢幕尺寸和裝置類型，提供最佳的用戶體驗。

## 🏗️ 架構組成

### 1. ScreenUtil 工具類
**檔案位置**：`lib/utils/screen_util.dart`

**核心功能**：
- 螢幕尺寸檢測和計算
- 裝置類型判斷（手機/平板/桌面）
- 響應式尺寸轉換
- 方向感知功能

**主要方法**：
```dart
// 初始化
ScreenUtil.instance.init(context);

// 響應式尺寸
double width = ScreenUtil.instance.responsiveWidth(80); // 80%寬度
double height = ScreenUtil.instance.responsiveHeight(50); // 50%高度
double fontSize = ScreenUtil.instance.responsiveFontSize(16);
double spacing = ScreenUtil.instance.responsiveSpacing(12);

// 裝置類型判斷
DeviceType deviceType = ScreenUtil.instance.deviceType;
bool isLandscape = ScreenUtil.instance.isLandscape;

// 便捷擴展方法
double width = 80.w;    // 80%寬度
double height = 50.h;   // 50%高度
double fontSize = 16.sp; // 響應式字體
double spacing = 12.r;   // 響應式間距
```

### 2. 響應式Widget組件
**檔案位置**：`lib/widgets/responsive_layout.dart`

#### ResponsiveLayout
```dart
ResponsiveLayout(
  mobile: MobileWidget(),
  tablet: TabletWidget(), 
  desktop: DesktopWidget(),
  landscape: LandscapeWidget(),
  portrait: PortraitWidget(),
)
```

#### ResponsiveContainer
```dart
ResponsiveContainer(
  widthPercentage: 80,
  heightPercentage: 60,
  maxWidth: 400,
  padding: EdgeInsets.all(16),
  child: Content(),
)
```

#### ResponsiveText
```dart
ResponsiveText(
  '響應式文字',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.black,
)
```

#### ResponsiveGrid
```dart
ResponsiveGrid(
  children: widgets,
  spacing: 8,
  aspectRatio: 1.0,
)
```

## 📱 裝置類型適配

### 手機 (< 600px)
- **導航**：底部導航 + 側邊欄modal
- **佈局**：單列垂直佈局
- **側邊欄寬度**：70%螢幕寬度
- **字體縮放**：基準尺寸

### 平板 (600px - 1024px)
- **導航**：固定側邊欄 + 底部導航
- **佈局**：雙列或多列佈局
- **側邊欄寬度**：320px固定寬度
- **字體縮放**：1.2倍

### 桌面 (> 1024px)
- **導航**：固定側邊欄 + 頂部導航
- **佈局**：多列網格佈局
- **側邊欄寬度**：350px固定寬度
- **字體縮放**：1.5倍

## 🔄 方向適配

### 直向模式 (Portrait)
- 標準垂直佈局
- 側邊欄為modal形式（手機）
- 網格列數較少

### 橫向模式 (Landscape)
- 水平展開佈局
- 側邊欄可能固定顯示
- 網格列數較多
- 導航列高度調整

## 🎯 已實作的響應式頁面

### ✅ LoginScreen
**特色**：
- 手機：垂直居中佈局
- 平板：左右分欄佈局（左側品牌，右側表單）
- 響應式表單寬度和間距
- 自適應字體和圖標大小

### ✅ MainScreen  
**特色**：
- 手機：底部導航 + modal側邊欄
- 平板/桌面：固定側邊欄 + 主內容區
- 響應式導航列
- 自適應佈局切換

### ✅ CustomSidebar
**特色**：
- 響應式寬度（手機70%，平板320px，桌面350px）
- 自適應圖標和字體大小
- 響應式間距和邊框圓角

### ✅ CustomBottomNavBar
**特色**：
- 響應式高度（手機8%，平板7%）
- 自適應圖標大小和間距
- 安全區域支援

## 📐 設計規範

### 斷點定義
```dart
enum DeviceType {
  mobile,   // < 600px
  tablet,   // 600px - 1024px  
  desktop,  // > 1024px
}
```

### 字體縮放
```dart
// 基準：iPhone 6/7/8 (375px)
double scaleFactor = screenWidth / 375;
double responsiveFontSize = fontSize * scaleFactor;
```

### 間距系統
```dart
// 基礎間距
mobile: spacing
tablet: spacing * 1.2
desktop: spacing * 1.5
```

### 圖標縮放
```dart
mobile: iconSize
tablet: iconSize * 1.3
desktop: iconSize * 1.6
```

## 🔧 使用最佳實踐

### 1. 初始化
每個頁面開始時調用：
```dart
@override
Widget build(BuildContext context) {
  ScreenUtil.instance.init(context);
  // ... 其他程式碼
}
```

### 2. 響應式尺寸
優先使用擴展方法：
```dart
// ✅ 推薦
Container(
  width: 80.w,
  height: 50.h,
  padding: EdgeInsets.all(16.r),
  child: Text('內容', style: TextStyle(fontSize: 16.sp)),
)

// ❌ 避免固定尺寸
Container(
  width: 300,
  height: 200,
  padding: EdgeInsets.all(16),
  child: Text('內容', style: TextStyle(fontSize: 16)),
)
```

### 3. 條件式佈局
```dart
if (ScreenUtil.instance.deviceType == DeviceType.mobile) {
  return MobileLayout();
} else {
  return TabletLayout();
}
```

### 4. 方向感知
```dart
OrientationListener(
  builder: (context, orientation) {
    return orientation == Orientation.portrait 
        ? PortraitLayout() 
        : LandscapeLayout();
  },
)
```

## 🚀 下一步擴展

### 計劃中的改進
1. **深色模式響應式調整**
2. **更多裝置類型支援**（折疊螢幕等）
3. **動態字體大小設定**
4. **無障礙功能增強**
5. **效能優化**（建議的重新建構）

### 性能考量
- 使用`Selector`避免不必要的重新建構
- 快取響應式計算結果
- 適當使用`const`構造函數

## 📊 測試覆蓋

### 支援的螢幕尺寸
- **手機**：320px - 599px
- **小平板**：600px - 767px  
- **大平板**：768px - 1023px
- **桌面**：1024px+

### 支援的方向
- 直向（Portrait）
- 橫向（Landscape）

### 支援的平台
- iOS (所有尺寸)
- Android (所有尺寸)
- Web (響應式設計)

---

**實作狀態**: ✅ 完成基礎架構和核心頁面  
**下一階段**: 擴展到所有頁面並進行效能優化