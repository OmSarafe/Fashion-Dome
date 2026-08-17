import 'package:ecommerence_project/screens/admin/manage_categories_page.dart';
import 'package:ecommerence_project/screens/admin/manage_orders_page.dart';
import 'package:ecommerence_project/screens/admin/manage_products_page.dart';
import 'package:ecommerence_project/screens/admin/send_notification_page.dart';
import 'package:ecommerence_project/models/order.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/services/admin_dashboard_service.dart';
import 'package:ecommerence_project/utils/currency_formatter.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatelessWidget {
  AdminDashboardPage({super.key});

  final AdminDashboardService _dashboardService = AdminDashboardService();

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final profile = shop.userProfile;

    if (shop.isLoadingProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (profile?.isAdmin != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    final orders = shop.adminOrders;
    final activeOrders = orders.where((order) =>
        order.status == OrderStatus.placed ||
        order.status == OrderStatus.processing ||
        order.status == OrderStatus.shipped);
    final recognisedSales = orders.where(_countsAsSale).fold<int>(
          0,
          (total, order) => total + order.totalInPence,
        );
    final lowStockProducts = shop.products
        .where((product) => !product.isInStock || product.isLowStock)
        .toList(growable: false)
      ..sort((a, b) => a.stock.compareTo(b.stock));
    final recentOrders = orders.take(3).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 24,
        title: const Text('Admin overview'),
      ),
      body: ResponsiveContent(
        child: RefreshIndicator(
          onRefresh: () async => Future<void>.delayed(
            const Duration(milliseconds: 500),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final metricColumns = constraints.maxWidth >= 960
                  ? 4
                  : constraints.maxWidth >= 600
                      ? 3
                      : 2;
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 32),
                children: [
                  Text(
                    'Welcome, ${profile?.name ?? 'Admin'}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Here is what is happening in your store.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (shop.isLoadingAdminOrders) ...[
                    const SizedBox(height: 14),
                    const LinearProgressIndicator(),
                  ],
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: metricColumns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.35,
                    children: [
                      _MetricCard(
                        icon: Icons.payments_outlined,
                        label: 'Total sales',
                        value: formatPounds(recognisedSales),
                        color: Colors.green,
                      ),
                      _MetricCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Orders',
                        value: orders.length.toString(),
                        color: Colors.blue,
                      ),
                      _MetricCard(
                        icon: Icons.pending_actions_outlined,
                        label: 'Active orders',
                        value: activeOrders.length.toString(),
                        color: Colors.orange,
                      ),
                      StreamBuilder<int>(
                        stream: _dashboardService.watchCustomerCount(),
                        builder: (context, snapshot) => _MetricCard(
                          icon: Icons.people_outline,
                          label: 'Customers',
                          value: snapshot.hasError
                              ? '—'
                              : snapshot.hasData
                                  ? snapshot.data.toString()
                                  : '…',
                          color: Colors.purple,
                        ),
                      ),
                      _MetricCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Products',
                        value: shop.products.length.toString(),
                        color: Colors.teal,
                      ),
                      _MetricCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Low stock',
                        value: lowStockProducts.length.toString(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Quick actions'),
                  const SizedBox(height: 10),
                  _AdminAction(
                    icon: Icons.edit_outlined,
                    title: 'Manage Products',
                    subtitle: 'Add, edit and remove catalogue items',
                    onTap: () => _open(context, const ManageProductsPage()),
                  ),
                  const SizedBox(height: 10),
                  _AdminAction(
                    icon: Icons.category_outlined,
                    title: 'Manage Categories',
                    subtitle: 'Add, rename and organise catalogue sections',
                    onTap: () => _open(context, const ManageCategoriesPage()),
                  ),
                  const SizedBox(height: 10),
                  _AdminAction(
                    icon: Icons.local_shipping_outlined,
                    title: 'Manage Orders',
                    subtitle: 'Review orders and update their status',
                    onTap: () => _open(context, const ManageOrdersPage()),
                  ),
                  const SizedBox(height: 10),
                  _AdminAction(
                    icon: Icons.campaign_outlined,
                    title: 'Send Notification',
                    subtitle: 'Send an offer or announcement to customers',
                    onTap: () => _open(context, const SendNotificationPage()),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'Low-stock products',
                    actionLabel: 'Manage',
                    onAction: () => _open(context, const ManageProductsPage()),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: lowStockProducts.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.green),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        'All products have healthy stock.')),
                              ],
                            ),
                          )
                        : Column(
                            children: lowStockProducts.take(5).map((product) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: product.stock == 0
                                      ? Theme.of(context)
                                          .colorScheme
                                          .errorContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                  child: Text(product.stock.toString()),
                                ),
                                title: Text(product.name),
                                subtitle: Text(product.category),
                                trailing: Text(
                                  product.stock == 0
                                      ? 'Out of stock'
                                      : 'Low stock',
                                  style: TextStyle(
                                    color: product.stock == 0
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.orange.shade800,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }).toList(growable: false),
                          ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'Recent orders',
                    actionLabel: 'View all',
                    onAction: () => _open(context, const ManageOrdersPage()),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: recentOrders.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: Text('No customer orders yet.'),
                          )
                        : Column(
                            children: recentOrders.map((order) {
                              final shortId = order.id.length > 6
                                  ? order.id.substring(order.id.length - 6)
                                  : order.id;
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.shopping_bag_outlined),
                                ),
                                title: Text('Order #$shortId'),
                                subtitle: Text(_statusLabel(order.status)),
                                trailing: Text(
                                  formatPounds(order.totalInPence),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                onTap: () =>
                                    _open(context, const ManageOrdersPage()),
                              );
                            }).toList(growable: false),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _countsAsSale(Order order) {
    if (order.status == OrderStatus.cancelled ||
        order.paymentStatus == 'refunded' ||
        order.paymentStatus == 'failed') {
      return false;
    }
    return order.paymentStatus == 'paid' ||
        (order.paymentMethod == 'Cash on delivery' &&
            order.status == OrderStatus.delivered);
  }

  String _statusLabel(OrderStatus status) => switch (status) {
        OrderStatus.placed => 'Placed',
        OrderStatus.processing => 'Processing',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 27),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({this.title = '', this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _AdminAction extends StatelessWidget {
  const _AdminAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
