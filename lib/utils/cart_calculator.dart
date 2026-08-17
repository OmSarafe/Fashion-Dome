import 'package:ecommerence_project/models/cart_item.dart';
import 'package:ecommerence_project/models/product.dart';

class CartCalculator {
  const CartCalculator._();

  static const int standardShippingInPence = 80;

  static int subtotalInPence(Iterable<CartItem> items) => items.fold(
        0,
        (total, item) => total + item.lineTotalInPence,
      );

  static int totalInPence(
    int subtotalInPence, {
    int shippingInPence = standardShippingInPence,
  }) =>
      subtotalInPence + shippingInPence;

  static bool canAddAnother(Product product, int currentQuantity) =>
      product.isInStock && currentQuantity < product.stock;
}
