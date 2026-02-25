import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/home_features/home/models/barber_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NearestBarberResponse {
  final bool success;
  final List<Barber> barbers;

  NearestBarberResponse({
    required this.success,
    required this.barbers,
  });

  factory NearestBarberResponse.fromJson(Map<String, dynamic> json) {
    return NearestBarberResponse(
      success: json['success'] ?? false,
      barbers: (json['data'] as List<dynamic>?)
              ?.map((e) => Barber.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class HomeController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  Timer? _searchTimer;

  // Form Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController searchBarberController = TextEditingController();

  // Barber data
  final RxList<Barber> nearbyBarbers = <Barber>[].obs;
  final RxList<Barber> recommendedBarbers = <Barber>[].obs;
  final RxList<Barber> searchResults = <Barber>[].obs;
  final RxInt totalBarbers = 0.obs;
  final RxInt currentPage = 1.obs;

  // Search state
  final RxBool isSearching = false.obs;

  // UI States
  final RxBool isLoading = true.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  // Tab controller
  late TabController tabController;

  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    searchBarberController.dispose(); // Dispose search controller
    _searchTimer?.cancel(); // Cancel timer on close
    super.onClose();
  }

  // Fetch barbers data from API
  Future<void> getBarbers() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiCall.getData(Variables.GET_BARBERS);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final barbersResponse = BarbersResponse.fromJson(responseBody);
        print("Barbers response: ${response.body}");
        // Update total count
        totalBarbers.value = barbersResponse.totalBarbers;
        currentPage.value = barbersResponse.page;

        // Filter and assign barbers
        final allBarbers = barbersResponse.barbers;

        // For simplicity, we'll consider all barbers as nearby
        // and active barbers as recommended
        nearbyBarbers.value = allBarbers;
        recommendedBarbers.value =
            allBarbers.where((barber) => barber.status == 'active').toList();
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch barbers data';
        // ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      // Get.snackbar('Error', 'Failed to connect to server',
      //     backgroundColor: Colors.red, colorText: Colors.white);

      // Keep using static data if API fails
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getNearestBarbers(double longitude, double latitude) async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiCall.getData(
        "${Variables.baseUrl}user/nearest-barber?longitude=$longitude&latitude=$latitude",
      );
      final responseBody = json.decode(response.body);
      print(
          "${Variables.baseUrl}user/nearest-barber?longitude=$longitude&latitude=$latitude");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final nearestBarbersResponse =
            NearestBarberResponse.fromJson(responseBody);

        print("Nearest barbers response: ${response.body}");

        // التعيين
        nearbyBarbers.value = nearestBarbersResponse.barbers;

        // التوصية باللي حالتهم active
        recommendedBarbers.value = nearestBarbersResponse.barbers
            .where((barber) => barber.status == 'active')
            .toList();
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch nearest barbers data';
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Network error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBarbersCity({
    required String city, // ممكن يكون "Cairo,Alexandria,Giza"
  }) async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiCall.getData(Variables.GET_BARBERS);
      print(Variables.GET_BARBERS);
      final responseBody = json.decode(response.body);
      print("city: $city");

      if (response.statusCode == 200) {
        final barbersResponse = BarbersResponse.fromJson(responseBody);
        print("Barbers response: ${response.body}");

        // Update total count
        totalBarbers.value = barbersResponse.totalBarbers;
        currentPage.value = barbersResponse.page;

        // Get all barbers
        final allBarbers = barbersResponse.barbers;

        // ✨ دعم المدن المتعددة
        final cityList = city
            .split(',')
            .map((c) => c.trim().toLowerCase())
            .where((c) => c.isNotEmpty)
            .toList();

        final filteredBarbers = allBarbers.where((barber) {
          final barberCity = barber.city.toLowerCase();
          return cityList.any((c) => barberCity.contains(c));
        }).toList();

        // nearby = all filtered barbers
        nearbyBarbers.value = filteredBarbers;

        // recommended = only active barbers in those cities
        recommendedBarbers.value = filteredBarbers
            .where((barber) => barber.status == 'active')
            .toList();
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch barbers data';
        // ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      // Get.snackbar(
      //   'Error',
      //   'Failed to connect to server',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAvailableBarbers({
    required String city, // ممكن يكون "Cairo,Alexandria,Giza"
    required int startDate, // 1744297200000
    required int endDate, // 1744300800000
  }) async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final url =
          "${Variables.baseUrl}appointment/available?startDate=$startDate&endDate=$endDate&city=$city";
      print("API URL: $url");

      final response = await _apiCall.getData(url);
      final responseBody = json.decode(response.body);

      print("city: $city");
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final availableBarbers = (responseBody["availableBarbers"] as List)
            .map((e) => Barber.fromJson(e))
            .toList();

        // ✨ دعم المدن المتعددة
        final cityList = city
            .split(',')
            .map((c) => c.trim().toLowerCase())
            .where((c) => c.isNotEmpty)
            .toList();

        final filteredBarbers = availableBarbers.where((barber) {
          final barberCity = barber.city.toLowerCase();
          return cityList.any((c) => barberCity.contains(c));
        }).toList();

        // update observables
        totalBarbers.value = filteredBarbers.length;
        currentPage.value = responseBody["currentPage"] ?? 1;

        nearbyBarbers.value = filteredBarbers;

        recommendedBarbers.value = filteredBarbers
            .where((barber) => barber.status == "active")
            .toList();
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch available barbers';
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Network error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ دالة البحث
  // RxList<Barber> filteredSearchBarbers = <Barber>[].obs;
  // void searchBarbers(String query) {
  //   if (query.isEmpty) {
  //    } else {
  //     final q = query.toLowerCase();
  //     filteredSearchBarbers.value = recommendedBarbers.where((barber) {
  //       final nameMatch = barber.fullName.toLowerCase().contains(q) ?? false;
  //       final shopMatch =
  //           barber.barberShop?.toLowerCase().contains(q) ?? false;
  //       return nameMatch || shopMatch;
  //     }).toList();
  //   }
  //   update(); // لتحديث الواجهة
  // }

  Future<void> getBarbersByFilter({
    required String city,
    int page = 1,
    int limit = 5,
  }) async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiCall.getData(
        Variables.GET_BARBERS_FILTER,
        body: {"city": city, "page": page, "limit": limit},
      );
      print(Variables.GET_BARBERS_FILTER);
      print("city: $city, page: $page, limit: $limit");
      final responseBody = json.decode(response.body);
      print("Barbers filter response: ${response.body}");

      if (response.statusCode == 200) {
        // final barbersResponse = BarbersResponse.fromJson(responseBody);
        print("Barbers response: ${response.body}");
        // Update total count
        totalBarbers.value =
            responseBody['total']; //barbersResponse.totalBarbers;
        currentPage.value = responseBody['page']; // barbersResponse.page;

        // Filter and assign barbers
        final allBarbers = List<Barber>.from(
            (responseBody['results'] ?? []).map((x) => Barber.fromJson(x)));

        // For simplicity, we'll consider all barbers as nearby
        // and active barbers as recommended

        nearbyBarbers.value = allBarbers;
        recommendedBarbers.value =
            allBarbers.where((barber) => barber.status == 'active').toList();
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch barbers data';
        ShowToast.showError(message: errorMessage.value);
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      Get.snackbar('Error', 'Failed to connect to server',
          backgroundColor: Colors.red, colorText: Colors.white);

      // Keep using static data if API fails
    } finally {
      isLoading.value = false;
    }
  }

  // Search barbers by salon name
  // Search barbers by salon name
  Future<void> searchBarbers(String query) async {
    _searchTimer?.cancel(); // Cancel any previous timer

    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      isLoading.value = false;
      return;
    }

    isSearching.value = true;
    isLoading.value = true; // Show loading immediately
    _searchTimer = Timer(const Duration(milliseconds: 500), () async {
      await searchBarberGeneral(query);
    });
  }

  // Fetch barbers data by salon name or barber name
  Future<void> searchBarberGeneral(String query) async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';
    print("Searching for: $query");

    final q = query.toLowerCase();
    final combinedMap = <String, Barber>{};

    try {
      // 1. Local Search (Full name and Shop name)
      for (var b in [...nearbyBarbers, ...recommendedBarbers]) {
        final nameMatch = b.fullName.toLowerCase().contains(q);
        final shopMatch = b.barberShop?.toLowerCase().contains(q) ?? false;
        if (nameMatch || shopMatch) {
          combinedMap[b.id] = b;
        }
      }

      // 2. API Search - By Shop Name
      final shopResponse = await _apiCall
          .getData("${Variables.SEARCH_BARBER_SHOP}?name=$query&page=1");
      if (shopResponse.statusCode == 200) {
        final List<dynamic> results =
            json.decode(shopResponse.body)['results'] ?? [];
        for (var data in results) {
          final b = Barber.fromJson(data);
          combinedMap[b.id] = b;
        }
      }

      // 3. API Search - By Barber Name (Attempt)
      try {
        final nameResponse = await _apiCall
            .getData("${Variables.SEARCH_BARBER_FULL_NAME}?name=$query&page=1");
        if (nameResponse.statusCode == 200) {
          final List<dynamic> results =
              json.decode(nameResponse.body)['results'] ?? [];
          for (var data in results) {
            final b = Barber.fromJson(data);
            combinedMap[b.id] = b;
          }
        }
      } catch (e) {
        print("Optional name search API call failed: $e");
      }

      searchResults.value = combinedMap.values.toList();
      totalBarbers.value = searchResults.length;

      if (searchResults.isEmpty && !isError.value) {
        // No results found anywhere
      }
    } catch (e) {
      print("Search Exception: $e");
      isError.value = true;
      errorMessage.value = 'Network error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to get working days as formatted string
  String getWorkingDaysAsString(Barber barber) {
    if (barber.workingDays.isEmpty) {
      return 'No working days set';
    }

    final List<String> formattedDays = barber.workingDays.map((day) {
      return '${day.day} (${day.startHour}:00 - ${day.endHour}:00)';
    }).toList();

    return formattedDays.join(', ');
  }

  // Helper method to get off days as string
  String getOffDaysAsString(Barber barber) {
    if (barber.offDay.isEmpty) {
      return 'No off days set';
    }

    return barber.offDay.join(', ');
  }

  // ---- Working Days as String ----
//   String getWorkingDaysAsString(Barber barber) {
//     if (barber.workingDays.isEmpty) {
//       return 'No working days set';
//     }
//
//     final List<String> formattedDays = barber.workingDays.map((day) {
//       return '${day.day} (${day.startHour}:00 - ${day.endHour}:00)';
//     }).toList();
//
//     return formattedDays.join(', ');
//   }
//
// // ---- Off Days as String ----
//   String getOffDaysAsString(Barber barber) {
//     if (barber.offDay.isEmpty) {
//       return 'No off days set';
//     }
//
//     return barber.offDay.join(', ');
//   }

// ---- Check if barber working today ----
  bool isBarberWorkingToday(Barber barber) {
    final today = DateTime.now().weekday; // 1=Mon .. 7=Sun

    try {
      return barber.workingDays.any((day) => day.day == today);
    } catch (_) {
      return false;
    }
  }

// ---- Count previous appointments ----
// ---- Count previous appointments ----
  int countPreviousAppointments(List<Appointment> allAppointments) {
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);

    return allAppointments.where((a) {
      final d = a.date;
      return d.isBefore(dayStart); // كل المواعيد اللي قبل بداية النهار
    }).length;
  }

// ---- Count today's appointments ----
  int countTodayAppointments(List<Appointment> allAppointments) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));

    return allAppointments.where((a) {
      final d = a.date;
      return !d.isBefore(dayStart) && !d.isAfter(dayEnd);
    }).length;
  }

// ---- Count upcoming appointments ----
  int countUpcomingAppointments(
    List<Appointment> allAppointments, {
    required int days,
    required bool includeToday,
  }) {
    final now = DateTime.now();
    final start = includeToday
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    final end = start
        .add(Duration(days: days))
        .subtract(const Duration(milliseconds: 1));

    return allAppointments.where((a) {
      final d = a.date;
      return !d.isBefore(start) && !d.isAfter(end);
    }).length;
  }
}

class Appointment {
  final DateTime date;

  Appointment({required this.date});

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // adjust if your API uses seconds instead of ms
    return Appointment(date: DateTime.parse(json['date'] as String));
    // or: DateTime.fromMillisecondsSinceEpoch(json['date'] as int);
  }
}
