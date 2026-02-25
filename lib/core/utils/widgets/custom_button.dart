import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.fontSize,
    this.style,
    this.textStyle,
    this.isLoading =
        false, // Add the isLoading parameter with default value false
    this.borderRadiusDirectional,
  });

  final String text;
  final void Function()? onPressed;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadiusDirectional? borderRadiusDirectional;
  final BorderRadius? borderRadius;
  final double? fontSize;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final bool isLoading;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isClicked = true;

  // Add this property
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 40.h,
      width: widget.width ?? 185.w,
      child: TextButton(
        style: widget.style ??
            TextButton.styleFrom(
              backgroundColor: widget.backgroundColor ?? ColorsData.primary,
              shape: RoundedRectangleBorder(
                borderRadius: widget.borderRadiusDirectional ??
                    widget.borderRadius ??
                    BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.zero,
              // Remove default padding
              minimumSize: Size.zero,
              // Remove minimum size constraints
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        onPressed: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          if (isClicked) {
            isClicked = false;
            setState(() {});
            try {
              widget.onPressed?.call();
            } catch (e) {
              isClicked = true;
              if (mounted) setState(() {});
            } finally {
              await Future.delayed(const Duration(seconds: 2), () {
                isClicked = true;
                if (mounted) setState(() {});
              });
            }
          }
        },
        child: Center(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 8.w), // Add horizontal padding
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : Text(
                    widget.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: widget.textStyle ??
                        Styles.textStyleS14W400(
                          color: widget.textColor ?? ColorsData.font,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
