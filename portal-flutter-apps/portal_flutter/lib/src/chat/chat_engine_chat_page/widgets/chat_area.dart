import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import '../../../widgets/widgets.dart';
import '../state/state.dart';
import 'create_new_chat_modal.dart';
import 'user_info.dart';

/// A preview of the [Chat] details. This widget
/// is displayed in [ChatListDrawer] to give users
/// a preview of their chats.
class _UserChatsListTile extends StatelessWidget {
  const _UserChatsListTile(
    this.chat, {
    Key? key,
    this.onTap,
  }) : super(key: key);

  final Chat chat;
  final Function()? onTap;

  Widget _buildLastMessageText(BuildContext context) {
    final lastMessage = chat.lastMessage;
    if (lastMessage.created != null) {
      final timestamp =
          lastMessage.created!.toLocal().formatDateTimeWithoutSeconds;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lastMessage.text.truncate(20),
            style: Theme.of(context).textTheme.caption,
          ),
          Text(
            timestamp,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      );
    } else {
      return Text(
        "Start the conversation!",
        style: Theme.of(context).textTheme.caption,
      );
    }
  }

  Widget _buildCaption(BuildContext context, List<String> typingUsers) {
    if (typingUsers.isNotEmpty) {
      String text = "";
      if (typingUsers.length == 1) {
        text = "${typingUsers.first} is typing...";
      } else if (typingUsers.length == 2) {
        text = "${typingUsers.first} and ${typingUsers.last} are typing...";
      } else if (typingUsers.length > 2) {
        text = "Multiple users are typing...";
      }
      assert(text.isNotEmpty);
      return Text(
        text,
        style: Theme.of(context).textTheme.caption,
      );
    } else {
      return _buildLastMessageText(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChatPageStateConsumer(builder: (context, chatPageState) {
      final typingUsers = chatPageState.getUsersTypingInChat(chat.id);
      final isSelected = chatPageState.activeChatId == chat.id;
      return GestureDetector(
        onTap: onTap,
        child: HoverBaseCard(
          color: isSelected ? PortalColors.inactiveWidget : null,
          elevation: isSelected ? null : 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildChatAvatar(chatPageState.username),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
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
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChatAvatar(String currentUser) {
    final members = chat.people;

    final avatars = <Widget>[];

    final avatarsToAdd = members.length >= 2 ? 2 : 1;

    // log("Chat ID ${chat.id}: Avatars to add: $avatarsToAdd");
    for (var i = 0; i < members.length; i++) {
      final offset = (avatars.length) * 10.0;
      final member = members[i].person;
      final memberIsCurrentUser = member.username != currentUser;
      if (memberIsCurrentUser && avatars.length < avatarsToAdd) {
        // log("Chat ID ${chat.id}: Adding avatar for ${member.username}");
        avatars.add(
          Positioned(
            top: offset,
            right: offset,
            child: UserAvatar(members[i].person),
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

class ChatSettingsDrawer extends StatelessWidget {
  const ChatSettingsDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatPageStateConsumer(
      builder: (context, stateManager) {
        final activeChat = stateManager.activeChat;
        if (activeChat == null) {
          return const SizedBox.shrink();
        } else {
          return BaseDrawer(
            child: Column(
              children: [
                HoverTitle(
                  "Members",
                  topPadding: 24,
                  bottomPadding: 8,
                  fontWeight: FontWeight.w900,
                ),
                // SelectableText(activeChat.id.toString()),
                const Expanded(
                  child: _ChatMembersListView(),
                ),
                CallToAction(
                  text: "Delete Chat",
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return BaseConfirmationDialog(
                          height: 200,
                          children: [
                            HoverHeading("Delete Chat"),
                            HoverText(
                              "Are you sure you want to delete this chat?",
                              textAlign: TextAlign.center,
                            ),
                          ],
                          onConfirm: () async {
                            return stateManager.deleteActiveChat();
                          },
                          onComplete: () async {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _ChatMembersListView extends StatelessWidget {
  const _ChatMembersListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatPageStateConsumer(
      builder: (context, stateManager) {
        return FutureBuilder<People>(
          future: stateManager.getActiveChatMembers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final members = snapshot.data!;
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, i) {
                    return UserListTile(members[i]);
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}

class ChatListDrawer extends StatelessWidget {
  const ChatListDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseDrawer(
      child: ChatPageStateConsumer(builder: (context, stateManager) {
        if (stateManager.fetchingChats) {
          return const Center(child: CircularProgressIndicator());
        }
        final chats = stateManager.chats;
        return Column(
          children: [
            Expanded(
              child: _UserChatsListView(
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
    );
  }
}

class _UserChatsListView extends StatelessWidget {
  const _UserChatsListView({
    Key? key,
    required this.chats,
    this.onItemTapped,
  }) : super(key: key);

  final List<Chat> chats;
  final Function(Chat chat)? onItemTapped;

  @override
  Widget build(BuildContext context) {
    final helper = HoverResponsiveHelper(context);
    return ListView.builder(
      controller: ScrollController(),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _UserChatsListTile(chat, onTap: () {
          onItemTapped?.call(chat);
          if (helper.onMobile) {
            Hover.closeDrawer(context);
          }
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
            content = _ChatAreaMessagesListView(
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
              const _ChatAreaTextField(),
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

class _ChatAreaTextField extends StatefulWidget {
  const _ChatAreaTextField({Key? key}) : super(key: key);

  @override
  State<_ChatAreaTextField> createState() => _ChatAreaTextFieldState();
}

class _ChatAreaTextFieldState extends State<_ChatAreaTextField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _awaitingResponse = false;

  @override
  Widget build(BuildContext context) {
    final helper = HoverResponsiveHelper(context);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (helper.onDesktop) {
        _focusNode.requestFocus();
      }
    });

    return ChatPageStateConsumer(
      builder: (context, stateManager) {
        return HoverTextInput(
          enabled: !_awaitingResponse,
          controller: _controller,
          focusNode: _focusNode,
          backgroundColor: _awaitingResponse
              ? PortalColors.inactiveWidget
              : PortalColors.white,
          clearOnSubmit: true,
          onSubmitted: (message) async {
            if (message.isNotEmpty) {
              setState(() => _awaitingResponse = true);
              await stateManager.sendTextMessage(message);
              setState(() => _awaitingResponse = false);
            }
          },
        );
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
        PortalTitle(chat.title),
        if (chat.lastMessage.created != null)
          PortalCaptionText(
            "Active:  ${chat.lastMessage.created!.formatDateTimeWithoutSeconds}",
          )
      ],
    );
  }
}

class _ChatAreaMessagesListView extends StatelessWidget {
  _ChatAreaMessagesListView({
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
    WidgetsBinding.instance?.addPostFrameCallback((_) => _scrollToEnd());
    return ListView.builder(
      controller: _conversationScrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final messageIsfromMyself = message.sender.username == myUsername;

        if (message.text.isEmpty) return const SizedBox.shrink();

        return Row(
          mainAxisAlignment: messageIsfromMyself
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Column(
              children: [
                /// TODO: add preview for attachments
                /// TODO: sanitize HTML
                HoverBaseCard(
                  leftPadding: 8,
                  rightPadding: 8,
                  topPadding: 2,
                  bottomPadding: 2,
                  color: messageIsfromMyself ? PortalColors.base : null,
                  elevation: 4,
                  child: Row(
                    children: [
                      if (!messageIsfromMyself) UserAvatar(message.sender),
                      Html(
                        style: {
                          "*": Style(
                            color: messageIsfromMyself
                                ? PortalColors.white
                                : PortalColors.black,
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
    _conversationScrollController.animateTo(
      _conversationScrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 150),
    );
  }
}
