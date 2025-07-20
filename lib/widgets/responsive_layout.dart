import 'package:flutter/cupertino.dart';
import '../utils/screen_util.dart';

/// 響應式佈局Widget
/// 根據螢幕尺寸和方向提供不同的佈局
class ResponsiveLayout extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? landscape;
  final Widget? portrait;

  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.landscape,
    this.portrait,
  });

  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    ScreenUtil.instance.init(context);
    
    // STEP 02: 優先檢查方向特定佈局
    if (ScreenUtil.instance.isLandscape && landscape != null) {
      return landscape!;
    }
    if (ScreenUtil.instance.isPortrait && portrait != null) {
      return portrait!;
    }
    
    // STEP 03: 根據裝置類型返回適當的佈局
    switch (ScreenUtil.instance.deviceType) {
      case DeviceType.mobile:
        return mobile ?? _getDefaultWidget();
      case DeviceType.tablet:
        return tablet ?? mobile ?? _getDefaultWidget();
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? _getDefaultWidget();
    }
  }

  /// STEP 04: 取得預設Widget
  Widget _getDefaultWidget() {
    // STEP 04.01: 返回空的Container作為fallback
    return const SizedBox.shrink();
  }
}

/// 響應式容器Widget
/// 提供響應式的容器尺寸和樣式
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? widthPercentage;
  final double? heightPercentage;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.widthPercentage,
    this.heightPercentage,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    ScreenUtil.instance.init(context);
    
    // STEP 02: 計算響應式尺寸
    double? width = widthPercentage != null 
        ? ScreenUtil.instance.responsiveWidth(widthPercentage!) 
        : null;
    double? height = heightPercentage != null 
        ? ScreenUtil.instance.responsiveHeight(heightPercentage!) 
        : null;
    
    // STEP 03: 應用最大尺寸限制
    if (maxWidth != null && width != null) {
      width = width > maxWidth! ? maxWidth : width;
    }
    if (maxHeight != null && height != null) {
      height = height > maxHeight! ? maxHeight : height;
    }
    
    // STEP 04: 構建容器
    return Container(
      width: width,
      height: height,
      padding: padding != null 
          ? EdgeInsets.only(
              top: ScreenUtil.instance.responsiveSpacing(padding!.top),
              bottom: ScreenUtil.instance.responsiveSpacing(padding!.bottom),
              left: ScreenUtil.instance.responsiveSpacing(padding!.left),
              right: ScreenUtil.instance.responsiveSpacing(padding!.right),
            )
          : null,
      margin: margin != null 
          ? EdgeInsets.only(
              top: ScreenUtil.instance.responsiveSpacing(margin!.top),
              bottom: ScreenUtil.instance.responsiveSpacing(margin!.bottom),
              left: ScreenUtil.instance.responsiveSpacing(margin!.left),
              right: ScreenUtil.instance.responsiveSpacing(margin!.right),
            )
          : null,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// 響應式文字Widget
/// 根據螢幕尺寸自動調整字體大小
class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? lineHeight;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    ScreenUtil.instance.init(context);
    
    // STEP 02: 計算響應式字體大小
    double responsiveFontSize = ScreenUtil.instance.responsiveFontSize(fontSize);
    
    // STEP 03: 構建文字Widget
    return Text(
      text,
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: fontWeight,
        color: color,
        height: lineHeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 響應式間距Widget
/// 根據螢幕尺寸自動調整間距大小
class ResponsiveSpacing extends StatelessWidget {
  final double spacing;
  final Axis direction;

  const ResponsiveSpacing({
    super.key,
    required this.spacing,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    ScreenUtil.instance.init(context);
    
    // STEP 02: 計算響應式間距
    double responsiveSpacing = ScreenUtil.instance.responsiveSpacing(spacing);
    
    // STEP 03: 根據方向返回間距Widget
    if (direction == Axis.vertical) {
      return SizedBox(height: responsiveSpacing);
    } else {
      return SizedBox(width: responsiveSpacing);
    }
  }
}

/// 響應式網格Widget
/// 根據螢幕尺寸自動調整網格列數
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? aspectRatio;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.aspectRatio = 1.0,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    ScreenUtil.instance.init(context);
    
    // STEP 02: 取得響應式列數
    int columns = ScreenUtil.instance.getGridColumns();
    
    // STEP 03: 計算響應式間距
    double gridSpacing = spacing != null 
        ? ScreenUtil.instance.responsiveSpacing(spacing!) 
        : 8.0;
    
    // STEP 04: 構建網格視圖
    return GridView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
        childAspectRatio: aspectRatio!,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// 螢幕方向變化監聽Widget
class OrientationListener extends StatelessWidget {
  final Widget Function(BuildContext context, Orientation orientation) builder;

  const OrientationListener({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // STEP 01: 使用OrientationBuilder監聽方向變化
    return OrientationBuilder(
      builder: (context, orientation) {
        // STEP 02: 更新ScreenUtil
        ScreenUtil.instance.init(context);
        // STEP 03: 調用builder回調
        return builder(context, orientation);
      },
    );
  }
}