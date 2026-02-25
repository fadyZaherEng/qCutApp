import 'dart:convert';
import 'package:get/get.dart';
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';

class GalleryController extends GetxController {
  final NetworkAPICall _apiCall = NetworkAPICall();
  RxList<String> photos = <String>[].obs;
  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> fetchGallery(String barberId) async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response =
          await _apiCall.getData('${Variables.baseUrl}gallery/$barberId');

      print('Response status: ${response.body}');
      print('Response status code: ${response.statusCode}');
      print('Response bodyhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh: ${response.body}');
      if (response.statusCode == 200) {
        try {
          final dynamic decodedData = json.decode(response.body);

          // Handle case when response is not a Map
          if (decodedData is! Map<String, dynamic>) {
            photos.value = [];
            return;
          }

          final Map<String, dynamic> data = decodedData;

          // Handle both empty object {} and regular response with photos array
          if (data.isEmpty || data['photos'] == null) {
            photos.value = [];
          } else {
            List<String> photosList = List<String>.from(data['photos'] ?? []);
            photos.value = photosList;
          }
        } on FormatException catch (e) {
          // Handle JSON format issues
          photos.value = [];
          hasError.value = true;
          errorMessage.value = 'Invalid response format';
          print('Error parsing gallery response: $e');
        }
      } else {
        hasError.value = false;
        photos.value = [];
        print('Gallery API returned status: ${response.statusCode}, falling back to empty gallery');
      }
    } catch (e) {
      hasError.value = true;
      photos.value = []; // Ensure empty list on error
      errorMessage.value = e.toString();
      print('Error fetching gallery: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
