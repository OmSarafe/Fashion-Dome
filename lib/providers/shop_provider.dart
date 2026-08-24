import 'dart:async';
import 'dart:collection';

import 'package:ecommerence_project/models/cart_item.dart';
import 'package:ecommerence_project/models/order.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/models/user_profile.dart';
import 'package:ecommerence_project/services/cart_service.dart';
import 'package:ecommerence_project/services/category_service.dart';
import 'package:ecommerence_project/services/currency_migration_service.dart';
import 'package:ecommerence_project/services/favorite_service.dart';
import 'package:ecommerence_project/services/order_service.dart';
import 'package:ecommerence_project/services/product_service.dart';
import 'package:ecommerence_project/services/user_profile_service.dart';
import 'package:ecommerence_project/utils/cart_calculator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ShopProvider extends ChangeNotifier {
  ShopProvider({
    ProductService? productService,
    CategoryService? categoryService,
    CartService? cartService,
    CurrencyMigrationService? currencyMigrationService,
    FavoriteService? favoriteService,
    OrderService? orderService,
    UserProfileService? userProfileService,
    FirebaseAuth? firebaseAuth,
  })  : _productService = productService ?? ProductService(),
        _categoryService = categoryService ?? CategoryService(),
        _cartService = cartService ?? CartService(),
        _currencyMigrationService =
            currencyMigrationService ?? CurrencyMigrationService(),
        _favoriteService = favoriteService ?? FavoriteService(),
        _orderService = orderService ?? OrderService(),
        _userProfileService = userProfileService ?? UserProfileService(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _watchProducts();
    _watchCategories();
    _authSubscription =
        _firebaseAuth.authStateChanges().listen(_handleAuthStateChanged);
    unawaited(_seedStarterProducts());
  }

  final ProductService _productService;
  final CategoryService _categoryService;
  final CartService _cartService;
  final CurrencyMigrationService _currencyMigrationService;
  final FavoriteService _favoriteService;
  final OrderService _orderService;
  final UserProfileService _userProfileService;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<List<Product>>? _productSubscription;
  StreamSubscription<List<String>>? _categorySubscription;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<StoredCartItem>>? _cartSubscription;
  StreamSubscription<Set<String>>? _favoriteSubscription;
  StreamSubscription<List<Order>>? _orderSubscription;
  StreamSubscription<List<Order>>? _adminOrderSubscription;
  StreamSubscription<UserProfile?>? _profileSubscription;
  String? _activeUserId;

  static const List<Product> _starterProducts = [
    Product(
      id: 'regular-fit-slogan',
      name: 'Regular Fit Slogan',
      description: 'A comfortable everyday slogan T-shirt.',
      category: 'T-shirts',
      priceInPence: 1190,
      assetImagePath: 'assets/products/regular-fit-slogan.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 20,
    ),
    Product(
      id: 'regular-fit-polo',
      name: 'Regular Fit Polo',
      description: 'A versatile polo shirt with a regular fit.',
      category: 'T-shirts',
      priceInPence: 1000,
      compareAtPriceInPence: 1100,
      assetImagePath: 'assets/products/regular-fit-polo.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 14,
    ),
    Product(
      id: 'regular-fit-black',
      name: 'Regular Fit Black',
      description: 'A minimal black top for everyday styling.',
      category: 'T-shirts',
      priceInPence: 1690,
      assetImagePath: 'assets/products/regular-fit-black.png',
      availableSizes: ['S', 'M', 'L'],
      stock: 8,
    ),
    Product(
      id: 'regular-fit-v-neck',
      name: 'Regular Fit V-Neck',
      description: 'A soft V-neck shirt with a relaxed silhouette.',
      category: 'T-shirts',
      priceInPence: 1290,
      assetImagePath: 'assets/products/regular-fit-v-neck.png',
      availableSizes: ['XS', 'S', 'M', 'L'],
      stock: 11,
    ),
    Product(
      id: 'regular-fit-crew',
      name: 'Regular Fit Crew',
      description: 'A classic crew-neck shirt for daily wear.',
      category: 'T-shirts',
      priceInPence: 990,
      assetImagePath: 'assets/products/regular-fit-crew.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 18,
    ),
    Product(
      id: 'regular-fit-stripe',
      name: 'Regular Fit Stripe',
      description: 'A striped regular-fit shirt with a clean finish.',
      category: 'T-shirts',
      priceInPence: 1050,
      assetImagePath: 'assets/products/regular-fit-stripe.png',
      availableSizes: ['S', 'M', 'L'],
      stock: 9,
    ),
    Product(
      id: 'oxford-button-down-shirt',
      name: 'Oxford Button-Down Shirt',
      description: 'A versatile cotton Oxford shirt for smart-casual outfits.',
      category: 'Shirts',
      priceInPence: 2499,
      assetImagePath: 'assets/products/oxford-button-down-shirt.png',
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      stock: 18,
    ),
    Product(
      id: 'linen-blend-shirt',
      name: 'Linen Blend Shirt',
      description: 'A breathable linen-blend shirt with a relaxed summer fit.',
      category: 'Shirts',
      priceInPence: 2999,
      compareAtPriceInPence: 3499,
      assetImagePath: 'assets/products/linen-blend-shirt.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 15,
    ),
    Product(
      id: 'checked-overshirt',
      name: 'Checked Overshirt',
      description: 'A soft checked overshirt designed for easy layering.',
      category: 'Shirts',
      priceInPence: 3499,
      assetImagePath: 'assets/products/checked-overshirt.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 12,
    ),
    Product(
      id: 'slim-fit-formal-shirt',
      name: 'Slim Fit Formal Shirt',
      description: 'A crisp slim-fit shirt suitable for work and occasions.',
      category: 'Shirts',
      priceInPence: 2750,
      assetImagePath: 'assets/products/slim-fit-formal-shirt.png',
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      stock: 20,
    ),
    Product(
      id: 'corduroy-shirt',
      name: 'Corduroy Shirt',
      description: 'A textured corduroy shirt with a comfortable regular fit.',
      category: 'Shirts',
      priceInPence: 3299,
      assetImagePath: 'assets/products/corduroy-shirt.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 11,
    ),
    Product(
      id: 'short-sleeve-resort-shirt',
      name: 'Short Sleeve Resort Shirt',
      description: 'A lightweight open-collar shirt for warm-weather styling.',
      category: 'Shirts',
      priceInPence: 2299,
      compareAtPriceInPence: 2799,
      assetImagePath: 'assets/products/short-sleeve-resort-shirt.png',
      availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
      stock: 16,
    ),
    Product(
      id: 'straight-leg-indigo-jeans',
      name: 'Straight Leg Indigo Jeans',
      description: 'Classic indigo denim with a comfortable straight-leg cut.',
      category: 'Jeans',
      priceInPence: 3999,
      assetImagePath: 'assets/products/straight-leg-indigo-jeans.png',
      availableSizes: ['28', '30', '32', '34', '36'],
      stock: 17,
    ),
    Product(
      id: 'slim-fit-black-jeans',
      name: 'Slim Fit Black Jeans',
      description: 'Clean black denim with stretch and a modern slim fit.',
      category: 'Jeans',
      priceInPence: 4200,
      assetImagePath: 'assets/products/slim-fit-black-jeans.png',
      availableSizes: ['28', '30', '32', '34', '36'],
      stock: 14,
    ),
    Product(
      id: 'relaxed-fit-stonewash-jeans',
      name: 'Relaxed Fit Stonewash Jeans',
      description: 'Relaxed stonewashed denim inspired by vintage workwear.',
      category: 'Jeans',
      priceInPence: 4499,
      assetImagePath: 'assets/products/relaxed-fit-stonewash-jeans.png',
      availableSizes: ['28', '30', '32', '34', '36', '38'],
      stock: 13,
    ),
    Product(
      id: 'tapered-dark-wash-jeans',
      name: 'Tapered Dark Wash Jeans',
      description: 'Dark-wash denim with room at the thigh and a tapered leg.',
      category: 'Jeans',
      priceInPence: 4150,
      assetImagePath: 'assets/products/tapered-dark-wash-jeans.png',
      availableSizes: ['28', '30', '32', '34', '36'],
      stock: 19,
    ),
    Product(
      id: 'wide-leg-light-blue-jeans',
      name: 'Wide Leg Light Blue Jeans',
      description: 'Light-blue denim with a contemporary wide-leg silhouette.',
      category: 'Jeans',
      priceInPence: 4599,
      assetImagePath: 'assets/products/wide-leg-light-blue-jeans.png',
      availableSizes: ['26', '28', '30', '32', '34', '36'],
      stock: 12,
    ),
    Product(
      id: 'vintage-wash-jeans',
      name: 'Vintage Wash Jeans',
      description: 'Authentic-look denim finished with a soft vintage wash.',
      category: 'Jeans',
      priceInPence: 4750,
      compareAtPriceInPence: 5200,
      assetImagePath: 'assets/products/vintage-wash-jeans.png',
      availableSizes: ['28', '30', '32', '34', '36'],
      stock: 10,
    ),
    Product(
      id: 'classic-denim-jacket',
      name: 'Classic Denim Jacket',
      description: 'A timeless denim jacket with durable metal-button details.',
      category: 'Jackets',
      priceInPence: 5499,
      assetImagePath: 'assets/products/classic-denim-jacket.png',
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      stock: 14,
    ),
    Product(
      id: 'lightweight-bomber-jacket',
      name: 'Lightweight Bomber Jacket',
      description:
          'A streamlined bomber jacket for mild and transitional days.',
      category: 'Jackets',
      priceInPence: 5999,
      assetImagePath: 'assets/products/lightweight-bomber-jacket.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 16,
    ),
    Product(
      id: 'quilted-puffer-jacket',
      name: 'Quilted Puffer Jacket',
      description: 'A warm quilted puffer with lightweight insulation.',
      category: 'Jackets',
      priceInPence: 6999,
      compareAtPriceInPence: 7999,
      assetImagePath: 'assets/products/quilted-puffer-jacket.png',
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      stock: 12,
    ),
    Product(
      id: 'utility-field-jacket',
      name: 'Utility Field Jacket',
      description: 'A practical field jacket with multiple utility pockets.',
      category: 'Jackets',
      priceInPence: 6450,
      assetImagePath: 'assets/products/utility-field-jacket.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 11,
    ),
    Product(
      id: 'faux-suede-jacket',
      name: 'Faux Suede Jacket',
      description: 'A soft faux-suede jacket with a refined minimal finish.',
      category: 'Jackets',
      priceInPence: 7499,
      assetImagePath: 'assets/products/faux-suede-jacket.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      stock: 9,
    ),
    Product(
      id: 'hooded-rain-jacket',
      name: 'Hooded Rain Jacket',
      description:
          'A lightweight water-resistant layer with an adjustable hood.',
      category: 'Jackets',
      priceInPence: 5750,
      compareAtPriceInPence: 6500,
      assetImagePath: 'assets/products/hooded-rain-jacket.png',
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      stock: 15,
    ),
  ];

  final List<Product> _products = List<Product>.from(_starterProducts);
  final List<String> _storedCategories = [];

  final Set<String> _favoriteProductIds = {};
  final Map<String, CartItem> _cartItems = {};
  final Map<String, StoredCartItem> _storedCartItems = {};
  final List<Order> _orders = [];
  final List<Order> _adminOrders = [];
  UserProfile? _userProfile;

  bool _isLoadingProducts = true;
  bool _isLoadingCart = false;
  bool _isLoadingFavorites = false;
  bool _isLoadingOrders = false;
  bool _isLoadingAdminOrders = false;
  bool _isLoadingProfile = false;
  String? _cartError;
  String? _productLoadError;
  String? _favoriteError;
  String? _orderError;
  String? _adminOrderError;
  String? _profileError;
  bool _isUsingStarterProducts = true;

  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);

  UnmodifiableListView<String> get categories {
    final names = <String>{
      ..._storedCategories,
      ..._products.map((product) => product.category),
    }.where((name) => name.trim().isNotEmpty).toList(growable: false)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return UnmodifiableListView(names);
  }

  bool get isLoadingProducts => _isLoadingProducts;

  String? get productLoadError => _productLoadError;

  bool get isUsingStarterProducts => _isUsingStarterProducts;

  bool get isLoadingCart => _isLoadingCart;

  String? get cartError => _cartError;

  bool get isLoadingFavorites => _isLoadingFavorites;

  String? get favoriteError => _favoriteError;

  bool get isLoadingOrders => _isLoadingOrders;

  String? get orderError => _orderError;

  bool get isLoadingAdminOrders => _isLoadingAdminOrders;

  String? get adminOrderError => _adminOrderError;

  UserProfile? get userProfile => _userProfile;

  bool get isAdmin => _userProfile?.isAdmin ?? false;

  bool get isLoadingProfile => _isLoadingProfile;

  String? get profileError => _profileError;

  List<Product> get favoriteProducts => _products
      .where((product) => _favoriteProductIds.contains(product.id))
      .toList(growable: false);

  UnmodifiableListView<CartItem> get cartItems =>
      UnmodifiableListView(_cartItems.values);

  UnmodifiableListView<Order> get orders => UnmodifiableListView(_orders);

  UnmodifiableListView<Order> get adminOrders =>
      UnmodifiableListView(_adminOrders);

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);

  int get cartQuantity => _cartItems.values.fold(
        0,
        (total, item) => total + item.quantity,
      );

  int get subtotalInPence => CartCalculator.subtotalInPence(_cartItems.values);

  int cartQuantityForProduct(String productId) => _cartItems.values
      .where((item) => item.product.id == productId)
      .fold(0, (total, item) => total + item.quantity);

  bool canAddProduct(Product product) => CartCalculator.canAddAnother(
        product,
        cartQuantityForProduct(product.id),
      );

  String? get cartStockIssue {
    final checkedProductIds = <String>{};
    for (final item in _cartItems.values) {
      if (!checkedProductIds.add(item.product.id)) continue;
      final quantity = cartQuantityForProduct(item.product.id);
      if (item.product.stock <= 0) {
        return '${item.product.name} is now out of stock.';
      }
      if (quantity > item.product.stock) {
        return 'Only ${item.product.stock} of ${item.product.name} are available.';
      }
    }
    return null;
  }

  void _watchProducts() {
    _productSubscription = _productService.watchProducts().listen(
      (products) {
        _isLoadingProducts = false;
        _productLoadError = null;

        if (products.isNotEmpty) {
          _products
            ..clear()
            ..addAll(products);
          _isUsingStarterProducts = false;
        }

        _rebuildCartItems();

        notifyListeners();
      },
      onError: (Object error) {
        _isLoadingProducts = false;
        _productLoadError = error.toString();
        notifyListeners();
      },
    );
  }

  void _watchCategories() {
    _categorySubscription = _categoryService.watchCategories().listen(
      (categories) {
        _storedCategories
          ..clear()
          ..addAll(categories);
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Unable to load categories: $error');
      },
    );
  }

  Future<void> _seedStarterProducts() async {
    try {
      await _productService.seedStarterProductsIfNeeded(_starterProducts);
    } catch (error) {
      debugPrint('Unable to upload the starter catalogue: $error');
    }
  }

  void _handleAuthStateChanged(User? user) {
    final userId = user?.uid;
    if (_activeUserId == userId) return;

    _activeUserId = userId;
    if (userId != null) unawaited(_seedStarterProducts());
    unawaited(_cartSubscription?.cancel());
    unawaited(_favoriteSubscription?.cancel());
    unawaited(_orderSubscription?.cancel());
    unawaited(_adminOrderSubscription?.cancel());
    unawaited(_profileSubscription?.cancel());
    _cartSubscription = null;
    _favoriteSubscription = null;
    _orderSubscription = null;
    _adminOrderSubscription = null;
    _profileSubscription = null;
    _storedCartItems.clear();
    _cartItems.clear();
    _favoriteProductIds.clear();
    _orders.clear();
    _adminOrders.clear();
    _userProfile = null;
    _cartError = null;
    _favoriteError = null;
    _orderError = null;
    _adminOrderError = null;
    _profileError = null;
    _isLoadingCart = userId != null;
    _isLoadingFavorites = userId != null;
    _isLoadingOrders = userId != null;
    _isLoadingAdminOrders = false;
    _isLoadingProfile = userId != null;
    notifyListeners();

    if (userId == null) return;

    unawaited(_migrateCurrencyToPence());

    _profileSubscription = _userProfileService.watchProfile(userId).listen(
      (profile) {
        if (_activeUserId != userId) return;
        _userProfile = profile;
        _isLoadingProfile = false;
        _profileError = null;
        _updateAdminOrderSubscription(profile);
        notifyListeners();
      },
      onError: (Object error) {
        if (_activeUserId != userId) return;
        _isLoadingProfile = false;
        _profileError = error.toString();
        notifyListeners();
      },
    );

    _cartSubscription = _cartService.watchCart(userId).listen(
      (storedItems) {
        if (_activeUserId != userId) return;
        _storedCartItems
          ..clear()
          ..addEntries(storedItems.map((item) => MapEntry(item.id, item)));
        _rebuildCartItems();
        _isLoadingCart = false;
        _cartError = null;
        notifyListeners();
      },
      onError: (Object error) {
        if (_activeUserId != userId) return;
        _isLoadingCart = false;
        _cartError = error.toString();
        notifyListeners();
      },
    );

    _favoriteSubscription =
        _favoriteService.watchFavoriteProductIds(userId).listen(
      (productIds) {
        if (_activeUserId != userId) return;
        _favoriteProductIds
          ..clear()
          ..addAll(productIds);
        _isLoadingFavorites = false;
        _favoriteError = null;
        notifyListeners();
      },
      onError: (Object error) {
        if (_activeUserId != userId) return;
        _isLoadingFavorites = false;
        _favoriteError = error.toString();
        notifyListeners();
      },
    );

    _orderSubscription = _orderService.watchOrders(userId).listen(
      (orders) {
        if (_activeUserId != userId) return;
        _orders
          ..clear()
          ..addAll(orders);
        _isLoadingOrders = false;
        _orderError = null;
        notifyListeners();
      },
      onError: (Object error) {
        if (_activeUserId != userId) return;
        _isLoadingOrders = false;
        _orderError = error.toString();
        notifyListeners();
      },
    );
  }

  void _updateAdminOrderSubscription(UserProfile? profile) {
    if (profile?.isAdmin == true) {
      if (_adminOrderSubscription != null) return;
      _isLoadingAdminOrders = true;
      _adminOrderSubscription = _orderService.watchAllOrders().listen(
        (orders) {
          _adminOrders
            ..clear()
            ..addAll(orders);
          _isLoadingAdminOrders = false;
          _adminOrderError = null;
          notifyListeners();
        },
        onError: (Object error) {
          _isLoadingAdminOrders = false;
          _adminOrderError = error.toString();
          notifyListeners();
        },
      );
      return;
    }

    unawaited(_adminOrderSubscription?.cancel());
    _adminOrderSubscription = null;
    _adminOrders.clear();
    _isLoadingAdminOrders = false;
    _adminOrderError = null;
  }

  Future<void> _migrateCurrencyToPence() async {
    try {
      await _currencyMigrationService.migrateToPenceIfNeeded();
    } catch (error) {
      debugPrint('Unable to migrate currency fields to pence: $error');
    }
  }

  void _rebuildCartItems() {
    final productsById = {
      for (final product in _products) product.id: product,
    };
    _cartItems
      ..clear()
      ..addEntries(
        _storedCartItems.values.map((storedItem) {
          final product = productsById[storedItem.productId];
          if (product == null || !product.isInStock) return null;
          return MapEntry(
            storedItem.id,
            CartItem(
              product: product,
              size: storedItem.size,
              quantity: storedItem.quantity.clamp(1, product.stock).toInt(),
            ),
          );
        }).whereType<MapEntry<String, CartItem>>(),
      );
  }

  void toggleFavorite(String productId) {
    final userId = _activeUserId;
    if (userId == null) {
      _favoriteError = 'Please sign in to save products.';
      notifyListeners();
      return;
    }

    final wasFavorite = _favoriteProductIds.contains(productId);
    if (wasFavorite) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    _favoriteError = null;
    notifyListeners();

    unawaited(
      _saveFavorite(
        userId: userId,
        productId: productId,
        isFavorite: !wasFavorite,
      ),
    );
  }

  Future<String> saveProduct(Product product) {
    if (!isAdmin) {
      throw StateError('Only administrators can save products.');
    }
    return _productService.saveProduct(product);
  }

  String createProductId() {
    if (!isAdmin) {
      throw StateError('Only administrators can create products.');
    }
    return _productService.createProductId();
  }

  Future<void> deleteProduct(String productId) {
    if (!isAdmin) {
      throw StateError('Only administrators can delete products.');
    }
    return _productService.deleteProduct(productId);
  }

  Future<void> addCategory(String name) {
    if (!isAdmin) {
      throw StateError('Only administrators can add categories.');
    }
    return _categoryService.addCategory(name);
  }

  Future<void> renameCategory(String oldName, String newName) {
    if (!isAdmin) {
      throw StateError('Only administrators can rename categories.');
    }
    return _categoryService.renameCategory(oldName, newName);
  }

  Future<void> deleteCategory(String name) {
    if (!isAdmin) {
      throw StateError('Only administrators can delete categories.');
    }
    return _categoryService.deleteCategory(name);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) {
    if (!isAdmin) {
      throw StateError('Only administrators can update orders.');
    }
    return _orderService.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }

  Future<void> cancelOrder(Order order) {
    final userId = _activeUserId;
    if (userId == null) {
      throw StateError('Please sign in before cancelling an order.');
    }
    if (order.userId != userId) {
      throw StateError('You cannot cancel another customer\'s order.');
    }
    return _orderService.cancelOrder(
      orderId: order.id,
      userId: userId,
    );
  }

  Future<void> _saveFavorite({
    required String userId,
    required String productId,
    required bool isFavorite,
  }) async {
    try {
      await _favoriteService.setFavorite(
        userId: userId,
        productId: productId,
        isFavorite: isFavorite,
      );
    } catch (error) {
      if (_activeUserId != userId) return;

      if (isFavorite) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
      _favoriteError = 'Unable to update saved items. Please try again.';
      debugPrint('Unable to update favorite: $error');
      notifyListeners();
    }
  }

  bool addToCart(Product product, {required String size}) {
    final userId = _activeUserId;
    if (userId == null) {
      _cartError = 'Please sign in to add products to your cart.';
      notifyListeners();
      return false;
    }

    final id = '${product.id}:$size';
    final existingItem = _cartItems[id];
    if (!canAddProduct(product)) return false;
    final item = CartItem(
      product: product,
      size: size,
      quantity: (existingItem?.quantity ?? 0) + 1,
    );
    _cartItems[id] = item;
    _storedCartItems[id] = StoredCartItem(
      id: id,
      productId: product.id,
      size: size,
      quantity: item.quantity,
    );
    _cartError = null;
    notifyListeners();
    unawaited(_saveCartItem(userId, item));
    return true;
  }

  bool increaseQuantity(String cartItemId) {
    final item = _cartItems[cartItemId];
    if (item == null || !canAddProduct(item.product)) return false;
    final updatedItem = item.copyWith(quantity: item.quantity + 1);
    _cartItems[cartItemId] = updatedItem;
    _storedCartItems[cartItemId] = StoredCartItem(
      id: cartItemId,
      productId: item.product.id,
      size: item.size,
      quantity: updatedItem.quantity,
    );
    notifyListeners();
    final userId = _activeUserId;
    if (userId != null) unawaited(_saveCartItem(userId, updatedItem));
    return true;
  }

  void decreaseQuantity(String cartItemId) {
    final item = _cartItems[cartItemId];
    if (item == null) return;
    if (item.quantity <= 1) {
      removeFromCart(cartItemId);
      return;
    } else {
      final updatedItem = item.copyWith(quantity: item.quantity - 1);
      _cartItems[cartItemId] = updatedItem;
      _storedCartItems[cartItemId] = StoredCartItem(
        id: cartItemId,
        productId: item.product.id,
        size: item.size,
        quantity: updatedItem.quantity,
      );
      final userId = _activeUserId;
      if (userId != null) unawaited(_saveCartItem(userId, updatedItem));
    }
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.remove(cartItemId);
    _storedCartItems.remove(cartItemId);
    notifyListeners();
    final userId = _activeUserId;
    if (userId != null) {
      unawaited(
        _removeCartItem(userId: userId, cartItemId: cartItemId),
      );
    }
  }

  void clearCart() {
    _cartItems.clear();
    _storedCartItems.clear();
    notifyListeners();
    final userId = _activeUserId;
    if (userId != null) unawaited(_clearStoredCart(userId));
  }

  Future<void> _saveCartItem(String userId, CartItem item) async {
    try {
      await _cartService.saveCartItem(
        userId: userId,
        cartItemId: item.id,
        productId: item.product.id,
        size: item.size,
        quantity: item.quantity,
      );
    } catch (error) {
      _handleCartWriteError(userId, error);
    }
  }

  Future<void> _removeCartItem({
    required String userId,
    required String cartItemId,
  }) async {
    try {
      await _cartService.removeCartItem(
        userId: userId,
        cartItemId: cartItemId,
      );
    } catch (error) {
      _handleCartWriteError(userId, error);
    }
  }

  Future<void> _clearStoredCart(String userId) async {
    try {
      await _cartService.clearCart(userId);
    } catch (error) {
      _handleCartWriteError(userId, error);
    }
  }

  void _handleCartWriteError(String userId, Object error) {
    if (_activeUserId != userId) return;
    _cartError = 'Unable to update your cart. Please try again.';
    debugPrint('Unable to update cart: $error');
    notifyListeners();
  }

  Future<Order> placeOrder({
    required String deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    required String paymentMethod,
    String? stripePaymentIntentId,
  }) async {
    if (isAdmin) {
      throw StateError('Administrator accounts cannot place orders.');
    }

    if (_cartItems.isEmpty) {
      throw StateError('Cannot place an order with an empty cart.');
    }

    final stockIssue = cartStockIssue;
    if (stockIssue != null) {
      throw StateError(stockIssue);
    }

    final userId = _activeUserId;
    if (userId == null) {
      throw StateError('Please sign in before placing an order.');
    }

    final trimmedAddress = deliveryAddress.trim();
    if (trimmedAddress.length < 10) {
      throw StateError('Enter your full delivery address.');
    }

    await _userProfileService.updateDeliveryAddress(
      userId: userId,
      deliveryAddress: trimmedAddress,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );

    final order = await _orderService.submitOrder(
      userId: userId,
      items: _cartItems.values.toList(growable: false),
      deliveryAddress: trimmedAddress,
      paymentMethod: paymentMethod,
      stripePaymentIntentId: stripePaymentIntentId,
    );

    clearCart();
    return order;
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    _categorySubscription?.cancel();
    _authSubscription?.cancel();
    _cartSubscription?.cancel();
    _favoriteSubscription?.cancel();
    _orderSubscription?.cancel();
    _adminOrderSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
