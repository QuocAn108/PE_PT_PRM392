import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Data/ApiResponse/base_response.dart';

abstract class BaseRepository {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<BaseResponse<Map<String, dynamic>>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

  Future<BaseResponse<Map<String, dynamic>>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<BaseResponse<Map<String, dynamic>>> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<BaseResponse<Map<String, dynamic>>> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

  BaseResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BaseResponse<Map<String, dynamic>>.fromJson(jsonResponse, (data) => data);
    } else {
      return BaseResponse<Map<String, dynamic>>(
        success: false,
        message: jsonResponse['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
      );
    }
  }
}
