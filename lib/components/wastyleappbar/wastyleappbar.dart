import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class WaStyleAppBar extends StatelessWidget {
  const WaStyleAppBar({
    required this.title,
    required this.image,
  });

  final Widget title;
  final Image image;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _AppBarDelegate(
        maxHeight: 168,
        minHeight: 80,
        title: title,
        image: image,
      ),
    );
  }
}

class _FlexibleSpaceBg extends StatelessWidget {
  const _FlexibleSpaceBg({
    required this.title,
    required this.image,
  });

  final Widget title;
  final Image image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          image,
          /*SizedBox(width: 16),
          Expanded(
            child: title,
          ),*/
        ],
      ),
    );
  }
}

class _AppBarDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final Widget title;
  final Image image;

  _AppBarDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.title,
    required this.image,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double shrinkPercentage =
        math.min(1, shrinkOffset / (maxExtent - minExtent));
    shrinkPercentage = (1 - shrinkPercentage);

    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox.expand(
      child: AppBar(
        //title: Text('Your App'),
        backgroundColor: Colors.blue, // Customize the app bar color
        elevation: 0, // Optional: Set the elevation as per your design
        flexibleSpace: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SizedBox(width: screenWidth / 2 * shrinkPercentage),
              Transform.scale(
                scale: 1 + (2 * shrinkPercentage),
                child: image,
              )
              /*SizedBox(width: 16),
          Expanded(
            child: title,
          ),*/
            ],
          ),
        ),
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
