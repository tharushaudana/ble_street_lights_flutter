import 'package:flutter/material.dart';

class GradienText extends StatelessWidget {
  const GradienText(
    this.text, {
    super.key,
    this.style,
    required this.gradient,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
