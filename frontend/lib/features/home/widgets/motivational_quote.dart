import 'package:flutter/material.dart';
import 'dart:math';

import '../../../core/utils/platform_utils.dart';

class MotivationalQuote extends StatefulWidget {
  const MotivationalQuote({super.key});

  @override
  State<MotivationalQuote> createState() => _MotivationalQuoteState();
}

class _MotivationalQuoteState extends State<MotivationalQuote> {
  late String currentQuote;
  late String currentAuthor;

  final List<Map<String, String>> quotes = [
    {
      'quote': 'النجاح هو الانتقال من فشل إلى فشل دون فقدان الحماس',
      'author': 'ونستون تشرشل'
    },
    {
      'quote': 'الطريقة الوحيدة للقيام بعمل عظيم هي أن تحب ما تفعله',
      'author': 'ستيف جوبز'
    },
    {
      'quote': 'لا تؤجل عمل اليوم إلى الغد',
      'author': 'بنجامين فرانكلين'
    },
    {
      'quote': 'الإنجاز الصغير أفضل من الخطة الكبيرة',
      'author': 'مثل صيني'
    },
    {
      'quote': 'كل إنجاز عظيم كان يوماً ما مستحيلاً',
      'author': 'نيلسون مانديلا'
    },
    {
      'quote': 'ابدأ من حيث أنت، استخدم ما لديك، افعل ما تستطيع',
      'author': 'آرثر آش'
    },
    {
      'quote': 'الطموح هو الوقود الذي يحرك المحرك',
      'author': 'نورمان فينسنت بيل'
    },
    {
      'quote': 'التركيز والبساطة هما سر النجاح',
      'author': 'ستيف جوبز'
    },
    {
      'quote': 'الوقت أثمن من المال، يمكنك الحصول على المزيد من المال ولكن لا يمكنك الحصول على المزيد من الوقت',
      'author': 'جيم رون'
    },
    {
      'quote': 'إذا كنت تريد شيئاً لم تحصل عليه من قبل، عليك أن تفعل شيئاً لم تفعله من قبل',
      'author': 'توماس جيفرسون'
    },
    {
      'quote': 'النجاح ليس نهائياً، والفشل ليس قاتلاً، الشجاعة للاستمرار هي ما يهم',
      'author': 'ونستون تشرشل'
    },
    {
      'quote': 'لا تنتظر الفرصة، اصنعها',
      'author': 'جورج برنارد شو'
    },
    {
      'quote': 'الطريق إلى النجاح دائماً قيد الإنشاء',
      'author': 'ليلي توملين'
    },
    {
      'quote': 'أفضل وقت لزراعة شجرة كان قبل 20 عاماً، ثاني أفضل وقت هو الآن',
      'author': 'مثل صيني'
    },
    {
      'quote': 'التقدم مستحيل بدون تغيير، ومن لا يستطيع تغيير عقله لا يستطيع تغيير أي شيء',
      'author': 'جورج برنارد شو'
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomQuote();
  }

  void _selectRandomQuote() {
    final random = Random();
    final selectedQuote = quotes[random.nextInt(quotes.length)];
    setState(() {
      currentQuote = selectedQuote['quote']!;
      currentAuthor = selectedQuote['author']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PlatformUtils.getCardElevation(),
      shape: RoundedRectangleBorder(
        borderRadius: PlatformUtils.getCardBorderRadius(),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: PlatformUtils.getCardBorderRadius(),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'اقتباس اليوم',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _selectRandomQuote,
                    tooltip: 'اقتباس جديد',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '"$currentQuote"',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '- $currentAuthor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
