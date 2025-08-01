// 導入Flutter的iOS風格元件庫，提供Cupertino風格的UI元件
// 包含CupertinoApp、CupertinoButton、CupertinoTextField等iOS風格元件
import 'package:flutter/cupertino.dart';

// 導入專案自定義的響應式工具類
// 提供螢幕尺寸檢測、響應式計算、裝置類型判斷等功能
import '../utils/screen_util.dart';

/// 響應式佈局Widget
/// 根據螢幕尺寸和方向提供不同的佈局
/// 類似於React中的ResponsiveContainer或React Native中的條件渲染
class ResponsiveLayout extends StatelessWidget {
  // 手機版佈局Widget，當裝置為手機時顯示
  // 使用可空類型（Widget?），表示可以不提供手機版佈局
  final Widget? mobile;
  
  // 平板版佈局Widget，當裝置為平板時顯示
  // 如果沒有提供平板版佈局，會fallback到手機版佈局
  final Widget? tablet;
  
  // 桌面版佈局Widget，當裝置為桌面時顯示
  // 如果沒有提供桌面版佈局，會fallback到平板版或手機版佈局
  final Widget? desktop;
  
  // 橫向模式佈局Widget，當螢幕為橫向時顯示
  // 優先級高於裝置類型，會覆蓋mobile/tablet/desktop設定
  final Widget? landscape;
  
  // 直向模式佈局Widget，當螢幕為直向時顯示
  // 優先級高於裝置類型，會覆蓋mobile/tablet/desktop設定
  final Widget? portrait;

  // 建構函數，定義ResponsiveLayout的參數
  // super.key: 傳遞給父類StatelessWidget的key，用於Widget識別和重建控制
  // 所有佈局參數都是可選的，使用this.語法直接賦值給final變數
  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.landscape,
    this.portrait,
  });

  // 覆寫StatelessWidget的build方法
  // 這是Widget的核心方法，負責建立和返回UI元件
  // BuildContext context: 提供Widget建構時需要的上下文資訊
  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    // 初始化響應式設計工具，獲取當前裝置的螢幕資訊
    // 包括螢幕尺寸、裝置類型、螢幕方向等
    ScreenUtil.instance.init(context);
    
    // STEP 02: 優先檢查方向特定佈局
    // 檢查是否為橫向模式且有提供橫向佈局
    // ScreenUtil.instance.isLandscape: 判斷當前是否為橫向模式
    // landscape != null: 檢查是否有提供橫向佈局Widget
    if (ScreenUtil.instance.isLandscape && landscape != null) {
      // 如果條件滿足，直接返回橫向佈局Widget
      // ! 是空值斷言操作符，告訴編譯器landscape不為null
      return landscape!;
    }
    
    // 檢查是否為直向模式且有提供直向佈局
    // ScreenUtil.instance.isPortrait: 判斷當前是否為直向模式
    // portrait != null: 檢查是否有提供直向佈局Widget
    if (ScreenUtil.instance.isPortrait && portrait != null) {
      // 如果條件滿足，直接返回直向佈局Widget
      return portrait!;
    }
    
    // STEP 03: 根據裝置類型返回適當的佈局
    // 使用switch語句根據裝置類型選擇佈局
    // ScreenUtil.instance.deviceType: 獲取當前裝置類型
    switch (ScreenUtil.instance.deviceType) {
      // 當裝置為手機時
      case DeviceType.mobile:
        // 返回手機版佈局，如果沒有提供則返回預設Widget
        // ?? 是空值合併操作符，如果mobile為null則使用_getDefaultWidget()
        return mobile ?? _getDefaultWidget();
      
      // 當裝置為平板時
      case DeviceType.tablet:
        // 優先返回平板版佈局，如果沒有則fallback到手機版，最後是預設Widget
        // 使用鏈式空值合併，確保總是有Widget返回
        return tablet ?? mobile ?? _getDefaultWidget();
      
      // 當裝置為桌面時
      case DeviceType.desktop:
        // 優先返回桌面版佈局，然後是平板版，最後是手機版，最後是預設Widget
        // 提供完整的fallback鏈，確保在所有情況下都有佈局顯示
        return desktop ?? tablet ?? mobile ?? _getDefaultWidget();
    }
  }

  /// STEP 04: 取得預設Widget
  /// 當沒有提供任何佈局時，返回一個預設的Widget
  /// 這是一個私有方法（以_開頭），只能在類別內部使用
  Widget _getDefaultWidget() {
    // STEP 04.01: 返回空的Container作為fallback
    // SizedBox.shrink(): 建立一個尺寸為0的Widget，不佔用任何空間
    // const: 編譯時常數，提高效能
    return const SizedBox.shrink();
  }
}

/// 響應式容器Widget
/// 提供響應式的容器尺寸和樣式
/// 類似於React中的ResponsiveContainer或CSS中的響應式div
class ResponsiveContainer extends StatelessWidget {
  // 子Widget，容器內要顯示的內容
  // required: 表示這個參數是必需的，使用時必須提供
  final Widget child;
  
  // 寬度百分比，0-100之間的數值
  // double?: 可空的double類型，表示可以不設定寬度
  final double? widthPercentage;
  
  // 高度百分比，0-100之間的數值
  // double?: 可空的double類型，表示可以不設定高度
  final double? heightPercentage;
  
  // 最大寬度限制，防止容器在大螢幕上過度放大
  // 當計算出的寬度超過此值時，會使用此值作為寬度
  final double? maxWidth;
  
  // 最大高度限制，防止容器在大螢幕上過度放大
  // 當計算出的高度超過此值時，會使用此值作為高度
  final double? maxHeight;
  
  // 內邊距，容器內部內容與邊界的距離
  // EdgeInsets?: 可空的EdgeInsets類型，表示可以不設定內邊距
  final EdgeInsets? padding;
  
  // 外邊距，容器外部與其他元素的距離
  // EdgeInsets?: 可空的EdgeInsets類型，表示可以不設定外邊距
  final EdgeInsets? margin;
  
  // 容器裝飾，包括背景色、邊框、圓角、陰影等
  // BoxDecoration?: 可空的BoxDecoration類型，表示可以不設定裝飾
  final BoxDecoration? decoration;
  
  // 對齊方式，控制子Widget在容器內的位置
  // AlignmentGeometry?: 可空的對齊類型，表示可以不設定對齊
  final AlignmentGeometry? alignment;

  // 建構函數，定義ResponsiveContainer的參數
  // required this.child: child是必需參數，其他都是可選的
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

  // 覆寫StatelessWidget的build方法
  // 負責建立響應式容器Widget
  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    // 初始化響應式設計工具，獲取當前裝置資訊
    ScreenUtil.instance.init(context);
    
    // STEP 02: 計算響應式尺寸
    // 計算寬度：如果有設定寬度百分比，則使用響應式計算
    // widthPercentage != null: 檢查是否有設定寬度百分比
    // ?: 三元運算符，條件為真時執行第一個表達式，否則執行第二個
    // ScreenUtil.instance.responsiveWidth(): 根據螢幕寬度計算響應式寬度
    // !: 空值斷言，告訴編譯器widthPercentage不為null
    double? width = widthPercentage != null 
        ? ScreenUtil.instance.responsiveWidth(widthPercentage!) 
        : null;
    
    // 計算高度：如果有設定高度百分比，則使用響應式計算
    // 邏輯與寬度計算相同
    double? height = heightPercentage != null 
        ? ScreenUtil.instance.responsiveHeight(heightPercentage!) 
        : null;
    
    // STEP 03: 應用最大尺寸限制
    // 檢查最大寬度限制
    // maxWidth != null && width != null: 確保兩個值都不為null
    // width > maxWidth!: 比較計算出的寬度與最大寬度
    // ?: 如果寬度超過最大寬度，則使用最大寬度，否則保持原寬度
    if (maxWidth != null && width != null) {
      width = width > maxWidth! ? maxWidth : width;
    }
    
    // 檢查最大高度限制，邏輯與寬度限制相同
    if (maxHeight != null && height != null) {
      height = height > maxHeight! ? maxHeight : height;
    }
    
    // STEP 04: 構建容器
    // 返回Container Widget，這是Flutter的基礎容器元件
    return Container(
      // 設定容器寬度
      width: width,
      // 設定容器高度
      height: height,
      // 設定內邊距，使用響應式計算
      // padding != null: 檢查是否有設定內邊距
      // ?: 如果有設定，則建立響應式EdgeInsets
      // EdgeInsets.only(): 建立只有特定方向邊距的EdgeInsets
      // ScreenUtil.instance.responsiveSpacing(): 將邊距值轉換為響應式邊距
      padding: padding != null 
          ? EdgeInsets.only(
              top: ScreenUtil.instance.responsiveSpacing(padding!.top),
              bottom: ScreenUtil.instance.responsiveSpacing(padding!.bottom),
              left: ScreenUtil.instance.responsiveSpacing(padding!.left),
              right: ScreenUtil.instance.responsiveSpacing(padding!.right),
            )
          : null,
      // 設定外邊距，邏輯與內邊距相同
      margin: margin != null 
          ? EdgeInsets.only(
              top: ScreenUtil.instance.responsiveSpacing(margin!.top),
              bottom: ScreenUtil.instance.responsiveSpacing(margin!.bottom),
              left: ScreenUtil.instance.responsiveSpacing(margin!.left),
              right: ScreenUtil.instance.responsiveSpacing(margin!.right),
            )
          : null,
      // 設定容器裝飾，直接使用傳入的decoration
      decoration: decoration,
      // 設定對齊方式，直接使用傳入的alignment
      alignment: alignment,
      // 設定子Widget，這是容器的內容
      child: child,
    );
  }
}

/// 響應式文字Widget
/// 根據螢幕尺寸自動調整字體大小
/// 類似於CSS中的rem單位或React Native中的響應式文字
class ResponsiveText extends StatelessWidget {
  // 要顯示的文字內容
  // final: 表示這個變數在初始化後不能修改
  final String text;
  
  // 基礎字體大小，會根據螢幕尺寸進行響應式調整
  // required: 表示這個參數是必需的
  final double fontSize;
  
  // 字體粗細，如FontWeight.bold、FontWeight.normal等
  // FontWeight?: 可空的FontWeight類型
  final FontWeight? fontWeight;
  
  // 文字顏色
  // Color?: 可空的Color類型
  final Color? color;
  
  // 文字對齊方式，如TextAlign.center、TextAlign.left等
  // TextAlign?: 可空的TextAlign類型
  final TextAlign? textAlign;
  
  // 最大行數限制，超過此行數的文字會被截斷
  // int?: 可空的int類型
  final int? maxLines;
  
  // 文字溢出處理方式，如TextOverflow.ellipsis（省略號）
  // TextOverflow?: 可空的TextOverflow類型
  final TextOverflow? overflow;
  
  // 行高，控制文字行與行之間的距離
  // double?: 可空的double類型
  final double? lineHeight;

  // 建構函數，定義ResponsiveText的參數
  // this.text: 位置參數，必須放在最前面
  // 其他參數都是命名參數，使用{}包圍
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

  // 覆寫StatelessWidget的build方法
  // 負責建立響應式文字Widget
  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    // 初始化響應式設計工具
    ScreenUtil.instance.init(context);
    
    // STEP 02: 計算響應式字體大小
    // 將基礎字體大小轉換為響應式字體大小
    // ScreenUtil.instance.responsiveFontSize(): 根據螢幕尺寸計算響應式字體大小
    double responsiveFontSize = ScreenUtil.instance.responsiveFontSize(fontSize);
    
    // STEP 03: 構建文字Widget
    // 返回Text Widget，這是Flutter的文字顯示元件
    return Text(
      // 要顯示的文字內容
      text,
      // 文字樣式設定
      style: TextStyle(
        // 響應式字體大小
        fontSize: responsiveFontSize,
        // 字體粗細
        fontWeight: fontWeight,
        // 文字顏色
        color: color,
        // 行高
        height: lineHeight,
      ),
      // 文字對齊方式
      textAlign: textAlign,
      // 最大行數
      maxLines: maxLines,
      // 文字溢出處理
      overflow: overflow,
    );
  }
}

/// 響應式間距Widget
/// 根據螢幕尺寸自動調整間距大小
/// 類似於CSS中的margin或React Native中的Spacer組件
class ResponsiveSpacing extends StatelessWidget {
  // 基礎間距大小，會根據螢幕尺寸進行響應式調整
  // required: 表示這個參數是必需的
  final double spacing;
  
  // 間距方向，Axis.vertical（垂直）或Axis.horizontal（水平）
  // 預設值為Axis.vertical
  final Axis direction;

  // 建構函數，定義ResponsiveSpacing的參數
  const ResponsiveSpacing({
    super.key,
    required this.spacing,
    this.direction = Axis.vertical,  // 預設為垂直方向
  });

  // 覆寫StatelessWidget的build方法
  // 負責建立響應式間距Widget
  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    // 初始化響應式設計工具
    ScreenUtil.instance.init(context);
    
    // STEP 02: 計算響應式間距
    // 將基礎間距轉換為響應式間距
    // ScreenUtil.instance.responsiveSpacing(): 根據螢幕尺寸計算響應式間距
    double responsiveSpacing = ScreenUtil.instance.responsiveSpacing(spacing);
    
    // STEP 03: 根據方向返回間距Widget
    // 檢查間距方向
    if (direction == Axis.vertical) {
      // 如果是垂直方向，返回高度為響應式間距的SizedBox
      // SizedBox: 建立固定尺寸的Widget
      return SizedBox(height: responsiveSpacing);
    } else {
      // 如果是水平方向，返回寬度為響應式間距的SizedBox
      return SizedBox(width: responsiveSpacing);
    }
  }
}

/// 響應式網格Widget
/// 根據螢幕尺寸自動調整網格列數
/// 類似於CSS Grid或React Native中的FlatList
class ResponsiveGrid extends StatelessWidget {
  // 網格中的子Widget列表
  // List<Widget>: Widget類型的列表
  // required: 表示這個參數是必需的
  final List<Widget> children;
  
  // 網格項目之間的間距
  // double?: 可空的double類型
  final double? spacing;
  
  // 網格項目的寬高比
  // 預設值為1.0，表示正方形
  final double? aspectRatio;
  
  // 滾動物理效果，控制滾動行為
  // ScrollPhysics?: 可空的ScrollPhysics類型
  final ScrollPhysics? physics;
  
  // 是否收縮包裝，控制GridView的高度行為
  // 預設值為false，表示GridView會佔用所有可用空間
  final bool shrinkWrap;

  // 建構函數，定義ResponsiveGrid的參數
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.aspectRatio = 1.0,  // 預設為正方形
    this.physics,
    this.shrinkWrap = false,  // 預設不收縮包裝
  });

  // 覆寫StatelessWidget的build方法
  // 負責建立響應式網格Widget
  @override
  Widget build(BuildContext context) {
    // STEP 01: 初始化ScreenUtil
    // 初始化響應式設計工具
    ScreenUtil.instance.init(context);
    
    // STEP 02: 取得響應式列數
    // 根據螢幕尺寸決定網格的列數
    // ScreenUtil.instance.getGridColumns(): 根據裝置類型返回適當的列數
    int columns = ScreenUtil.instance.getGridColumns();
    
    // STEP 03: 計算響應式間距
    // 如果有設定間距，則轉換為響應式間距
    // spacing != null: 檢查是否有設定間距
    // ?: 如果有設定，則使用響應式間距，否則使用預設值8.0
    double gridSpacing = spacing != null 
        ? ScreenUtil.instance.responsiveSpacing(spacing!) 
        : 8.0;
    
    // STEP 04: 構建網格視圖
    // 返回GridView.builder，這是Flutter的網格視圖元件
    return GridView.builder(
      // 滾動物理效果
      physics: physics,
      // 是否收縮包裝
      shrinkWrap: shrinkWrap,
      // 網格代理，定義網格的佈局規則
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // 交叉軸（水平方向）的列數
        crossAxisCount: columns,
        // 交叉軸方向的間距
        crossAxisSpacing: gridSpacing,
        // 主軸方向的間距
        mainAxisSpacing: gridSpacing,
        // 子項目的寬高比
        childAspectRatio: aspectRatio!,
      ),
      // 子項目的總數
      itemCount: children.length,
      // 子項目建構器，根據索引返回對應的Widget
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// 螢幕方向變化監聽Widget
/// 監聽螢幕方向變化並重新建構UI
/// 類似於React Native中的Dimensions.addEventListener
class OrientationListener extends StatelessWidget {
  // 建構器函數，接收context和orientation參數，返回Widget
  // Widget Function(...): 函數類型，表示這個函數返回Widget
  // required: 表示這個參數是必需的
  final Widget Function(BuildContext context, Orientation orientation) builder;

  // 建構函數，定義OrientationListener的參數
  const OrientationListener({
    super.key,
    required this.builder,
  });

  // 覆寫StatelessWidget的build方法
  // 負責建立方向監聽Widget
  @override
  Widget build(BuildContext context) {
    // STEP 01: 使用OrientationBuilder監聽方向變化
    // OrientationBuilder是Flutter內建的方向監聽Widget
    return OrientationBuilder(
      // builder回調函數，當方向改變時會被呼叫
      builder: (context, orientation) {
        // STEP 02: 更新ScreenUtil
        // 當方向改變時，重新初始化ScreenUtil
        ScreenUtil.instance.init(context);
        
        // STEP 03: 調用builder回調
        // 呼叫傳入的builder函數，傳遞context和orientation
        // 返回builder函數建立的Widget
        return builder(context, orientation);
      },
    );
  }
}