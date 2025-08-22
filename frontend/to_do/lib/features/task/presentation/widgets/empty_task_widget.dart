import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyTaskWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyTaskWidget({
    super.key,
    this.message = 'Chưa có công việc nào hôm nay',
    this.icon = Icons.event_busy_outlined
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon for a friendly touch
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Icon(
                  icon,
                  size: 100,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              // Text with softer typography and dynamic color
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}