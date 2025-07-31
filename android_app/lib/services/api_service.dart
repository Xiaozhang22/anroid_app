import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class ApiService {
  static String? _baseUrl;
  static String? _deviceId;

  static Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('server_url');
    _deviceId = prefs.getString('device_id');
  }

  static Future<bool> registerDevice(String serverUrl, String deviceName) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_name': deviceName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _deviceId = data['device_id'];
        _baseUrl = serverUrl;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('server_url', serverUrl);
        await prefs.setString('device_id', _deviceId!);
        await prefs.setString('device_name', deviceName);

        return true;
      }
    } catch (e) {
      print('Registration error: $e');
    }
    return false;
  }

  static Future<List<Task>> getTasks() async {
    if (_baseUrl == null || _deviceId == null) {
      await initialize();
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tasks/$_deviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> tasksJson = data['tasks'];
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      }
    } catch (e) {
      print('Get tasks error: $e');
    }
    return [];
  }

  static Future<bool> updateTaskStatus(int taskId, String status, String result) async {
    if (_baseUrl == null || _deviceId == null) {
      await initialize();
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/tasks/$taskId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': _deviceId,
          'status': status,
          'result': result,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update task status error: $e');
    }
    return false;
  }

  static Future<bool> testConnection(String serverUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/devices'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test error: $e');
    }
    return false;
  }
}