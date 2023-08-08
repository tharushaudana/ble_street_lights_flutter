import 'package:flutter/material.dart';

class NeumorphismButton extends StatefulWidget {
  const NeumorphismButton({
    super.key,
    this.initialSwitched = false,
    this.switched,
    this.glowEnabled = true,
    this.disabled = false,
    required this.onSwitching,
  });

  final bool initialSwitched;
  final bool? switched;
  final bool glowEnabled;
  final bool disabled;
  final bool Function(bool will) onSwitching;

  @override
  State<StatefulWidget> createState() => _NeumorphismButtonState();
}

class _NeumorphismButtonState extends State<NeumorphismButton> {
  bool isPressed = true;

  //Color bgColor = Color(0xFFE7ECEF);

  Color _shadeColor(Color color, double shadingFactor) {
    assert(shadingFactor >= 0 && shadingFactor <= 1,
        'The shadingFactor must be between 0 and 1 (inclusive).');

    int red = (color.red + (255 - color.red) * shadingFactor).round();
    int green = (color.green + (255 - color.green) * shadingFactor).round();
    int blue = (color.blue + (255 - color.blue) * shadingFactor).round();

    return Color.fromARGB(color.alpha, red, green, blue);
  }

  updateValue(bool value) {
    setState(() {
      isPressed = value;
    });
  }

  @override
  void initState() {
    isPressed = widget.initialSwitched;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Offset distance = !isPressed ? Offset(20, 20) : Offset(8, 8);

    final double bSize = 60;

    //Color bgColor = Color(0xFFE7ECEF);

    if (widget.switched != null) {
      isPressed = widget.switched!;
    }

    return GestureDetector(
      onTap: !widget.disabled
          ? () {
              if (widget.onSwitching(!isPressed)) {
                setState(() {
                  isPressed = !isPressed;
                });
              }
            }
          : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: bSize,
        height: bSize,
        child: Icon(
          Icons.power_settings_new_rounded,
          size: bSize * 0.3,
          color: _shadeColor(Colors.blue, 0.7),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: !isPressed
                ? [
                    Color(0xffffffff),
                    Color(0xffced2d5),
                  ]
                : [
                    _shadeColor(Colors.blue, 0),
                    _shadeColor(Colors.blue, 0.7),
                  ],
          ),
          boxShadow: widget.glowEnabled
              ? [
                  BoxShadow(
                    color: !isPressed
                        ? Color(0xffffffff)
                        : _shadeColor(Colors.blue, 0.7),
                    offset: -distance,
                    blurRadius: (bSize / 10) * 2,
                    spreadRadius: 0.0,
                  ),
                  BoxShadow(
                    color: !isPressed
                        ? Color(0xffced2d5)
                        : _shadeColor(Colors.blue, 0.6),
                    offset: distance,
                    blurRadius: (bSize / 10) * 2,
                    spreadRadius: 0.0,
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
