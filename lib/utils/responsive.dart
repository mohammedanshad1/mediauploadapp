import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  final double width;
  final double height;
  final double textScaleFactor;
  final TextScaler textScaler;

  Responsive({required this.context})
      : width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height,
        textScaler = MediaQuery.textScalerOf(context),
        textScaleFactor = MediaQuery.textScaleFactorOf(context);

  double wp(double percentage) {
    return width * percentage / 100;
  }

  double hp(double percentage) {
    return height * percentage / 100;
  }

  double sp(double fontSize) {
    // Adjust the scale factor to normalize text sizes across devices
    double normalizedFontSize = fontSize / textScaleFactor;
    return textScaler.scale(normalizedFontSize);
  }
}

extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(context: this);
}