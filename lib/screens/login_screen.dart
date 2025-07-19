import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    // STEP 01: 釋放資源
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// STEP 02: 處理登入邏輯
  Future<void> _handleLogin() async {
    // STEP 02.01: 檢查輸入欄位
    if (_usernameController.text.trim().isEmpty) {
      _showAlert('請輸入使用者名稱');
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showAlert('請輸入密碼');
      return;
    }

    // STEP 02.02: 設定載入狀態
    setState(() {
      _isLoading = true;
    });

    try {
      // STEP 02.03: 模擬登入延遲
      await Future.delayed(const Duration(milliseconds: 1000));

      // STEP 02.04: 導航到主頁面
      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    } catch (e) {
      // STEP 02.05: 處理錯誤
      if (mounted) {
        _showAlert('登入過程發生錯誤：$e');
      }
    } finally {
      // STEP 02.06: 重置載入狀態
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// STEP 03: 顯示提示對話框
  void _showAlert(String message) {
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

  /// STEP 04: 建立輸入欄位
  Widget _buildInputField({
    required String placeholder,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: Constants.SPACING_MEDIUM),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: isPassword,
        keyboardType: keyboardType,
        textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
        padding: const EdgeInsets.all(Constants.SPACING_MEDIUM),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
        ),
        style: const TextStyle(
          fontSize: Constants.FONT_SIZE_MEDIUM,
        ),
        onSubmitted: isPassword ? (_) => _handleLogin() : null,
      ),
    );
  }

  /// STEP 05: 建立登入按鈕
  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(top: Constants.SPACING_MEDIUM),
      child: CupertinoButton(
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_MEDIUM),
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const CupertinoActivityIndicator(
                color: CupertinoColors.white,
              )
            : const Text(
                '登入',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_MEDIUM,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
      ),
    );
  }

  /// STEP 06: 建立快速登入按鈕
  Widget _buildQuickLoginButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Constants.SPACING_MEDIUM),
      child: CupertinoButton(
        child: const Text(
          '快速體驗（無需輸入）',
          style: TextStyle(
            fontSize: Constants.FONT_SIZE_SMALL,
            color: CupertinoColors.systemGrey,
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.SPACING_LARGE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // STEP 07.01: 應用程式標題和圖標
              const Icon(
                CupertinoIcons.heart_fill,
                size: Constants.ICON_SIZE_EXTRA_LARGE * 2,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(height: Constants.SPACING_MEDIUM),
              
              // STEP 07.02: 應用程式名稱
              const Text(
                Constants.APP_NAME,
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_EXTRA_LARGE * 1.5,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: Constants.SPACING_SMALL),
              
              // STEP 07.03: 副標題
              const Text(
                '歡迎使用第一個Flutter專案',
                style: TextStyle(
                  fontSize: Constants.FONT_SIZE_MEDIUM,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: Constants.SPACING_EXTRA_LARGE),
              
              // STEP 07.04: 登入表單容器
              Container(
                padding: const EdgeInsets.all(Constants.SPACING_LARGE),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(Constants.BORDER_RADIUS_LARGE),
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
                    // STEP 07.05: 使用者名稱輸入欄
                    _buildInputField(
                      placeholder: '請輸入使用者名稱',
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                    ),
                    
                    // STEP 07.06: 密碼輸入欄
                    _buildInputField(
                      placeholder: '請輸入密碼',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    
                    // STEP 07.07: 登入按鈕
                    _buildLoginButton(),
                    
                    // STEP 07.08: 快速登入按鈕
                    _buildQuickLoginButton(),
                  ],
                ),
              ),
              
              const SizedBox(height: Constants.SPACING_LARGE),
              
              // STEP 07.09: 版本資訊
              Text(
                'Version ${Constants.APP_VERSION}',
                style: const TextStyle(
                  fontSize: Constants.FONT_SIZE_SMALL,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 