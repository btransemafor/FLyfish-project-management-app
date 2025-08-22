import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool gradient;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool cartAppbar;
  final bool isReload; 

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.gradient = false,
    this.onBackPressed,
    this.leading,
    this.cartAppbar = false,
    this.isReload = false

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Màu trắng chủ đạo
    final Color whiteBackground = Colors.white;
    final Color accentColor = Colors.grey.shade800;

    return Container(
      decoration: gradient
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                colors: [
                 const Color.fromARGB(255, 155, 191, 253),
                 // const Color.fromARGB(255, 23, 18, 175), 
                 // const Color.fromARGB(255, 1, 20, 116), 
                  const Color.fromARGB(255, 105, 118, 240), 
                 const Color.fromARGB(255, 16, 34, 150), 
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : BoxDecoration(
              color: backgroundColor ?? whiteBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20), 
                bottomRight: Radius.circular(20)
              )
            ),
      child: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: gradient
                ? Colors.grey.shade50.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            border: gradient
                ? Border.all(color: Colors.grey.shade200, width: 0)
                : null,
          ),
        
        ),
        leading: leading ??
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: onBackPressed ?? () {
                    isReload == true ? 
                    context.pop(true) : context.pop(false); 
                    
                  },
                  icon: Icon(
                    color: Colors.black,
                    Icons.arrow_back_ios_new_outlined,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        actions: actions != null
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(children: actions!),
                )
              ]
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
