import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  ShimmerWidget.rectangular({
    Key? key,
    this.width = double.infinity,
    required this.height,
  })  : shapeBorder = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        super(key: key);

  const ShimmerWidget.circular({
    Key? key,
    required this.width,
    required this.height,
  })  : shapeBorder = const CircleBorder(),
        super(key: key);

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: Colors.grey.shade400,
            shape: shapeBorder,
          ),
        ),
      );
}
