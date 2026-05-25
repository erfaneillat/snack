import 'package:flutter/material.dart';

class ForwardChevron extends StatelessWidget {
  const ForwardChevron({super.key, required this.color, this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.chevron_right_rounded, color: color, size: size);
  }
}
