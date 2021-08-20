import 'package:flutter/widgets.dart';
import 'package:hover/hover.dart';

import 'chat_page_state_management.dart';

class ChatPageStateConsumer extends StatelessWidget {
  const ChatPageStateConsumer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    ChatPageStateManagement stateManager,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final stateManager = Provider.of<ChatPageStateManagement>(context);
    return builder(context, stateManager);
  }
}
