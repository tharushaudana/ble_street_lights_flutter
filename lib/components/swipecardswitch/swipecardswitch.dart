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
  final double _cardSize = 100;

  double _scaleOfActiveCard(double p) {
    return 1 - 0.2 * p;
  }

  double _scaleOfHiddenCard(double p) {
    return 0.8 + 0.2 * p;
  }

  double _shiftedOfActiveCard(double p) {
    return p < 0.5 ? 0 : (_cardSize / 4) * (p - 0.5) / 0.5;
  }

  double _shiftedOfHiddenCard(double p) {
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
    final double _percentage = widget.p;

    final double _width = MediaQuery.of(context).size.width;

    final List<Widget> cards = [
      _Card(
        size: _cardSize,
        left: _width / 2 -
            _cardSize / 2 +
            _shiftedOfHiddenCard(_percentage) +
            _moveOfCards(_percentage),
        top: _height / 2 - _cardSize / 2,
        scale: _scaleOfHiddenCard(_percentage),
        color: Colors.blue,
        child: Text("MANUAL", style: TextStyle(fontSize: 20,),),
      ),
      _Card(
        size: _cardSize,
        left: _width / 2 -
            _cardSize / 2 -
            _shiftedOfActiveCard(_percentage) -
            _moveOfCards(_percentage),
        top: _height / 2 - _cardSize / 2,
        scale: _scaleOfActiveCard(_percentage),
        color: Colors.green,
        child: Text("ASTRO", style: TextStyle(fontSize: 20,),),
      ),
    ];

    return Container(
      width: double.infinity,
      height: _height,
      color: Colors.red,
      child: Stack(
        children: _percentage <= 0.5 ? cards : cards.reversed.toList(),
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
            color: color,
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(0, 1),
                blurRadius: 2,
                //spreadRadius: 2,
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
