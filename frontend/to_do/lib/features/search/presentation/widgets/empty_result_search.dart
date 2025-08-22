import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyResultSearch extends StatelessWidget {
  final String message;
  const EmptyResultSearch({
    super.key,
    this.message = "Không tìm thấy kết quả nào",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
