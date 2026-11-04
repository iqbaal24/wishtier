import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorage {
  const ImageStorage._();

  static const _folder = 'wish_photos';

  static Future<String?> pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 86,
    );
    if (picked == null) return null;

    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(documents.path, _folder));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final extension = p.extension(picked.path);
    final fileName =
        '${const Uuid().v4()}${extension.isEmpty ? '.jpg' : extension}';
    final destination = p.join(folder.path, fileName);
    final saved = await File(picked.path).copy(destination);
    return saved.path;
  }

  static Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      return;
    }
  }
}
