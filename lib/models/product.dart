import 'package:cloud_firestore/cloud_firestore.dart';

const Map<String, String> _bundledProductImagePaths = {
  'regular-fit-slogan': 'assets/products/regular-fit-slogan.png',
  'regular-fit-polo': 'assets/products/regular-fit-polo.png',
  'regular-fit-black': 'assets/products/regular-fit-black.png',
  'regular-fit-v-neck': 'assets/products/regular-fit-v-neck.png',
  'regular-fit-crew': 'assets/products/regular-fit-crew.png',
  'regular-fit-stripe': 'assets/products/regular-fit-stripe.png',
  'oxford-button-down-shirt': 'assets/products/oxford-button-down-shirt.png',
  'linen-blend-shirt': 'assets/products/linen-blend-shirt.png',
  'checked-overshirt': 'assets/products/checked-overshirt.png',
  'slim-fit-formal-shirt': 'assets/products/slim-fit-formal-shirt.png',
  'navy-tailored-blazer': 'assets/products/navy-tailored-blazer.png',
  'charcoal-formal-trousers':
      'assets/products/charcoal-formal-trousers.png',
  'black-oxford-shoes': 'assets/products/black-oxford-shoes.png',
  'corduroy-shirt': 'assets/products/corduroy-shirt.png',
  'short-sleeve-resort-shirt': 'assets/products/short-sleeve-resort-shirt.png',
  'straight-leg-indigo-jeans': 'assets/products/straight-leg-indigo-jeans.png',
  'slim-fit-black-jeans': 'assets/products/slim-fit-black-jeans.png',
  'relaxed-fit-stonewash-jeans':
      'assets/products/relaxed-fit-stonewash-jeans.png',
  'tapered-dark-wash-jeans': 'assets/products/tapered-dark-wash-jeans.png',
  'wide-leg-light-blue-jeans': 'assets/products/wide-leg-light-blue-jeans.png',
  'vintage-wash-jeans': 'assets/products/vintage-wash-jeans.png',
  'classic-denim-jacket': 'assets/products/classic-denim-jacket.png',
  'lightweight-bomber-jacket': 'assets/products/lightweight-bomber-jacket.png',
  'quilted-puffer-jacket': 'assets/products/quilted-puffer-jacket.png',
  'utility-field-jacket': 'assets/products/utility-field-jacket.png',
  'faux-suede-jacket': 'assets/products/faux-suede-jacket.png',
  'hooded-rain-jacket': 'assets/products/hooded-rain-jacket.png',
};

abstract final class OutfitOccasion {
  static const casual = 'Casual';
  static const work = 'Work';
  static const party = 'Party';
  static const formal = 'Formal';

  static const values = [casual, work, party, formal];
}

abstract final class OutfitCategory {
  static const top = 'top';
  static const bottom = 'bottom';
  static const outerwear = 'outerwear';
  static const footwear = 'footwear';
  static const accessory = 'accessory';
  static const other = 'other';

  static const values = [top, bottom, outerwear, footwear, accessory, other];
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.priceInPence,
    required this.assetImagePath,
    required this.availableSizes,
    required this.stock,
    this.lowStockThreshold = 5,
    this.compareAtPriceInPence,
    this.imageUrl,
    this.createdAt,
    this.averageRating = 0,
    this.ratingCount = 0,
    this.outfitCategory = OutfitCategory.other,
    this.occasionTags = const [OutfitOccasion.casual],
    this.colour = 'Neutral',
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final int priceInPence;
  final int? compareAtPriceInPence;
  final String assetImagePath;
  final String? imageUrl;
  final List<String> availableSizes;
  final int stock;
  final int lowStockThreshold;
  final DateTime? createdAt;
  final double averageRating;
  final int ratingCount;
  final String outfitCategory;
  final List<String> occasionTags;
  final String colour;

  bool get isInStock => stock > 0;
  bool get isLowStock => stock > 0 && stock <= lowStockThreshold;

  double get price => priceInPence / 100;

  double? get compareAtPrice =>
      compareAtPriceInPence == null ? null : compareAtPriceInPence! / 100;

  String get resolvedOutfitCategory {
    if (OutfitCategory.values.contains(outfitCategory) &&
        outfitCategory != OutfitCategory.other) {
      return outfitCategory;
    }

    final normalizedCategory = category.toLowerCase();
    if (normalizedCategory.contains('shirt') ||
        normalizedCategory.contains('top')) {
      return OutfitCategory.top;
    }
    if (normalizedCategory.contains('jean') ||
        normalizedCategory.contains('trouser') ||
        normalizedCategory.contains('skirt')) {
      return OutfitCategory.bottom;
    }
    if (normalizedCategory.contains('jacket') ||
        normalizedCategory.contains('blazer') ||
        normalizedCategory.contains('coat')) {
      return OutfitCategory.outerwear;
    }
    if (normalizedCategory.contains('shoe') ||
        normalizedCategory.contains('footwear')) {
      return OutfitCategory.footwear;
    }
    if (normalizedCategory.contains('accessor')) {
      return OutfitCategory.accessory;
    }
    return OutfitCategory.other;
  }

  List<String> get resolvedOccasionTags {
    final tags = <String>{...occasionTags};
    final searchText = '$name $description $category'.toLowerCase();

    if (resolvedOutfitCategory == OutfitCategory.top ||
        resolvedOutfitCategory == OutfitCategory.bottom) {
      tags.add(OutfitOccasion.casual);
    }
    if (category.toLowerCase().contains('shirt') ||
        searchText.contains('formal') ||
        searchText.contains('tailored') ||
        searchText.contains('oxford')) {
      tags.add(OutfitOccasion.work);
    }
    if (searchText.contains('formal') ||
        searchText.contains('tailored') ||
        searchText.contains('blazer') ||
        searchText.contains('oxford shoe')) {
      tags.add(OutfitOccasion.formal);
    }
    if (resolvedOutfitCategory == OutfitCategory.outerwear ||
        searchText.contains('black') ||
        searchText.contains('resort')) {
      tags.add(OutfitOccasion.party);
    }

    return OutfitOccasion.values.where(tags.contains).toList(growable: false);
  }

  bool supportsOccasion(String occasion) =>
      resolvedOccasionTags.contains(occasion);

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];
    return Product(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      priceInPence: (data['priceInPence'] as num?)?.toInt() ??
          ((data['priceInPaise'] as num?)?.toInt() ?? 0) ~/ 100,
      compareAtPriceInPence: data['compareAtPriceInPence'] != null
          ? (data['compareAtPriceInPence'] as num).toInt()
          : data['compareAtPriceInPaise'] != null
              ? (data['compareAtPriceInPaise'] as num).toInt() ~/ 100
              : null,
      assetImagePath: _bundledProductImagePaths[id] ??
          data['assetImagePath'] as String? ??
          '',
      imageUrl: data['imageUrl'] as String?,
      availableSizes: List<String>.from(
        data['availableSizes'] as List<dynamic>? ?? const [],
      ),
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 5,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : createdAtValue is DateTime
              ? createdAtValue
              : null,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      outfitCategory:
          data['outfitCategory'] as String? ?? OutfitCategory.other,
      occasionTags: List<String>.from(
        data['occasionTags'] as List<dynamic>? ??
            const [OutfitOccasion.casual],
      ),
      colour: data['colour'] as String? ?? 'Neutral',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'priceInPence': priceInPence,
      'compareAtPriceInPence': compareAtPriceInPence,
      'assetImagePath': assetImagePath,
      'imageUrl': imageUrl,
      'availableSizes': availableSizes,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'outfitCategory': outfitCategory,
      'occasionTags': occasionTags,
      'colour': colour,
    };
  }
}
