import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required SnackBarType snackBarType,
    required String label,
    required Color? bgColor,
  }) {
    IconSnackBar.show(
      context,
      snackBarType: snackBarType,
      label: label,
    );
  }
}