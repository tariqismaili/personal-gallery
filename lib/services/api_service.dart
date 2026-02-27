import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/photo_item.dart';
import 'settings_service.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String get _baseUrl => SettingsService.instance.baseUrl;

  Future<bool> uploadMedia(File mediaFile, bool isVideo) async {
    try {
      final uri = Uri.parse('$_baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.files.add(
        await http.MultipartFile.fromPath('file', mediaFile.path),
      );

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<List<PhotoItem>> fetchPhotos() async {
    try {
      final uri = Uri.parse('$_baseUrl/photos');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => PhotoItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load photos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch photos: $e');
    }
  }

  Future<String> downloadPhoto(String filename) async {
    try {
      final uri = Uri.parse('$_baseUrl/download/$filename');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Download failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to download photo: $e');
    }
  }
}
