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
    ChatPageStateManagement chatDisplayState,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final chatDisplayState = Provider.of<ChatPageStateManagement>(context);
    return builder(context, chatDisplayState);
  }
}
