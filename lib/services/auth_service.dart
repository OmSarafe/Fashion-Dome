import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerence_project/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    FirebaseFunctions? functions,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-west2');

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FirebaseFunctions _functions;

  User? get currentUser => _firebaseAuth.currentUser;

  bool get currentUserUsesPassword =>
      currentUser?.providerData.any(
        (provider) => provider.providerId == 'password',
      ) ??
      false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'The account could not be created.',
      );
    }

    try {
      await user.updateDisplayName(trimmedName);
      await _firestore.collection('users').doc(user.uid).set({
        'name': trimmedName,
        'email': trimmedEmail,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return credential;
    } catch (_) {
      await user.delete();
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    try {
      final googleAuthentication = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'google-user-not-created',
          message: 'Google Sign-In could not create the account.',
        );
      }

      final profileReference = _firestore.collection('users').doc(user.uid);
      final existingProfile = await profileReference.get();
      final email = user.email ?? googleUser.email;
      final suggestedName =
          user.displayName ?? googleUser.displayName ?? email.split('@').first;
      final name =
          suggestedName.trim().isEmpty ? 'Customer' : suggestedName.trim();

      final profileData = <String, Object?>{
        'name': name,
        'email': email,
      };
      if (!existingProfile.exists) {
        profileData.addAll({
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await profileReference.set(profileData, SetOptions(merge: true));

      return result;
    } catch (_) {
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> deleteCurrentAccount({String? password}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Please sign in again before deleting your account.',
      );
    }

    await _reauthenticate(user, password: password);
    await user.getIdToken(true);
    await _functions.httpsCallable('deleteCustomerAccount').call();
    await _firebaseAuth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // The Firebase account is already deleted, so Google cleanup is best-effort.
    }
  }

  Future<void> _reauthenticate(User user, {String? password}) async {
    final usesPassword = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );

    if (usesPassword) {
      final email = user.email;
      if (email == null || password == null || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-password',
          message: 'Enter your password to confirm account deletion.',
        );
      }
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
      return;
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google confirmation was cancelled.',
      );
    }
    final googleAuthentication = await googleUser.authentication;
    await user.reauthenticateWithCredential(
      GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      ),
    );
  }

  Future<void> signOut() async {
    await NotificationService.instance.removeCurrentDeviceToken();
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
