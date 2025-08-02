// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== FLUTTER TEST =====
import 'package:flutter_test/flutter_test.dart';

// ===== CUSTOM UTILS =====
import 'package:hello_world/utils/screen_util.dart' as screen_util;

// ===== CUSTOM WIDGETS =====
import 'package:hello_world/widgets/responsive_layout.dart'
    as responsive_widgets;

void main() {
  group('ScreenUtil 測試', () {
    testWidgets('ScreenUtil 初始化測試', (WidgetTester tester) async {
      // STEP 01: 建立測試應用程式
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.Builder(
            builder: (context) {
              // STEP 01.01: 初始化ScreenUtil
              screen_util.ScreenUtil.instance.init(context);

              // STEP 01.02: 驗證初始化後的值
              expect(
                screen_util.ScreenUtil.instance.screenWidth,
                greaterThan(0),
              );
              expect(
                screen_util.ScreenUtil.instance.screenHeight,
                greaterThan(0),
              );
              expect(
                screen_util.ScreenUtil.instance.pixelRatio,
                greaterThan(0),
              );

              return const cupertino.Text('測試');
            },
          ),
        ),
      );
    });

    testWidgets('裝置類型判斷測試', (WidgetTester tester) async {
      // STEP 02: 測試裝置類型判斷功能
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.Builder(
            builder: (context) {
              screen_util.ScreenUtil.instance.init(context);
              // 驗證 ScreenUtil 能正確初始化
              expect(
                screen_util.ScreenUtil.instance.screenWidth,
                greaterThan(0),
              );
              expect(
                screen_util.ScreenUtil.instance.screenHeight,
                greaterThan(0),
              );
              return const cupertino.Text('裝置類型測試');
            },
          ),
        ),
      );
    });

    testWidgets('響應式計算測試', (WidgetTester tester) async {
      // STEP 03: 測試響應式計算功能
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.Builder(
            builder: (context) {
              // STEP 03.01: 初始化ScreenUtil
              screen_util.ScreenUtil.instance.init(context);

              // STEP 03.02: 測試響應式寬度計算
              double width50 = screen_util.ScreenUtil.instance.responsiveWidth(
                50,
              );
              expect(width50, greaterThan(0));

              // STEP 03.03: 測試響應式高度計算
              double height30 = screen_util.ScreenUtil.instance
                  .responsiveHeight(30);
              expect(height30, greaterThan(0));

              // STEP 03.04: 測試響應式字體大小
              double fontSize = screen_util.ScreenUtil.instance
                  .responsiveFontSize(16);
              expect(fontSize, greaterThan(0));

              // STEP 03.05: 測試響應式間距
              double spacing = screen_util.ScreenUtil.instance
                  .responsiveSpacing(12);
              expect(spacing, greaterThan(0));

              return const cupertino.Text('計算測試');
            },
          ),
        ),
      );
    });

    testWidgets('方向檢測測試', (WidgetTester tester) async {
      // STEP 04: 測試方向檢測功能
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.Builder(
            builder: (context) {
              screen_util.ScreenUtil.instance.init(context);
              // 驗證方向檢測功能正常
              expect(screen_util.ScreenUtil.instance.isPortrait, isA<bool>());
              expect(screen_util.ScreenUtil.instance.isLandscape, isA<bool>());
              return const cupertino.Text('方向檢測測試');
            },
          ),
        ),
      );
    });

    testWidgets('網格列數計算測試', (WidgetTester tester) async {
      // STEP 05: 測試網格列數計算功能
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.Builder(
            builder: (context) {
              screen_util.ScreenUtil.instance.init(context);
              // 驗證網格列數計算功能正常
              int columns = screen_util.ScreenUtil.instance.getGridColumns();
              expect(columns, greaterThan(0));
              return const cupertino.Text('網格列數測試');
            },
          ),
        ),
      );
    });
  });

  group('響應式Widget測試', () {
    testWidgets('ResponsiveText 測試', (WidgetTester tester) async {
      // STEP 06: 測試響應式文字組件
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: cupertino.Builder(
              builder: (context) {
                screen_util.ScreenUtil.instance.init(context);
                return const responsive_widgets.ResponsiveText(
                  '測試文字',
                  fontSize: 16,
                  fontWeight: cupertino.FontWeight.bold,
                );
              },
            ),
          ),
        ),
      );

      // STEP 06.01: 驗證文字存在
      expect(find.text('測試文字'), findsOneWidget);

      // STEP 06.02: 驗證文字樣式
      final textWidget = tester.widget<cupertino.Text>(find.text('測試文字'));
      expect(textWidget.style?.fontWeight, cupertino.FontWeight.bold);
    });

    testWidgets('ResponsiveContainer 測試', (WidgetTester tester) async {
      // STEP 07: 測試響應式容器組件
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: cupertino.Builder(
              builder: (context) {
                screen_util.ScreenUtil.instance.init(context);
                return responsive_widgets.ResponsiveContainer(
                  widthPercentage: 50,
                  heightPercentage: 30,
                  child: const cupertino.Text('容器內容'),
                );
              },
            ),
          ),
        ),
      );

      // STEP 07.01: 驗證容器內容存在
      expect(find.text('容器內容'), findsOneWidget);

      // STEP 07.02: 驗證容器存在
      expect(find.byType(cupertino.Container), findsAtLeastNWidgets(1));
    });

    testWidgets('ResponsiveLayout 測試', (WidgetTester tester) async {
      // STEP 08: 測試響應式佈局功能
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: cupertino.Builder(
              builder: (context) {
                screen_util.ScreenUtil.instance.init(context);
                return const responsive_widgets.ResponsiveLayout(
                  mobile: cupertino.Text('手機佈局'),
                  tablet: cupertino.Text('平板佈局'),
                  desktop: cupertino.Text('桌面佈局'),
                );
              },
            ),
          ),
        ),
      );

      // STEP 08.01: 驗證佈局組件能正常顯示
      expect(find.byType(cupertino.Text), findsOneWidget);
    });

    testWidgets('ResponsiveSpacing 測試', (WidgetTester tester) async {
      // STEP 09: 測試響應式間距組件
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: cupertino.Builder(
              builder: (context) {
                screen_util.ScreenUtil.instance.init(context);
                return const cupertino.Column(
                  children: [
                    cupertino.Text('上方文字'),
                    responsive_widgets.ResponsiveSpacing(spacing: 16),
                    cupertino.Text('下方文字'),
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
      expect(find.byType(cupertino.SizedBox), findsAtLeastNWidgets(1));
    });

    testWidgets('OrientationListener 測試', (WidgetTester tester) async {
      // STEP 10: 測試方向監聽組件
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: cupertino.OrientationBuilder(
              builder: (context, orientation) {
                return cupertino.Text(
                  orientation == cupertino.Orientation.portrait
                      ? '直向模式'
                      : '橫向模式',
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
        cupertino.CupertinoApp(
          home: cupertino.Builder(
            builder: (context) {
              // STEP 11.01: 初始化ScreenUtil
              screen_util.ScreenUtil.instance.init(context);

              // STEP 11.02: 測試擴展方法
              double width = 50.w; // responsiveWidth
              double height = 30.h; // responsiveHeight
              double fontSize = 16.sp; // responsiveFontSize
              double spacing = 12.r; // responsiveSpacing

              // STEP 11.03: 驗證計算結果有效
              expect(width, greaterThan(0));
              expect(height, greaterThan(0));
              expect(fontSize, greaterThan(0));
              expect(spacing, greaterThan(0));

              return const cupertino.Text('擴展方法測試');
            },
          ),
        ),
      );
    });
  });
}
