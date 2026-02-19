import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  void Function(String)? onFieldSubmitted;
  void Function(String)? onChanged;
  final TextStyle? style;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  void Function(String?)? onSaved;
  final Color? fillColor;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection ?textDirection;

  CustomTextFormField({
    super.key,
    this.hintText,
    this.onSaved,
    this.controller,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
    this.style,
    this.suffixIconColor,
    this.prefixIconColor,
    this.fillColor,
    this.prefixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    // Special handling for phone field
    final languageCode = Localizations.localeOf(context).languageCode;
    if (keyboardType == TextInputType.phone ||
        keyboardType == TextInputType.number) {
      return Directionality(
        textDirection: textDirection ??
            (languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters:inputFormatters?? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9), // allow only 9 digits
          ],
          validator: validator,
          onChanged: onChanged,
          onSaved: onSaved,
          style: style ?? Styles.textStyleS14W500(),
          decoration: InputDecoration(
            hintText: hintText ?? "5xxxxxxxx",
            hintStyle: Styles.textStyleS14W400(color: ColorsData.cardStrock),
            fillColor: fillColor ?? ColorsData.secondary,
            filled: true,
            contentPadding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: 14.h,
              bottom: 14.h,
            ),
            //get the suffix icon with the country code
            suffixIcon: languageCode == 'ar'
                ? Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),

                    // margin: EdgeInsets.only(left: 8.w, right: 4.w),
                    decoration: BoxDecoration(
                      color: ColorsData.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "\u200E+972",
                      style: Styles.textStyleS14W500(color: ColorsData.primary),
                    ),
                  )
                : null,
            prefixIcon: languageCode == 'en'
                ? Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                    // margin: EdgeInsets.only(left: 8.w, right: 4.w),
                    decoration: BoxDecoration(
                      color: ColorsData.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "\u200E+972",
                      style: Styles.textStyleS14W500(color: ColorsData.primary),
                    ),
                  )
                : null,
            // suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: ColorsData.cardStrock),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: ColorsData.cardStrock),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: ColorsData.cardStrock),
            ),
          ),
        ),
      );
    }

    // Normal field for other cases
    return Directionality(
      textDirection: keyboardType == TextInputType.visiblePassword
          ? TextDirection.ltr
          : Directionality.of(context),
      child: TextFormField(
        inputFormatters: keyboardType == TextInputType.visiblePassword
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'[ -~]')),
              ]
            : null,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        onSaved: onSaved,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType ?? TextInputType.emailAddress,
        validator: validator,
        style: style ?? Styles.textStyleS14W500(),
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Styles.textStyleS14W400(color: ColorsData.cardStrock),
          fillColor: fillColor ?? ColorsData.secondary,
          filled: true,
          contentPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 14.h,
            bottom: 14.h,
          ),
          suffixIconColor: ColorsData.primary,
          prefixIconColor: ColorsData.secondary,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: ColorsData.cardStrock),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: ColorsData.cardStrock),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: ColorsData.cardStrock),
          ),
        ),
      ),
    );
  }
}
