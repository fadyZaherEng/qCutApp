import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/navigation_helper.dart';
import 'package:q_cut/modules/main/logic/main_controller.dart';
import 'package:q_cut/modules/main/view/widgets/custom_bottom_nav_bar.dart';
import 'dart:convert';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:http/http.dart' as http;

class HomeNavigationBar extends StatefulWidget {
  const HomeNavigationBar({super.key});

  @override
  State<HomeNavigationBar> createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  void _navigateAfterDelay() async {
    bool saveMe = SharedPref().getBool(PrefKeys.saveMe) ?? false;
    String? phoneNumber = SharedPref().getString(PrefKeys.phoneNumber);
    String? password = SharedPref().getString(PrefKeys.password);
    bool? isUserRole = SharedPref().getBool(PrefKeys.userRole);
    print("Navigating with saveMe: $saveMe, phoneNumber: $phoneNumber, password: ${password != null ? '***' : null}, isUserRole: $isUserRole");
    // Get FCM token before making the request
    String? token = SharedPref().getString(PrefKeys.accessToken);
    // Verify ban status in background if we have credentials
    if (phoneNumber != null &&
        phoneNumber.isNotEmpty &&
        password != null &&
        password.isNotEmpty &&
        saveMe) {
      try {
        final response = await http
            .post(
              Uri.parse(Variables.LOGIN),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'phoneNumber': phoneNumber,
                'password': password,
                'userType':
                    isUserRole != null && isUserRole ? 'user' : 'barber',
                "fcmToken": token,
              }),
            )
            .timeout(const Duration(seconds: 5));
        print("Ban check response: ${response.statusCode} - ${response.body}");
        print("Ban check request body: ${jsonEncode({
              'phoneNumber': phoneNumber,
              'password': password,
              'userType': isUserRole != null && isUserRole ? 'user' : 'barber',
              "fcmToken": token,
            })}");

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final bool isBanned = responseBody['isBanned'] ?? false;

          if (isBanned) {
            NavigationHelper.navigateToAndRemoveUntil(AppRouter.bannedPath,
                arguments: {
                  "banReason": responseBody['banReason'],
                  "bannedUntil": responseBody['bannedUntil'],
                  "daysRemaining": responseBody['daysRemaining'],
                });
            return; // Stop further navigation
          }
        }
      } catch (e) {
        debugPrint("Background ban check failed: $e");
      }
    }

    if (token != null && token.isNotEmpty) {
      // Do nothing, already on the home navigation bar
    } else {
      NavigationHelper.navigateToAndRemoveUntil(AppRouter.selectServicesPath);
    }
  }

  final MainController controller = Get.find<MainController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateAfterDelay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(controller.currentIndex.value),
              child: controller.pages[controller.currentIndex.value],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          initialIndex: controller.currentIndex.value,
          onPageChanged: (index) {
            controller.changePage(index);
          },
          pages: controller.pages,
        ),
      ),
    );
  }
}
