import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? web;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.web,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Web-specific layout
        if (PlatformUtils.isWeb && web != null) {
          return web!;
        }

        // Desktop layout
        if (constraints.maxWidth >= 1024) {
          return desktop ?? tablet ?? mobile;
        }

        // Tablet layout
        if (constraints.maxWidth >= 768) {
          return tablet ?? mobile;
        }

        // Mobile layout
        return mobile;
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        DeviceType deviceType;
        
        if (constraints.maxWidth >= 1024) {
          deviceType = DeviceType.desktop;
        } else if (constraints.maxWidth >= 768) {
          deviceType = DeviceType.tablet;
        } else {
          deviceType = DeviceType.mobile;
        }

        return builder(context, constraints, deviceType);
      },
    );
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return DeviceType.desktop;
    if (width >= 768) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static double getResponsiveWidth(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    final responsiveValue = ResponsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return responsiveValue.getValue(deviceType);
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      final width = MediaQuery.of(context).size.width;
      if (width > 1400) return 4;
      if (width > 1200) return 3;
      return 2;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 1;
    }
  }

  static double getCardWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 400.0;
    } else if (isTablet(context)) {
      return 350.0;
    } else {
      return double.infinity;
    }
  }

  static double getFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.1;
    } else if (isTablet(context)) {
      return baseSize * 1.05;
    } else {
      return baseSize;
    }
  }
}
