import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import '../../state/auth_state/auth_state.dart';
import '../../widgets/widgets.dart';
import 'state/state.dart';
import 'widgets/widgets.dart';

class ChatEngineChatPage extends StatelessWidget {
  const ChatEngineChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);

    return AuthStateConsumer(
      builder: (context, authState) {
        switch (authState.currentState) {
          case AuthenticationFlowState.LOGGED_IN:
            final chatStateManagement = ChatPageStateManagement(
              secret: authState.secret,
              username: authState.activeUser!.username,
            );

            return MultiProvider(
              providers: [
                ChangeNotifierProvider<ChatPageStateManagement>.value(
                  value: chatStateManagement,
                ),
              ],
              child: Scaffold(
                backgroundColor: PortalColors.transparent,
                drawer: mediaQuery.onMobile ? const ChatListDrawer() : null,
                endDrawer:
                    mediaQuery.onMobile && chatStateManagement.withActiveChat
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

          default:
            return const Text("Invalid State");
        }
      },
    );
  }
}
