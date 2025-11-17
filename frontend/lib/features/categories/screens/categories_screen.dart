import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/responsive_layout.dart';
import '../../../core/utils/platform_utils.dart';
import '../providers/category_provider.dart';
import '../../../core/models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفئات'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'البحث في الفئات...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: _buildCategoriesList(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: PlatformUtils.getScreenPadding(context),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'البحث في الفئات...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildCategoriesList()),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildCategoryStats(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        List<Category> categories = _searchQuery.isEmpty
            ? categoryProvider.categories
            : categoryProvider.searchCategories(_searchQuery);

        if (categories.isEmpty) {
          return const Center(
            child: Text('لا توجد فئات'),
          );
        }

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(category);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: PlatformUtils.getCardElevation(),
      shape: RoundedRectangleBorder(
        borderRadius: PlatformUtils.getCardBorderRadius(),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000),
          child: Icon(
            _getCategoryIcon(category.icon),
            color: Colors.white,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: category.description?.isNotEmpty == true
            ? Text(category.description!)
            : null,
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('تعديل'),
              ),
            ),
            if (!category.isDefault)
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('حذف', style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditCategoryDialog(context, category);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, category);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategoryStats() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return Card(
          elevation: PlatformUtils.getCardElevation(),
          shape: RoundedRectangleBorder(
            borderRadius: PlatformUtils.getCardBorderRadius(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات الفئات',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow('إجمالي الفئات', categoryProvider.categories.length.toString()),
                _buildStatRow('الفئات الافتراضية', categoryProvider.getDefaultCategories().length.toString()),
                _buildStatRow('الفئات المخصصة', categoryProvider.getCustomCategories().length.toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'shopping':
        return Icons.shopping_cart;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(context, null);
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _showCategoryDialog(context, category);
  }

  void _showCategoryDialog(BuildContext context, Category? category) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    String selectedColor = category?.color ?? '#6366F1';
    String selectedIcon = category?.icon ?? 'category';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'إضافة فئة جديدة' : 'تعديل الفئة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الفئة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                
                if (category == null) {
                  categoryProvider.addCategory(
                    name: name,
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                    color: selectedColor,
                    icon: selectedIcon,
                  );
                } else {
                  categoryProvider.updateCategory(
                    category.id,
                    name: name,
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                    color: selectedColor,
                    icon: selectedIcon,
                  );
                }
                Navigator.of(context).pop();
              }
            },
            child: Text(category == null ? 'إضافة' : 'تحديث'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف فئة "${category.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
              categoryProvider.deleteCategory(category.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
