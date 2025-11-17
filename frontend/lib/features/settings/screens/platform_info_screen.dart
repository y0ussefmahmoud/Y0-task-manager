import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../core/services/platform_service.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/responsive_layout.dart';

class PlatformInfoScreen extends StatefulWidget {
  const PlatformInfoScreen({super.key});

  @override
  State<PlatformInfoScreen> createState() => _PlatformInfoScreenState();
}

class _PlatformInfoScreenState extends State<PlatformInfoScreen> {
  Map<String, dynamic>? _platformInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlatformInfo();
  }

  Future<void> _loadPlatformInfo() async {
    try {
      final platformService = PlatformService.instance;
      final deviceInfo = await PlatformUtils.getDeviceInfo();
      final platformSettings = platformService.getPlatformSettings();
      
      setState(() {
        _platformInfo = {
          'device': deviceInfo,
          'settings': platformSettings,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _platformInfo = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات المنصة'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileLayout(),
              desktop: _buildDesktopLayout(),
            ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlatformOverview(),
          const SizedBox(height: 16),
          _buildDeviceInfo(),
          const SizedBox(height: 16),
          _buildFeatureSupport(),
          const SizedBox(height: 16),
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: PlatformUtils.getScreenPadding(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildPlatformOverview(),
                const SizedBox(height: 16),
                _buildAppInfo(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildDeviceInfo(),
                const SizedBox(height: 16),
                _buildFeatureSupport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformOverview() {
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
            Row(
              children: [
                Icon(
                  _getPlatformIcon(),
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PlatformUtils.platformName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getPlatformDescription(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('نوع الجهاز', _getDeviceType()),
            _buildInfoRow('دقة الشاشة', _getScreenResolution()),
            _buildInfoRow('حجم الشاشة', _getScreenSize()),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo() {
    if (_platformInfo == null || _platformInfo!['device'] == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('لا توجد معلومات متاحة'),
        ),
      );
    }

    final deviceInfo = _platformInfo!['device'] as Map<String, dynamic>;

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
              'معلومات الجهاز',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...deviceInfo.entries.map((entry) {
              if (entry.key == 'platform') return const SizedBox.shrink();
              return _buildInfoRow(
                _translateKey(entry.key),
                entry.value?.toString() ?? 'غير متاح',
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSupport() {
    if (_platformInfo == null || _platformInfo!['settings'] == null) {
      return const SizedBox.shrink();
    }

    final settings = _platformInfo!['settings'] as Map<String, dynamic>;
    final features = <String, bool>{};

    settings.forEach((key, value) {
      if (key.startsWith('supports') && value is bool) {
        features[key] = value;
      }
    });

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
              'المميزات المدعومة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.entries.map((entry) {
              return _buildFeatureRow(
                _translateFeature(entry.key),
                entry.value,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    if (_platformInfo == null || _platformInfo!['settings'] == null) {
      return const SizedBox.shrink();
    }

    final settings = _platformInfo!['settings'] as Map<String, dynamic>;

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
              'معلومات التطبيق',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('إصدار التطبيق', settings['appVersion'] ?? 'غير متاح'),
            _buildInfoRow('رقم البناء', settings['buildNumber'] ?? 'غير متاح'),
            _buildInfoRow('المنصة', settings['platform'] ?? 'غير متاح'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool isSupported) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isSupported ? Icons.check_circle : Icons.cancel,
            color: isSupported ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon() {
    if (PlatformUtils.isAndroid) return Icons.android;
    if (PlatformUtils.isIOS) return Icons.phone_iphone;
    if (PlatformUtils.isWindows) return Icons.desktop_windows;
    if (PlatformUtils.isMacOS) return Icons.desktop_mac;
    if (PlatformUtils.isLinux) return Icons.computer;
    if (PlatformUtils.isWeb) return Icons.web;
    return Icons.device_unknown;
  }

  String _getPlatformDescription() {
    if (PlatformUtils.isAndroid) return 'تطبيق Android أصلي';
    if (PlatformUtils.isIOS) return 'تطبيق iOS أصلي';
    if (PlatformUtils.isWindows) return 'تطبيق Windows سطح المكتب';
    if (PlatformUtils.isMacOS) return 'تطبيق macOS سطح المكتب';
    if (PlatformUtils.isLinux) return 'تطبيق Linux سطح المكتب';
    if (PlatformUtils.isWeb) return 'تطبيق ويب متقدم (PWA)';
    return 'منصة غير معروفة';
  }

  String _getDeviceType() {
    if (PlatformUtils.isMobile) return 'هاتف محمول';
    if (PlatformUtils.isDesktop) return 'سطح مكتب';
    if (PlatformUtils.isWeb) return 'متصفح ويب';
    return 'غير محدد';
  }

  String _getScreenResolution() {
    final size = MediaQuery.of(context).size;
    return '${size.width.toInt()} × ${size.height.toInt()}';
  }

  String _getScreenSize() {
    final size = MediaQuery.of(context).size;
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    return '${diagonal.toStringAsFixed(1)} نقطة';
  }

  String _translateKey(String key) {
    const translations = {
      'model': 'الموديل',
      'manufacturer': 'الشركة المصنعة',
      'androidVersion': 'إصدار Android',
      'sdkInt': 'مستوى SDK',
      'brand': 'العلامة التجارية',
      'device': 'الجهاز',
      'name': 'الاسم',
      'systemVersion': 'إصدار النظام',
      'localizedModel': 'الموديل المحلي',
      'identifierForVendor': 'معرف البائع',
      'computerName': 'اسم الكمبيوتر',
      'numberOfCores': 'عدد المعالجات',
      'systemMemoryInMegabytes': 'ذاكرة النظام (MB)',
      'userName': 'اسم المستخدم',
      'majorVersion': 'الإصدار الرئيسي',
      'minorVersion': 'الإصدار الفرعي',
      'hostName': 'اسم المضيف',
      'arch': 'المعمارية',
      'kernelVersion': 'إصدار النواة',
      'osRelease': 'إصدار النظام',
      'activeCPUs': 'المعالجات النشطة',
      'memorySize': 'حجم الذاكرة',
      'version': 'الإصدار',
      'id': 'المعرف',
      'idLike': 'مشابه لـ',
      'versionCodename': 'اسم الإصدار الرمزي',
      'versionId': 'معرف الإصدار',
      'prettyName': 'الاسم الجميل',
      'buildId': 'معرف البناء',
      'variant': 'المتغير',
      'variantId': 'معرف المتغير',
      'browserName': 'اسم المتصفح',
      'userAgent': 'وكيل المستخدم',
      'platform_details': 'تفاصيل المنصة',
      'vendor': 'البائع',
    };
    return translations[key] ?? key;
  }

  String _translateFeature(String feature) {
    const translations = {
      'supportsNotifications': 'الإشعارات',
      'supportsFileSystem': 'نظام الملفات',
      'supportsCamera': 'الكاميرا',
      'supportsLocation': 'تحديد الموقع',
      'supportsBiometrics': 'القياسات الحيوية',
      'supportsBackgroundTasks': 'المهام الخلفية',
      'supportsSystemTray': 'شريط النظام',
      'supportsWindowManagement': 'إدارة النوافذ',
      'supportsVibration': 'الاهتزاز',
    };
    return translations[feature] ?? feature;
  }
}
