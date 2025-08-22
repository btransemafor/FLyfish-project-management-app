import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemProfileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color colorBackgroundIcon;
  final Color colorIcon;
  final Function(BuildContext)? onTap;

  const ItemProfileCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.colorBackgroundIcon,
    required this.colorIcon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorBackgroundIcon,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorIcon, size: 24),
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
