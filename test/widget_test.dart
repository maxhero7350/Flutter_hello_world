// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== FLUTTER TEST =====
import 'package:flutter_test/flutter_test.dart';

// ===== CUSTOM MAIN =====
import 'package:hello_world/main.dart' as main_app;

void main() {
  testWidgets('HelloWorld 登入頁面測試', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const main_app.HelloWorldApp());

    // Verify that login screen elements are displayed.
    expect(find.text('HelloWorld'), findsOneWidget);
    expect(find.text('歡迎使用第一個Flutter專案'), findsOneWidget);
    expect(find.text('請輸入使用者名稱'), findsOneWidget);
    expect(find.text('請輸入密碼'), findsOneWidget);
    expect(find.text('登入'), findsOneWidget);
    expect(find.text('快速體驗（無需輸入）'), findsOneWidget);

    // Verify that the heart icon is displayed.
    expect(find.byIcon(cupertino.CupertinoIcons.heart_fill), findsOneWidget);

    // Verify version info is displayed.
    expect(find.textContaining('Version'), findsOneWidget);
  });

  testWidgets('快速登入功能測試', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const main_app.HelloWorldApp());

    // Find and tap the quick login button.
    final quickLoginButton = find.text('快速體驗（無需輸入）');
    expect(quickLoginButton, findsOneWidget);

    await tester.tap(quickLoginButton);
    await tester.pumpAndSettle();

    // Verify that we navigated to main screen by checking for navigation bar and content.
    expect(find.byIcon(cupertino.CupertinoIcons.bars), findsOneWidget); // 側邊欄按鈕
    expect(find.text('歡迎來到A頁面！'), findsOneWidget); // A頁面歡迎文字
    expect(find.text('前往A1頁面'), findsOneWidget); // A1導航按鈕
    expect(
      find.byIcon(cupertino.CupertinoIcons.square_grid_2x2),
      findsAtLeastNWidgets(1),
    ); // A頁面圖標
  });

  testWidgets('側邊欄開關功能測試', (WidgetTester tester) async {
    // Build our app and navigate to main screen.
    await tester.pumpWidget(const main_app.HelloWorldApp());
    await tester.tap(find.text('快速體驗（無需輸入）'));
    await tester.pumpAndSettle();

    // Verify sidebar is initially closed.
    expect(find.text('歡迎使用 HelloWorld'), findsNothing);

    // Tap the sidebar button.
    await tester.tap(find.byIcon(cupertino.CupertinoIcons.bars));
    await tester.pumpAndSettle();

    // Verify sidebar is now open.
    expect(find.text('歡迎使用 HelloWorld'), findsOneWidget);
    expect(find.text('使用者'), findsOneWidget);
  });

  testWidgets('底部導航功能測試', (WidgetTester tester) async {
    // Build our app and navigate to main screen.
    await tester.pumpWidget(const main_app.HelloWorldApp());
    await tester.tap(find.text('快速體驗（無需輸入）'));
    await tester.pumpAndSettle();

    // Initially should be on A page.
    expect(find.text('歡迎來到A頁面！'), findsOneWidget);

    // Find bottom navigation buttons by text.
    final bPageButton = find
        .text('B頁面')
        .last; // Use .last to get the bottom nav button
    final cPageButton = find.text('C頁面').last;

    // Tap B page button.
    await tester.tap(bPageButton);
    await tester.pump(); // 只pump一次而不是pumpAndSettle
    await tester.pump(const Duration(milliseconds: 100)); // 等待一點時間讓資料庫載入
    expect(find.text('資料儲存功能'), findsOneWidget);

    // Tap C page button.
    await tester.tap(cPageButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100)); // 等待一點時間讓網路狀態初始化
    expect(find.text('API呼叫功能'), findsOneWidget);
  });
}
