import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import 'widgets/widgets.dart';

class ChatEngineChatPage extends StatelessWidget {
  const ChatEngineChatPage({
    Key? key,
    required this.secret,
    required this.username,
  }) : super(key: key);

  final String secret;
  final String username;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageStateManagement>.value(
          value: ChatPageStateManagement(secret: secret, username: username),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: mediaQuery.onPhone ? const UserChatsDrawer() : null,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!mediaQuery.onPhone) const UserChatsDrawer(),
            Expanded(child: ConversationContent()),
          ],
        ),
      ),
    );
  }
}
