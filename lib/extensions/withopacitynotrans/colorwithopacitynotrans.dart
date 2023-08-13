import 'package:flutter/material.dart';

extension ColorWithOpacityNoTrans on Color {
  Color withOpacityNoTrans(double opacity, Color bgColor) {

    int red = ((1 - opacity) * bgColor.red + opacity * this.red).round();
    int green = ((1 - opacity) * bgColor.green + opacity * this.green).round();
    int blue = ((1 - opacity) * bgColor.blue + opacity * this.blue).round();

    return Color.fromARGB(255, red, green, blue);
  }
}