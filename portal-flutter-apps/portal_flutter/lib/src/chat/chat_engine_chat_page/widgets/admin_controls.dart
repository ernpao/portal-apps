import 'package:flutter/material.dart';
import 'package:hover/hover.dart';
import '../state/state.dart';

class AdminControls extends StatelessWidget {
  const AdminControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatPageStateConsumer(
      builder: (context, stateManager) {
        return HoverBaseCard(
          child: Row(
            children: const [],
          ),
        );
      },
    );
  }
}
