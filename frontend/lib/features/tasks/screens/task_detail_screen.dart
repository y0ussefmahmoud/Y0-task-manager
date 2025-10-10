import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/task_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/task.dart';
import '../../../core/theme/app_theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Task? _task;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    final taskProvider = context.read<TaskProvider>();
    _task = taskProvider.getTaskById(widget.taskId);
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('المهمة غير موجودة')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('المهمة غير موجودة أو تم حذفها'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المهمة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/tasks/${_task!.id}/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation();
                  break;
                case 'duplicate':
                  _duplicateTask();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('تكرار المهمة'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف المهمة', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title and Status
            _buildTaskHeader(),
            
            const SizedBox(height: 24),
            
            // Task Details Cards
            _buildTaskDetailsCard(),
            
            const SizedBox(height: 16),
            
            // Description
            if (_task!.description != null && _task!.description!.isNotEmpty)
              _buildDescriptionCard(),
            
            const SizedBox(height: 16),
            
            // Tags
            if (_task!.tags.isNotEmpty)
              _buildTagsCard(),
            
            const SizedBox(height: 16),
            
            // Progress Card
            _buildProgressCard(),
            
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: _buildStatusFAB(),
    );
  }

  Widget _buildTaskHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _task!.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      decoration: _task!.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(_task!.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.getStatusColor(_task!.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(_task!.status),
                    style: TextStyle(
                      color: AppTheme.getStatusColor(_task!.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.getPriorityColor(_task!.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: AppTheme.getPriorityColor(_task!.priority),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getPriorityText(_task!.priority),
                        style: TextStyle(
                          color: AppTheme.getPriorityColor(_task!.priority),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                if (_task!.isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.red),
                        SizedBox(width: 4),
                        Text(
                          'متأخرة',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل المهمة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Category
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                final category = _task!.categoryId != null
                    ? categoryProvider.getCategoryById(_task!.categoryId!)
                    : null;
                
                return _buildDetailRow(
                  icon: Icons.category,
                  label: 'الفئة',
                  value: category?.name ?? 'بدون فئة',
                  color: category != null 
                      ? Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000)
                      : null,
                );
              },
            ),
            
            const Divider(),
            
            // Due Date
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'تاريخ الاستحقاق',
              value: _task!.dueDate != null
                  ? DateFormat('yyyy/MM/dd - HH:mm').format(_task!.dueDate!)
                  : 'غير محدد',
            ),
            
            const Divider(),
            
            // Reminder
            _buildDetailRow(
              icon: Icons.notifications,
              label: 'التذكير',
              value: _task!.reminderDate != null
                  ? DateFormat('yyyy/MM/dd - HH:mm').format(_task!.reminderDate!)
                  : 'لا يوجد',
            ),
            
            const Divider(),
            
            // Estimated Duration
            _buildDetailRow(
              icon: Icons.timer,
              label: 'المدة المقدرة',
              value: _task!.estimatedDuration != null
                  ? '${_task!.estimatedDuration} دقيقة'
                  : 'غير محدد',
            ),
            
            const Divider(),
            
            // Created Date
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'تاريخ الإنشاء',
              value: DateFormat('yyyy/MM/dd - HH:mm').format(_task!.createdAt),
            ),
            
            if (_task!.completedAt != null) ...[
              const Divider(),
              _buildDetailRow(
                icon: Icons.check_circle,
                label: 'تاريخ الإكمال',
                value: DateFormat('yyyy/MM/dd - HH:mm').format(_task!.completedAt!),
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الوصف',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _task!.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العلامات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _task!.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقدم والمكافآت',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text('نقاط الخبرة: ${_task!.xpReward}'),
              ],
            ),
            
            if (_task!.isCompleted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.celebration, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'تهانينا! لقد أكملت هذه المهمة',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFAB() {
    if (_task!.isCompleted) {
      return FloatingActionButton.extended(
        onPressed: () => _updateTaskStatus('pending'),
        icon: const Icon(Icons.undo),
        label: const Text('إلغاء الإكمال'),
        backgroundColor: Colors.orange,
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () => _updateTaskStatus('completed'),
        icon: const Icon(Icons.check),
        label: const Text('إكمال المهمة'),
        backgroundColor: Colors.green,
      );
    }
  }

  Future<void> _updateTaskStatus(String status) async {
    final taskProvider = context.read<TaskProvider>();
    final success = await taskProvider.updateTask(_task!.id, status: status);
    
    if (success) {
      // Award XP if task completed
      if (status == 'completed') {
        final authProvider = context.read<AuthProvider>();
        authProvider.addXp(_task!.xpReward);
        authProvider.updateStreak();
      }
      
      _loadTask(); // Reload task data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'completed' 
                  ? 'تم إكمال المهمة! +${_task!.xpReward} نقطة خبرة'
                  : 'تم تحديث حالة المهمة',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskProvider.error ?? 'فشل في تحديث المهمة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
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
                final success = await taskProvider.deleteTask(_task!.id);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف المهمة بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop(); // Go back to previous screen
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(taskProvider.error ?? 'فشل في حذف المهمة'),
                      backgroundColor: Colors.red,
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

  void _duplicateTask() {
    // Navigate to add task screen with pre-filled data
    context.push('/tasks/add'); // TODO: Pass task data for duplication
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلقة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغية';
      default:
        return status;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'منخفضة';
      case 'medium':
        return 'متوسطة';
      case 'high':
        return 'عالية';
      case 'urgent':
        return 'عاجلة';
      default:
        return priority;
    }
  }
}
