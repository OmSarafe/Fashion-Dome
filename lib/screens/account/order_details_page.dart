import 'package:ecommerence_project/models/order.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/widgets/product_image.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final shortId = order.id.length > 6
        ? order.id.substring(order.id.length - 6)
        : order.id;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #$shortId',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            _Section(title: 'Order status', child: _Timeline(order: order)),
            const SizedBox(height: 14),
            _Section(
              title: 'Items (${order.items.length})',
              child: Column(
                children: order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ProductImage(
                            product: item.product,
                            width: 64,
                            height: 76,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 5),
                              Text('Size: ${item.size}'),
                              Text('Quantity: ${item.quantity}'),
                              Text(
                                  '${formatPounds(item.product.priceInPence)} each'),
                            ],
                          ),
                        ),
                        Text(
                          formatPounds(item.lineTotalInPence),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Payment',
              child: Column(
                children: [
                  _InfoRow(
                    icon: order.paymentMethod == 'Stripe card payment'
                        ? Icons.credit_card_outlined
                        : Icons.payments_outlined,
                    label: 'Method',
                    value: order.paymentMethod.isEmpty
                        ? 'Not recorded'
                        : order.paymentMethod,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: _paymentIcon(order.paymentStatus),
                    label: 'Payment status',
                    value: _paymentLabel(order),
                  ),
                  if (order.stripePaymentIntentId != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'Reference',
                      value: _shortReference(order.stripePaymentIntentId!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Delivery address',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 10),
                  Expanded(child: Text(order.deliveryAddress)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Order summary',
              child: Column(
                children: [
                  _PriceRow(
                      label: 'Subtotal',
                      value: formatPounds(order.subtotalInPence)),
                  const SizedBox(height: 10),
                  _PriceRow(
                      label: 'Shipping',
                      value: formatPounds(order.shippingInPence)),
                  const Divider(height: 24),
                  _PriceRow(
                      label: 'Total',
                      value: formatPounds(order.totalInPence),
                      emphasized: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Ordered ${_formatDateTime(order.createdAt)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _paymentLabel(Order order) => switch (order.paymentStatus) {
        'paid' => 'Paid',
        'verification_pending' => 'Verification pending',
        'failed' => 'Failed',
        'refunded' => 'Refunded',
        'cancelled' => 'Cancelled',
        _ when order.paymentMethod == 'Cash on delivery' => 'Pay on delivery',
        _ => 'Pending',
      };

  static IconData _paymentIcon(String status) => switch (status) {
        'paid' => Icons.check_circle_outline,
        'refunded' => Icons.replay_circle_filled_outlined,
        'failed' || 'cancelled' => Icons.error_outline,
        _ => Icons.schedule_outlined,
      };

  static String _shortReference(String value) {
    if (value.length <= 16) return value;
    return '${value.substring(0, 8)}…${value.substring(value.length - 6)}';
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} at $hour:$minute';
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    if (order.status == OrderStatus.cancelled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TimelineStep(label: 'Order placed', completed: true),
          const _TimelineStep(
            label: 'Order cancelled',
            completed: true,
            isError: true,
            isLast: true,
          ),
          if (order.cancelledBy != null)
            Text(
              'Cancelled by ${order.cancelledBy == 'customer' ? 'you' : 'the store'}'
              '${order.cancelledAt == null ? '' : ' on ${OrderDetailsPage._formatDateTime(order.cancelledAt!)}'}.',
            ),
        ],
      );
    }

    final currentStep = switch (order.status) {
      OrderStatus.placed => 0,
      OrderStatus.processing => 1,
      OrderStatus.shipped => 2,
      OrderStatus.delivered => 3,
      OrderStatus.cancelled => 0,
    };
    const labels = ['Order placed', 'Processing', 'Shipped', 'Delivered'];
    return Column(
      children: List.generate(
        labels.length,
        (index) => _TimelineStep(
          label: labels[index],
          completed: index <= currentStep,
          isCurrent: index == currentStep,
          isLast: index == labels.length - 1,
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.completed,
    this.isCurrent = false,
    this.isError = false,
    this.isLast = false,
  });

  final String label;
  final bool completed;
  final bool isCurrent;
  final bool isError;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isError
        ? colors.error
        : completed
            ? colors.primary
            : colors.outline;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Icon(
                  isError
                      ? Icons.cancel
                      : completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                  size: 21,
                  color: color,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: completed ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 21),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.label, required this.value, this.emphasized = false});
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasized ? 17 : 14,
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}
