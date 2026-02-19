import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/assets_data.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:q_cut/modules/customer/features/settings/chat_feature/logic/upload_media.dart';

class FavoriteCutsView extends StatefulWidget {
  const FavoriteCutsView({super.key});

  @override
  State<FavoriteCutsView> createState() => _FavoriteCutsViewState();
}

class _FavoriteCutsViewState extends State<FavoriteCutsView> {
  final NetworkAPICall _apiCall = NetworkAPICall();
  final UploadMedia _uploadMedia = UploadMedia();
  List<String> favoriteCuts = [];
  bool isLoading = true;
  bool isUploadingPhotos = false;
  List<RxBool> isFavorite = [];

  @override
  void initState() {
    super.initState();
    fetchFavoriteCuts();
  }

  Future<void> fetchFavoriteCuts() async {
    if (!mounted) return;
    try {
      final response =
          await _apiCall.getData("${Variables.baseUrl}favoriteForUser/cuts");
      print("${Variables.baseUrl}/favoriteForUser/cuts");
      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            favoriteCuts = List<String>.from(data['favoriteCuts']);
            favoriteCuts = List<String>.from(data['favoriteCuts']);
            isFavorite =
                List.generate(favoriteCuts.length, (index) => RxBool(true));

            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
          ShowToast.showError(message: 'failedToFetchFavorites'.tr);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        // ShowToast.showError(
        //     message: '${'errorOccurredWhileFetchingFavorites'.tr}: $e');
      }
    }
  }

  Future<void> addPhotosToFavorites() async {
    try {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        isUploadingPhotos = true;
      });

      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isEmpty) {
        if (!mounted) return;
        setState(() {
          isUploadingPhotos = false;
        });
        return;
      }

      // Upload each image one by one and toggle favorite
      for (final image in images) {
        if (!mounted) return;

        final uploadedUrl =
            await _uploadMedia.uploadFile(File(image.path), 'image');

        if (uploadedUrl != null && mounted) {
          // Call the toggle-favorite-photo endpoint
          final requestData = {
            'photoUrl': uploadedUrl,
          };

          print('Adding photo to favorites: $requestData');

          final response = await _apiCall.addData(
            requestData,
            '${Variables.baseUrl}favoriteForUser/toggle-favorite-photo',
          );

          print(
              'Favorite photo toggle response: ${response.statusCode}, ${response.body}');

          if (mounted &&
              (response.statusCode == 200 || response.statusCode == 201)) {
            // Success - the photo was added to favorites
            ShowToast.showSuccessSnackBar(message: 'photoAddedToFavorites'.tr);
          } else if (mounted) {
            // Error
            ShowToast.showError(
              message: '${'failedToAddPhoto'.tr}: ${response.statusCode}',
            );
          }
        }
      }

      // Refresh the favorites list
      if (mounted) {
        await fetchFavoriteCuts();
      }
    } catch (e) {
      print('Error adding photos to favorites: $e');
      if (mounted) {
        ShowToast.showError(
          message: '${'failedToUploadPhotos'.tr}: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploadingPhotos = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchFavoriteCuts,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "youHave".tr,
                        style: Styles.textStyleS14W400(),
                      ),
                      Text(
                        " ${favoriteCuts.length} ",
                        style: Styles.textStyleS20W700(
                            color: ColorsData.primary),
                      ),
                      Text(
                        favoriteCuts.length == 1
                            ? "favoriteCut".tr
                            : "favoriteCuts".tr,
                        style: Styles.textStyleS14W400(),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: isUploadingPhotos ? null : addPhotosToFavorites,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: ColorsData.secondary,
                        border:
                            Border.all(color: ColorsData.primary, width: 1.w),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          isUploadingPhotos
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  child: SpinKitDoubleBounce(
                                    color: ColorsData.primary,
                                  ),
                                )
                              : SvgPicture.asset(
                                  AssetsData.addImageIcon,
                                  width: 24.w,
                                  height: 24.h,
                                ),
                          SizedBox(width: 2.w),
                          Text(
                            isUploadingPhotos ? "uploading".tr : "addPhotos".tr,
                            style: Styles.textStyleS16W400(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: isLoading
                ? Center(child: SpinKitDoubleBounce(color: ColorsData.primary))
                : favoriteCuts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: fetchFavoriteCuts,
                        child: GridView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                              top: 16.h, left: 16.w, right: 17.w),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 110.w,
                            crossAxisSpacing: 6.h,
                            mainAxisSpacing: 9.w,
                          ),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              // Open the image in full screen
                              _showFullScreenImage(
                                context,
                                favoriteCuts[index],
                                index,
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: ColorsData.cardStrock,
                                      width: 1.w,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.network(
                                      favoriteCuts[index],
                                      width: 108.w,
                                      height: 94.h,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        AssetsData.hairCutInGallery,
                                        width: 108.w,
                                        height: 94.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                                // Favorite button at top right
                                Positioned(
                                  top: 4.h,
                                  right: 12.w,
                                  child: Container(
                                    width: 32.w,
                                    height: 32.h,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      // color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 32.w,
                                        height: 32.h,
                                        child: IconButton(
                                          alignment: Alignment.center,
                                          icon: Obx(() => Center(
                                                child: Icon(
                                                  isFavorite[index].value
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isFavorite[index].value
                                                      ? Colors.red
                                                      : Colors.white,
                                                  size: 20.sp,
                                                ),
                                              )),
                                          onPressed: () async {
                                            isLoading = true;
                                            final response =
                                                await NetworkAPICall().addData(
                                              {"photoUrl": favoriteCuts[index]},
                                              "${Variables.baseUrl}favoriteForUser/toggle-favorite-photo",
                                            );
                                            if (response.statusCode == 200) {
                                              fetchFavoriteCuts();
                                              setState(() {});
                                            }

                                            //
                                            // if (response.statusCode == 200) {
                                            isFavorite[index].value =
                                                !isFavorite[index].value;
                                            // barber.isFavorite = isFavorite.value;
                                            // } else {
                                            //   ShowToast.showError(
                                            //       message: "Error occurred");
                                            // }
                                          },
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          itemCount: favoriteCuts.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AssetsData.addImageIcon,
            width: 70.w,
            height: 70.h,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            "noFavoriteCutsAdded".tr,
            style: Styles.textStyleS16W600(color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              "addPhotosOfFavoriteHaircuts".tr,
              textAlign: TextAlign.center,
              style: Styles.textStyleS14W400(color: Colors.grey),
            ),
          ),
          SizedBox(height: 20.h),
          InkWell(
            onTap: isUploadingPhotos ? null : addPhotosToFavorites,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ColorsData.secondary,
                border: Border.all(color: ColorsData.primary, width: 1.w),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isUploadingPhotos
                      ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsData.primary),
                          ),
                        )
                      : SvgPicture.asset(
                          AssetsData.addImageIcon,
                          width: 24.w,
                          height: 24.h,
                        ),
                  SizedBox(width: 8.w),
                  Text(
                    isUploadingPhotos ? "uploading".tr : "addYourFirstCut".tr,
                    style: Styles.textStyleS16W400(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7), // background blur/dim
      builder: (_) {
        return Center(
          child: Stack(
            children: [
              Hero(
                tag: imageUrl,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Obx(() => IconButton(
                      icon: Icon(
                        isFavorite[index].value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            isFavorite[index].value ? Colors.red : Colors.white,
                        size: 32,
                      ),
                      onPressed: () async {
                        final response = await _apiCall.addData(
                          {"photoUrl": favoriteCuts[index]},
                          "${Variables.baseUrl}favoriteForUser/toggle-favorite-photo",
                        );
                        if (response.statusCode == 200) {
                          isFavorite[index].value = !isFavorite[index].value;
                          if (!isFavorite[index].value) {
                            favoriteCuts.removeAt(index);
                            isFavorite.removeAt(index);
                            Navigator.pop(context); // close if removed
                          }
                          setState(() {});
                        }
                      },
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Local image viewer widget for fallback
class _ImageViewScreen extends StatefulWidget {
  final String imageUrl;

  const _ImageViewScreen({required this.imageUrl});

  @override
  State<_ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<_ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            ColorsData.primary),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 16.h),
                        Text(
                          "failedToLoadImage".tr,
                          style: Styles.textStyleS16W600(color: Colors.white),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
