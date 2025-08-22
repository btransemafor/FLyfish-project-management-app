import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
 
  final bool isLoading;
  final bool isDisabled;
  final Color backgroundColor;
  final Color textColor;
  final Color disabledColor;
  final double borderRadius;
  final double elevation;
  final double padding;
  final double fontSize;


  const CustomButton({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.disabledColor = Colors.grey,
    this.borderRadius = 12.0,
    this.elevation = 3.0,
    this.padding = 16.0,
    this.fontSize = 16.0,
  }) : super(key: key);

  bool get _canTap => !isLoading && !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: isDisabled ? 0.6 : 1.0,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: isDisabled
                  ? Colors.transparent
                  : Colors.blue.shade800, // customizable
              width: 2.0,
            ),
          ),
          color: backgroundColor,
          elevation: elevation,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: _canTap ? onPressed : null,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      height: 40,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ] else ...[
                    if (icon != null) ...[
                      Icon(icon, color: textColor),
                      SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.aBeeZee(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ));
  }
}
