import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    this.onSend,
    this.onCameraTap,
    this.onRecTap,
    this.onSendMessage,
  });

  final void Function()? onSend;
  final void Function()? onCameraTap;
  final void Function()? onRecTap;
  final void Function(String)? onSendMessage;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isNotEmpty && widget.onSendMessage != null) {
      widget.onSendMessage!(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorsData.secondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
              onTap: widget.onCameraTap,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AssetsData.cameraIcon,
                  height: 20.h,
                  width: 20.w,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: widget.onRecTap,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AssetsData.microphoneIcon,
                  height: 20.h,
                  width: 20.w,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _controller,
                  style: Styles.textStyleS14W400(color: Colors.white),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: "enterYourMessage".tr,
                    hintStyle: Styles.textStyleS14W400(color: Colors.grey),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            InkWell(
              onTap: _submit,
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: ColorsData.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
