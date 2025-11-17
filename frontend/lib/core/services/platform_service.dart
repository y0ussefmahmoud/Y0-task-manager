import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PlatformService {
  static PlatformService? _instance;
  static PlatformService get instance => _instance ??= PlatformService._();
  
  PlatformService._();

  // App Info
  PackageInfo? _packageInfo;
  Map<String, dynamic>? _deviceInfo;

  /// Initialize platform service
  Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
    _deviceInfo = await _getDeviceInfo();
  }

  /// Get app information
  PackageInfo get appInfo {
    if (_packageInfo == null) {
      throw Exception('PlatformService not initialized. Call initialize() first.');
    }
    return _packageInfo!;
  }

  /// Get device information
  Map<String, dynamic> get deviceInfo {
    if (_deviceInfo == null) {
      throw Exception('PlatformService not initialized. Call initialize() first.');
    }
    return _deviceInfo!;
  }

  /// Get device info based on platform
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> info = {};

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfoPlugin.webBrowserInfo;
        info = {
          'platform': 'Web',
          'browserName': webInfo.browserName.name,
          'userAgent': webInfo.userAgent ?? 'Unknown',
          'platform_details': webInfo.platform ?? 'Unknown',
          'vendor': webInfo.vendor ?? 'Unknown',
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        info = {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        info = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        info = {
          'platform': 'Windows',
          'computerName': windowsInfo.computerName,
          'numberOfCores': windowsInfo.numberOfCores,
          'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
          'userName': windowsInfo.userName,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
        };
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        info = {
          'platform': 'macOS',
          'model': macInfo.model,
          'hostName': macInfo.hostName,
          'arch': macInfo.arch,
          'kernelVersion': macInfo.kernelVersion,
          'osRelease': macInfo.osRelease,
          'activeCPUs': macInfo.activeCPUs,
          'memorySize': macInfo.memorySize,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        info = {
          'platform': 'Linux',
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'id': linuxInfo.id,
          'idLike': linuxInfo.idLike,
          'versionCodename': linuxInfo.versionCodename,
          'versionId': linuxInfo.versionId,
          'prettyName': linuxInfo.prettyName,
          'buildId': linuxInfo.buildId,
          'variant': linuxInfo.variant,
          'variantId': linuxInfo.variantId,
        };
      }
    } catch (e) {
      info = {
        'platform': 'Unknown',
        'error': e.toString(),
      };
    }

    return info;
  }

  /// Get application documents directory
  Future<Directory> getApplicationDocumentsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('Documents directory not supported on web');
    }
    return await getApplicationDocumentsDirectory();
  }

  /// Get temporary directory
  Future<Directory> getTemporaryDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('Temporary directory not supported on web');
    }
    return await getTemporaryDirectory();
  }

  /// Get application support directory
  Future<Directory> getApplicationSupportDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('Application support directory not supported on web');
    }
    return await getApplicationSupportDirectory();
  }

  /// Check network connectivity
  Future<ConnectivityResult> checkConnectivity() async {
    final connectivity = Connectivity();
    return await connectivity.checkConnectivity();
  }

  /// Listen to connectivity changes
  Stream<ConnectivityResult> get connectivityStream {
    final connectivity = Connectivity();
    return connectivity.onConnectivityChanged;
  }

  /// Launch URL
  Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Launch email
  Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    String emailUrl = 'mailto:$email';
    
    List<String> params = [];
    if (subject != null) params.add('subject=${Uri.encodeComponent(subject)}');
    if (body != null) params.add('body=${Uri.encodeComponent(body)}');
    
    if (params.isNotEmpty) {
      emailUrl += '?${params.join('&')}';
    }
    
    return await launchURL(emailUrl);
  }

  /// Launch phone call
  Future<bool> launchPhone(String phoneNumber) async {
    return await launchURL('tel:$phoneNumber');
  }

  /// Launch SMS
  Future<bool> launchSMS(String phoneNumber, {String? message}) async {
    String smsUrl = 'sms:$phoneNumber';
    if (message != null) {
      smsUrl += '?body=${Uri.encodeComponent(message)}';
    }
    return await launchURL(smsUrl);
  }

  /// Copy to clipboard
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Get from clipboard
  Future<String?> getFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData?.text;
  }

  /// Vibrate device (mobile only)
  Future<void> vibrate({Duration duration = const Duration(milliseconds: 100)}) async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return; // Vibration not supported on desktop/web
    }
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore vibration errors
    }
  }

  /// Show system notification (if supported)
  Future<void> showSystemNotification(String title, String body) async {
    // This would integrate with flutter_local_notifications
    // Implementation depends on the notification service
  }

  /// Get platform-specific app data directory
  Future<String> getAppDataDirectory() async {
    if (kIsWeb) {
      return 'web_storage'; // Use localStorage/indexedDB
    }
    
    try {
      final directory = await getApplicationSupportDirectory();
      return directory.path;
    } catch (e) {
      // Fallback to documents directory
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  /// Check if feature is supported on current platform
  bool isFeatureSupported(PlatformFeature feature) {
    switch (feature) {
      case PlatformFeature.notifications:
        return !kIsWeb;
      case PlatformFeature.fileSystem:
        return !kIsWeb;
      case PlatformFeature.camera:
        return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      case PlatformFeature.location:
        return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      case PlatformFeature.biometrics:
        return Platform.isAndroid || Platform.isIOS;
      case PlatformFeature.backgroundTasks:
        return Platform.isAndroid || Platform.isIOS;
      case PlatformFeature.systemTray:
        return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
      case PlatformFeature.windowManagement:
        return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
      case PlatformFeature.vibration:
        return Platform.isAndroid || Platform.isIOS;
      case PlatformFeature.clipboard:
        return true; // Supported on all platforms
      case PlatformFeature.urlLauncher:
        return true; // Supported on all platforms
    }
  }

  /// Get platform-specific settings
  Map<String, dynamic> getPlatformSettings() {
    return {
      'supportsNotifications': isFeatureSupported(PlatformFeature.notifications),
      'supportsFileSystem': isFeatureSupported(PlatformFeature.fileSystem),
      'supportsCamera': isFeatureSupported(PlatformFeature.camera),
      'supportsLocation': isFeatureSupported(PlatformFeature.location),
      'supportsBiometrics': isFeatureSupported(PlatformFeature.biometrics),
      'supportsBackgroundTasks': isFeatureSupported(PlatformFeature.backgroundTasks),
      'supportsSystemTray': isFeatureSupported(PlatformFeature.systemTray),
      'supportsWindowManagement': isFeatureSupported(PlatformFeature.windowManagement),
      'supportsVibration': isFeatureSupported(PlatformFeature.vibration),
      'platform': deviceInfo['platform'],
      'appVersion': appInfo.version,
      'buildNumber': appInfo.buildNumber,
    };
  }
}

enum PlatformFeature {
  notifications,
  fileSystem,
  camera,
  location,
  biometrics,
  backgroundTasks,
  systemTray,
  windowManagement,
  vibration,
  clipboard,
  urlLauncher,
}
