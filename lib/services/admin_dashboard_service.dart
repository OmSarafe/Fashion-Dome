import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardService {
  AdminDashboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<int> watchCustomerCount() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
