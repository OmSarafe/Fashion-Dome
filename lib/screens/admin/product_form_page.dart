import 'dart:io';

import 'package:ecommerence_project/models/product.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/services/product_image_service.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:ecommerence_project/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _compareAtPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _lowStockThresholdController;
  late final TextEditingController _sizesController;
  late final TextEditingController _assetPathController;
  final _imagePicker = ImagePicker();
  final _productImageService = ProductImageService();
  XFile? _selectedImage;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _categoryController =
        TextEditingController(text: product?.category ?? 'T-shirts');
    _priceController = TextEditingController(
      text: product == null
          ? ''
          : (product.priceInPence / 100).toStringAsFixed(2),
    );
    _compareAtPriceController = TextEditingController(
      text: product?.compareAtPriceInPence == null
          ? ''
          : (product!.compareAtPriceInPence! / 100).toStringAsFixed(2),
    );
    _stockController =
        TextEditingController(text: product?.stock.toString() ?? '10');
    _lowStockThresholdController = TextEditingController(
      text: product?.lowStockThreshold.toString() ?? '5',
    );
    _sizesController = TextEditingController(
      text: product?.availableSizes.join(', ') ?? 'S, M, L, XL',
    );
    _assetPathController = TextEditingController(
      text: product?.assetImagePath ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ShopProvider>().categories.toList();
    final currentCategory = _categoryController.text.trim();
    if (currentCategory.isNotEmpty && !categories.contains(currentCategory)) {
      categories.add(currentCategory);
      categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          _isEditing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: 760,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 32),
            children: [
              _imageSelector(),
              const SizedBox(height: 16),
              _field(
                controller: _nameController,
                label: 'Product name',
                validator: _required,
              ),
              _field(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: _required,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: DropdownButtonFormField<String>(
                  value: categories.contains(currentCategory)
                      ? currentCategory
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                  hint: const Text('Choose a category'),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _isSaving
                      ? null
                      : (value) => _categoryController.text = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Choose a category.'
                      : null,
                ),
              ),
              _field(
                controller: _priceController,
                label: 'Price in pounds (£)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: _positiveMoney,
              ),
              _field(
                controller: _compareAtPriceController,
                label: 'Original price in pounds (£) — optional',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return _positiveMoney(value);
                },
              ),
              _field(
                controller: _stockController,
                label: 'Stock quantity',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _nonNegativeNumber,
              ),
              _field(
                controller: _lowStockThresholdController,
                label: 'Low-stock warning level',
                hint: '5',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _nonNegativeNumber,
              ),
              _field(
                controller: _sizesController,
                label: 'Sizes separated by commas',
                hint: 'S, M, L, XL',
                validator: _required,
              ),
              _field(
                controller: _assetPathController,
                label: 'Image asset path (optional)',
                hint: 'assets/image1.png',
                validator: (value) {
                  final hasAssetPath = value?.trim().isNotEmpty ?? false;
                  final hasUploadedImage = _selectedImage != null ||
                      (widget.product?.imageUrl?.trim().isNotEmpty ?? false);
                  if (!hasAssetPath && !hasUploadedImage) {
                    return 'Choose an image or enter an asset path';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Add product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 210,
              child: _selectedImage != null
                  ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                  : widget.product != null
                      ? ProductImage(product: widget.product!)
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 52,
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              _selectedImage == null ? 'Choose product image' : 'Change image',
            ),
          ),
          const Text(
            'JPEG, PNG or WebP. Maximum upload size: 5 MB.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() => _selectedImage = image);
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? 'This field is required.'
        : null;
  }

  String? _positiveMoney(String? value) {
    final amount = double.tryParse(value ?? '');
    return amount == null || amount <= 0 ? 'Enter a valid price.' : null;
  }

  String? _nonNegativeNumber(String? value) {
    final number = int.tryParse(value ?? '');
    return number == null || number < 0
        ? 'Enter a valid stock quantity.'
        : null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final priceInPence =
        (double.parse(_priceController.text.trim()) * 100).round();
    final compareAtText = _compareAtPriceController.text.trim();
    final sizes = _sizesController.text
        .split(',')
        .map((size) => size.trim().toUpperCase())
        .where((size) => size.isNotEmpty)
        .toSet()
        .toList(growable: false);

    try {
      final shop = context.read<ShopProvider>();
      final productId = widget.product?.id ?? shop.createProductId();
      var imageUrl = widget.product?.imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _productImageService.uploadProductImage(
          productId: productId,
          image: _selectedImage!,
        );
      }

      final product = Product(
        id: productId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        priceInPence: priceInPence,
        compareAtPriceInPence: compareAtText.isEmpty
            ? null
            : (double.parse(compareAtText) * 100).round(),
        assetImagePath: _assetPathController.text.trim(),
        imageUrl: imageUrl,
        availableSizes: sizes,
        stock: int.parse(_stockController.text.trim()),
        lowStockThreshold: int.parse(_lowStockThresholdController.text.trim()),
      );
      await shop.saveProduct(product);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Product updated.' : 'Product added.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save the product.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _compareAtPriceController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    _sizesController.dispose();
    _assetPathController.dispose();
    super.dispose();
  }
}
