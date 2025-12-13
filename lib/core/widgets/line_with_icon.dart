import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctorclinic/core/core.dart';

class LineWithIcon extends StatelessWidget {
  final String? imagePath;
  final IconData? icon;
  final double circleSize;
  final Color circleColor;
  final Color lineColor;
  final double lineHeight;
  final double linePadding;
  final double? iconSize;
  final Color? iconColor;

  const LineWithIcon({
    super.key,
    this.imagePath,
    this.icon,
    this.circleSize = 35,
    this.circleColor = const Color(0xFF355CE4),
    this.lineColor = const Color(0xFF5F6FFF),
    this.lineHeight = 1,
    this.linePadding = 20,
    this.iconSize,
    this.iconColor,
  });

  // Factory for image
  factory LineWithIcon.image({
    required String imagePath,
    double circleSize = 35,
    Color? circleColor,
    Color? lineColor,
    double lineHeight = 1,
    double linePadding = 20,
  }) {
    return LineWithIcon(
      imagePath: imagePath,
      circleSize: circleSize,
      circleColor: circleColor ?? AppColors.primary,
      lineColor: lineColor ?? AppColors.primary2nd,
      lineHeight: lineHeight,
      linePadding: linePadding,
    );
  }

  // Factory for icon
  factory LineWithIcon.icon({
    required IconData icon,
    double circleSize = 35,
    Color? circleColor,
    Color? lineColor,
    double lineHeight = 1,
    double linePadding = 20,
    double? iconSize,
    Color? iconColor,
  }) {
    return LineWithIcon(
      icon: icon,
      circleSize: circleSize,
      circleColor: circleColor ?? AppColors.primary,
      lineColor: lineColor ?? AppColors.primary2nd,
      lineHeight: lineHeight,
      linePadding: linePadding,
      iconSize: iconSize,
      iconColor: iconColor ?? AppColors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left line
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: linePadding.w),
            child: Container(
              height: lineHeight.h,
              color: lineColor.withOpacity(0.5),
            ),
          ),
        ),
        // Circle with icon/image
        Container(
          width: circleSize.w,
          height: circleSize.h,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: circleColor,
              width: 2.w,
            ),
          ),
          child: Center(
            child: imagePath != null
                ? Image.asset(
                    imagePath!,
                    height: (circleSize - 5).h,
                    width: (circleSize - 5).w,
                  )
                : Icon(
                    icon,
                    size: (iconSize ?? circleSize * 0.6).sp,
                    color: iconColor ?? AppColors.white,
                  ),
          ),
        ),
        // Right line
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: linePadding.w),
            child: Container(
              height: lineHeight.h,
              color: lineColor.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
