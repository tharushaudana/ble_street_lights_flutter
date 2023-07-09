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
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _AppBarDelegate(
        maxHeight: 200,
        minHeight: statusBarHeight + 56,
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

    double imgScale = 1 + (2 * shrinkPercentage);

    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return AppBar(
      //title: Text('Your App'),
      backgroundColor: Colors.blue, // Customize the app bar color
      elevation: 0, // Optional: Set the elevation as per your design
      flexibleSpace: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: statusBarHeight),
          SizedBox(height: (minHeight - statusBarHeight - image.height!) / 2),
          Container(
            margin: EdgeInsets.only(
              //top: 25,
              left: ((screenWidth / 2 - (image.width! * imgScale / 2)) - 56) *
                      shrinkPercentage +
                  56,
            ),
            /*child: Transform.scale(
              scale: imgScale,
              child: image,
            ),*/
            child: Container(
              width: image.width! * imgScale,
              height: image.height! * imgScale,
              color: Colors.red,
              child: Image(image: AssetImage("assets/images/device_icon.png")),
            ),
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
