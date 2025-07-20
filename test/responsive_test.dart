import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/utils/screen_util.dart';
import 'package:hello_world/widgets/responsive_layout.dart';

void main() {
  group('ScreenUtil 測試', () {
    testWidgets('ScreenUtil 初始化測試', (WidgetTester tester) async {
      // STEP 01: 建立測試應用程式
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              // STEP 01.01: 初始化ScreenUtil
              ScreenUtil.instance.init(context);
              
              // STEP 01.02: 驗證初始化後的值
              expect(ScreenUtil.instance.screenWidth, greaterThan(0));
              expect(ScreenUtil.instance.screenHeight, greaterThan(0));
              expect(ScreenUtil.instance.pixelRatio, greaterThan(0));
              
              return const Text('測試');
            },
          ),
        ),
      );
    });

    testWidgets('裝置類型判斷測試', (WidgetTester tester) async {
      // STEP 02: 測試不同螢幕尺寸的裝置類型判斷
      
      // STEP 02.01: 手機尺寸測試 (375x667)
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              ScreenUtil.instance.init(context);
              expect(ScreenUtil.instance.deviceType, DeviceType.mobile);
              return const Text('手機測試');
            },
          ),
        ),
      );

      // STEP 02.02: 平板尺寸測試 (768x1024)
      tester.binding.window.physicalSizeTestValue = const Size(768, 1024);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              ScreenUtil.instance.init(context);
              expect(ScreenUtil.instance.deviceType, DeviceType.tablet);
              return const Text('平板測試');
            },
          ),
        ),
      );

      // STEP 02.03: 桌面尺寸測試 (1200x800)
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              ScreenUtil.instance.init(context);
              expect(ScreenUtil.instance.deviceType, DeviceType.desktop);
              return const Text('桌面測試');
            },
          ),
        ),
      );

      // STEP 02.04: 重置螢幕尺寸
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('響應式計算測試', (WidgetTester tester) async {
      // STEP 03: 設定測試螢幕尺寸
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              // STEP 03.01: 初始化ScreenUtil
              ScreenUtil.instance.init(context);
              
              // STEP 03.02: 測試響應式寬度計算
              double width50 = ScreenUtil.instance.responsiveWidth(50);
              expect(width50, 187.5); // 375 * 0.5
              
              // STEP 03.03: 測試響應式高度計算
              double height30 = ScreenUtil.instance.responsiveHeight(30);
              expect(height30, 200.1); // 667 * 0.3
              
              // STEP 03.04: 測試響應式字體大小
              double fontSize = ScreenUtil.instance.responsiveFontSize(16);
              expect(fontSize, 16.0); // 375/375 * 16 = 16
              
              // STEP 03.05: 測試響應式間距
              double spacing = ScreenUtil.instance.responsiveSpacing(12);
              expect(spacing, 12.0); // 手機裝置不放大
              
              return const Text('計算測試');
            },
          ),
        ),
      );

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('方向檢測測試', (WidgetTester tester) async {
      // STEP 04: 測試直向模式
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              ScreenUtil.instance.init(context);
              expect(ScreenUtil.instance.isPortrait, true);
              expect(ScreenUtil.instance.isLandscape, false);
              return const Text('直向測試');
            },
          ),
        ),
      );

      // STEP 04.01: 測試橫向模式
      tester.binding.window.physicalSizeTestValue = const Size(667, 375);
      
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              ScreenUtil.instance.init(context);
              expect(ScreenUtil.instance.isPortrait, false);
              expect(ScreenUtil.instance.isLandscape, true);
              return const Text('橫向測試');
            },
          ),
        ),
      );

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('網格列數計算測試', (WidgetTester tester) async {
      // STEP 05: 測試手機直向模式
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              ScreenUtil.instance.init(context);
              expect(ScreenUtil.instance.getGridColumns(), 2);
              return const Text('手機直向');
            },
          ),
        ),
      );

      // STEP 05.01: 測試手機橫向模式
      tester.binding.window.physicalSizeTestValue = const Size(667, 375);
      
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              ScreenUtil.instance.init(context);
              expect(ScreenUtil.instance.getGridColumns(), 3);
              return const Text('手機橫向');
            },
          ),
        ),
      );

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });

  group('響應式Widget測試', () {
    testWidgets('ResponsiveText 測試', (WidgetTester tester) async {
      // STEP 06: 測試響應式文字組件
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Builder(
              builder: (context) {
                ScreenUtil.instance.init(context);
                return const ResponsiveText(
                  '測試文字',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                );
              },
            ),
          ),
        ),
      );

      // STEP 06.01: 驗證文字存在
      expect(find.text('測試文字'), findsOneWidget);
      
      // STEP 06.02: 驗證文字樣式
      final textWidget = tester.widget<Text>(find.text('測試文字'));
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('ResponsiveContainer 測試', (WidgetTester tester) async {
      // STEP 07: 測試響應式容器組件
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Builder(
              builder: (context) {
                ScreenUtil.instance.init(context);
                return ResponsiveContainer(
                  widthPercentage: 50,
                  heightPercentage: 30,
                  child: const Text('容器內容'),
                );
              },
            ),
          ),
        ),
      );

      // STEP 07.01: 驗證容器內容存在
      expect(find.text('容器內容'), findsOneWidget);
      
      // STEP 07.02: 驗證容器存在
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('ResponsiveLayout 測試', (WidgetTester tester) async {
      // STEP 08: 測試響應式佈局切換
      tester.binding.window.physicalSizeTestValue = const Size(375, 667); // 手機尺寸
      
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Builder(
              builder: (context) {
                ScreenUtil.instance.init(context);
                return const ResponsiveLayout(
                  mobile: Text('手機佈局'),
                  tablet: Text('平板佈局'),
                  desktop: Text('桌面佈局'),
                );
              },
            ),
          ),
        ),
      );

      // STEP 08.01: 驗證手機佈局顯示
      expect(find.text('手機佈局'), findsOneWidget);
      expect(find.text('平板佈局'), findsNothing);
      expect(find.text('桌面佈局'), findsNothing);

      // STEP 08.02: 切換到平板尺寸
      tester.binding.window.physicalSizeTestValue = const Size(768, 1024);
      
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Builder(
              builder: (context) {
                ScreenUtil.instance.init(context);
                return const ResponsiveLayout(
                  mobile: Text('手機佈局'),
                  tablet: Text('平板佈局'),
                  desktop: Text('桌面佈局'),
                );
              },
            ),
          ),
        ),
      );

      // STEP 08.03: 驗證平板佈局顯示
      expect(find.text('手機佈局'), findsNothing);
      expect(find.text('平板佈局'), findsOneWidget);
      expect(find.text('桌面佈局'), findsNothing);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('ResponsiveSpacing 測試', (WidgetTester tester) async {
      // STEP 09: 測試響應式間距組件
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Builder(
              builder: (context) {
                ScreenUtil.instance.init(context);
                return const Column(
                  children: [
                    Text('上方文字'),
                    ResponsiveSpacing(spacing: 16),
                    Text('下方文字'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // STEP 09.01: 驗證文字存在
      expect(find.text('上方文字'), findsOneWidget);
      expect(find.text('下方文字'), findsOneWidget);
      
      // STEP 09.02: 驗證間距組件存在
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });

    testWidgets('OrientationListener 測試', (WidgetTester tester) async {
      // STEP 10: 測試方向監聽組件
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: OrientationListener(
              builder: (context, orientation) {
                return Text(
                  orientation == Orientation.portrait ? '直向模式' : '橫向模式',
                );
              },
            ),
          ),
        ),
      );

      // STEP 10.01: 驗證初始狀態（通常是直向）
      expect(find.text('直向模式'), findsOneWidget);
    });
  });

  group('響應式擴展方法測試', () {
    testWidgets('數字擴展方法測試', (WidgetTester tester) async {
      // STEP 11: 測試數字擴展方法
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              // STEP 11.01: 初始化ScreenUtil
              ScreenUtil.instance.init(context);
              
              // STEP 11.02: 測試擴展方法
              double width = 50.w;   // responsiveWidth
              double height = 30.h;  // responsiveHeight  
              double fontSize = 16.sp; // responsiveFontSize
              double spacing = 12.r;   // responsiveSpacing
              
              // STEP 11.03: 驗證計算結果有效
              expect(width, greaterThan(0));
              expect(height, greaterThan(0));
              expect(fontSize, greaterThan(0));
              expect(spacing, greaterThan(0));
              
              return const Text('擴展方法測試');
            },
          ),
        ),
      );
    });
  });
}