import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  File? _mediaFile;
  bool _isVideo = false;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _capturePhoto();
    } else if (status.isDenied) {
      _showMessage('Camera permission denied');
    } else if (status.isPermanentlyDenied) {
      _showMessage('Camera permission permanently denied. Please enable in settings.');
      openAppSettings();
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _mediaFile = File(photo.path);
          _isVideo = false;
        });
      }
    } catch (e) {
      _showMessage('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _mediaFile = File(photo.path);
          _isVideo = false;
        });
      }
    } catch (e) {
      _showMessage('Failed to pick photo: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        setState(() {
          _mediaFile = File(video.path);
          _isVideo = true;
        });
      }
    } catch (e) {
      _showMessage('Failed to pick video: $e');
    }
  }

  Future<void> _uploadMedia() async {
    if (_mediaFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload to server
      final success = await ApiService.instance.uploadMedia(_mediaFile!, _isVideo);
      
      if (success) {
        // Save a copy locally in the "uploaded" folder
        await LocalStorageService.instance.saveUploadedMedia(_mediaFile!, _isVideo);
        
        _showMessage('${_isVideo ? "Video" : "Photo"} uploaded and saved successfully!');
        setState(() {
          _mediaFile = null;
          _isVideo = false;
        });
      } else {
        _showMessage('Upload failed');
      }
    } catch (e) {
      _showMessage('Upload error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Media'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_mediaFile != null)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _isVideo
                              ? Container(
                                  color: Colors.black,
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.video_library, size: 80, color: Colors.white),
                                        SizedBox(height: 16),
                                        Text(
                                          'Video Selected',
                                          style: TextStyle(color: Colors.white, fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Image.file(
                                  _mediaFile!,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : () {
                              setState(() {
                                _mediaFile = null;
                                _isVideo = false;
                              });
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Discard'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _uploadMedia,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.upload),
                            label: Text(_isUploading ? 'Uploading...' : 'Upload'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 100,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose media to upload',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _requestCameraPermission,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text('Choose Video'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(200, 50),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
