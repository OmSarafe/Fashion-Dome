import 'package:ecommerence_project/models/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.size,
    required this.quantity,
  });

  final Product product;
  final String size;
  final int quantity;

  String get id => '${product.id}:$size';

  int get lineTotalInPence => product.priceInPence * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      size: size,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    final productData = Map<String, dynamic>.from(
      data['product'] as Map<dynamic, dynamic>? ?? const {},
    );
    return CartItem(
      product: Product.fromMap(
        data['productId'] as String? ?? '',
        productData,
      ),
      size: data['size'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'product': product.toMap(),
      'size': size,
      'quantity': quantity,
    };
  }
}
