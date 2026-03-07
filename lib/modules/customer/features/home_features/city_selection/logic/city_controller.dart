import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';
import 'package:q_cut/modules/customer/features/home_features/city_selection/models/city_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CityController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();

  final RxList<City> cities = <City>[].obs;
  final RxList<City> filteredCities = <City>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalBarbers = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  // ✅ multi selection
  final RxSet<City> selectedCities = <City>{}.obs;
  final String _selectedCitiesKey = "selectedCities"; // مفتاح التخزين

  @override
  void onInit() {
    super.onInit();
    fetchCities();
  }

  Future<void> fetchCities({int limit = 20}) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final response = await _apiCall.getData(
        // '${Variables.baseUrl}mainDashboard/cities?page=${currentPage.value}&limit=$limit',
        '${Variables.baseUrl}mainDashboard/countBarber/byCity',
      );
      print("Url ${'${Variables.baseUrl}mainDashboard/countBarber/byCity'} ");
      final responseBody = json.decode(response.body);
      print(responseBody);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        final List<dynamic> barberCounts = responseBody['barberCounts'] ?? [];
        final List<City> fetchedCities = barberCounts
            .map((cityJson) => City.fromJson(cityJson))
            .toList();

        cities.assignAll(fetchedCities);
        filterCities(searchQuery.value);

        // ✅ بعد تحميل المدن من API نحمل الاختيارات المحفوظة ونربطها
        await loadSelectedCities();

        // ✅ تحديث معلومات الباجينيشن
        totalBarbers.value = responseBody['totalBarbers'] ?? 0;
        final pagination = responseBody['pagination'] ?? {};
        totalPages.value = pagination['totalPages'] ?? 1;
        currentPage.value = pagination['currentPage'] ?? 1;
      } else {
        isError.value = true;
        errorMessage.value =
            responseBody['message'] ?? 'Failed to fetch cities';
        Get.snackbar(
          'Error',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Network error: $e';
      Get.snackbar(
        'Error',
        'Failed to connect to server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> fetchCities() async {
  //   try {
  //     isLoading.value = true;
  //     isError.value = false;
  //     errorMessage.value = '';
  //
  //     final response = await _apiCall.getData(
  //       '${Variables.baseUrl}mainDashboard/countBarber/byCity?page=${currentPage.value}',
  //     );
  //
  //     final responseBody = json.decode(response.body);
  //     print(responseBody);
  //
  //     if (response.statusCode == 200) {
  //       final cityResponse = CityResponse.fromJson(responseBody);
  //       cities.assignAll(cityResponse.cities);
  //       filterCities(searchQuery.value);
  //
  //       // ✅ بعد تحميل المدن من API نحمل الاختيارات المحفوظة ونربطها
  //       await loadSelectedCities();
  //
  //       totalBarbers.value = cityResponse.totalBarbers;
  //       totalPages.value = cityResponse.pagination.totalPages;
  //     } else {
  //       isError.value = true;
  //       errorMessage.value =
  //           responseBody['message'] ?? 'Failed to fetch cities';
  //       Get.snackbar(
  //         'Error',
  //         errorMessage.value,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //     }
  //   } catch (e) {
  //     isError.value = true;
  //     errorMessage.value = 'Network error: $e';
  //     Get.snackbar(
  //       'Error',
  //       'Failed to connect to server',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void loadMore() async {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      await fetchCities();
    }
  }

  @override
  void refresh() {
    currentPage.value = 1;
    fetchCities();
  }

  void searchCities(String query) {
    searchQuery.value = query;
    filterCities(query);
  }

  void filterCities(String query) {
    if (query.isEmpty) {
      filteredCities.assignAll(cities);
    } else {
      filteredCities.assignAll(
        cities
            .where(
                (city) => city.name.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  bool isCitySelected(City city) {
    return selectedCities.any((c) => c.name == city.name);
  }

  bool isAllSelected() {
    if (filteredCities.isEmpty) return false;
    return filteredCities.every((city) => isCitySelected(city));
  }

  void toggleSelectAll() async {
    if (isAllSelected()) {
      selectedCities.clear();
    } else {
      selectedCities.addAll(filteredCities);
    }
    selectedCities.refresh();
    await saveSelectedCities();
  }

  void toggleCitySelection(City city) async {
    if (isCitySelected(city)) {
      selectedCities.removeWhere((c) => c.name == city.name);
    } else {
      selectedCities.add(city);
    }
    selectedCities.refresh();
    await saveSelectedCities(); // ✅ حفظ الاختيارات بعد أي تغيير
  }

  String getSelectedCitiesAsString() {
    return selectedCities.map((c) => c.name.trim()).join(', ');
  }

  List<City> getSelectedCitiesAsList() {
    return selectedCities.toList();
  }

  void clearSelection() async {
    selectedCities.clear();
    await saveSelectedCities();
  }

  void clearSelections() async {
    selectedCities.clear();
    await saveSelectedCities();
  }

  // ✅ حفظ المدن المختارة في التخزين المحلي
  Future<void> saveSelectedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = selectedCities.map((city) => city.name).toList();
    await prefs.setStringList(_selectedCitiesKey, ids);
  }

  // ✅ استرجاع المدن المختارة من التخزين المحلي
  Future<void> loadSelectedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNames = prefs.getStringList(_selectedCitiesKey) ?? [];

    final restoredCities =
        cities.where((city) => savedNames.contains(city.name)).toSet();

    selectedCities.assignAll(restoredCities);
    selectedCities.refresh();
  }

  @override
  void onClose() {
    searchQuery.close();
    selectedCities.close();
    super.onClose();
  }
}
