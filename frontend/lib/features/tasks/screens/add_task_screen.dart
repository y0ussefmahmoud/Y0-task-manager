import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/task_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../ai/providers/ai_provider.dart';
import '../../ai/widgets/voice_input_button.dart';
import '../../../core/models/task.dart';
import '../../../core/models/category.dart';

class AddTaskScreen extends StatefulWidget {
  final String? taskId;

  const AddTaskScreen({super.key, this.taskId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _estimatedDurationController = TextEditingController();

  String _priority = 'medium';
  DateTime? _dueDate;
  DateTime? _reminderDate;
  Category? _selectedCategory;
  List<String> _tags = [];
  bool _isLoading = false;
  Task? _editingTask;
  String? _aiSuggestedPriority;
  DateTime? _aiSuggestedDate;
  int? _aiEstimatedDuration;

  @override
  void initState() {
    super.initState();
    _loadTaskForEditing();
  }

  Future<void> _loadTaskForEditing() async {
    if (widget.taskId != null) {
      final taskProvider = context.read<TaskProvider>();
      _editingTask = taskProvider.getTaskById(widget.taskId!);
      
      if (_editingTask != null) {
        _titleController.text = _editingTask!.title;
        _descriptionController.text = _editingTask!.description ?? '';
        _priority = _editingTask!.priority;
        _dueDate = _editingTask!.dueDate;
        _reminderDate = _editingTask!.reminderDate;
        _tags = List.from(_editingTask!.tags);
        _tagsController.text = _tags.join(', ');
        _estimatedDurationController.text = 
            _editingTask!.estimatedDuration?.toString() ?? '';
        
        // Load category
        if (_editingTask!.categoryId != null) {
          final categoryProvider = context.read<CategoryProvider>();
          _selectedCategory = categoryProvider.getCategoryById(_editingTask!.categoryId!);
        }
        
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final taskProvider = context.read<TaskProvider>();
    bool success;

    if (_editingTask != null) {
      // Update existing task
      success = await taskProvider.updateTask(
        _editingTask!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        reminderDate: _reminderDate,
        estimatedDuration: _estimatedDurationController.text.isEmpty 
            ? null 
            : int.tryParse(_estimatedDurationController.text),
        tags: _tags,
        categoryId: _selectedCategory?.id,
      );
    } else {
      // Create new task
      success = await taskProvider.addTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        reminderDate: _reminderDate,
        estimatedDuration: _estimatedDurationController.text.isEmpty 
            ? null 
            : int.tryParse(_estimatedDurationController.text),
        tags: _tags,
        categoryId: _selectedCategory?.id,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingTask != null ? 'تم تحديث المهمة بنجاح' : 'تم إضافة المهمة بنجاح',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskProvider.error ?? (_editingTask != null 
                ? 'فشل في تحديث المهمة' 
                : 'فشل في إضافة المهمة'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingTask != null ? 'تعديل المهمة' : 'مهمة جديدة'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('حفظ'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field with AI
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان المهمة *',
                prefixIcon: const Icon(Icons.title),
                suffixIcon: CompactVoiceButton(
                  onTextReceived: (text) {
                    _titleController.text = text;
                    _analyzeTaskText(text);
                  },
                  tooltip: 'إدخال صوتي للمهمة',
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'عنوان المهمة مطلوب';
                }
                return null;
              },
              onChanged: _analyzeTaskText,
            ),

            const SizedBox(height: 8),
            
            // AI Suggestions Card
            _buildAISuggestionsCard(),

            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'الوصف',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // Priority Selection
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'الأولوية',
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                DropdownMenuItem(value: 'high', child: Text('عالية')),
                DropdownMenuItem(value: 'urgent', child: Text('عاجلة')),
              ],
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Category Selection
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                return DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    const DropdownMenuItem<Category>(
                      value: null,
                      child: Text('بدون فئة'),
                    ),
                    ...categoryProvider.categories.map((category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Due Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('تاريخ الاستحقاق'),
              subtitle: _dueDate != null
                  ? Text(DateFormat('yyyy/MM/dd HH:mm').format(_dueDate!))
                  : const Text('لم يتم تحديد تاريخ'),
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                    )
                  : null,
              onTap: _selectDueDate,
            ),

            const Divider(),

            // Reminder Date
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('تذكير'),
              subtitle: _reminderDate != null
                  ? Text(DateFormat('yyyy/MM/dd HH:mm').format(_reminderDate!))
                  : const Text('لا يوجد تذكير'),
              trailing: _reminderDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _reminderDate = null;
                        });
                      },
                    )
                  : null,
              onTap: _selectReminderDate,
            ),

            const Divider(),

            // Estimated Duration
            TextFormField(
              controller: _estimatedDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المدة المقدرة (بالدقائق)',
                prefixIcon: Icon(Icons.timer),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'المدة يجب أن تكون رقم موجب';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'العلامات (مفصولة بفاصلة)',
                prefixIcon: Icon(Icons.tag),
                hintText: 'مثال: عمل, مهم, سريع',
              ),
              onChanged: (value) {
                _tags = value
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_editingTask != null ? 'تحديث المهمة' : 'إضافة المهمة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectReminderDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _dueDate ?? DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _reminderDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // AI Analysis Methods
  void _analyzeTaskText(String text) {
    if (text.trim().isEmpty) return;
    
    final aiProvider = context.read<AIProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final taskProvider = context.read<TaskProvider>();
    
    // Analyze text with NLP
    final categories = categoryProvider.categories.map((c) => c.name).toList();
    final analysis = aiProvider.analyzeTaskText(text, categories);
    
    // Suggest priority
    final suggestedPriority = aiProvider.suggestPriority(text, _descriptionController.text);
    
    // Estimate duration
    final estimatedDuration = aiProvider.estimateDuration(text, _descriptionController.text, taskProvider.allTasks);
    
    setState(() {
      _aiSuggestedPriority = suggestedPriority;
      _aiSuggestedDate = analysis.combinedDateTime;
      _aiEstimatedDuration = estimatedDuration;
    });
  }

  Widget _buildAISuggestionsCard() {
    if (_aiSuggestedPriority == null && _aiSuggestedDate == null && _aiEstimatedDuration == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Text(
                  'اقتراحات ذكية',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (_aiSuggestedPriority != null && _aiSuggestedPriority != _priority)
              _buildSuggestionChip(
                'الأولوية: ${_getPriorityText(_aiSuggestedPriority!)}',
                () {
                  setState(() {
                    _priority = _aiSuggestedPriority!;
                  });
                },
              ),
            
            if (_aiSuggestedDate != null && _aiSuggestedDate != _dueDate)
              _buildSuggestionChip(
                'التاريخ: ${DateFormat('dd/MM/yyyy').format(_aiSuggestedDate!)}',
                () {
                  setState(() {
                    _dueDate = _aiSuggestedDate;
                  });
                },
              ),
            
            if (_aiEstimatedDuration != null && _aiEstimatedDuration != int.tryParse(_estimatedDurationController.text))
              _buildSuggestionChip(
                'المدة المقدرة: ${_aiEstimatedDuration} دقيقة',
                () {
                  _estimatedDurationController.text = _aiEstimatedDuration.toString();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.add, size: 12, color: Colors.blue[700]),
            ],
          ),
        ),
      ),
    );
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low': return 'منخفضة';
      case 'medium': return 'متوسطة';
      case 'high': return 'عالية';
      case 'urgent': return 'عاجلة';
      default: return 'متوسطة';
    }
  }
}
