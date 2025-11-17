import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../../categories/providers/category_provider.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String)? onTextReceived;
  final Function(String)? onTaskCreated;
  final bool createTaskDirectly;

  const VoiceInputButton({
    super.key,
    this.onTextReceived,
    this.onTaskCreated,
    this.createTaskDirectly = false,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleVoiceInput() async {
    final aiProvider = context.read<AIProvider>();
    
    if (aiProvider.isListening) {
      await aiProvider.stopListening();
      _animationController.stop();
      return;
    }

    try {
      _animationController.repeat(reverse: true);
      
      final command = await aiProvider.startVoiceCommand();
      
      if (command != null && mounted) {
        switch (command.action) {
          case VoiceCommandAction.addTask:
            if (widget.createTaskDirectly) {
              final taskProvider = context.read<TaskProvider>();
              final categoryProvider = context.read<CategoryProvider>();
              
              final success = await aiProvider.createSmartTask(
                command.originalText,
                taskProvider,
                categoryProvider,
              );
              
              if (success && widget.onTaskCreated != null) {
                widget.onTaskCreated!(command.taskTitle ?? command.originalText);
              }
            } else if (widget.onTextReceived != null) {
              widget.onTextReceived!(command.taskTitle ?? command.originalText);
            }
            break;
            
          case VoiceCommandAction.searchTasks:
            if (widget.onTextReceived != null) {
              widget.onTextReceived!(command.searchQuery ?? command.originalText);
            }
            break;
            
          case VoiceCommandAction.showStats:
            // Navigate to analytics
            if (mounted) {
              Navigator.of(context).pushNamed('/analytics');
            }
            break;
            
          case VoiceCommandAction.unknown:
            if (widget.onTextReceived != null) {
              widget.onTextReceived!(command.originalText);
            }
            _showUnknownCommandDialog(command.originalText);
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التعرف على الصوت: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _showUnknownCommandDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أمر غير مفهوم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('لم أتمكن من فهم الأمر:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),
            const Text('الأوامر المتاحة:'),
            const SizedBox(height: 8),
            const Text('• "أضف مهمة [اسم المهمة]"'),
            const Text('• "ابحث عن [كلمة البحث]"'),
            const Text('• "اعرض الإحصائيات"'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
          if (widget.onTextReceived != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onTextReceived!(text);
              },
              child: const Text('استخدم كنص'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        final isListening = aiProvider.isListening;
        
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isListening ? _scaleAnimation.value : 1.0,
              child: FloatingActionButton(
                onPressed: _handleVoiceInput,
                backgroundColor: isListening 
                    ? Colors.red 
                    : Theme.of(context).primaryColor,
                child: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// زر صوتي مصغر للاستخدام داخل النماذج
class CompactVoiceButton extends StatelessWidget {
  final Function(String)? onTextReceived;
  final String tooltip;

  const CompactVoiceButton({
    super.key,
    this.onTextReceived,
    this.tooltip = 'إدخال صوتي',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        return IconButton(
          onPressed: aiProvider.isListening ? null : () async {
            try {
              final command = await aiProvider.startVoiceCommand();
              if (command != null && onTextReceived != null) {
                String text = '';
                switch (command.action) {
                  case VoiceCommandAction.addTask:
                    text = command.taskTitle ?? command.originalText;
                    break;
                  case VoiceCommandAction.searchTasks:
                    text = command.searchQuery ?? command.originalText;
                    break;
                  default:
                    text = command.originalText;
                }
                onTextReceived!(text);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في التعرف على الصوت: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          icon: Icon(
            aiProvider.isListening ? Icons.mic : Icons.mic_none,
            color: aiProvider.isListening 
                ? Colors.red 
                : Theme.of(context).primaryColor,
          ),
          tooltip: tooltip,
        );
      },
    );
  }
}
