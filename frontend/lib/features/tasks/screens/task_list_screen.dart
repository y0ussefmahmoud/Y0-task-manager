import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/task_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_chip.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المهام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث في المهام...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Chips
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    TaskFilterChip(
                      label: 'الكل',
                      isSelected: taskProvider.filterStatus == 'all',
                      onSelected: () => taskProvider.setFilterStatus('all'),
                    ),
                    const SizedBox(width: 8),
                    TaskFilterChip(
                      label: 'معلقة',
                      isSelected: taskProvider.filterStatus == 'pending',
                      onSelected: () => taskProvider.setFilterStatus('pending'),
                    ),
                    const SizedBox(width: 8),
                    TaskFilterChip(
                      label: 'قيد التنفيذ',
                      isSelected: taskProvider.filterStatus == 'in_progress',
                      onSelected: () => taskProvider.setFilterStatus('in_progress'),
                    ),
                    const SizedBox(width: 8),
                    TaskFilterChip(
                      label: 'مكتملة',
                      isSelected: taskProvider.filterStatus == 'completed',
                      onSelected: () => taskProvider.setFilterStatus('completed'),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Task List
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final tasks = _searchQuery.isEmpty
                    ? taskProvider.tasks
                    : taskProvider.searchTasks(_searchQuery);

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty 
                              ? Icons.task_outlined 
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'لا توجد مهام بعد'
                              : 'لا توجد نتائج للبحث',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'اضغط على + لإضافة مهمة جديدة'
                              : 'جرب كلمات بحث أخرى',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await taskProvider.initialize();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () => context.push('/tasks/${task.id}'),
                        onStatusChanged: (status) {
                          taskProvider.updateTask(task.id, status: status);
                        },
                        onEdit: () => context.push('/tasks/${task.id}/edit'),
                        onDelete: () => _showDeleteConfirmation(task.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ترتيب حسب',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.priority_high),
                    title: const Text('الأولوية'),
                    trailing: taskProvider.sortBy == 'priority'
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      taskProvider.setSortBy('priority');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('تاريخ الاستحقاق'),
                    trailing: taskProvider.sortBy == 'dueDate'
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      taskProvider.setSortBy('dueDate');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('تاريخ الإنشاء'),
                    trailing: taskProvider.sortBy == 'createdAt'
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      taskProvider.setSortBy('createdAt');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer2<TaskProvider, CategoryProvider>(
          builder: (context, taskProvider, categoryProvider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تصفية المهام',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Priority Filter
                  Text(
                    'الأولوية',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('الكل'),
                        selected: taskProvider.filterPriority == 'all',
                        onSelected: (_) => taskProvider.setFilterPriority('all'),
                      ),
                      FilterChip(
                        label: const Text('عاجل'),
                        selected: taskProvider.filterPriority == 'urgent',
                        onSelected: (_) => taskProvider.setFilterPriority('urgent'),
                      ),
                      FilterChip(
                        label: const Text('عالي'),
                        selected: taskProvider.filterPriority == 'high',
                        onSelected: (_) => taskProvider.setFilterPriority('high'),
                      ),
                      FilterChip(
                        label: const Text('متوسط'),
                        selected: taskProvider.filterPriority == 'medium',
                        onSelected: (_) => taskProvider.setFilterPriority('medium'),
                      ),
                      FilterChip(
                        label: const Text('منخفض'),
                        selected: taskProvider.filterPriority == 'low',
                        onSelected: (_) => taskProvider.setFilterPriority('low'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category Filter
                  Text(
                    'الفئة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      children: [
                        FilterChip(
                          label: const Text('الكل'),
                          selected: taskProvider.filterCategory == null,
                          onSelected: (_) => taskProvider.setFilterCategory(null),
                        ),
                        const SizedBox(height: 8),
                        ...categoryProvider.categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FilterChip(
                              label: Text(category.name),
                              selected: taskProvider.filterCategory == category.id,
                              onSelected: (_) => taskProvider.setFilterCategory(category.id),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Clear Filters Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        taskProvider.clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('مسح التصفية'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف المهمة'),
          content: const Text('هل أنت متأكد من حذف هذه المهمة؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final taskProvider = context.read<TaskProvider>();
                final success = await taskProvider.deleteTask(taskId);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'تم حذف المهمة بنجاح' : 'فشل في حذف المهمة',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}
