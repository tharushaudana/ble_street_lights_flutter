import 'package:flutter/material.dart';
import 'dart:math' as math;

class SliverPersistentHeaderBuilder extends StatelessWidget {
  const SliverPersistentHeaderBuilder({
    super.key,
    required this.minExtent,
    required this.maxExtent,
    required this.builder,
  });

  final double minExtent;
  final double maxExtent;
  final Widget Function(
    BuildContext context,
    double shrinkPercentage,
    bool overlapsContent,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _HeaderDelegate(
        kMinExtent: minExtent,
        kMaxExtent: maxExtent,
        kBuild: builder,
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    required this.kMinExtent,
    required this.kMaxExtent,
    required this.kBuild,
  });

  final double kMinExtent;
  final double kMaxExtent;
  final Widget Function(
    BuildContext context,
    double shrinkPercentage,
    bool overlapsContent,
  ) kBuild;

  double _shrinkPercentage(double shrinkOffset) {
    double d = math.min(
      1,
      shrinkOffset / (maxExtent - minExtent),
    );

    return 1 - d;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return kBuild(context, _shrinkPercentage(shrinkOffset), overlapsContent);
  }

  @override
  double get maxExtent => kMaxExtent;

  @override
  double get minExtent => kMinExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
