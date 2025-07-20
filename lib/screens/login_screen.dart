import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import '../utils/constants.dart';
import '../utils/screen_util.dart';
import '../widgets/responsive_layout.dart';
import 'main_screen.dart';

/// 登入頁面
/// 提供簡單的登入介面，不需要實際認證功能
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // STEP 01: 釋放資源
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// STEP 02: 處理登入邏輯
  Future<void> _handleLogin(BuildContext context) async {
    // STEP 02.01: 取得Provider實例
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // STEP 02.02: 檢查輸入欄位
    if (_usernameController.text.trim().isEmpty) {
      _showAlert(context, '請輸入使用者名稱');
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showAlert(context, '請輸入密碼');
      return;
    }

    // STEP 02.03: 設定載入狀態
    appStateProvider.setLoading(true);
    appStateProvider.clearError();

    try {
      // STEP 02.04: 模擬登入延遲
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // STEP 02.05: 執行登入
      userProvider.login(_usernameController.text.trim());
      
      // STEP 02.06: 更新應用程式狀態
      appStateProvider.setCurrentPage('main');
      appStateProvider.setFirstRun(false);

      // STEP 02.07: 導航到主頁面
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      // STEP 02.08: 處理錯誤
      appStateProvider.setError('登入過程發生錯誤：$e');
      if (mounted) {
        _showAlert(context, '登入過程發生錯誤：$e');
      }
    } finally {
      // STEP 02.09: 重置載入狀態
      appStateProvider.setLoading(false);
    }
  }

  /// STEP 03: 處理快速登入
  void _handleQuickLogin(BuildContext context) {
    // STEP 03.01: 取得Provider實例
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    
    // STEP 03.02: 使用預設使用者名稱登入
    userProvider.login(Constants.DEFAULT_USERNAME);
    
    // STEP 03.03: 更新應用程式狀態
    appStateProvider.setCurrentPage('main');
    appStateProvider.setFirstRun(false);
    
    // STEP 03.04: 導航到主頁面
    Navigator.pushReplacementNamed(context, '/main');
  }

  /// STEP 04: 顯示提示對話框
  void _showAlert(BuildContext context, String message) {
    // STEP 04.01: 顯示提示對話框
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('提示'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// STEP 05: 建立響應式輸入欄位
  Widget _buildInputField({
    required String placeholder,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required BuildContext context,
  }) {
    // STEP 05.01: 初始化ScreenUtil
    ScreenUtil.instance.init(context);
    
    // STEP 05.02: 返回響應式輸入欄位UI
    return ResponsiveContainer(
      margin: EdgeInsets.only(bottom: 12.r),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: isPassword,
        keyboardType: keyboardType,
        textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
        padding: ScreenUtil.instance.responsivePadding(all: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 1.0,
          ),
          borderRadius: ScreenUtil.instance.responsiveBorderRadius(8),
        ),
        style: TextStyle(
          fontSize: 16.sp,
        ),
        onSubmitted: isPassword ? (_) => _handleLogin(context) : null,
      ),
    );
  }

  /// STEP 06: 建立響應式登入按鈕
  Widget _buildLoginButton(BuildContext context, bool isLoading) {
    // STEP 06.01: 返回響應式登入按鈕UI
    return ResponsiveContainer(
      widthPercentage: 100,
      heightPercentage: ScreenUtil.instance.deviceType == DeviceType.mobile ? 6 : 5,
      margin: EdgeInsets.only(top: 16.r),
      child: CupertinoButton(
        color: CupertinoColors.activeBlue,
        borderRadius: ScreenUtil.instance.responsiveBorderRadius(8),
        onPressed: isLoading ? null : () => _handleLogin(context),
        child: isLoading
            ? CupertinoActivityIndicator(
                color: CupertinoColors.white,
                radius: 12.r,
              )
            : ResponsiveText(
                '登入',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
      ),
    );
  }

  /// STEP 07: 建立響應式快速登入按鈕
  Widget _buildQuickLoginButton(BuildContext context) {
    // STEP 07.01: 返回響應式快速登入按鈕UI
    return ResponsiveContainer(
      widthPercentage: 100,
      margin: EdgeInsets.only(top: 16.r),
      child: CupertinoButton(
        child: ResponsiveText(
          '快速體驗（無需輸入）',
          fontSize: 14,
          color: CupertinoColors.systemGrey,
        ),
        onPressed: () => _handleQuickLogin(context),
      ),
    );
  }

  /// STEP 08: 建立主要應用程式標題區域
  Widget _buildAppHeader() {
    return ResponsiveContainer(
      child: Column(
        children: [
          // STEP 08.01: 應用程式圖標
          Icon(
            CupertinoIcons.heart_fill,
            size: ScreenUtil.instance.responsiveIconSize(64),
            color: CupertinoColors.systemRed,
          ),
          ResponsiveSpacing(spacing: 16),
          
          // STEP 08.02: 應用程式名稱
          ResponsiveText(
            Constants.APP_NAME,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
          ResponsiveSpacing(spacing: 8),
          
          // STEP 08.03: 副標題
          ResponsiveText(
            '歡迎使用第一個Flutter專案',
            fontSize: 16,
            color: CupertinoColors.secondaryLabel,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// STEP 09: 建立響應式登入表單
  Widget _buildLoginForm(BuildContext context, bool isLoading) {
    return ResponsiveContainer(
      maxWidth: ScreenUtil.instance.deviceType == DeviceType.mobile ? null : 400,
      padding: ScreenUtil.instance.responsivePadding(all: 24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: ScreenUtil.instance.responsiveBorderRadius(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // STEP 09.01: 使用者名稱輸入欄
          _buildInputField(
            placeholder: '請輸入使用者名稱',
            controller: _usernameController,
            keyboardType: TextInputType.text,
            context: context,
          ),
          
          // STEP 09.02: 密碼輸入欄
          _buildInputField(
            placeholder: '請輸入密碼',
            controller: _passwordController,
            isPassword: true,
            context: context,
          ),
          
          // STEP 09.03: 登入按鈕
          _buildLoginButton(context, isLoading),
          
          // STEP 09.04: 快速登入按鈕
          _buildQuickLoginButton(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // STEP 10: 初始化響應式設計
    ScreenUtil.instance.init(context);
    
    // STEP 10.01: 使用Consumer監聽AppStateProvider
    return Consumer<AppStateProvider>(
      builder: (context, appStateProvider, child) {
        // STEP 10.02: 從Provider取得載入狀態
        final isLoading = appStateProvider.isLoading;
        
        // STEP 10.03: 使用響應式佈局包裝器
        return OrientationListener(
          builder: (context, orientation) {
            return CupertinoPageScaffold(
              backgroundColor: CupertinoColors.systemGroupedBackground,
              child: SafeArea(
                child: ResponsiveLayout(
                  // STEP 10.04: 手機版佈局
                  mobile: _buildMobileLayout(context, isLoading),
                  // STEP 10.05: 平板版佈局
                  tablet: _buildTabletLayout(context, isLoading),
                  // STEP 10.06: 桌面版佈局（fallback到平板佈局）
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
  Widget _buildMobileLayout(BuildContext context, bool isLoading) {
    return ResponsiveContainer(
      padding: ScreenUtil.instance.responsivePadding(all: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // STEP 11.01: 應用程式標題區域
          _buildAppHeader(),
          ResponsiveSpacing(spacing: 32),
          
          // STEP 11.02: 登入表單
          _buildLoginForm(context, isLoading),
          ResponsiveSpacing(spacing: 24),
          
          // STEP 11.03: 版本資訊
          ResponsiveText(
            'Version ${Constants.APP_VERSION}',
            fontSize: 12,
            color: CupertinoColors.tertiaryLabel,
          ),
        ],
      ),
    );
  }

  /// STEP 12: 平板版佈局
  Widget _buildTabletLayout(BuildContext context, bool isLoading) {
    return ResponsiveContainer(
      padding: ScreenUtil.instance.responsivePadding(all: 40),
      child: Row(
        children: [
          // STEP 12.01: 左側：應用程式標題區域
          Expanded(
            flex: ScreenUtil.instance.isLandscape ? 1 : 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAppHeader(),
                ResponsiveSpacing(spacing: 32),
                ResponsiveText(
                  'Version ${Constants.APP_VERSION}',
                  fontSize: 12,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
          ),
          
          ResponsiveSpacing(spacing: 40, direction: Axis.horizontal),
          
          // STEP 12.02: 右側：登入表單
          Expanded(
            flex: 1,
            child: Center(
              child: _buildLoginForm(context, isLoading),
            ),
          ),
        ],
      ),
    );
  }
}