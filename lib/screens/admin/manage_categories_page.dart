import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  String? _busyCategory;

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    if (!shop.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Categories')),
        body: const Center(child: Text('Administrator access is required.')),
      );
    }

    final categories = shop.categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busyCategory == null ? () => _showCategoryDialog() : null,
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
      ),
      body: categories.isEmpty
          ? const Center(child: Text('No categories have been added.'))
          : ResponsiveContent(
              maxWidth: 900,
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 12, bottom: 100),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final productCount = shop.products
                      .where((product) => product.category == category)
                      .length;
                  final isBusy = _busyCategory == category;
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      leading: CircleAvatar(
                        child: isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.category_outlined),
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '$productCount product${productCount == 1 ? '' : 's'}',
                      ),
                      trailing: PopupMenuButton<String>(
                        enabled: _busyCategory == null,
                        onSelected: (action) {
                          if (action == 'rename') {
                            _showCategoryDialog(existingName: category);
                          } else {
                            _deleteCategory(category);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'rename', child: Text('Rename')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _showCategoryDialog({String? existingName}) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryNameDialog(existingName: existingName),
    );
    if (name == null || name.isEmpty || !mounted) return;

    setState(() => _busyCategory = existingName ?? name);
    try {
      final shop = context.read<ShopProvider>();
      if (existingName == null) {
        await shop.addCategory(name);
      } else {
        await shop.renameCategory(existingName, name);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingName == null
              ? 'Category added.'
              : 'Category and its products were updated.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageFor(error))),
      );
    } finally {
      if (mounted) setState(() => _busyCategory = null);
    }
  }

  Future<void> _deleteCategory(String category) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete category?'),
            content: Text(
              '“$category” can only be deleted when it contains no products.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _busyCategory = category);
    try {
      await context.read<ShopProvider>().deleteCategory(category);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageFor(error))),
      );
    } finally {
      if (mounted) setState(() => _busyCategory = null);
    }
  }

  String _messageFor(Object error) {
    if (error is StateError) return error.message.toString();
    if (error is ArgumentError) return error.message.toString();
    return 'Unable to update categories. Please try again.';
  }
}

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({this.existingName});

  final String? existingName;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingName != null;
    return AlertDialog(
      title: Text(isEditing ? 'Rename category' : 'Add category'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Category name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
