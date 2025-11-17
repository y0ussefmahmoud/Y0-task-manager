import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;
  
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Get device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    Map<String, dynamic> info = {
      'platform': platformName,
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };

    if (isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      info.addAll({
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'androidVersion': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
      });
    } else if (isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      info.addAll({
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemVersion': iosInfo.systemVersion,
        'identifierForVendor': iosInfo.identifierForVendor,
      });
    } else if (isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      info.addAll({
        'computerName': windowsInfo.computerName,
        'userName': windowsInfo.userName,
        'majorVersion': windowsInfo.majorVersion,
        'minorVersion': windowsInfo.minorVersion,
      });
    } else if (isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      info.addAll({
        'model': macInfo.model,
        'hostName': macInfo.hostName,
        'osRelease': macInfo.osRelease,
        'kernelVersion': macInfo.kernelVersion,
      });
    } else if (isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      info.addAll({
        'name': linuxInfo.name,
        'version': linuxInfo.version,
        'id': linuxInfo.id,
        'prettyName': linuxInfo.prettyName,
      });
    } else if (isWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      info.addAll({
        'browserName': webInfo.browserName.name,
        'userAgent': webInfo.userAgent,
        'platform': webInfo.platform,
        'vendor': webInfo.vendor,
      });
    }

    return info;
  }

  /// Get appropriate padding for different platforms
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isDesktop) {
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth > 1200) {
        return EdgeInsets.symmetric(horizontal: screenWidth * 0.15);
      } else if (screenWidth > 800) {
        return EdgeInsets.symmetric(horizontal: screenWidth * 0.1);
      }
      return const EdgeInsets.symmetric(horizontal: 32.0);
    }
    return const EdgeInsets.all(16.0);
  }

  /// Get appropriate app bar height
  static double getAppBarHeight() {
    if (isMobile) return kToolbarHeight;
    if (isDesktop) return 64.0;
    return kToolbarHeight;
  }

  /// Get appropriate card elevation
  static double getCardElevation() {
    if (isMobile) return 2.0;
    if (isDesktop) return 4.0;
    return 1.0;
  }

  /// Get appropriate border radius
  static BorderRadius getCardBorderRadius() {
    if (isMobile) return BorderRadius.circular(12.0);
    if (isDesktop) return BorderRadius.circular(8.0);
    return BorderRadius.circular(8.0);
  }

  /// Check if platform supports notifications
  static bool get supportsNotifications {
    return isAndroid || isIOS || isWindows || isMacOS;
  }

  /// Check if platform supports file picker
  static bool get supportsFilePicker {
    return !isWeb || isAndroid || isIOS || isDesktop;
  }

  /// Get appropriate grid columns count
  static int getGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile) {
      return screenWidth > 600 ? 2 : 1;
    } else if (isDesktop) {
      if (screenWidth > 1400) return 4;
      if (screenWidth > 1000) return 3;
      if (screenWidth > 600) return 2;
      return 1;
    }
    return 2;
  }

  /// Get appropriate font size scaling
  static double getFontSizeScale() {
    if (isMobile) return 1.0;
    if (isDesktop) return 1.1;
    return 1.0;
  }

  /// Get appropriate icon size
  static double getIconSize({double base = 24.0}) {
    if (isMobile) return base;
    if (isDesktop) return base * 1.2;
    return base;
  }

  /// Check if platform supports window management
  static bool get supportsWindowManagement {
    return isDesktop;
  }

  /// Get appropriate minimum window size
  static Size getMinimumWindowSize() {
    if (isDesktop) return const Size(800, 600);
    return const Size(360, 640);
  }

  /// Get appropriate default window size
  static Size getDefaultWindowSize() {
    if (isDesktop) return const Size(1200, 800);
    return const Size(360, 640);
  }

  /// Check if platform supports system tray
  static bool get supportsSystemTray {
    return isWindows || isMacOS || isLinux;
  }

  /// Get platform-specific storage path
  static String getStoragePath() {
    if (isAndroid) return '/data/data/com.y0.taskmanager/';
    if (isIOS) return 'Documents/';
    if (isWindows) return r'C:\Users\%USERNAME%\AppData\Local\Y0TaskManager\';
    if (isMacOS) return '~/Library/Application Support/Y0TaskManager/';
    if (isLinux) return '~/.local/share/Y0TaskManager/';
    return './';
  }

  /// Get platform-specific keyboard shortcuts
  static Map<String, String> getKeyboardShortcuts() {
    final isMac = isMacOS;
    return {
      'newTask': isMac ? 'Cmd+N' : 'Ctrl+N',
      'search': isMac ? 'Cmd+F' : 'Ctrl+F',
      'save': isMac ? 'Cmd+S' : 'Ctrl+S',
      'refresh': isMac ? 'Cmd+R' : 'F5',
      'settings': isMac ? 'Cmd+,' : 'Ctrl+,',
      'quit': isMac ? 'Cmd+Q' : 'Alt+F4',
    };
  }
}
