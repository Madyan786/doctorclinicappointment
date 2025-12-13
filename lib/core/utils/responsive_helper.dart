import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive helper utility for adaptive layouts
class ResponsiveHelper {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late bool isTablet;
  static late bool isPhone;
  static late bool isLandscape;
  static late DeviceType deviceType;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    isLandscape = _mediaQueryData.orientation == Orientation.landscape;
    isTablet = screenWidth > 600;
    isPhone = screenWidth <= 600;
    
    deviceType = _getDeviceType();
  }

  static DeviceType _getDeviceType() {
    if (screenWidth < 360) return DeviceType.smallPhone;
    if (screenWidth < 600) return DeviceType.phone;
    if (screenWidth < 900) return DeviceType.tablet;
    return DeviceType.largeTablet;
  }

  /// Get responsive value based on device type
  static double getResponsiveValue({
    required double phone,
    double? tablet,
    double? smallPhone,
    double? largeTablet,
  }) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return smallPhone ?? phone * 0.85;
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone * 1.2;
      case DeviceType.largeTablet:
        return largeTablet ?? tablet ?? phone * 1.4;
    }
  }

  /// Get responsive font size
  static double fontSize(double size) {
    double scaleFactor = getResponsiveValue(
      smallPhone: 0.85,
      phone: 1.0,
      tablet: 1.1,
      largeTablet: 1.2,
    );
    return (size * scaleFactor).sp;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding({
    double horizontal = 20,
    double vertical = 16,
  }) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveValue(
        smallPhone: horizontal * 0.8,
        phone: horizontal,
        tablet: horizontal * 1.5,
      ).w,
      vertical: vertical.h,
    );
  }

  /// Get responsive margin
  static EdgeInsets responsiveMargin({
    double all = 16,
  }) {
    return EdgeInsets.all(
      getResponsiveValue(
        smallPhone: all * 0.8,
        phone: all,
        tablet: all * 1.3,
      ).w,
    );
  }

  /// Get grid cross axis count based on screen size
  static int getGridCrossAxisCount({
    int phone = 2,
    int tablet = 3,
    int largeTablet = 4,
  }) {
    if (isLandscape && isPhone) return phone + 1;
    switch (deviceType) {
      case DeviceType.smallPhone:
        return phone;
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.largeTablet:
        return largeTablet;
    }
  }

  /// Get responsive icon size
  static double iconSize(double size) {
    return getResponsiveValue(
      smallPhone: size * 0.85,
      phone: size,
      tablet: size * 1.15,
      largeTablet: size * 1.3,
    ).sp;
  }

  /// Get responsive border radius
  static double borderRadius(double radius) {
    return getResponsiveValue(
      smallPhone: radius * 0.9,
      phone: radius,
      tablet: radius * 1.1,
    ).r;
  }

  /// Get responsive card width for horizontal lists
  static double cardWidth({double phoneWidth = 160}) {
    return getResponsiveValue(
      smallPhone: phoneWidth * 0.85,
      phone: phoneWidth,
      tablet: phoneWidth * 1.3,
      largeTablet: phoneWidth * 1.5,
    ).w;
  }

  /// Check if should use single column layout
  static bool get useSingleColumn => screenWidth < 600;

  /// Get max content width for tablets
  static double get maxContentWidth => isTablet ? 600.w : screenWidth;
}

enum DeviceType {
  smallPhone,
  phone,
  tablet,
  largeTablet,
}

/// Extension for responsive sizing
extension ResponsiveExtension on num {
  /// Responsive width with device type consideration
  double get rw => ResponsiveHelper.getResponsiveValue(
    smallPhone: toDouble() * 0.85,
    phone: toDouble(),
    tablet: toDouble() * 1.2,
  ).w;

  /// Responsive height
  double get rh => ResponsiveHelper.getResponsiveValue(
    smallPhone: toDouble() * 0.9,
    phone: toDouble(),
    tablet: toDouble() * 1.1,
  ).h;

  /// Responsive font
  double get rf => ResponsiveHelper.fontSize(toDouble());

  /// Responsive radius
  double get rr => ResponsiveHelper.borderRadius(toDouble());
}

/// Responsive widget that rebuilds on orientation/size changes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveHelper helper) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return builder(context, ResponsiveHelper());
  }
}

/// Widget that shows different layouts for phone vs tablet
class AdaptiveLayout extends StatelessWidget {
  final Widget phoneLayout;
  final Widget? tabletLayout;
  final Widget? landscapeLayout;

  const AdaptiveLayout({
    super.key,
    required this.phoneLayout,
    this.tabletLayout,
    this.landscapeLayout,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    
    if (ResponsiveHelper.isLandscape && landscapeLayout != null) {
      return landscapeLayout!;
    }
    
    if (ResponsiveHelper.isTablet && tabletLayout != null) {
      return tabletLayout!;
    }
    
    return phoneLayout;
  }
}
