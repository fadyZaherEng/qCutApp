import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/auth/auth_helper.dart';
import 'package:q_cut/main.dart';
import 'package:q_cut/modules/customer/features/home_features/profile_feature/views/my_profile_view.dart';

class CustomHomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function(String)? onSearchTap;

  const CustomHomeAppBar({
    super.key,
    this.onSearchTap,
  });

  @override
  State<CustomHomeAppBar> createState() => _CustomHomeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(67.h);
}

class _CustomHomeAppBarState extends State<CustomHomeAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: SvgPicture.asset(
            AssetsData.menuIcon,
            width: 24,
            height: 24,
          ),
        ),
        SizedBox(width: 11.w),
        InkWell(
          onTap: () {
            Get.toNamed(AppRouter.notificationPath);
          },
          child: SvgPicture.asset(
            AssetsData.notificationsIcon,
            width: 24,
            height: 24,
          ),
        ),
        SizedBox(width: 11.w),

        // ✅ هنا التحويل بين الايقونة والسيرش بار
        if ((widget.onSearchTap == null || _searchController.text.isEmpty) &&
            !isSearching)
          InkWell(
            onTap: () {
              setState(() {
                isSearching = true;
              });
            },
            child: SvgPicture.asset(
              AssetsData.searchIcon,
              width: 24,
              height: 24,
            ),
          )
        else
          Expanded(
            child: SizedBox(
              height: 40.h,
              child: TextField(
                controller: _searchController,
                onTapOutside: (_) {
                  if (_searchController.text.isEmpty) {
                    setState(() {
                      isSearching = false;
                    });
                  }
                },
                onTapUpOutside: (_) {
                  if (_searchController.text.isEmpty) {
                    setState(() {
                      isSearching = false;
                    });
                  }
                },
                onChanged: (value) {
                  widget.onSearchTap?.call(value);
                  setState(() {});
                  if (value.isEmpty) {
                    isSearching = false;
                  }
                },
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  // icon: SvgPicture.asset(
                  //   AssetsData.searchIcon,
                  //   width: 20,
                  //   height: 20,
                  //   color: Colors.grey.shade600,
                  // ),
                  hintText: "search".tr,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: ColorsData.primary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchTap?.call('');
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
        if (widget.onSearchTap != null) SizedBox(width: 11.w),
        if ((widget.onSearchTap == null || _searchController.text.isEmpty) &&
            !isSearching)
          const Spacer(),

        InkWell(
          onTap: () {
            // Check authentication before accessing profile
            if (!AuthHelper.requireAuthentication(returnRoute: AppRouter.myProfilePath)) {
              return; // User redirected to login
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyProfileView(isBack: true),
              ),
            );
          },
          child: CircleAvatar(
            radius: 24,
            backgroundImage: CachedNetworkImageProvider(
              profileImage,
              errorListener: (exception) =>
                  print("Error loading image: $exception"),
            ),
            onBackgroundImageError: (exception, stackTrace) =>
                const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
