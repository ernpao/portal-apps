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
        /// TODO: Don't use FutureBuilder -> will trigger an http request
        /// everytime the keyboard opens on mobile devices when typing.
        child: FutureBuilder<List<Chat>?>(
          future: state.fetchChats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                    child: Text("Error: ${snapshot.error.toString()}"));
              } else if (snapshot.hasData) {
                final chats = snapshot.data!;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return HoverBaseCard(
                            color: Colors.grey.shade200,
                            leftMargin: 0,
                            rightMargin: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HoverText(
                                  chat.title,
                                  leftPadding: 0,
                                  bottomPadding: 8,
                                ),
                                Text(
                                  chat.created.toIso8601String(),
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    TextField(controller: TextEditingController()),
                    HoverCallToActionButton(
                      text: "Create New Chat",
                      onPressed: () => _createNewChat(context, state),
                      cornerRadius: 32,
                      color: Colors.blue,
                    )
                  ],
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _createNewChat(BuildContext context, ChatEngineChatState state) {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = Hover.getScreenWidth(context);
        final screenHeight = Hover.getScreenHeight(context);
        final dialogWidth = (screenWidth * 0.5).clamp(300.0, screenWidth);
        final dialogHeight = (screenHeight * 0.5).clamp(300.0, screenHeight);

        final textFieldController = TextEditingController();

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ((screenWidth - dialogWidth) / 2),
              vertical: ((screenHeight - dialogHeight) / 2)),
          child: HoverBaseCard(
            width: dialogWidth,
            child: Column(
              children: [
                HoverTextInput(
                  controller: textFieldController,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
