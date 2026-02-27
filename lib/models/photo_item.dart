class PhotoItem {
  final String filename;

  PhotoItem({required this.filename});

  factory PhotoItem.fromJson(Map<String, dynamic> json) {
    return PhotoItem(
      filename: json['filename'] as String,
    );
  }
}
