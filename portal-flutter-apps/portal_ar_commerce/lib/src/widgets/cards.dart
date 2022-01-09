import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

import 'buttons.dart';

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

/// A generic confirmation dialog with "Yes" and "Cancel" options.
class BaseConfirmationDialog extends StatefulWidget {
  const BaseConfirmationDialog({
    this.confirmText = "Yes",
    this.cancelText = "Cancel",
    this.children,
    this.onCancel,
    this.onConfirm,
    this.onComplete,
    this.height = 300,
    Key? key,
  }) : super(key: key);

  final String confirmText;
  final String cancelText;
  final List<Widget>? children;

  /// The function to call when the user
  /// clicks on the confirm action.
  final Future<void> Function()? onConfirm;

  /// The function to call when the user
  /// clicks on the cancel action.
  final Future<void> Function()? onCancel;

  /// The function to call when
  /// `onConfirm` or `onCancel` complete.
  final Future<void> Function()? onComplete;

  final double height;

  @override
  State<BaseConfirmationDialog> createState() => _BaseConfirmationDialogState();
}

class _BaseConfirmationDialogState extends State<BaseConfirmationDialog> {
  bool _processingUserInput = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HoverBaseCard(
          width: 300,
          height: widget.height,
          child: Column(
            children: [
              Expanded(
                child: _processingUserInput
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.children ?? [],
                      ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CancelAction(
                      enabled: !_processingUserInput,
                      text: widget.cancelText,
                      onPressed: () async {
                        _processUserInput(widget.onCancel);
                      },
                    ),
                  ),
                  Expanded(
                    child: CallToAction(
                      enabled: !_processingUserInput,
                      text: widget.confirmText,
                      onPressed: () async {
                        _processUserInput(widget.onConfirm);
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _processUserInput(Future<void> Function()? process) async {
    setState(() => _processingUserInput = true);
    await process?.call();
    await widget.onComplete?.call();
    setState(() => _processingUserInput = false);
  }
}
