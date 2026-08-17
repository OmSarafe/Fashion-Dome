import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  CategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<String>> watchCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      final names = snapshot.docs
          .map((document) => document.data()['name'] as String? ?? '')
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList(growable: false);
      names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return names;
    });
  }

  Future<void> addCategory(String name) async {
    final normalized = _validateName(name);
    await _firestore.collection('categories').doc(_documentId(normalized)).set({
      'name': normalized,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> renameCategory(String oldName, String newName) async {
    final normalizedOld = _validateName(oldName);
    final normalizedNew = _validateName(newName);
    if (normalizedOld.toLowerCase() == normalizedNew.toLowerCase()) return;

    final products = await _firestore
        .collection('products')
        .where('category', isEqualTo: normalizedOld)
        .get();
    final batch = _firestore.batch();
    final newReference =
        _firestore.collection('categories').doc(_documentId(normalizedNew));
    batch.set(
        newReference,
        {
          'name': normalizedNew,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));
    for (final product in products.docs) {
      batch.update(product.reference, {
        'category': normalizedNew,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    batch.delete(
      _firestore.collection('categories').doc(_documentId(normalizedOld)),
    );
    await batch.commit();
  }

  Future<void> deleteCategory(String name) async {
    final normalized = _validateName(name);
    final products = await _firestore
        .collection('products')
        .where('category', isEqualTo: normalized)
        .limit(1)
        .get();
    if (products.docs.isNotEmpty) {
      throw StateError(
        'Move or delete products in this category before deleting it.',
      );
    }
    await _firestore
        .collection('categories')
        .doc(_documentId(normalized))
        .delete();
  }

  String _validateName(String value) {
    final name = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.length < 2 || name.length > 40) {
      throw ArgumentError('Category names must contain 2–40 characters.');
    }
    return name;
  }

  String _documentId(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? Uri.encodeComponent(value.toLowerCase()) : slug;
  }
}
