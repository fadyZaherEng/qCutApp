import 'package:get/get.dart';
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/app_router.dart';

class AuthHelper {
  /// Check if the user is authenticated (has a valid access token)
  static bool isAuthenticated() {
    final accessToken = SharedPref().getString(PrefKeys.accessToken);
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Check if user is a customer (as opposed to a barber)
  static bool isCustomer() {
    return SharedPref().getBool(PrefKeys.userRole) ?? false;
  }

  /// Prompt user to login if not authenticated
  /// Returns true if user is already authenticated, false if redirected to login
  static bool requireAuthentication({String? returnRoute}) {
    if (isAuthenticated()) {
      return true;
    }

    // Store the intended route to return to after login
    if (returnRoute != null) {
      SharedPref().setString(PrefKeys.pendingRoute, returnRoute);
    }

    // Redirect to login
    Get.toNamed(AppRouter.loginPath);
    return false;
  }

  /// Get and clear the pending route (route to return to after login)
  static String? consumePendingRoute() {
    final route = SharedPref().getString(PrefKeys.pendingRoute);
    if (route != null) {
      SharedPref().removePreference(PrefKeys.pendingRoute);
    }
    return route;
  }

  /// Clear all authentication data
  static Future<void> logout() async {
    await SharedPref().removePreference(PrefKeys.accessToken);
    await SharedPref().removePreference(PrefKeys.id);
    await SharedPref().removePreference(PrefKeys.barberId);
    await SharedPref().removePreference(PrefKeys.profilePic);
    await SharedPref().removePreference(PrefKeys.coverPic);
    await SharedPref().removePreference(PrefKeys.phoneNumber);
    await SharedPref().removePreference(PrefKeys.fullName);
    await SharedPref().removePreference(PrefKeys.barber);
  }
}
