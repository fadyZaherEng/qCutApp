import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/constants/colors_data.dart';
import 'package:q_cut/core/utils/styles.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  // To keep track if the dialog is currently showing
  bool _isDialogShowing = false;
  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    debugPrint("NetworkController: Initializing...");
    _checkInitialConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      debugPrint("NetworkController: Connection Changed -> $results");
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    // Try multiple times to ensure we get a valid initial status if the system is booting up
    for (int i = 0; i < 3; i++) {
      await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      debugPrint("NetworkController: Initial Check ($i) -> $results");
      
      bool isConnected = results.any((result) => result != ConnectivityResult.none);
      if (!isConnected) {
        _updateConnectionStatus(results);
        break; // Show dialog and stop retrying if offline
      }
      
      // If we found a connection, we can stop checking or keep checking as per need.
      // Usually, if we find a connection once, we are good.
      if (isConnected) break;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool isConnected = results.any((result) => result != ConnectivityResult.none);
    
    if (!isConnected) {
      if (!_isDialogShowing) {
        debugPrint("NetworkController: Showing No Internet Dialog");
        _wasOffline = true;
        _showNoInternetDialog();
      }
    } else {
      if (_isDialogShowing) {
        debugPrint("NetworkController: Internet Restored, closing dialog");
        Get.back();
        _isDialogShowing = false;
      }
      
      // Only show "Back Online" if it was actually offline before
      if (_wasOffline) {
        _wasOffline = false;
        Get.snackbar(
          'backOnline'.tr,
          'connectionRestored'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _showNoInternetDialog() {
    // Check again before showing to avoid race conditions
    _isDialogShowing = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: ColorsData.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.signal_wifi_off_rounded,
                  size: 72,
                  color: ColorsData.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'noInternet'.tr,
                  style: Styles.textStyleS20W700(color: ColorsData.font),
                ),
                const SizedBox(height: 12),
                Text(
                  'pleaseCheckConnection'.tr,
                  textAlign: TextAlign.center,
                  style: Styles.textStyleS14W400(color: ColorsData.thirty),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
                    _updateConnectionStatus(results);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsData.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 0,
                  ),
                  child: Text(
                    'retry'.tr,
                    style: Styles.textStyleS16W700(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    debugPrint("NetworkController: Closing Subscription");
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
