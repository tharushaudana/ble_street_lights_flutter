import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SwipeCardSwitch extends StatefulWidget {
  const SwipeCardSwitch({
    super.key,
    this.color = Colors.blue,
    this.cardSize = 140,
    required this.child1,
    required this.child2,
    this.initialSwitchedChild = 1,
    required this.onSwitching,
  });

  final double cardSize;
  final Color color;
  final Widget child1;
  final Widget child2;
  final int initialSwitchedChild;
  final bool Function(int willSwitchingChild) onSwitching;

  @override
  State<StatefulWidget> createState() => _SwipeCardSwitchState();
}

class _SwipeCardSwitchState extends State<SwipeCardSwitch>
    with SingleTickerProviderStateMixin {

  final double _hiddenScale = 0.8;

  double _startX = 0;
  double _preX = 0;

  double _percentage = 0;

  int switchedChild = 1;

  late Animation<double> _anim;
  late AnimationController _animController;

  double _scaleOfCard1(double p) {
    return 1 - (1 - _hiddenScale) * p;
  }

  double _scaleOfCard2(double p) {
    return _hiddenScale + (1 - _hiddenScale) * p;
  }

  double _shiftedOfCard1(double p) {
    return p < 0.5 ? 0 : (widget.cardSize / 4) * (p - 0.5) / 0.5;
  }

  double _shiftedOfCard2(double p) {
    return p > 0.5 ? 0 : (widget.cardSize / 4) * (0.5 - p) / 0.5;
  }

  double _moveOfCards(double p) {
    if (p <= 0.5) {
      return widget.cardSize / 2 * (p / 0.5);
    } else {
      return widget.cardSize / 2 * ((1 - p) / 0.5);
    }
  }

  _startCompleteAnimation(double start, double end) {
    _animController.reset();

    _anim = Tween(begin: start, end: end).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCirc,
      ),
    )..addListener(() {
        setState(() {
          _percentage = _anim.value;
        });
      });

    _animController.forward();
  }

  _runCompleteAnimation() {
    if (_percentage == 1 || _percentage == 0) return;

    // switch to next card
    if (_percentage >= 0.5) {
      _startCompleteAnimation(_percentage, 1);
    }
    // reset current card
    else {
      _startCompleteAnimation(_percentage, 0);
    }
  }

  _handleOnPanEnd() {
    if (_percentage >= 0.5) {
      if (switchedChild == 2) {
        _runCompleteAnimation();
      } else {
        if (widget.onSwitching(2)) {
          switchedChild = 2;
          _runCompleteAnimation();
        } else {
          // discrabe switching
          _startCompleteAnimation(_percentage, 0);
        }
      }

      return;
    }

    if (switchedChild == 1) {
      _runCompleteAnimation();
      return;
    } else {
      if (widget.onSwitching(1)) {
        switchedChild = 1;
        _runCompleteAnimation();
      } else {
        // discrabe switching
        _startCompleteAnimation(_percentage, 1);
      }
    }
  }

  @override
  void initState() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    switchedChild = widget.initialSwitchedChild;

    if (switchedChild == 2) {
      _percentage = 1;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;

    final List<Widget> cards = [
      _Card(
        size: widget.cardSize,
        left: _width / 2 -
            widget.cardSize / 2 +
            _shiftedOfCard2(_percentage) +
            _moveOfCards(_percentage),
        //top: _height / 2 - _cardSize / 2,
        top: 0,
        scale: _scaleOfCard2(_percentage),
        color: Colors.blue,
        child: widget.child2,
      ),
      _Card(
        size: widget.cardSize,
        left: _width / 2 -
            widget.cardSize / 2 -
            _shiftedOfCard1(_percentage) -
            _moveOfCards(_percentage),
        //top: _height / 2 - _cardSize / 2,
        top: 0,
        scale: _scaleOfCard1(_percentage),
        color: Colors.blue,
        child: widget.child1,
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
      onPanEnd: (details) {
        _handleOnPanEnd();
      },
      child: Container(
        width: double.infinity,
        height: widget.cardSize,
        child: Stack(
          children: _percentage <= 0.5 ? cards : cards.reversed.toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
