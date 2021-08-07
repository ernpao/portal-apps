import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import 'chat_engine_chat_state.dart';
import 'widgets/widgets.dart';

class ChatEngineChatPage extends StatelessWidget {
  ChatEngineChatPage({
    Key? key,
    required this.secret,
    required this.username,
  }) : super(key: key);

  final String secret;
  final String username;

  late final chatEngineChatState = ChatEngineChatState(
    secret: secret,
    username: username,
  );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);
    return ChangeNotifierProvider<ChatEngineChatState>(
      create: (_) => chatEngineChatState,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: mediaQuery.onPhone ? ChatListDrawer() : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!mediaQuery.onPhone) ChatListDrawer(),
              Expanded(child: HoverBaseCard()),
            ],
          )),
    );
  }
}
