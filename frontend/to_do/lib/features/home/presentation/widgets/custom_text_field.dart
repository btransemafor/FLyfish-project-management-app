import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  // Text properties
  final String label;
  final String? placeholder;
  final String? initialValue;
  final TextEditingController? controller;
  final String? helperText;
  final String? errorText;
  
  // Styling properties
  final Color? labelColor;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final double borderWidth;
  final double focusedBorderWidth;
  
  // Input properties
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  
  // Focus properties
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  
  // Validation
  final String? Function(String?)? validator;
  final bool required;
  
  // Callbacks
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  
  // Icons
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  
  const CustomTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.initialValue,
    this.controller,
    this.helperText,
    this.errorText,
    
    // Styling
    this.labelColor,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textStyle,
    this.labelStyle,
    this.contentPadding,
    this.borderRadius = 12.0,
    this.borderWidth = 1.0,
    this.focusedBorderWidth = 2.0,
    
    // Input properties
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    
    // Focus
    this.focusNode,
    this.nextFocusNode,
    
    // Validation
    this.validator,
    this.required = false,
    
    // Callbacks
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    
    // Icons
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleFieldSubmitted(String value) {
    if (widget.nextFocusNode != null) {
      FocusScope.of(context).requestFocus(widget.nextFocusNode);
    } else {
      _focusNode.unfocus();
    }
    widget.onFieldSubmitted?.call(value);
  }

  Color get _labelColor {
    if (!widget.enabled) return Colors.grey.shade400;
    if (widget.errorText != null) return Colors.red;
    if (_isFocused) return widget.focusedBorderColor ?? widget.labelColor ?? Theme.of(context).primaryColor;
    return widget.labelColor ?? Colors.grey.shade600;
  }

  Color get _borderColor {
    if (!widget.enabled) return Colors.grey.shade300;
    if (widget.errorText != null) return Colors.red;
    if (_isFocused) return widget.focusedBorderColor ?? widget.labelColor ?? Theme.of(context).primaryColor;
    return widget.borderColor ?? Colors.grey.shade400;
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey.shade600,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        splashRadius: 20,
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          focusNode: _focusNode,
          style: widget.textStyle ?? const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
          
          // Input properties
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction ?? 
            (widget.nextFocusNode != null ? TextInputAction.next : TextInputAction.done),
          inputFormatters: widget.inputFormatters,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          
          
          // Callbacks
          onChanged: widget.onChanged,
          onFieldSubmitted: _handleFieldSubmitted,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          
          // Validation
          validator: widget.validator ?? (widget.required ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập ${widget.label.toLowerCase()}';
            }
            return null;
          } : null),
          
          decoration: InputDecoration(
            // Content padding
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            
            // Labels and hints
            labelText: widget.label + (widget.required ? ' *' : ''),
            labelStyle: widget.labelStyle ?? GoogleFonts.inter(
              fontSize: 14,
              color: _labelColor,
              fontWeight: FontWeight.w500,
            ),
            hintText: widget.placeholder ?? "Nhập ${widget.label.toLowerCase()}...",
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
            helperText: widget.helperText,
            helperStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            errorText: widget.errorText,
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
            
            // Fill
            filled: true,
            fillColor: widget.enabled 
              ? (widget.fillColor ?? Colors.grey.shade50)
              : Colors.grey.shade100,
            
            // Icons
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            prefix: widget.prefix,
            suffix: widget.suffix,
            
            // Borders
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: _borderColor,
                width: widget.borderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: widget.borderColor ?? Colors.grey.shade400,
                width: widget.borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: _borderColor,
                width: widget.focusedBorderWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: widget.borderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: Colors.red.shade600,
                width: widget.focusedBorderWidth,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: widget.borderWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Extension để tạo các loại TextField thường dùng
class TextFieldFactory {
  static CustomTextField email({
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return CustomTextField(
      label: label,
      controller: controller,
      focusNode: focusNode,
      nextFocusNode: nextFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined),
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email không hợp lệ';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  static CustomTextField password({
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return CustomTextField(
      label: label,
      controller: controller,
      focusNode: focusNode,
      nextFocusNode: nextFocusNode,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập mật khẩu';
        }
        if (value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  static CustomTextField phone({
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return CustomTextField(
      label: label,
      controller: controller,
      focusNode: focusNode,
      nextFocusNode: nextFocusNode,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập số điện thoại';
        }
        if (value.length < 10) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  static CustomTextField multiline({
    required String label,
    TextEditingController? controller,
    FocusNode? focusNode,
    int maxLines = 4,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return CustomTextField(
      label: label,
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: 3,
      maxLength: maxLength,
      textInputAction: TextInputAction.newline,
      validator: validator,
      onChanged: onChanged,
    );
  }
}