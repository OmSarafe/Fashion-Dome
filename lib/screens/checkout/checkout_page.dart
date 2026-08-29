import 'package:ecommerence_project/screens/navigation/bottom_nav_bar_page.dart';
import 'package:ecommerence_project/screens/checkout/map_address_picker_page.dart';
import 'package:ecommerence_project/models/order.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/services/stripe_payment_service.dart';
import 'package:ecommerence_project/utils/cart_calculator.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ecommerence_project/widgets/address_autocomplete_field.dart';
import 'package:ecommerence_project/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const _shippingInPence = CartCalculator.standardShippingInPence;

  final _deliveryAddressController = TextEditingController();
  final _stripePaymentService = StripePaymentService();
  String _paymentMethod = 'Cash on delivery';
  bool _isPlacingOrder = false;
  bool _addressInitialized = false;
  LatLng? _selectedLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_addressInitialized) return;
    final profile = context.read<ShopProvider>().userProfile;
    if (profile == null) return;
    _deliveryAddressController.text = profile.deliveryAddress;
    if (profile.deliveryLatitude != null && profile.deliveryLongitude != null) {
      _selectedLocation = LatLng(
        profile.deliveryLatitude!,
        profile.deliveryLongitude!,
      );
    }
    _addressInitialized = true;
  }

  Future<void> _chooseLocation() async {
    final selection = await Navigator.push<MapAddressSelection>(
      context,
      MaterialPageRoute(
        builder: (_) => MapAddressPickerPage(
          initialLocation: _selectedLocation,
        ),
      ),
    );
    if (selection != null && mounted) {
      setState(() {
        _selectedLocation = selection.location;
        if (selection.address.isNotEmpty) {
          _deliveryAddressController.text = selection.address;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final items = shop.cartItems;
    final stockIssue = shop.cartStockIssue;

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Your cart is empty.')),
      );
    }

    final totalInPence = CartCalculator.totalInPence(shop.subtotalInPence);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 140),
          children: [
            _CheckoutSection(
              title: 'Delivery address',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isPlacingOrder ? null : _chooseLocation,
                    icon: const Icon(Icons.map_outlined),
                    label: Text(
                      _selectedLocation == null
                          ? 'Choose location on map'
                          : 'Change map location',
                    ),
                  ),
                  if (_selectedLocation != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Delivery pin selected. Confirm your full address below.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  AddressAutocompleteField(
                    controller: _deliveryAddressController,
                    enabled: !_isPlacingOrder,
                    helperText:
                        'Select a suggestion or continue typing manually.',
                    onManualChanged: () => _selectedLocation = null,
                    onSelection: (selection) {
                      setState(() {
                        _selectedLocation = LatLng(
                          selection.latitude,
                          selection.longitude,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CheckoutSection(
              title: 'Order items (${items.length})',
              child: Column(
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ProductImage(
                            product: item.product,
                            width: 58,
                            height: 68,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Size ${item.size} · Quantity ${item.quantity}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatPounds(item.lineTotalInPence),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _CheckoutSection(
              title: 'Payment method',
              child: Column(
                children: [
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: 'Cash on delivery',
                    groupValue: _paymentMethod,
                    onChanged: _isPlacingOrder
                        ? null
                        : (value) => setState(() => _paymentMethod = value!),
                    secondary: const Icon(Icons.payments_outlined),
                    title: const Text('Cash on delivery'),
                    subtitle: const Text('Pay when your order is delivered.'),
                  ),
                  const Divider(),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: 'Stripe card payment',
                    groupValue: _paymentMethod,
                    onChanged: _isPlacingOrder
                        ? null
                        : (value) => setState(() => _paymentMethod = value!),
                    secondary: const Icon(Icons.credit_card_outlined),
                    title: const Text('Debit or credit card'),
                    subtitle:
                        const Text('Secure test payment powered by Stripe.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CheckoutSection(
              title: 'Payment summary',
              child: Column(
                children: [
                  _PriceRow(
                    label: 'Subtotal',
                    value: formatPounds(shop.subtotalInPence),
                  ),
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Shipping',
                    value: formatPounds(_shippingInPence),
                  ),
                  const Divider(height: 24),
                  _PriceRow(
                    label: 'Total',
                    value: formatPounds(totalInPence),
                    emphasized: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: SizedBox(
            height: 54,
            child: FilledButton(
              onPressed:
                  _isPlacingOrder || stockIssue != null ? null : _placeOrder,
              child: _isPlacingOrder
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Place order · ${formatPounds(totalInPence)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    final stockIssue = context.read<ShopProvider>().cartStockIssue;
    if (stockIssue != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(stockIssue)),
      );
      return;
    }
    final deliveryAddress = _deliveryAddressController.text.trim();
    if (deliveryAddress.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your full delivery address.')),
      );
      return;
    }
    setState(() => _isPlacingOrder = true);

    StripePaymentResult? stripePayment;
    try {
      final shop = context.read<ShopProvider>();
      if (_paymentMethod == 'Stripe card payment') {
        stripePayment = await _stripePaymentService.pay(
          items: shop.cartItems,
        );
        final expectedTotal = CartCalculator.totalInPence(shop.subtotalInPence);
        if (stripePayment.totalInPence != expectedTotal) {
          throw StateError('The cart total changed during payment.');
        }
      }

      final order = await shop.placeOrder(
        deliveryAddress: deliveryAddress,
        deliveryLatitude: _selectedLocation?.latitude,
        deliveryLongitude: _selectedLocation?.longitude,
        paymentMethod: _paymentMethod,
        stripePaymentIntentId: stripePayment?.paymentIntentId,
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _OrderSuccessDialog(order: order),
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
        (route) => false,
      );
    } on StripeException catch (error) {
      if (!mounted) return;
      final wasCancelled = error.error.code == FailureCode.Canceled;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasCancelled
                ? 'Payment cancelled. Your cart is unchanged.'
                : 'Stripe could not complete the payment. Please try again.',
          ),
        ),
      );
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ??
                'The order could not be completed. Please try again.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to place the order. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    super.dispose();
  }
}

class _CheckoutSection extends StatelessWidget {
  const _CheckoutSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: emphasized ? 17 : 14,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasized ? 17 : 14,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OrderSuccessDialog extends StatelessWidget {
  const _OrderSuccessDialog({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final shortId = order.id.substring(order.id.length - 6);
    return AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
      title: const Text('Order placed!'),
      content: Text(
        'Your order #$shortId was created successfully. You can track it from My Orders.',
        textAlign: TextAlign.center,
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue shopping'),
          ),
        ),
      ],
    );
  }
}
