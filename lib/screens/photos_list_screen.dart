import 'package:flutter/material.dart';
import '../models/photo_item.dart';
import '../services/api_service.dart';

class PhotosListScreen extends StatefulWidget {
  const PhotosListScreen({super.key});

  @override
  State<PhotosListScreen> createState() => _PhotosListScreenState();
}

class _PhotosListScreenState extends State<PhotosListScreen> {
  List<PhotoItem> _photos = [];
  bool _isLoading = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photos = await ApiService.instance.fetchPhotos();
      setState(() {
        _photos = photos;
      });
    } catch (e) {
      _showMessage('Failed to load photos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPhoto(String filename) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final filePath = await ApiService.instance.downloadPhoto(filename);
      _showMessage('Downloaded to: $filePath');
    } catch (e) {
      _showMessage('Download failed: $e');
    } finally {
      setState(() {
        _isDownloading = false;
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
        title: const Text('Server Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPhotos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No photos found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _photos.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final photo = _photos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: const Icon(Icons.photo, color: Colors.blue),
                        title: Text(photo.filename),
                        trailing: _isDownloading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download),
                        onTap: _isDownloading
                            ? null
                            : () => _downloadPhoto(photo.filename),
                      ),
                    );
                  },
                ),
    );
  }
}
