import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../ai/providers/ai_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AISuggestions extends StatefulWidget {
  const AISuggestions({super.key});

  @override
  State<AISuggestions> createState() => _AISuggestionsState();
}

class _AISuggestionsState extends State<AISuggestions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAI();
    });
  }

  Future<void> _initializeAI() async {
    final aiProvider = context.read<AIProvider>();
    await aiProvider.initializeAI();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AIProvider, TaskProvider, AuthProvider>(
      builder: (context, aiProvider, taskProvider, authProvider, child) {
        if (authProvider.user == null) return const SizedBox.shrink();
        
        final suggestions = aiProvider.getSmartSuggestions(
          taskProvider.allTasks, 
          authProvider.user!
        );

        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'اقتراحات ذكية',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/analytics'),
                      child: const Text('المزيد'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // عرض أول اقتراحين فقط
                ...suggestions.take(2).map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                
                if (suggestions.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'و ${suggestions.length - 2} اقتراحات أخرى...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
