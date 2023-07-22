import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SwipeCardSwitch extends StatefulWidget {
  const SwipeCardSwitch({
    super.key,
    required this.p,
  });

  final double p;

  @override
  State<StatefulWidget> createState() => _SwipeCardSwitchState();
}

class _SwipeCardSwitchState extends State<SwipeCardSwitch> {
  final double _height = 200;
  final double _cardSize = 140;
  final double _hiddenScale = 0.8;

  double _startX = 0;
  double _preX = 0;

  double _percentage = 0;

  double _scaleOfCard1(double p) {
    return 1 - (1 - _hiddenScale) * p;
  }

  double _scaleOfCard2(double p) {
    return _hiddenScale + (1 - _hiddenScale) * p;
  }

  double _shiftedOfCard1(double p) {
    return p < 0.5 ? 0 : (_cardSize / 4) * (p - 0.5) / 0.5;
  }

  double _shiftedOfCard2(double p) {
    return p > 0.5 ? 0 : (_cardSize / 4) * (0.5 - p) / 0.5;
  }

  double _moveOfCards(double p) {
    if (p <= 0.5) {
      return _cardSize / 2 * (p / 0.5);
    } else {
      return _cardSize / 2 * ((1 - p) / 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    //final double _percentage = widget.p;

    final double _width = MediaQuery.of(context).size.width;

    final List<Widget> cards = [
      _Card(
        size: _cardSize,
        left: _width / 2 -
            _cardSize / 2 +
            _shiftedOfCard2(_percentage) +
            _moveOfCards(_percentage),
        top: _height / 2 - _cardSize / 2,
        scale: _scaleOfCard2(_percentage),
        color: Colors.blue,
        child: Text(
          "MANUAL",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      _Card(
        size: _cardSize,
        left: _width / 2 -
            _cardSize / 2 -
            _shiftedOfCard1(_percentage) -
            _moveOfCards(_percentage),
        top: _height / 2 - _cardSize / 2,
        scale: _scaleOfCard1(_percentage),
        color: Colors.blue,
        child: Text(
          "ASTRO",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    ];

    return GestureDetector(
      onPanStart: (details) {
        _startX = details.localPosition.dx;
        _preX = _startX;
      },
      onPanUpdate: (details) {
        double dx = details.localPosition.dx;

        // right pan
        if (dx > _preX) {
          setState(() {
            _percentage -= 0.01;
            if (_percentage < 0) _percentage = 0;
          });
        }
        // left pan
        else {
          setState(() {
            _percentage += 0.01;
            if (_percentage > 1) _percentage = 1;
          });
        }

        _preX = dx;
      },
      onPanEnd: (details) {},
      child: Container(
        width: double.infinity,
        height: _height,
        child: Stack(
          children: _percentage <= 0.5 ? cards : cards.reversed.toList(),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    super.key,
    required this.size,
    required this.left,
    required this.top,
    required this.scale,
    required this.color,
    required this.child,
  });

  final double size;
  final double left;
  final double top;
  final double scale;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            //color: color,
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: [
              /*BoxShadow(
                color: Colors.black87,
                offset: const Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0.03,
              ),*/
              BoxShadow(
                color: color.withOpacity(0.4),
                offset: Offset(0, 0),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Theme.of(context).scaffoldBackgroundColor,
                offset: Offset(-2, -2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
