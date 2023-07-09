import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';

const _appBarHeight = 56;

class WaStyleAppBar extends StatelessWidget {
  const WaStyleAppBar({
    super.key,
    required this.title,
    required this.logoChild,
    this.logoChildSize = 40,
    this.extendedScale = 2,
    this.extendHeight = 200,
    this.backgroundColor = Colors.blue,
  });

  final Widget title;
  final Widget logoChild;
  final double logoChildSize;
  final double extendedScale;
  final double extendHeight;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _AppBarDelegate(
        maxHeight: extendHeight,
        minHeight: statusBarHeight + _appBarHeight,
        title: title,
        logoChild: logoChild,
        logoChildInitialSize: logoChildSize,
        extendedScale: extendedScale,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _AppBarDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final Widget title;
  final Widget logoChild;
  final double logoChildInitialSize;
  final double extendedScale;
  final Color backgroundColor;

  _AppBarDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.title,
    required this.logoChild,
    required this.logoChildInitialSize,
    required this.extendedScale,
    required this.backgroundColor,
  });

  double _shrinkPercentage(double shrinkOffset) {
    double d = math.min(
      1,
      shrinkOffset / (maxExtent - minExtent),
    );

    return 1 - d;
  }

  double _currentScale(double shrinkPercentage) {
    return 1 + (extendedScale * shrinkPercentage);
  }

  double _logoChildSize(double shrinkPercentage) {
    return logoChildInitialSize * _currentScale(shrinkPercentage);
  }

  double _logoChildLeftMargin(
    double shrinkPercentage,
    double logoChildSize,
    double screenWidth,
  ) {
    double d;

    d = (screenWidth - logoChildSize) / 2;
    d -= _appBarHeight;
    d *= shrinkPercentage;
    d += _appBarHeight;

    return d;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    double shrinkPercentage = _shrinkPercentage(shrinkOffset);
    double logoChildSize = _logoChildSize(shrinkPercentage);
    double logoChildLeftMargin = _logoChildLeftMargin(
      shrinkPercentage,
      logoChildSize,
      screenWidth,
    );

    return AppBar(
      title: Row(
        children: [
          SizedBox(width: logoChildInitialSize + 10,),
          Opacity (
            opacity: shrinkPercentage > 0.08 ? 0 : (0.08 - shrinkPercentage) / 0.08,
            child: title,
          ),
        ],
      ),
      backgroundColor: backgroundColor, 
      elevation: 0, 
      titleSpacing: 0,
      flexibleSpace: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          SizedBox(
            height: (minHeight - statusBarHeight - logoChildInitialSize) / 2,
          ),
          Container(
            margin: EdgeInsets.only(
              left: logoChildLeftMargin,
            ),
            width: logoChildSize,
            height: logoChildSize,
            child: logoChild,
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
