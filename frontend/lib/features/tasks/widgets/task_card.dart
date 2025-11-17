import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/task.dart';
import '../../../core/utils/platform_utils.dart';
import '../providers/task_provider.dart';
import '../../categories/providers/category_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: PlatformUtils.getCardElevation(),
      shape: RoundedRectangleBorder(
        borderRadius: PlatformUtils.getCardBorderRadius(),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push('/task-detail/${task.id}'),
        borderRadius: PlatformUtils.getCardBorderRadius(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: PlatformUtils.getCardBorderRadius(),
            border: Border.all(
              color: _getPriorityColor(task.priority).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Priority indicator
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with checkbox and menu
                    Row(
                      children: [
                        _buildCheckbox(context),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: task.isCompleted 
                                  ? Colors.grey 
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildTaskMenu(context),
                      ],
                    ),
                    
                    // Description
                    if (task.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.description!,
                        style: TextStyle(
                          color: task.isCompleted 
                              ? Colors.grey 
                              : Colors.grey[600],
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // Task details row
                    Row(
                      children: [
                        // Category
                        _buildCategoryChip(context),
                        const Spacer(),
                        // Due date
                        if (task.dueDate != null)
                          _buildDueDateChip(),
                        const SizedBox(width: 8),
                        // Priority
                        _buildPriorityChip(),
                      ],
                    ),
                    
                    // XP reward
                    if (task.xpReward > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.xpReward} XP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            if (value != null) {
              taskProvider.toggleTaskCompletion(task.id);
            }
          },
          activeColor: Theme.of(context).primaryColor,
        );
      },
    );
  }

  Widget _buildTaskMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('تعديل'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: ListTile(
            leading: Icon(Icons.copy),
            title: Text('نسخ'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('حذف', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        
        switch (value) {
          case 'edit':
            context.push('/edit-task/${task.id}');
            break;
          case 'duplicate':
            taskProvider.duplicateTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم نسخ المهمة')),
            );
            break;
          case 'delete':
            _showDeleteConfirmation(context, taskProvider);
            break;
        }
      },
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final category = task.categoryId != null 
            ? categoryProvider.getCategoryById(task.categoryId!) 
            : null;
        
        if (category == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000)
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000)
                  .withOpacity(0.5),
            ),
          ),
          child: Text(
            category.name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDueDateChip() {
    final isOverdue = task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;
    final isToday = _isToday(task.dueDate!);
    
    Color chipColor;
    if (isOverdue) {
      chipColor = Colors.red;
    } else if (isToday) {
      chipColor = Colors.orange;
    } else {
      chipColor = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.schedule,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(task.dueDate!),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(task.priority),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getPriorityText(task.priority),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'منخفض';
      case 'medium':
        return 'متوسط';
      case 'high':
        return 'عالي';
      case 'urgent':
        return 'عاجل';
      default:
        return 'متوسط';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'اليوم';
    } else if (taskDate == tomorrow) {
      return 'غداً';
    } else if (taskDate.isBefore(today)) {
      final difference = today.difference(taskDate).inDays;
      return 'متأخر $difference يوم';
    } else {
      final difference = taskDate.difference(today).inDays;
      return 'خلال $difference يوم';
    }
  }

  void _showDeleteConfirmation(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المهمة "${task.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              taskProvider.deleteTask(task.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المهمة')),
              );
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
