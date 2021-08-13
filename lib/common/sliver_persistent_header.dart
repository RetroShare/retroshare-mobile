import 'package:flutter/material.dart';
import 'package:retroshare/common/styles.dart';
import 'dart:math' as math;

SliverPersistentHeader sliverPersistentHeader(String headerText, context) {
  return SliverPersistentHeader(
    pinned: true,
    delegate: _SliverAppBarDelegate(
      minHeight: 3 * personDelegateHeight / 4,
      maxHeight: 3 * personDelegateHeight / 4,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: personDelegateHeight / 4),
        alignment: Alignment.centerLeft,
        child: Text(
          headerText,
          style: Theme.of(context).textTheme.body2,
        ),
      ),
    ),
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
