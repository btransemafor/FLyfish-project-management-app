import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPress;
  const CustomBackButton({super.key, this.onPress});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        onPressed: onPress,
        icon: Icon(
          color: Colors.black,
          Icons.arrow_back_ios_new_outlined,
          size: 20,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
