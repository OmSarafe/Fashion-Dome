import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrencyMigrationService {
  CurrencyMigrationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<void> migrateToPenceIfNeeded() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final userReference = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userReference.get();
    final userData = userSnapshot.data();
    if (userData?['role'] != 'admin' ||
        userData?['currencyMigratedToGbpAt'] != null) {
      return;
    }

    final productsSnapshot = await _firestore.collection('products').get();
    final ordersSnapshot = await _firestore.collection('orders').get();
    final pendingUpdates = <_MigrationUpdate>[];

    for (final productDocument in productsSnapshot.docs) {
      final data = productDocument.data();
      final updates = <String, dynamic>{};
      if (data['priceInPence'] == null && data['priceInPaise'] is num) {
        updates['priceInPence'] = (data['priceInPaise'] as num).toInt() ~/ 100;
        updates['priceInPaise'] = FieldValue.delete();
      }
      if (!data.containsKey('compareAtPriceInPence') &&
          data.containsKey('compareAtPriceInPaise')) {
        final oldPrice = data['compareAtPriceInPaise'];
        updates['compareAtPriceInPence'] =
            oldPrice is num ? oldPrice.toInt() ~/ 100 : null;
        updates['compareAtPriceInPaise'] = FieldValue.delete();
      }
      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        pendingUpdates.add(_MigrationUpdate(productDocument.reference, updates));
      }
    }

    for (final orderDocument in ordersSnapshot.docs) {
      final data = orderDocument.data();
      final updates = <String, dynamic>{};
      _moveMoneyField(data, updates, 'subtotalInPaise', 'subtotalInPence');
      _moveMoneyField(data, updates, 'shippingInPaise', 'shippingInPence');
      _moveMoneyField(data, updates, 'totalInPaise', 'totalInPence');

      final oldItems = data['items'];
      if (oldItems is List<dynamic>) {
        updates['items'] = oldItems.map((rawItem) {
          final item = Map<String, dynamic>.from(
            rawItem as Map<dynamic, dynamic>,
          );
          final rawProduct = item['product'];
          if (rawProduct is Map<dynamic, dynamic>) {
            final product = Map<String, dynamic>.from(rawProduct);
            _replaceNestedMoneyField(
              product,
              'priceInPaise',
              'priceInPence',
            );
            _replaceNestedMoneyField(
              product,
              'compareAtPriceInPaise',
              'compareAtPriceInPence',
            );
            item['product'] = product;
          }
          return item;
        }).toList(growable: false);
      }

      if (updates.isNotEmpty) {
        pendingUpdates.add(_MigrationUpdate(orderDocument.reference, updates));
      }
    }

    const batchLimit = 400;
    for (var start = 0; start < pendingUpdates.length; start += batchLimit) {
      final batch = _firestore.batch();
      final end = start + batchLimit < pendingUpdates.length
          ? start + batchLimit
          : pendingUpdates.length;
      for (final update in pendingUpdates.sublist(start, end)) {
        batch.update(update.reference, update.data);
      }
      await batch.commit();
    }

    await userReference.update({
      'currency': 'GBP',
      'currencyMigratedToGbpAt': FieldValue.serverTimestamp(),
    });
  }

  static void _moveMoneyField(
    Map<String, dynamic> source,
    Map<String, dynamic> updates,
    String oldKey,
    String newKey,
  ) {
    if (source[newKey] == null && source[oldKey] is num) {
      updates[newKey] = (source[oldKey] as num).toInt() ~/ 100;
      updates[oldKey] = FieldValue.delete();
    }
  }

  static void _replaceNestedMoneyField(
    Map<String, dynamic> data,
    String oldKey,
    String newKey,
  ) {
    if (!data.containsKey(newKey) && data.containsKey(oldKey)) {
      final oldValue = data.remove(oldKey);
      data[newKey] = oldValue is num ? oldValue.toInt() ~/ 100 : null;
    }
  }
}

class _MigrationUpdate {
  const _MigrationUpdate(this.reference, this.data);

  final DocumentReference<Map<String, dynamic>> reference;
  final Map<String, dynamic> data;
}
