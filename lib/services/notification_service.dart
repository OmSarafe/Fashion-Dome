import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'msc_clothing_notifications',
    'Fashion Dome notifications',
    description: 'Order updates, new products and promotional offers.',
    importance: Importance.max,
  );

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    _messageSubscription ??= FirebaseMessaging.onMessage.listen((message) {
      unawaited(_showForegroundNotification(message));
    });
    _tokenSubscription ??= _messaging.onTokenRefresh.listen((token) {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        unawaited(_saveTokenWithRetry(user.uid, token));
      }
    });
    _authSubscription ??=
        _firebaseAuth.authStateChanges().listen(_handleAuthStateChanged);

    final user = _firebaseAuth.currentUser;
    if (user != null) await _registerDevice(user.uid);
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(initializationSettings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'msc_clothing_notifications',
        'Fashion Dome notifications',
        channelDescription:
            'Order updates, new products and promotional offers.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _localNotifications.show(
      message.messageId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      notification.title ?? 'Fashion Dome',
      notification.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    if (user != null) await _registerDevice(user.uid);
  }

  Future<void> _registerDevice(String userId) async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await _messaging.getToken();
      if (token != null) await _saveTokenWithRetry(userId, token);
    } catch (error) {
      debugPrint('Unable to register notifications: $error');
    }
  }

  Future<void> _saveTokenWithRetry(String userId, String token) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _firestore.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
        }, SetOptions(merge: true));
        return;
      } catch (error) {
        if (attempt == 2) {
          debugPrint('Unable to save notification token: $error');
          return;
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> removeCurrentDeviceToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (error) {
      debugPrint('Unable to remove notification token: $error');
    }
  }
}
