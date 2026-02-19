import 'package:http/http.dart' as http;
import 'package:q_cut/core/utils/network/api.dart';
import 'package:q_cut/core/utils/network/network_helper.dart';

class AuthService {
  final NetworkAPICall _apiCall = NetworkAPICall();

  Future<http.Response> changePassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    final String url = '${Variables.baseUrl}authentication/change-password';

    final Map<String, dynamic> body = {
      'phoneNumber': phoneNumber,
      'otp': otp,
      'newPassword': newPassword,
    };

    return await _apiCall.postDataAsGuest(body, url);
  }
}
