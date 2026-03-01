import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import '../../../../../main.dart';

class ChatBubbleForCustomer extends StatelessWidget {
  final String? text;
  final bool isVoice;
  final String mediaType;
  final String? mediaUrl;

  const ChatBubbleForCustomer({
    super.key,
    this.text,
    this.isVoice = false,
    this.mediaType = 'text',
    this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsData.bodyFont,
                border: Border.all(color: ColorsData.primary, width: 1.w),
              ),
              child: CircleAvatar(
                radius: 25.r,
                foregroundImage: CachedNetworkImageProvider(profileImage),
                backgroundColor: ColorsData.secondary,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              constraints: BoxConstraints(maxWidth: 0.7.sw, minWidth: 70.w),
              decoration: BoxDecoration(
                color: ColorsData.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(20.r),
                ),
              ),
              child: _buildMessageContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    if (isVoice) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            height: 24.h,
            width: 24.w,
            AssetsData.playCircleIcon,
          ),
          SizedBox(width: 10.w),
          SvgPicture.asset(
            height: 12.h,
            width: 119.w,
            AssetsData.recordingTapeIcon,
          ),
        ],
      );
    } else if (mediaType == 'image') {
      // Get the image URL from mediaUrl or message field
      final imageUrl = (mediaUrl != null && mediaUrl!.isNotEmpty)
          ? mediaUrl
          : (text != null && text!.startsWith('http'))
              ? text
              : null;

      if (imageUrl != null) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 220.w,
            minWidth: 100.w,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 200.h,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: ColorsData.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 150.h,
                color: Colors.grey[300],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.red,
                  size: 30.sp,
                ),
              ),
            ),
          ),
        );
      }
    }

    // Default text display
    return Text(
      text ?? '',
      style: Styles.textStyleS16W400(),
    );
  }
}
