import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerence_project/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  UserProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Stream<UserProfile?> watchProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map(
      (snapshot) {
        final data = snapshot.data();
        return data == null ? null : UserProfile.fromMap(snapshot.id, data);
      },
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String deliveryAddress,
    required String gender,
    required DateTime? dateOfBirth,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid != userId) {
      throw FirebaseAuthException(
        code: 'user-mismatch',
        message: 'Please sign in again before updating your profile.',
      );
    }

    final trimmedName = name.trim();
    await user.updateDisplayName(trimmedName);
    await _firestore.collection('users').doc(userId).set({
      'name': trimmedName,
      'email': user.email ?? '',
      'phone': phone.trim(),
      'deliveryAddress': deliveryAddress.trim(),
      'gender': gender,
      'dateOfBirth':
          dateOfBirth == null ? FieldValue.delete() : _dateOnly(dateOfBirth),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateDeliveryAddress({
    required String userId,
    required String deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid != userId) {
      throw FirebaseAuthException(
        code: 'user-mismatch',
        message: 'Please sign in again before saving your address.',
      );
    }

    final updates = <String, dynamic>{
      'deliveryAddress': deliveryAddress.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (deliveryLatitude != null && deliveryLongitude != null) {
      updates['deliveryLatitude'] = deliveryLatitude;
      updates['deliveryLongitude'] = deliveryLongitude;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .set(updates, SetOptions(merge: true));
  }

  Future<void> updateOrderNotifications({
    required String userId,
    required bool enabled,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid != userId) {
      throw FirebaseAuthException(
        code: 'user-mismatch',
        message: 'Please sign in again before changing notifications.',
      );
    }

    await _firestore.collection('users').doc(userId).set({
      'orderNotificationsEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateMarketingNotifications({
    required String userId,
    required bool enabled,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.uid != userId) {
      throw FirebaseAuthException(
        code: 'user-mismatch',
        message: 'Please sign in again before changing notifications.',
      );
    }

    await _firestore.collection('users').doc(userId).set({
      'marketingNotificationsEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
