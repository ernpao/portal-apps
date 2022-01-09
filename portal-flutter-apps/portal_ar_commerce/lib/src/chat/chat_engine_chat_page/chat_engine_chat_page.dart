import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

import 'state/state.dart';
import 'widgets/widgets.dart';

class ChatEngineChatPage extends StatelessWidget {
  ChatEngineChatPage({
    Key? key,
    required this.secret,
    required this.username,
  }) : super(key: key);

  final String secret;
  final String username;
  late final stateManager = ChatPageStateManagement(
    secret: secret,
    username: username,
  );

  late final stateManagerProvider =
      ChangeNotifierProvider<ChatPageStateManagement>.value(
    value: stateManager,
  );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);
    return MultiProvider(
      providers: [stateManagerProvider],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: mediaQuery.onMobile ? const ChatListDrawer() : null,
        endDrawer: mediaQuery.onMobile && stateManager.withActiveChat
            ? const ChatSettingsDrawer()
            : null,
        resizeToAvoidBottomInset: false,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mediaQuery.onDesktop) const ChatListDrawer(),
            const Expanded(child: ChatArea()),
            if (mediaQuery.onDesktop) const ChatSettingsDrawer(),
          ],
        ),
      ),
    );
  }
}
