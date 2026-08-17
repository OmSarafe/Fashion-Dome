import 'package:ecommerence_project/models/order.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageOrdersPage extends StatelessWidget {
  const ManageOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    if (!shop.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Orders')),
        body: const Center(child: Text('Administrator access required.')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        toolbarHeight: 76,
        titleSpacing: 24,
        title: const Text(
          'Manage Orders',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),
      ),
      body: shop.isLoadingAdminOrders
          ? const Center(child: CircularProgressIndicator())
          : shop.adminOrderError != null
              ? const Center(child: Text('Unable to load customer orders.'))
              : shop.adminOrders.isEmpty
                  ? const Center(child: Text('No customer orders yet.'))
                  : ResponsiveContent(
                      maxWidth: 900,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 28),
                        itemCount: shop.adminOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) =>
                            _AdminOrderCard(order: shop.adminOrders[index]),
                      ),
                    ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final shortOrderId = order.id.length > 6
        ? order.id.substring(order.id.length - 6)
        : order.id;
    final shortUserId =
        order.userId.length > 8 ? order.userId.substring(0, 8) : order.userId;

    final nextStatuses = order.allowedNextStatuses;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #$shortOrderId',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  formatPounds(order.totalInPence),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Customer: $shortUserId · ${_formatDate(order.createdAt)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              order.items
                  .map(
                    (item) =>
                        '${item.product.name} (${item.size}) × ${item.quantity}',
                  )
                  .join('\n'),
            ),
            const SizedBox(height: 12),
            Text(
              order.deliveryAddress,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            if (nextStatuses.isEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline),
                title: Text(_statusLabel(order.status)),
                subtitle: const Text('This order is complete.'),
              )
            else
              DropdownButtonFormField<OrderStatus>(
                value: order.status,
                decoration: const InputDecoration(
                  labelText: 'Order status',
                  border: OutlineInputBorder(),
                ),
                items: [order.status, ...nextStatuses]
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (status) {
                  if (status == null || status == order.status) return;
                  _updateStatus(context, status);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    OrderStatus status,
  ) async {
    if (status == OrderStatus.cancelled) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Cancel this order?'),
              content: const Text(
                'The items will be returned to stock. This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Go back'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Cancel order'),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed || !context.mounted) return;
    }

    try {
      await context.read<ShopProvider>().updateOrderStatus(order.id, status);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as ${_statusLabel(status)}.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update the order status.')),
      );
    }
  }

  static String _statusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.placed => 'Placed',
      OrderStatus.processing => 'Processing',
      OrderStatus.shipped => 'Shipped',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
