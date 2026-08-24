import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerence_project/models/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentResult {
  const StripePaymentResult({
    required this.paymentIntentId,
    required this.totalInPence,
  });

  final String paymentIntentId;
  final int totalInPence;
}

class StripePaymentService {
  StripePaymentService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'europe-west2');

  final FirebaseFunctions _functions;

  Future<StripePaymentResult> pay({required List<CartItem> items}) async {
    final response = await _functions
        .httpsCallable('createStripePaymentIntent')
        .call(<String, dynamic>{
      'items': items
          .map(
            (item) => <String, dynamic>{
              'productId': item.product.id,
              'size': item.size,
              'quantity': item.quantity,
            },
          )
          .toList(growable: false),
    });

    final data = Map<String, dynamic>.from(response.data as Map);
    final publishableKey = data['publishableKey'] as String? ?? '';
    final clientSecret = data['clientSecret'] as String? ?? '';
    final paymentIntentId = data['paymentIntentId'] as String? ?? '';
    final totalInPence = (data['totalInPence'] as num?)?.toInt() ?? 0;
    if (publishableKey.isEmpty ||
        clientSecret.isEmpty ||
        paymentIntentId.isEmpty ||
        totalInPence <= 0) {
      throw StateError('Stripe returned an incomplete payment response.');
    }

    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Fashion Dome',
        style: ThemeMode.system,
        allowsDelayedPaymentMethods: false,
      ),
    );
    await Stripe.instance.presentPaymentSheet();

    return StripePaymentResult(
      paymentIntentId: paymentIntentId,
      totalInPence: totalInPence,
    );
  }
}
