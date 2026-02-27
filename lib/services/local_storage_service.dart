import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._internal();
  LocalStorageService._internal();

  Future<String> saveUploadedMedia(File mediaFile, bool isVideo) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final uploadedDir = Directory('${directory.path}/uploaded');
      
      if (!await uploadedDir.exists()) {
        await uploadedDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(mediaFile.path);
      final fileName = 'uploaded_$timestamp$extension';
      final savedPath = '${uploadedDir.path}/$fileName';

      await mediaFile.copy(savedPath);
      return savedPath;
    } catch (e) {
      throw Exception('Failed to save media locally: $e');
    }
  }

  Future<List<File>> getUploadedPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final uploadedDir = Directory('${directory.path}/uploaded');

      if (!await uploadedDir.exists()) {
        return [];
      }

      final files = uploadedDir.listSync()
          .whereType<File>()
          .where((file) => 
              file.path.endsWith('.jpg') || 
              file.path.endsWith('.jpeg') || 
              file.path.endsWith('.png') ||
              file.path.endsWith('.mp4') ||
              file.path.endsWith('.mov') ||
              file.path.endsWith('.avi'))
          .toList();

      files.sort((a, b) => b.path.compareTo(a.path));
      return files;
    } catch (e) {
      throw Exception('Failed to load uploaded media: $e');
    }
  }

  Future<void> deleteUploadedPhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete media: $e');
    }
  }

  bool isVideo(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ext == '.mp4' || ext == '.mov' || ext == '.avi';
  }
}
