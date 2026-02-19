import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:q_cut/core/services/shared_pref/pref_keys.dart';
import 'package:q_cut/core/services/shared_pref/shared_pref.dart';
import 'package:q_cut/core/utils/network/api.dart';

var token;

class NetworkAPICall {
  postDataAsGuest(data, apiUrl) async {
    return await http.post(Uri.parse(apiUrl), body: jsonEncode(data), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    }).timeout(
      Duration(seconds: 5),
      onTimeout: () {
        return http.Response('Error Time out', 408);
      },
    );
  }

  getData(apiUrl, {dynamic body}) async {
    token = SharedPref().getString(PrefKeys.accessToken);
    final request = http.Request('GET', Uri.parse(apiUrl));
    request.headers.addAll(_setHeaders());

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw TimeoutException('Request timed out');
      },
    );

    return http.Response.fromStream(streamedResponse).catchError((_) {
      return http.Response('Error Time out', 408);
    });
  }

  getDataWithoutTimout(apiUrl) async {
    token = SharedPref().getString(PrefKeys.accessToken);

    return await http.get(Uri.parse(apiUrl), headers: _setHeaders());
  }

  Future<http.Response> getDataAsGuest(String baseUrl,
      {Map<String, dynamic>? params}) async {
    print("params from network: $params");
    // Construct the full URL with parameters
    var uri = Uri.parse(baseUrl);
    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    return await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        // Timeout handling logic
        return http.Response('Error Time out', 408);
      },
    );
  }

  addData(data, apiUrl) async {
    token = SharedPref().getString(PrefKeys.accessToken);
    return await http
        .post(Uri.parse(apiUrl), body: jsonEncode(data), headers: _setHeaders())
        .timeout(
      Duration(seconds: 5),
      onTimeout: () {
        return http.Response('Error Time out', 408);
      },
    );
  }

  Future<http.Response> putData(
    String apiUrl,
    dynamic data,
  ) async {
    token = SharedPref().getString(PrefKeys.accessToken);
    return await http
        .put(Uri.parse(apiUrl), body: jsonEncode(data), headers: _setHeaders())
        .timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response('Error Time out', 408);
      },
    );
  }

  Future<http.Response> editData(String url, dynamic data) async {
    try {
      // Prepare headers with token if available
      Map<String, String> headers = await _setHeaders();

      // If data is already a String, assume it's already JSON encoded
      // Otherwise, encode the Map/object to JSON
      final body = data is String ? data : json.encode(data);

      print('Sending PUT request to: $url');
      print('Request data: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response;
    } catch (e) {
      print('Error in editData: $e');
      rethrow;
    }
  }

  deleteData(apiUrl) async {
    token = SharedPref().getString(PrefKeys.accessToken);
    return await http.delete(Uri.parse(apiUrl), headers: _setHeaders()).timeout(
      Duration(seconds: 5),
      onTimeout: () {
        return http.Response('Error Time out', 408);
      },
    );
  }

  Future<http.Response> deleteDataWithBody(String apiUrl, dynamic data) async {
    token = SharedPref().getString(PrefKeys.accessToken);

    final request = http.Request('DELETE', Uri.parse(apiUrl));
    request.headers.addAll(_setHeaders());
    request.body = jsonEncode(data);

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw TimeoutException('Request timed out');
      },
    );

    return http.Response.fromStream(streamedResponse).catchError((_) {
      return http.Response('Error Time out', 408);
    });
  }

  Future<http.Response> getPresignedUrl(String type, int count) async {
    token = SharedPref().getString(PrefKeys.accessToken);
    final url =
        '${Variables.baseUrl}media/generate-url?type=$type&count=$count';
    return await http.get(Uri.parse(url), headers: _setHeaders()).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response('Error Time out', 408);
      },
    );
  }

  Future<http.Response> uploadFileToPresignedUrl(
    String presignedUrl,
    List<int> fileBytes,
    String contentType,
  ) async {
    print('Uploading ${fileBytes.length} bytes to S3...');
    return await http.put(
      Uri.parse(presignedUrl),
      headers: {
        'Content-Type': contentType,
        'Content-Length': fileBytes.length.toString(),
      },
      body: fileBytes,
    );
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
}
