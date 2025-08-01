// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;

// ===== THIRD PARTY =====
import 'package:provider/provider.dart' as provider;

// ===== CUSTOM WIDGETS =====
import '../widgets/responsive_layout.dart' as responsive_widgets;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;
import '../utils/screen_util.dart' as screen_util;

// ===== CUSTOM PROVIDERS =====
import '../providers/providers.dart' as providers;

/// 登入頁面 - HelloWorld應用程式的主要入口介面
///
/// 這個檔案是應用程式的登入頁面，負責：
/// 1. 提供用戶登入介面
/// 2. 處理登入驗證邏輯
/// 3. 實現響應式設計（支援手機、平板、桌面）
/// 4. 管理登入狀態和錯誤處理
/// 5. 提供快速體驗功能
/// 6. 整合Provider狀態管理
///
/// 設計特色：
/// - 採用iOS風格設計（Cupertino元件）
/// - 支援多裝置響應式佈局
/// - 完整的錯誤處理和用戶提示
/// - 載入狀態指示器
/// - 無障礙功能支援
class LoginScreen extends cupertino.StatefulWidget {
  const LoginScreen({super.key});

  @override
  cupertino.State<LoginScreen> createState() => _LoginScreenState();
}

/// 登入頁面狀態管理類別
///
/// 這個類別負責管理登入頁面的所有狀態和邏輯，包括：
/// - 輸入欄位控制器管理
/// - 登入邏輯處理
/// - UI狀態管理
/// - 響應式佈局控制
/// - 錯誤處理和用戶提示
/// - 資源釋放管理
class _LoginScreenState extends cupertino.State<LoginScreen> {
  // STEP 01: 初始化輸入欄位控制器
  // 這些控制器用於管理使用者名稱和密碼輸入欄位的狀態
  // 包括文字內容、游標位置、選擇範圍等
  final cupertino.TextEditingController _usernameController =
      cupertino.TextEditingController();
  final cupertino.TextEditingController _passwordController =
      cupertino.TextEditingController();

  @override
  void dispose() {
    // STEP 01: 釋放資源
    // 在Widget銷毀時釋放控制器資源，避免記憶體洩漏
    // 這是Flutter中重要的資源管理實踐
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// STEP 02: 處理登入邏輯
  ///
  /// 這個方法負責處理用戶的登入請求，包括：
  /// - 輸入驗證
  /// - 狀態管理
  /// - 錯誤處理
  /// - 頁面導航
  /// - 載入狀態控制
  ///
  /// 參數：
  /// - context: 建構上下文，用於存取Provider和導航
  ///
  /// 返回：
  /// - Future<void>: 非同步操作，支援載入狀態管理
  Future<void> _handleLogin(cupertino.BuildContext context) async {
    // STEP 02.01: 取得Provider實例
    // 從Provider架構中取得應用程式狀態和用戶狀態的實例
    // listen: false 表示不需要監聽這些Provider的變化
    final appStateProvider = provider.Provider.of<providers.AppStateProvider>(
      context,
      listen: false,
    );
    final userProvider = provider.Provider.of<providers.UserProvider>(
      context,
      listen: false,
    );

    // STEP 02.02: 檢查輸入欄位
    // 驗證使用者名稱是否為空，提供用戶友善的錯誤提示
    if (_usernameController.text.trim().isEmpty) {
      _showAlert(context, '請輸入使用者名稱');
      return;
    }

    // 驗證密碼是否為空，確保用戶輸入完整的登入資訊
    if (_passwordController.text.trim().isEmpty) {
      _showAlert(context, '請輸入密碼');
      return;
    }

    // STEP 02.03: 設定載入狀態
    // 開始登入流程，顯示載入指示器
    // 清除之前的錯誤狀態，準備新的登入嘗試
    appStateProvider.setLoading(true);
    appStateProvider.clearError();

    try {
      // STEP 02.04: 模擬登入延遲
      // 模擬網路請求延遲，提供真實的用戶體驗
      // 在實際應用中，這裡會是真正的API呼叫
      await Future.delayed(const Duration(milliseconds: 1000));

      // STEP 02.05: 執行登入
      // 使用用戶輸入的使用者名稱進行登入
      // 更新用戶狀態，記錄登入資訊
      userProvider.login(_usernameController.text.trim());

      // STEP 02.06: 更新應用程式狀態
      // 設定當前頁面為主頁面
      // 標記應用程式已不是首次執行
      appStateProvider.setCurrentPage('main');
      appStateProvider.setFirstRun(false);

      // STEP 02.07: 導航到主頁面
      // 使用pushReplacementNamed進行頁面導航
      // 檢查Widget是否仍然掛載，避免在已銷毀的Widget上操作
      if (mounted) {
        material.Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      // STEP 02.08: 處理錯誤
      // 捕獲登入過程中的任何錯誤
      // 更新應用程式錯誤狀態
      // 顯示用戶友善的錯誤提示
      appStateProvider.setError('登入過程發生錯誤：$e');
      if (mounted) {
        _showAlert(context, '登入過程發生錯誤：$e');
      }
    } finally {
      // STEP 02.09: 重置載入狀態
      // 無論成功或失敗，都要重置載入狀態
      // 隱藏載入指示器，讓用戶可以重新嘗試
      appStateProvider.setLoading(false);
    }
    return null;
  }

  /// STEP 03: 處理快速登入
  ///
  /// 這個方法提供快速體驗功能，允許用戶無需輸入即可進入應用程式
  /// 主要用於演示和測試目的，提升用戶體驗
  ///
  /// 參數：
  /// - context: 建構上下文，用於存取Provider和導航
  void _handleQuickLogin(material.BuildContext context) {
    // STEP 03.01: 取得Provider實例
    // 取得用戶狀態和應用程式狀態的Provider實例
    final userProvider = provider.Provider.of<providers.UserProvider>(
      context,
      listen: false,
    );
    final appStateProvider = provider.Provider.of<providers.AppStateProvider>(
      context,
      listen: false,
    );

    // STEP 03.02: 使用預設使用者名稱登入
    // 使用常數中定義的預設使用者名稱
    // 跳過輸入驗證，直接進行登入
    userProvider.login(constants.Constants.DEFAULT_USERNAME);

    // STEP 03.03: 更新應用程式狀態
    // 設定當前頁面為主頁面
    // 標記應用程式已不是首次執行
    appStateProvider.setCurrentPage('main');
    appStateProvider.setFirstRun(false);

    // STEP 03.04: 導航到主頁面
    // 直接導航到主頁面，無需等待載入
    material.Navigator.pushReplacementNamed(context, '/main');
  }

  /// STEP 04: 顯示提示對話框
  ///
  /// 這個方法用於顯示用戶提示和錯誤訊息
  /// 使用iOS風格的CupertinoAlertDialog，提供一致的用戶體驗
  ///
  /// 參數：
  /// - context: 建構上下文，用於顯示對話框
  /// - message: 要顯示的訊息內容
  void _showAlert(material.BuildContext context, String message) {
    // STEP 04.01: 顯示提示對話框
    // 使用showCupertinoDialog顯示iOS風格的對話框
    // 提供統一的用戶介面體驗
    cupertino.showCupertinoDialog(
      context: context,
      builder: (material.BuildContext context) {
        return cupertino.CupertinoAlertDialog(
          title: const material.Text('提示'),
          content: material.Text(message),
          actions: [
            cupertino.CupertinoDialogAction(
              child: const material.Text('確定'),
              onPressed: () {
                material.Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 05: 建立響應式輸入欄位
  ///
  /// 這個方法建立可重用的響應式輸入欄位Widget
  /// 支援不同類型的輸入（文字、密碼、數字等）
  /// 自動適配不同裝置尺寸
  ///
  /// 參數：
  /// - placeholder: 輸入欄位的提示文字
  /// - controller: 文字控制器，管理輸入內容
  /// - isPassword: 是否為密碼欄位（預設false）
  /// - keyboardType: 鍵盤類型（預設文字鍵盤）
  /// - context: 建構上下文，用於響應式設計
  ///
  /// 返回：
  /// - Widget: 響應式輸入欄位Widget
  material.Widget _buildInputField({
    required String placeholder,
    required material.TextEditingController controller,
    bool isPassword = false,
    material.TextInputType keyboardType = material.TextInputType.text,
    required material.BuildContext context,
  }) {
    // STEP 05.01: 初始化ScreenUtil
    // 初始化響應式設計工具，獲取當前裝置資訊
    screen_util.ScreenUtil.instance.init(context);

    // STEP 05.02: 返回響應式輸入欄位UI
    // 使用ResponsiveContainer包裝，確保在不同裝置上都有良好的顯示效果
    return responsive_widgets.ResponsiveContainer(
      margin: material.EdgeInsets.only(bottom: 12.r),
      child: cupertino.CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: isPassword,
        keyboardType: keyboardType,
        textInputAction: isPassword
            ? material.TextInputAction.done
            : material.TextInputAction.next,
        padding: screen_util.ScreenUtil.instance.responsivePadding(all: 16),
        decoration: material.BoxDecoration(
          color: cupertino.CupertinoColors.systemBackground,
          border: material.Border.all(
            color: cupertino.CupertinoColors.systemGrey4,
            width: 1.0,
          ),
          borderRadius: screen_util.ScreenUtil.instance.responsiveBorderRadius(
            8,
          ),
        ),
        style: material.TextStyle(fontSize: 16.sp),
        onSubmitted: isPassword ? (_) => _handleLogin(context) : null,
      ),
    );
  }

  /// STEP 06: 建立響應式登入按鈕
  ///
  /// 這個方法建立主要的登入按鈕Widget
  /// 支援載入狀態顯示，提供視覺回饋
  /// 自動適配不同裝置尺寸
  ///
  /// 參數：
  /// - context: 建構上下文，用於響應式設計
  /// - isLoading: 是否處於載入狀態
  ///
  /// 返回：
  /// - Widget: 響應式登入按鈕Widget
  material.Widget _buildLoginButton(
    material.BuildContext context,
    bool isLoading,
  ) {
    // STEP 06.01: 返回響應式登入按鈕UI
    // 使用ResponsiveContainer確保按鈕在不同裝置上都有適當的尺寸
    return responsive_widgets.ResponsiveContainer(
      widthPercentage: 100,
      heightPercentage:
          screen_util.ScreenUtil.instance.deviceType ==
              screen_util.DeviceType.mobile
          ? 6
          : 5,
      margin: material.EdgeInsets.only(top: 16.r),
      child: cupertino.CupertinoButton(
        color: cupertino.CupertinoColors.activeBlue,
        borderRadius: screen_util.ScreenUtil.instance.responsiveBorderRadius(8),
        onPressed: isLoading ? null : () => _handleLogin(context),
        child: isLoading
            ? cupertino.CupertinoActivityIndicator(
                color: cupertino.CupertinoColors.white,
                radius: 12.r,
              )
            : responsive_widgets.ResponsiveText(
                '登入',
                fontSize: 16,
                fontWeight: material.FontWeight.w600,
                color: cupertino.CupertinoColors.white,
              ),
      ),
    );
  }

  /// STEP 07: 建立響應式快速登入按鈕
  ///
  /// 這個方法建立快速體驗按鈕Widget
  /// 提供次要的登入選項，提升用戶體驗
  /// 使用較淡的顏色，不搶走主要登入按鈕的注意力
  ///
  /// 參數：
  /// - context: 建構上下文，用於響應式設計
  ///
  /// 返回：
  /// - Widget: 響應式快速登入按鈕Widget
  material.Widget _buildQuickLoginButton(material.BuildContext context) {
    // STEP 07.01: 返回響應式快速登入按鈕UI
    // 使用ResponsiveContainer確保按鈕在不同裝置上都有適當的尺寸
    return responsive_widgets.ResponsiveContainer(
      widthPercentage: 100,
      margin: material.EdgeInsets.only(top: 16.r),
      child: cupertino.CupertinoButton(
        child: responsive_widgets.ResponsiveText(
          '快速體驗（無需輸入）',
          fontSize: 14,
          color: cupertino.CupertinoColors.systemGrey,
        ),
        onPressed: () => _handleQuickLogin(context),
      ),
    );
  }

  /// STEP 08: 建立主要應用程式標題區域
  ///
  /// 這個方法建立應用程式的標題區域Widget
  /// 包含應用程式圖標、名稱和副標題
  /// 使用響應式設計，在不同裝置上都有良好的顯示效果
  ///
  /// 返回：
  /// - Widget: 應用程式標題區域Widget
  material.Widget _buildAppHeader() {
    return responsive_widgets.ResponsiveContainer(
      child: material.Column(
        children: [
          // STEP 08.01: 應用程式圖標
          // 使用心形圖標作為應用程式的視覺識別
          // 使用響應式尺寸，在不同裝置上都有適當的大小
          material.Icon(
            cupertino.CupertinoIcons.heart_fill,
            size: screen_util.ScreenUtil.instance.responsiveIconSize(64),
            color: cupertino.CupertinoColors.systemRed,
          ),
          responsive_widgets.ResponsiveSpacing(spacing: 16),

          // STEP 08.02: 應用程式名稱
          // 顯示應用程式名稱，使用粗體字體強調
          // 使用系統標籤顏色，支援深色模式
          responsive_widgets.ResponsiveText(
            constants.Constants.APP_NAME,
            fontSize: 28,
            fontWeight: material.FontWeight.bold,
            color: cupertino.CupertinoColors.label,
          ),
          responsive_widgets.ResponsiveSpacing(spacing: 8),

          // STEP 08.03: 副標題
          // 顯示歡迎訊息，使用較小的字體和次要顏色
          // 置中對齊，提供良好的視覺層次
          responsive_widgets.ResponsiveText(
            '歡迎使用第一個Flutter專案',
            fontSize: 16,
            color: cupertino.CupertinoColors.secondaryLabel,
            textAlign: material.TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// STEP 09: 建立響應式登入表單
  ///
  /// 這個方法建立完整的登入表單Widget
  /// 包含所有輸入欄位和按鈕
  /// 使用卡片式設計，提供清晰的視覺分離
  /// 支援響應式設計，在不同裝置上都有良好的顯示效果
  ///
  /// 參數：
  /// - context: 建構上下文，用於響應式設計
  /// - isLoading: 是否處於載入狀態
  ///
  /// 返回：
  /// - Widget: 響應式登入表單Widget
  material.Widget _buildLoginForm(
    material.BuildContext context,
    bool isLoading,
  ) {
    return responsive_widgets.ResponsiveContainer(
      maxWidth:
          screen_util.ScreenUtil.instance.deviceType ==
              screen_util.DeviceType.mobile
          ? null
          : 400,
      padding: screen_util.ScreenUtil.instance.responsivePadding(all: 24),
      decoration: material.BoxDecoration(
        color: cupertino.CupertinoColors.systemBackground,
        borderRadius: screen_util.ScreenUtil.instance.responsiveBorderRadius(
          16,
        ),
        boxShadow: [
          material.BoxShadow(
            color: cupertino.CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 10,
            offset: const material.Offset(0, 2),
          ),
        ],
      ),
      child: material.Column(
        children: [
          // STEP 09.01: 使用者名稱輸入欄
          // 建立使用者名稱輸入欄位，使用文字鍵盤
          _buildInputField(
            placeholder: '請輸入使用者名稱',
            controller: _usernameController,
            keyboardType: material.TextInputType.text,
            context: context,
          ),

          // STEP 09.02: 密碼輸入欄
          // 建立密碼輸入欄位，隱藏輸入內容
          _buildInputField(
            placeholder: '請輸入密碼',
            controller: _passwordController,
            isPassword: true,
            context: context,
          ),

          // STEP 09.03: 登入按鈕
          // 建立主要登入按鈕，支援載入狀態
          _buildLoginButton(context, isLoading),

          // STEP 09.04: 快速登入按鈕
          // 建立快速體驗按鈕，提供便捷的登入選項
          _buildQuickLoginButton(context),
        ],
      ),
    );
  }

  @override
  material.Widget build(material.BuildContext context) {
    // STEP 10: 初始化響應式設計
    // 在build方法開始時初始化響應式設計工具
    // 確保所有子Widget都能獲得正確的裝置資訊
    screen_util.ScreenUtil.instance.init(context);

    // STEP 10.01: 使用Consumer監聽AppStateProvider
    // 使用Consumer監聽應用程式狀態變化
    // 當載入狀態改變時，自動重建UI
    return provider.Consumer<providers.AppStateProvider>(
      builder: (context, appStateProvider, child) {
        // STEP 10.02: 從Provider取得載入狀態
        // 從AppStateProvider取得當前的載入狀態
        // 用於控制登入按鈕的顯示和互動
        final isLoading = appStateProvider.isLoading;

        // STEP 10.03: 使用響應式佈局包裝器
        // 使用OrientationListener監聽螢幕方向變化
        // 當方向改變時，自動調整佈局
        return material.OrientationBuilder(
          builder: (context, orientation) {
            return cupertino.CupertinoPageScaffold(
              backgroundColor:
                  cupertino.CupertinoColors.systemGroupedBackground,
              child: material.SafeArea(
                child: responsive_widgets.ResponsiveLayout(
                  // STEP 10.04: 手機版佈局
                  // 為手機裝置提供垂直排列的佈局
                  // 標題在上方，表單在下方
                  mobile: _buildMobileLayout(context, isLoading),

                  // STEP 10.05: 平板版佈局
                  // 為平板裝置提供左右分欄的佈局
                  // 左側標題，右側表單
                  tablet: _buildTabletLayout(context, isLoading),

                  // STEP 10.06: 桌面版佈局（fallback到平板佈局）
                  // 桌面版使用平板版的佈局作為fallback
                  // 確保在所有裝置上都有良好的顯示效果
                  desktop: _buildTabletLayout(context, isLoading),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// STEP 11: 手機版佈局
  ///
  /// 這個方法建立手機裝置專用的佈局
  /// 使用垂直排列，適合較小的螢幕
  /// 標題區域在上方，登入表單在中間，版本資訊在下方
  ///
  /// 參數：
  /// - context: 建構上下文，用於響應式設計
  /// - isLoading: 是否處於載入狀態
  ///
  /// 返回：
  /// - Widget: 手機版佈局Widget
  material.Widget _buildMobileLayout(
    material.BuildContext context,
    bool isLoading,
  ) {
    return responsive_widgets.ResponsiveContainer(
      padding: screen_util.ScreenUtil.instance.responsivePadding(all: 24),
      child: material.Column(
        mainAxisAlignment: material.MainAxisAlignment.center,
        crossAxisAlignment: material.CrossAxisAlignment.center,
        children: [
          // STEP 11.01: 應用程式標題區域
          // 在手機版佈局中，標題區域位於頂部
          // 包含圖標、應用程式名稱和副標題
          _buildAppHeader(),
          responsive_widgets.ResponsiveSpacing(spacing: 32),

          // STEP 11.02: 登入表單
          // 登入表單位於中間位置
          // 包含所有輸入欄位和按鈕
          _buildLoginForm(context, isLoading),
          responsive_widgets.ResponsiveSpacing(spacing: 24),

          // STEP 11.03: 版本資訊
          // 版本資訊位於底部
          // 使用較小的字體和次要顏色，不搶走主要內容的注意力
          responsive_widgets.ResponsiveText(
            'Version ${constants.Constants.APP_VERSION}',
            fontSize: 12,
            color: cupertino.CupertinoColors.tertiaryLabel,
          ),
        ],
      ),
    );
  }

  /// STEP 12: 平板版佈局
  ///
  /// 這個方法建立平板裝置專用的佈局
  /// 使用左右分欄設計，充分利用較大的螢幕空間
  /// 左側顯示標題區域，右側顯示登入表單
  ///
  /// 參數：
  /// - context: 建構上下文，用於響應式設計
  /// - isLoading: 是否處於載入狀態
  ///
  /// 返回：
  /// - Widget: 平板版佈局Widget
  material.Widget _buildTabletLayout(
    material.BuildContext context,
    bool isLoading,
  ) {
    return responsive_widgets.ResponsiveContainer(
      padding: screen_util.ScreenUtil.instance.responsivePadding(all: 40),
      child: material.Row(
        children: [
          // STEP 12.01: 左側：應用程式標題區域
          // 左側區域包含應用程式標題和版本資訊
          // 使用Expanded確保適當的空間分配
          // 根據螢幕方向調整flex比例
          material.Expanded(
            flex: screen_util.ScreenUtil.instance.isLandscape ? 1 : 2,
            child: material.Column(
              mainAxisAlignment: material.MainAxisAlignment.center,
              children: [
                _buildAppHeader(),
                responsive_widgets.ResponsiveSpacing(spacing: 32),
                responsive_widgets.ResponsiveText(
                  'Version ${constants.Constants.APP_VERSION}',
                  fontSize: 12,
                  color: cupertino.CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
          ),

          // 水平間距，分隔左右兩個區域
          responsive_widgets.ResponsiveSpacing(
            spacing: 40,
            direction: material.Axis.horizontal,
          ),

          // STEP 12.02: 右側：登入表單
          // 右側區域包含登入表單
          // 使用Expanded確保適當的空間分配
          // 使用Center確保表單在區域內居中顯示
          material.Expanded(
            flex: 1,
            child: material.Center(child: _buildLoginForm(context, isLoading)),
          ),
        ],
      ),
    );
  }
}
