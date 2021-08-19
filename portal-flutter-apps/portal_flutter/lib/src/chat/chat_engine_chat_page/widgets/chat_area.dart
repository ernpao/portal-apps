import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import '../../../widgets/widgets.dart';
import '../state/state.dart';
import 'create_new_chat_modal.dart';
import 'user_info.dart';

/// A preview of the [Chat] details. This widget
/// is displayed in [UserChatsDrawer] to give users
/// a preview of their chats.
class ChatPreview extends StatelessWidget {
  const ChatPreview(
    this.chat, {
    Key? key,
    this.onTap,
  }) : super(key: key);

  final Chat chat;
  final Function()? onTap;

  Widget _buildTimestamp(BuildContext context) {
    if (chat.lastMessage.created != null) {
      return Text(
        chat.lastMessage.created!.toLocal().formatDateTimeWithoutSeconds,
        style: Theme.of(context).textTheme.caption,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCaption(BuildContext context, List<String> typingUsers) {
    String text = "";
    if (typingUsers.length == 1) {
      text = "${typingUsers.first} is typing...";
    } else if (typingUsers.length == 2) {
      text = "${typingUsers.first} and ${typingUsers.last} are typing...";
    } else if (typingUsers.length > 2) {
      text = "Multiple users are typing...";
    }

    if (typingUsers.isEmpty || text.isEmpty) return _buildTimestamp(context);
    return Text(
      text,
      style: Theme.of(context).textTheme.caption,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatPageStateConsumer(builder: (context, chatPageState) {
      final typingUsers = chatPageState.getUsersTypingInChat(chat.id);
      final isSelected = chatPageState.activeChatId == chat.id;
      return GestureDetector(
        onTap: onTap,
        child: HoverBaseCard(
          color: isSelected ? Colors.grey.shade200 : null,
          elevation: isSelected ? null : 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HoverText(
                    chat.title,
                    leftPadding: 0,
                    bottomPadding: 8,
                    softWrap: true,
                  ),
                  _buildCaption(context, typingUsers)
                ],
              ),
              _buildChatAvatar(chatPageState.username),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChatAvatar(String currentUser) {
    final users = chat.people;

    final avatars = <Widget>[];

    final avatarsToAdd = users.length >= 2 ? 2 : 1;

    debugPrint("Chat ID ${chat.id}: Avatars to add: $avatarsToAdd");
    for (var i = 0; i < users.length; i++) {
      final offset = (avatars.length) * 10.0;
      final person = users[i].person;
      if (person.username != currentUser && avatars.length < avatarsToAdd) {
        debugPrint("Chat ID ${chat.id}: Adding avatar for ${person.username}");
        avatars.add(
          Positioned(
            top: offset,
            right: offset,
            child: UserAvatar(users[i].person),
          ),
        );
      }
    }

    return Stack(
      children: [
        const SizedBox(width: 40, height: 40),
        ...avatars,
      ],
    );
  }
}

class UserChatsDrawer extends StatelessWidget {
  const UserChatsDrawer({Key? key}) : super(key: key);

  static const _maxDrawerWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final dimensionsHelper = HoverResponsiveHelper(context);
    return SizedBox(
      height: dimensionsHelper.screenHeight,
      width: dimensionsHelper.clampedScreenWidth(
        upperLimit: _maxDrawerWidth,
        scale: 0.8,
      ),
      child: HoverBaseCard(
        clipBehavior: Clip.antiAlias,
        padding: 0,
        child: ChatPageStateConsumer(builder: (context, stateManager) {
          if (stateManager.fetchingChats) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = stateManager.chats;
          return Column(
            children: [
              Expanded(
                child: UserChatsListView(
                  chats: chats,
                  onItemTapped: (chat) {
                    if (stateManager.activeChatId != chat.id) {
                      stateManager.setActiveChat(chat);
                    }
                  },
                ),
              ),
              CallToAction(
                text: "Create New Chat",
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => CreateNewChatModal(
                      stateManager: stateManager,
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class UserChatsListView extends StatelessWidget {
  const UserChatsListView({
    Key? key,
    required this.chats,
    this.onItemTapped,
  }) : super(key: key);

  final List<Chat> chats;
  final Function(Chat chat)? onItemTapped;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: ScrollController(),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatPreview(chat, onTap: () {
          onItemTapped?.call(chat);
        });
      },
    );
  }
}

/// A widget for displaying the messages of the `activeChat` in
/// the [ChatPageStateManagement]. Automatically updates when messages are received and
/// sent.
class ChatArea extends StatelessWidget {
  const ChatArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatPageStateConsumer(
      builder: (context, stateManager) {
        if (stateManager.activeChat != null) {
          final activeChat = stateManager.activeChat!;
          final activeChatMessages = stateManager.activeChatMessages;

          Widget content;

          if (activeChatMessages == null) {
            content = const Center(child: CircularProgressIndicator());
          } else if (activeChatMessages.isEmpty) {
            content = const Center(child: Text("Start the conversation!"));
          } else {
            content = _ChatAreaMessages(
              messages: activeChatMessages,
              myUsername: stateManager.username,
            );
          }

          return Column(
            children: [
              Expanded(
                child: HoverBaseCard(
                  child: Column(
                    children: [
                      _ChatAreaHeading(activeChat),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ),
              HoverTextInput(
                controller: TextEditingController(),
                onSubmitted: (message) {},
              )
            ],
          );
        } else {
          return Center(
            child: HoverText("Select a chat to begin!"),
          );
        }
      },
    );
  }
}

/// The title of the chat displayed at the top
/// of the [ChatArea].
class _ChatAreaHeading extends StatelessWidget {
  const _ChatAreaHeading(
    this.chat, {
    Key? key,
  }) : super(key: key);

  final Chat chat;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HoverTitle(
          chat.title,
          topPadding: 24,
          bottomPadding: 8,
          color: Colors.blue,
          fontWeight: FontWeight.w900,
        ),
        if (chat.lastMessage.created != null)
          HoverText(
            "Active:  ${chat.lastMessage.created!.formatDateTimeWithoutSeconds}",
            color: Colors.grey.shade400,
            bottomPadding: 24.0,
          )
      ],
    );
  }
}

class _ChatAreaMessages extends StatelessWidget {
  _ChatAreaMessages({
    required this.messages,
    required this.myUsername,
    Key? key,
  }) : super(key: key);

  final Messages messages;

  /// The username of the active user.
  final String myUsername;

  final _conversationScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(milliseconds: 150),
      _scrollToEnd,
    );
    return ListView.builder(
      controller: _conversationScrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final messageIsfromMyself = message.sender.username == myUsername;
        return Row(
          mainAxisAlignment: messageIsfromMyself
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Column(
              children: [
                /// TODO: add preview for attachments
                HoverBaseCard(
                  leftPadding: 8,
                  rightPadding: 8,
                  topPadding: 2,
                  bottomPadding: 2,
                  color: messageIsfromMyself ? Colors.blue : null,
                  elevation: 4,
                  child: Row(
                    children: [
                      if (!messageIsfromMyself) UserAvatar(message.sender),
                      Html(
                        style: {
                          "*": Style(
                            color: messageIsfromMyself
                                ? Colors.white
                                : Colors.black,
                          )
                        },
                        data: message.text,
                        shrinkWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _scrollToEnd() {
    debugPrint("Scrolling chat to end of conversation...");
    _conversationScrollController.animateTo(
      _conversationScrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 150),
    );
  }
}
