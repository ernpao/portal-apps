import 'package:flutter/widgets.dart';
import 'package:hover/hover.dart';

import 'colors.dart';

class PortalTitle extends StatelessWidget {
  const PortalTitle(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return HoverTitle(
      text,
      topPadding: 24,
      bottomPadding: 8,
      color: PortalColors.base,
      fontWeight: FontWeight.w900,
    );
  }
}

class PortalCaptionText extends StatelessWidget {
  const PortalCaptionText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return HoverText(
      text,
      color: PortalColors.caption,
      bottomPadding: 24.0,
    );
  }
}
