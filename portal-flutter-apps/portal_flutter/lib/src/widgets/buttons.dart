import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

const _buttonBorderRadius = 32.0;

class CallToAction extends StatelessWidget {
  const CallToAction({
    Key? key,
    required this.text,
    this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  final String text;
  final Function()? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return HoverCallToActionButton(
      cornerRadius: _buttonBorderRadius,
      enabled: enabled,
      text: text,
      onPressed: onPressed,
    );
  }
}

class CancelAction extends StatelessWidget {
  const CancelAction({
    Key? key,
    this.text = "Cancel",
    this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  final String text;
  final Function()? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return HoverCallToActionButton(
      cornerRadius: _buttonBorderRadius,
      color: Colors.orangeAccent,
      enabled: enabled,
      text: text,
      onPressed: onPressed,
    );
  }
}
