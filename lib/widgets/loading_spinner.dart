// ===== FLUTTER CORE =====
import 'package:flutter/cupertino.dart' as cupertino;

// ===== CUSTOM UTILS =====
import '../utils/constants.dart' as constants;

/// 全畫面載入遮罩元件
/// 提供統一的載入效果，覆蓋整個螢幕
class LoadingSpinner extends cupertino.StatelessWidget {
  final String? message;
  final double? spinnerRadius;
  final cupertino.Color? spinnerColor;
  final cupertino.Color? backgroundColor;
  final cupertino.Color? containerColor;
  final double? containerRadius;
  final List<cupertino.BoxShadow>? shadows;

  const LoadingSpinner({
    super.key,
    this.message,
    this.spinnerRadius,
    this.spinnerColor,
    this.backgroundColor,
    this.containerColor,
    this.containerRadius,
    this.shadows,
  });

  @override
  cupertino.Widget build(cupertino.BuildContext context) {
    // STEP 01: 建立全畫面遮罩容器
    return cupertino.Container(
      // STEP 02: 設定全畫面尺寸
      width: cupertino.MediaQuery.sizeOf(context).width,
      height: cupertino.MediaQuery.sizeOf(context).height,
      // STEP 03: 設定背景遮罩顏色
      color:
          backgroundColor ??
          cupertino.CupertinoColors.black.withValues(alpha: 0.5),
      // STEP 04: 建立中央載入內容
      child: cupertino.Center(
        child: cupertino.Container(
          // STEP 05: 設定載入容器內邊距
          padding: const cupertino.EdgeInsets.all(
            constants.Constants.spacingLarge,
          ),
          // STEP 06: 設定載入容器裝飾
          decoration: cupertino.BoxDecoration(
            color: containerColor ?? cupertino.CupertinoColors.systemBackground,
            borderRadius: cupertino.BorderRadius.circular(
              containerRadius ?? constants.Constants.borderRadiusLarge,
            ),
            // STEP 07: 設定陰影效果
            boxShadow:
                shadows ??
                [
                  cupertino.BoxShadow(
                    color: cupertino.CupertinoColors.black.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 10,
                    offset: const cupertino.Offset(0, 5),
                  ),
                ],
          ),
          // STEP 08: 建立載入內容
          child: cupertino.Column(
            mainAxisSize: cupertino.MainAxisSize.min,
            children: [
              // STEP 09: 載入動畫指示器
              cupertino.CupertinoActivityIndicator(
                radius: spinnerRadius ?? 20,
                color: spinnerColor ?? cupertino.CupertinoColors.systemBlue,
              ),
              // STEP 10: 載入訊息間距
              const cupertino.SizedBox(
                height: constants.Constants.spacingMedium,
              ),
              // STEP 11: 載入訊息文字
              cupertino.Text(
                message ?? "載入中...",
                style: const cupertino.TextStyle(
                  fontSize: constants.Constants.fontSizeMedium,
                  fontWeight: cupertino.FontWeight.w600,
                  color: cupertino.CupertinoColors.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
