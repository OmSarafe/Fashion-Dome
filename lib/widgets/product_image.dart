import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerence_project/models/product.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final Product product;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // Bundled catalogue photography is the canonical image for starter items.
    // Admin-created products still use their uploaded Firebase Storage image.
    if (product.assetImagePath.startsWith('assets/products/')) {
      return _assetOrPlaceholder(context);
    }
    final imageUrl = product.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        maxWidthDiskCache: 1200,
        maxHeightDiskCache: 1200,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (_, __, ___) => _assetOrPlaceholder(context),
      );
    }
    return _assetOrPlaceholder(context);
  }

  Widget _assetOrPlaceholder(BuildContext context) {
    if (product.assetImagePath.isEmpty) return _placeholder(context);
    return Image.asset(
      product.assetImagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
