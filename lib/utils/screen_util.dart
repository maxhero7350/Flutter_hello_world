// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

/// 響應式設計工具類
/// 提供螢幕尺寸相關的工具方法和適配邏輯
class ScreenUtil {
  // STEP 01: 單例模式設計
  static ScreenUtil? _instance;
  static ScreenUtil get instance => _instance ??= ScreenUtil._();
  ScreenUtil._();

  // STEP 02: 初始化螢幕資訊
  late cupertino.MediaQueryData _mediaQueryData;
  late double _screenWidth;
  late double _screenHeight;
  late double _pixelRatio;
  late double _statusBarHeight;
  late double _bottomBarHeight;
  late cupertino.Orientation _orientation;

  /// STEP 03: 初始化方法
  void init(cupertino.BuildContext context) {
    // STEP 03.01: 取得MediaQuery資料
    _mediaQueryData = cupertino.MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _pixelRatio = _mediaQueryData.devicePixelRatio;
    _statusBarHeight = _mediaQueryData.padding.top;
    _bottomBarHeight = _mediaQueryData.padding.bottom;
    _orientation = _mediaQueryData.orientation;
  }

  /// STEP 04: 螢幕寬度
  double get screenWidth => _screenWidth;

  /// STEP 05: 螢幕高度
  double get screenHeight => _screenHeight;

  /// STEP 06: 像素比例
  double get pixelRatio => _pixelRatio;

  /// STEP 07: 狀態列高度
  double get statusBarHeight => _statusBarHeight;

  /// STEP 08: 底部安全區域高度
  double get bottomBarHeight => _bottomBarHeight;

  /// STEP 09: 螢幕方向
  cupertino.Orientation get orientation => _orientation;

  /// STEP 10: 是否為橫向模式
  bool get isLandscape => _orientation == cupertino.Orientation.landscape;

  /// STEP 11: 是否為直向模式
  bool get isPortrait => _orientation == cupertino.Orientation.portrait;

  /// STEP 12: 裝置類型判斷
  DeviceType get deviceType {
    // STEP 12.01: 根據螢幕寬度判斷裝置類型
    if (_screenWidth < 600) {
      return DeviceType.mobile;
    } else if (_screenWidth < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// STEP 13: 響應式寬度
  double responsiveWidth(double percentage) {
    // STEP 13.01: 根據百分比計算響應式寬度
    return _screenWidth * percentage / 100;
  }

  /// STEP 14: 響應式高度
  double responsiveHeight(double percentage) {
    // STEP 14.01: 根據百分比計算響應式高度
    return _screenHeight * percentage / 100;
  }

  /// STEP 15: 響應式字體大小
  double responsiveFontSize(double fontSize) {
    // STEP 15.01: 根據螢幕寬度調整字體大小
    double scaleFactor = _screenWidth / 375; // 以iPhone 6/7/8為基準
    return fontSize * scaleFactor;
  }

  /// STEP 16: 響應式間距
  double responsiveSpacing(double spacing) {
    // STEP 16.01: 根據螢幕尺寸調整間距
    if (deviceType == DeviceType.mobile) {
      return spacing;
    } else if (deviceType == DeviceType.tablet) {
      return spacing * 1.2;
    } else {
      return spacing * 1.5;
    }
  }

  /// STEP 17: 響應式圖標大小
  double responsiveIconSize(double iconSize) {
    // STEP 17.01: 根據裝置類型調整圖標大小
    switch (deviceType) {
      case DeviceType.mobile:
        return iconSize;
      case DeviceType.tablet:
        return iconSize * 1.3;
      case DeviceType.desktop:
        return iconSize * 1.6;
    }
  }

  /// STEP 18: 取得適合的列數
  int getGridColumns() {
    // STEP 18.01: 根據螢幕寬度和方向決定網格列數
    if (isLandscape) {
      // STEP 18.02: 橫向模式
      switch (deviceType) {
        case DeviceType.mobile:
          return 3;
        case DeviceType.tablet:
          return 4;
        case DeviceType.desktop:
          return 6;
      }
    } else {
      // STEP 18.03: 直向模式
      switch (deviceType) {
        case DeviceType.mobile:
          return 2;
        case DeviceType.tablet:
          return 3;
        case DeviceType.desktop:
          return 4;
      }
    }
  }

  /// STEP 19: 取得適合的側邊欄寬度
  double getSidebarWidth() {
    // STEP 19.01: 根據裝置類型決定側邊欄寬度
    switch (deviceType) {
      case DeviceType.mobile:
        return responsiveWidth(70); // 70%螢幕寬度
      case DeviceType.tablet:
        return 320; // 固定寬度
      case DeviceType.desktop:
        return 350; // 固定寬度
    }
  }

  /// STEP 20: 檢查是否為小螢幕
  bool get isSmallScreen => _screenWidth < 360;

  /// STEP 21: 檢查是否為大螢幕
  bool get isLargeScreen => _screenWidth > 414;

  /// STEP 22: 取得安全區域
  cupertino.EdgeInsets get safeAreaPadding => cupertino.EdgeInsets.only(
    top: _statusBarHeight,
    bottom: _bottomBarHeight,
  );

  /// STEP 23: 響應式EdgeInsets
  cupertino.EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    // STEP 23.01: 計算響應式padding值
    return cupertino.EdgeInsets.only(
      top: responsiveSpacing(top ?? vertical ?? all ?? 0),
      bottom: responsiveSpacing(bottom ?? vertical ?? all ?? 0),
      left: responsiveSpacing(left ?? horizontal ?? all ?? 0),
      right: responsiveSpacing(right ?? horizontal ?? all ?? 0),
    );
  }

  /// STEP 24: 響應式BorderRadius
  cupertino.BorderRadius responsiveBorderRadius(double radius) {
    // STEP 24.01: 根據裝置類型調整圓角半徑
    double responsiveRadius = responsiveSpacing(radius);
    return cupertino.BorderRadius.circular(responsiveRadius);
  }
}

/// 裝置類型枚舉
enum DeviceType {
  mobile, // 手機
  tablet, // 平板
  desktop, // 桌面
}

/// ScreenUtil擴展方法
extension ScreenUtilExtension on num {
  /// 響應式寬度
  double get w => ScreenUtil.instance.responsiveWidth(toDouble());

  /// 響應式高度
  double get h => ScreenUtil.instance.responsiveHeight(toDouble());

  /// 響應式字體大小
  double get sp => ScreenUtil.instance.responsiveFontSize(toDouble());

  /// 響應式間距
  double get r => ScreenUtil.instance.responsiveSpacing(toDouble());
}
