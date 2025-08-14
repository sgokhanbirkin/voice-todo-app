import 'package:flutter/material.dart';

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Responsive breakpoints
class ResponsiveBreakpoints {
  /// Mobile breakpoint (width < 600)
  static const double mobile = 600;

  /// Tablet breakpoint (600 <= width < 900)
  static const double tablet = 900;

  /// Desktop breakpoint (width >= 900)
  static const double desktop = 900;
}

/// Responsive utilities for detecting device types and screen sizes
class Responsive {
  /// Gets the current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < ResponsiveBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Checks if the current device is a mobile phone
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Checks if the current device is a tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Checks if the current device is a desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Gets responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  /// Gets responsive margin based on device type
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(8);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
    }
  }

  /// Gets responsive font size based on device type
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Gets responsive spacing based on device type
  static double getResponsiveSpacing(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  /// Builder function for mobile layout
  final Widget Function(BuildContext) mobile;

  /// Builder function for tablet layout
  final Widget Function(BuildContext)? tablet;

  /// Builder function for desktop layout
  final Widget Function(BuildContext)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = Responsive.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile(context);
      case DeviceType.tablet:
        return tablet?.call(context) ?? mobile(context);
      case DeviceType.desktop:
        return desktop?.call(context) ??
            tablet?.call(context) ??
            mobile(context);
    }
  }
}

// TODO: Add more responsive utilities (e.g., grid layouts, navigation patterns)
// TODO: Implement orientation-aware responsive behavior
// TODO: Add custom breakpoint configuration
// TODO: Create responsive text scale factors
