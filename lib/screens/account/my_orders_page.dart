import 'package:ecommerence_project/screens/account/order_details_page.dart';
import 'package:ecommerence_project/models/order.dart';
import 'package:ecommerence_project/screens/catalog/product_detail_page.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:ecommerence_project/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Myorder extends StatelessWidget {
  const Myorder({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text(
            'My Orders',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderList(showCompleted: false),
            _OrderList(showCompleted: true),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.showCompleted});

  final bool showCompleted;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<ShopProvider>().orders.where((order) {
      final isCompleted = order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled;
      return isCompleted == showCompleted;
    }).toList(growable: false);

    if (orders.isEmpty) {
      return _EmptyOrders(showCompleted: showCompleted);
    }

    return ResponsiveContent(
      maxWidth: 900,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 18, bottom: 28),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) => _OrderCard(order: orders[index]),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final shortId = order.id.length > 6
        ? order.id.substring(order.id.length - 6)
        : order.id;
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #$shortId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: order.status),
              IconButton(
                tooltip: 'View order details',
                onPressed: _openOrderDetails,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const Divider(height: 28),
          SizedBox(
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(
                    product: item.product,
                    width: 58,
                    height: 66,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} item type${order.items.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                formatPounds(order.totalInPence),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.deliveryAddress,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          _PaymentSummary(order: order),
          const SizedBox(height: 16),
          _OrderProgress(status: order.status),
          if (order.status == OrderStatus.delivered) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openDeliveredProducts,
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(
                  order.items.length == 1
                      ? 'View and review product'
                      : 'View and review products',
                ),
              ),
            ),
          ],
          if (order.canBeCancelled) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isCancelling ? null : _confirmCancellation,
                icon: _isCancelling
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: Text(
                  _isCancelling ? 'Cancelling...' : 'Cancel order',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openOrderDetails() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(order: widget.order),
      ),
    );
  }

  Future<void> _openDeliveredProducts() async {
    final items = widget.order.items;
    if (items.length == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: items.first.product),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          children: [
            const Text(
              'Choose a product to review',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(
                    product: item.product,
                    width: 48,
                    height: 56,
                  ),
                ),
                title: Text(item.product.name),
                subtitle: Text('Size ${item.size}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: item.product),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancellation() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cancel this order?'),
            content: const Text(
              'The order will be cancelled and its items will be returned to stock. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep order'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Cancel order'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      await context.read<ShopProvider>().cancelOrder(widget.order);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled. Stock is being restored.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is StateError
          ? error.message.toString()
          : 'Unable to cancel this order. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isStripe = order.paymentMethod == 'Stripe card payment';
    final label = switch (order.paymentStatus) {
      'paid' => 'Paid',
      'verification_pending' => 'Verifying',
      'failed' => 'Failed',
      'refunded' => 'Refunded',
      'cancelled' => 'Cancelled',
      _ when !isStripe => 'Pay on delivery',
      _ => 'Pending',
    };
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (order.paymentStatus) {
      'paid' => (Colors.green.shade100, Colors.green.shade900),
      'failed' || 'cancelled' => (
          colors.errorContainer,
          colors.onErrorContainer
        ),
      'refunded' => (Colors.blue.shade100, Colors.blue.shade900),
      _ => (colors.secondaryContainer, colors.onSecondaryContainer),
    };

    return Row(
      children: [
        Icon(
          isStripe ? Icons.credit_card_outlined : Icons.payments_outlined,
          size: 20,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isStripe ? 'Stripe card payment' : 'Cash on delivery',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderProgress extends StatelessWidget {
  const _OrderProgress({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('This order was cancelled and will not be shipped.'),
          ),
        ],
      );
    }

    final step = switch (status) {
      OrderStatus.placed => 1,
      OrderStatus.processing => 2,
      OrderStatus.shipped => 3,
      OrderStatus.delivered => 4,
      OrderStatus.cancelled => 0,
    };
    final label = switch (status) {
      OrderStatus.placed => 'Order received',
      OrderStatus.processing => 'Preparing your order',
      OrderStatus.shipped => 'Order is on its way',
      OrderStatus.delivered => 'Order delivered',
      OrderStatus.cancelled => '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$step of 4'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: step / 4),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      OrderStatus.placed => 'Placed',
      OrderStatus.processing => 'Processing',
      OrderStatus.shipped => 'Shipped',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };

    final colors = Theme.of(context).colorScheme;
    final backgroundColor = switch (status) {
      OrderStatus.delivered => colors.primaryContainer,
      OrderStatus.cancelled => colors.errorContainer,
      _ => colors.secondaryContainer,
    };
    final foregroundColor = switch (status) {
      OrderStatus.delivered => colors.onPrimaryContainer,
      OrderStatus.cancelled => colors.onErrorContainer,
      _ => colors.onSecondaryContainer,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.showCompleted});

  final bool showCompleted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 58, color: Colors.grey),
            const SizedBox(height: 14),
            Text(
              showCompleted ? 'No completed orders' : 'No ongoing orders',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              showCompleted
                  ? 'Delivered and cancelled orders will appear here.'
                  : 'Your newly placed orders will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
