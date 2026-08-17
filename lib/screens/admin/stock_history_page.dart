import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class StockHistoryPage extends StatelessWidget {
  const StockHistoryPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final movements = FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .collection('stockMovements')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.inventory_2_outlined),
                ),
                title: Text(product.name),
                subtitle: Text(
                  'Current stock: ${product.stock}  •  Warning at ${product.lowStockThreshold}',
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: movements,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load stock history.'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final documents = snapshot.data!.docs;
                  if (documents.isEmpty) {
                    return const Center(
                      child: Text('No stock changes have been recorded yet.'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: documents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _StockMovementTile(data: documents[index].data());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockMovementTile extends StatelessWidget {
  const _StockMovementTile({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final delta = (data['delta'] as num?)?.toInt() ?? 0;
    final resultingStock = (data['resultingStock'] as num?)?.toInt() ?? 0;
    final type = data['type'] as String? ?? 'stock_change';
    final orderId = data['orderId'] as String?;
    final createdAt = data['createdAt'];
    final date = createdAt is Timestamp ? createdAt.toDate() : null;
    final positive = delta >= 0;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: positive
              ? Colors.green.withValues(alpha: 0.14)
              : colors.errorContainer,
          child: Icon(
            positive ? Icons.add_rounded : Icons.remove_rounded,
            color: positive ? Colors.green.shade700 : colors.onErrorContainer,
          ),
        ),
        title: Text(
          '${positive ? '+' : ''}$delta units — ${_labelFor(type)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text([
          'Resulting stock: $resultingStock',
          if (orderId != null && orderId.isNotEmpty)
            'Order: ${_shortId(orderId)}',
          if (date != null) _formatDate(date),
        ].join('\n')),
        isThreeLine: orderId != null && orderId.isNotEmpty,
      ),
    );
  }

  static String _labelFor(String type) {
    switch (type) {
      case 'initial_stock':
        return 'Initial stock';
      case 'admin_adjustment':
        return 'Admin adjustment';
      case 'order_reserved':
        return 'Customer order';
      case 'order_restored':
        return 'Cancelled order restored';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  static String _shortId(String value) {
    return value.length <= 10 ? value : '${value.substring(0, 10)}…';
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}
