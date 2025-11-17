import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_service.dart';
import '../providers/ai_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAnalytics();
    });
  }

  Future<void> _refreshAnalytics() async {
    final aiProvider = context.read<AIProvider>();
    final taskProvider = context.read<TaskProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user != null) {
      await aiProvider.analyzeProductivity(taskProvider.allTasks, authProvider.user!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل الإنتاجية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAnalytics,
          ),
        ],
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          if (aiProvider.isAnalyzing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحليل بياناتك...'),
                ],
              ),
            );
          }

          if (aiProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'خطأ في التحليل',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aiProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshAnalytics,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final analysis = aiProvider.currentAnalysis;
          if (analysis == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد بيانات للتحليل',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('أضف بعض المهام لرؤية التحليل'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshAnalytics,
                    child: const Text('تحديث'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAnalytics,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نقاط الإنتاجية
                  _buildProductivityScoreCard(analysis),
                  
                  const SizedBox(height: 16),
                  
                  // إحصائيات عامة
                  _buildStatsGrid(analysis),
                  
                  const SizedBox(height: 16),
                  
                  // معدل الإنجاز
                  _buildCompletionRateCard(analysis),
                  
                  const SizedBox(height: 16),
                  
                  // أفضل وقت للعمل
                  _buildBestWorkTimeCard(analysis),
                  
                  const SizedBox(height: 16),
                  
                  // اقتراحات التحسين
                  _buildSuggestionsCard(analysis),
                  
                  const SizedBox(height: 16),
                  
                  // المهام المتوقع تأخيرها
                  _buildOverdueTasksCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductivityScoreCard(ProductivityAnalysis analysis) {
    final score = analysis.productivityScore;
    final color = score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: color),
                const SizedBox(width: 8),
                Text(
                  'نقاط الإنتاجية',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$score',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'نقطة',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreDescription(score),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ProductivityAnalysis analysis) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildStatCard(
          'إجمالي المهام',
          '${analysis.totalTasks}',
          Icons.task_outlined,
          Colors.blue,
        ),
        _buildStatCard(
          'المهام المكتملة',
          '${analysis.completedTasks}',
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildStatCard(
          'المهام المعلقة',
          '${analysis.pendingTasks}',
          Icons.pending_outlined,
          Colors.orange,
        ),
        _buildStatCard(
          'السلسلة',
          '${analysis.streakDays} يوم',
          Icons.local_fire_department,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRateCard(ProductivityAnalysis analysis) {
    final rate = (analysis.completionRate * 100).round();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'معدل الإنجاز',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: analysis.completionRate,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 8),
            Text(
              '$rate% من المهام مكتملة',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'متوسط ${analysis.averageTasksPerDay.toStringAsFixed(1)} مهام يومياً',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestWorkTimeCard(ProductivityAnalysis analysis) {
    final hour = analysis.mostProductiveHour;
    final timeString = '${hour.toString().padLeft(2, '0')}:00';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'أفضل وقت للعمل',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    timeString,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'أنت أكثر إنتاجية في هذا الوقت',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsCard(ProductivityAnalysis analysis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'اقتراحات التحسين',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...analysis.suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueTasksCard() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final aiProvider = context.read<AIProvider>();
        final overdueTasks = aiProvider.predictOverdueTasks(taskProvider.allTasks);
        
        if (overdueTasks.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_outlined, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'المهام المعرضة للتأخير',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 8),
                  const Text('ممتاز! لا توجد مهام معرضة للتأخير'),
                ],
              ),
            ),
          );
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'مهام معرضة للتأخير (${overdueTasks.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...overdueTasks.take(3).map((task) => ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.orange),
                  title: Text(task.title),
                  subtitle: Text(
                    'موعد الاستحقاق: ${task.dueDate != null ? _formatDate(task.dueDate!) : 'غير محدد'}',
                  ),
                  trailing: Chip(
                    label: Text(task.priority),
                    backgroundColor: _getPriorityColor(task.priority),
                  ),
                )).toList(),
                if (overdueTasks.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'و ${overdueTasks.length - 3} مهام أخرى...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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

  String _getScoreDescription(int score) {
    if (score >= 90) return 'إنتاجية ممتازة! 🎉';
    if (score >= 80) return 'إنتاجية جيدة جداً! 👏';
    if (score >= 70) return 'إنتاجية جيدة 👍';
    if (score >= 60) return 'إنتاجية متوسطة 📈';
    if (score >= 40) return 'يمكن تحسينها 💪';
    return 'تحتاج لتحسين كبير 🚀';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'اليوم';
    if (difference == 1) return 'غداً';
    if (difference == -1) return 'أمس';
    if (difference > 0) return 'خلال $difference أيام';
    return 'متأخر ${-difference} أيام';
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent': return Colors.red.withOpacity(0.2);
      case 'high': return Colors.orange.withOpacity(0.2);
      case 'medium': return Colors.blue.withOpacity(0.2);
      case 'low': return Colors.green.withOpacity(0.2);
      default: return Colors.grey.withOpacity(0.2);
    }
  }
}
