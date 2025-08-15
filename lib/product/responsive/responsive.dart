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

/// Responsive widget utilities for common UI patterns
class ResponsiveWidgets {
  /// Create a responsive SizedBox with different heights for different devices
  static Widget verticalSpace(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    return SizedBox(
      height: Responsive.getResponsiveSpacing(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      ),
    );
  }

  /// Create a responsive SizedBox with different widths for different devices
  static Widget horizontalSpace(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    return SizedBox(
      width: Responsive.getResponsiveSpacing(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      ),
    );
  }

  /// Create responsive padding
  static EdgeInsets responsivePadding(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
    double? all,
    double? horizontal,
    double? vertical,
  }) {
    final deviceSpacing = Responsive.getResponsiveSpacing(
      context,
      mobile: mobile ?? all ?? horizontal ?? vertical ?? 16,
      tablet: tablet ?? all ?? horizontal ?? vertical ?? 20,
      desktop: desktop ?? all ?? horizontal ?? vertical ?? 24,
    );

    if (horizontal != null && vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: Responsive.getResponsiveSpacing(
          context,
          mobile: horizontal,
          tablet: horizontal * 1.25,
          desktop: horizontal * 1.5,
        ),
        vertical: Responsive.getResponsiveSpacing(
          context,
          mobile: vertical,
          tablet: vertical * 1.25,
          desktop: vertical * 1.5,
        ),
      );
    }

    return EdgeInsets.all(deviceSpacing);
  }

  /// Create a responsive container with consistent styling
  static Container responsiveContainer(
    BuildContext context, {
    required Widget child,
    Color? color,
    double? borderRadius,
    Border? border,
    BoxShadow? shadow,
  }) {
    return Container(
      padding: responsivePadding(context),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          borderRadius ??
              Responsive.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
        ),
        border: border,
        boxShadow: shadow != null ? [shadow] : null,
      ),
      child: child,
    );
  }

  /// Create a responsive card with enhanced theming
  static Card responsiveCard(
    BuildContext context, {
    required Widget child,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Border? border,
    List<BoxShadow>? shadows,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin:
          margin ??
          EdgeInsets.all(
            Responsive.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
          ),
      elevation: isDark ? 6 : 4,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.15),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ??
              Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
        ),
        side: border?.top ?? BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          borderRadius ??
              Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
        ),
        child: Container(
          padding:
              padding ??
              EdgeInsets.all(
                Responsive.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              borderRadius ??
                  Responsive.getResponsiveSpacing(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
            ),
            border: border,
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }

  /// Create enhanced task card with better theming
  static Widget enhancedTaskCard(
    BuildContext context, {
    required Widget child,
    bool isCompleted = false,
    Color? priorityColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Card(
      margin:
          margin ??
          EdgeInsets.all(
            Responsive.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
          ),
      elevation: isDark ? 8 : 6,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.6)
          : Colors.black.withValues(alpha: 0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isCompleted
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : priorityColor?.withValues(alpha: 0.3) ??
                    theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isCompleted ? 1 : 2,
        ),
      ),
      child: Container(
        padding:
            padding ??
            EdgeInsets.all(
              Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
        decoration: BoxDecoration(
          color: isCompleted
              ? theme.colorScheme.surface.withValues(alpha: 0.7)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          gradient: isCompleted
              ? null
              : (priorityColor != null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.surface,
                          priorityColor.withValues(alpha: 0.05),
                        ],
                      )
                    : null),
        ),
        child: child,
      ),
    );
  }

  /// Create responsive text with device-appropriate font sizes
  static Widget responsiveText(
    BuildContext context, {
    required String text,
    required double mobileFontSize,
    required double tabletFontSize,
    required double desktopFontSize,
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: Responsive.getResponsiveFontSize(
          context,
          mobile: mobileFontSize,
          tablet: tabletFontSize,
          desktop: desktopFontSize,
        ),
      ),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  /// Create a responsive icon with device-appropriate sizes
  static Widget responsiveIcon(
    BuildContext context, {
    required IconData icon,
    Color? color,
    double? mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    return Icon(
      icon,
      color: color,
      size: Responsive.getResponsiveSpacing(
        context,
        mobile: mobileSize ?? 24,
        tablet: tabletSize ?? 28,
        desktop: desktopSize ?? 32,
      ),
    );
  }
}
