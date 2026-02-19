import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/modules/main/logic/main_controller.dart';
import 'package:q_cut/modules/main/view/widgets/custom_bottom_nav_bar.dart';

class HomeNavigationBar extends StatelessWidget {
  const HomeNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

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
