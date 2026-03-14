import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerAdView extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerAdView({
    super.key,
    this.width = double.infinity,
    this.height = 300,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
