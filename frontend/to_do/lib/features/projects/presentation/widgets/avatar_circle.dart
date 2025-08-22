import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String avatar; 
  final double size; 

  const AvatarCircle({super.key, required this.avatar, required this.size}); 

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white, 
        shape: BoxShape.circle
      ),
      child: CircleAvatar(
        radius: size,
        backgroundImage: NetworkImage(avatar),
      ),
    ); 
  }
}