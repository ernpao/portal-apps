import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

class BaseDrawer extends StatelessWidget {
  const BaseDrawer({
    Key? key,
    this.child,
  }) : super(key: key);

  static const _maxDrawerWidth = 400.0;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final helper = HoverResponsiveHelper(context);
    final onMobile = helper.onMobile;
    final screenWidth = helper.screenWidth;
    return SizedBox(
      height: helper.screenHeight,
      width: helper.clampedScreenWidth(
        upperLimit: onMobile ? screenWidth : _maxDrawerWidth,
      ),
      child: HoverBaseCard(
        clipBehavior: Clip.antiAlias,
        padding: 0,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
