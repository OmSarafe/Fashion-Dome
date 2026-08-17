import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProductImageService {
  ProductImageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadProductImage({
    required String productId,
    required XFile image,
  }) async {
    final safeName = image.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final reference = _storage.ref('products/$productId/$fileName');
    final metadata = SettableMetadata(contentType: _contentType(image.name));
    await reference.putData(await image.readAsBytes(), metadata);
    return reference.getDownloadURL();
  }

  static String _contentType(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.endsWith('.png')) return 'image/png';
    if (lowerName.endsWith('.webp')) return 'image/webp';
    if (lowerName.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
