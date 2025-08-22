import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/* class CustomFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon; 
  final IconData? sufixIcon; 
  final VoidCallback? onDisplay; 

  const CustomFormField(
  
    {
    this.prefixIcon , 
    this.sufixIcon, 
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text, 
    this.onDisplay


  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, color: Colors.blue.shade900,),
        suffixIcon:
         
         GestureDetector(
          onTap: onDisplay,
          child: Icon(sufixIcon)
          ), 
         
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.blue.shade900),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1,color: Colors.blue.shade800),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2,color: Colors.blue.shade900),
          borderRadius: BorderRadius.circular(12)
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    );
  }
} */



class CustomFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final FocusNode? focusNode; 
  final FocusNode? nextFocusNode; 
  final int maxLines; 

  const CustomFormField({
    super.key,
    this.maxLines = 1, 
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.focusNode,
    this.nextFocusNode
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      focusNode: widget.focusNode,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(220, 7, 29, 48).withOpacity(0.7)),
      onFieldSubmitted: (_) {
      FocusScope.of(context).requestFocus(widget.nextFocusNode);
  },
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.prefixIcon,
          color: Colors.blue.shade900,
        ),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.blue.shade900,
                ),
              )
            : null,
        labelText: widget.label,
        labelStyle: GoogleFonts.poppins(color: Colors.blue.shade900, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.blue.shade800),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.blue.shade900),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    );
  }
}
