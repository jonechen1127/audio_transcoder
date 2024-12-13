import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text; // 按钮显示的文本
  final void Function()? onPressed; // 按钮点击时的回调函数
  final Color backgroundColor; // 按钮背景色
  final Color textColor; // 按钮文本颜色
  final bool isDisabled; // 是否禁用按钮
  final EdgeInsetsGeometry padding; // 按钮内边距
  final BorderRadiusGeometry borderRadius; // 按钮圆角
  final TextStyle textStyle;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.isDisabled = false,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.textStyle = const TextStyle(fontWeight: FontWeight.normal),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backgroundColor,
        disabledForegroundColor: textColor.withOpacity(0.8),
        disabledBackgroundColor: backgroundColor.withOpacity(0.7),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        elevation: 0,
        shadowColor: backgroundColor.withOpacity(0.3),
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
