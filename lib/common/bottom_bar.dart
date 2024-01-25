import 'package:flutter/material.dart';
import 'package:retroshare/common/styles.dart';

class BottomBar extends StatelessWidget {
  const BottomBar(
      {required this.child,
      this.minHeight = appBarHeight,
      this.maxHeight = appBarHeight,});
  final Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight,
          maxHeight: maxHeight,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20.0,
                spreadRadius: 5.0,
                offset: Offset(
                  0.0,
                  15.0,
                ),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(appBarHeight / 3),
              topRight: Radius.circular(appBarHeight / 3),
            ),
            color: Colors.white,
          ),
          child: child,
        ),);
  }
}
