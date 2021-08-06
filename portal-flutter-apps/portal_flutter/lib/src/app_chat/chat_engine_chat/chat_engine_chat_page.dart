import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import 'chat_engine_chat_state.dart';

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
          drawer: mediaQuery.onPhone ? _ChatListDrawer() : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!mediaQuery.onPhone) _ChatListDrawer(),
              Expanded(child: HoverBaseCard()),
            ],
          )),
    );
  }
}

class _ChatListDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ChatEngineChatState>(context);
    return SizedBox(
      height: Hover.getScreenHeight(context),
      width: 350,
      child: HoverBaseCard(
        child: FutureBuilder<List<Chat>?>(
          future: state.fetchChats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                    child: Text("Error: ${snapshot.error.toString()}"));
              } else if (snapshot.hasData) {
                final chats = snapshot.data!;
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return Text(chat.id.toString());
                  },
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
