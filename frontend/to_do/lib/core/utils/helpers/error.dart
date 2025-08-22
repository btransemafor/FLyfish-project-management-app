import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorHelper {
  static void showError(BuildContext context, String? message) {
    Flushbar(
      // Custom font ở đây
      messageText: Text(
        message ?? '',
        style: GoogleFonts.robotoSlab(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.redAccent,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }
}
