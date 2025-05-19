import 'package:flutter/material.dart';
import 'package:timetide/core/constants/colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final bool useDarkGradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.useDarkGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ??
              (useDarkGradient
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [AppColors.gradientStart, AppColors.gradientEnd]),
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}
