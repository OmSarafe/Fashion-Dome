import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  ProductService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-west2');

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _functions;

  Stream<List<Product>> watchProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((document) => Product.fromMap(document.id, document.data()))
          .where((product) => product.name.isNotEmpty)
          .toList(growable: false);
      products.sort((left, right) {
        final categoryComparison = left.category.compareTo(right.category);
        return categoryComparison != 0
            ? categoryComparison
            : left.name.compareTo(right.name);
      });
      return products;
    });
  }

  String createProductId() {
    return _firestore.collection('products').doc().id;
  }

  Future<String> saveProduct(Product product) async {
    final reference = product.id.isEmpty
        ? _firestore.collection('products').doc()
        : _firestore.collection('products').doc(product.id);
    final existingSnapshot = await reference.get();
    final isNewProduct = !existingSnapshot.exists;
    final previousStock = (existingSnapshot.data()?['stock'] as num?)?.toInt();
    final batch = _firestore.batch();
    batch.set(
        reference,
        {
          ...product.toMap(),
          if (isNewProduct) 'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));

    if (isNewProduct || previousStock != product.stock) {
      final movementReference = reference.collection('stockMovements').doc();
      batch.set(movementReference, {
        'type': isNewProduct ? 'initial_stock' : 'admin_adjustment',
        'delta': isNewProduct ? product.stock : product.stock - previousStock!,
        'previousStock': previousStock ?? 0,
        'resultingStock': product.stock,
        'adminUserId': _firebaseAuth.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return reference.id;
  }

  Future<void> deleteProduct(String productId) async {
    await _functions.httpsCallable('deleteProduct').call({
      'productId': productId,
    });
  }

  Future<bool> seedStarterProductsIfNeeded(List<Product> products) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    final userReference = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userReference.get();
    final userData = userSnapshot.data();
    final currentVersion = (userData?['catalogVersion'] as num?)?.toInt() ?? 0;
    if (userData?['role'] != 'admin' || currentVersion >= 4) {
      return false;
    }

    final existingProducts = await _firestore.collection('products').get();
    final existingIds =
        existingProducts.docs.map((document) => document.id).toSet();

    final batch = _firestore.batch();
    for (final product in products) {
      final productReference =
          _firestore.collection('products').doc(product.id);
      if (existingIds.contains(product.id)) {
        batch.set(
          productReference,
          {
            'assetImagePath': product.assetImagePath,
            'outfitCategory': product.outfitCategory,
            'occasionTags': product.occasionTags,
            'colour': product.colour,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        batch.set(productReference, {
          ...product.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    batch.update(userReference, {
      'starterCatalogSeededAt': FieldValue.serverTimestamp(),
      'catalogVersion': 4,
    });
    await batch.commit();
    return true;
  }
}
