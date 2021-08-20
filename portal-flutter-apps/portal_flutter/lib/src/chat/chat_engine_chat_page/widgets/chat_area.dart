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

  Widget _buildTimestamp(BuildContext context) {
    final lastMessage = chat.lastMessage;
    if (lastMessage.created != null) {
      final timestamp =
          lastMessage.created!.toLocal().formatDateTimeWithoutSeconds;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lastMessage.text,
            style: Theme.of(context).textTheme.caption,
          ),
          Text(
            timestamp,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
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
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

    log("Chat ID ${chat.id}: Avatars to add: $avatarsToAdd");
    for (var i = 0; i < members.length; i++) {
      final offset = (avatars.length) * 10.0;
      final member = members[i].person;
      final memberIsCurrentUser = member.username != currentUser;
      if (memberIsCurrentUser && avatars.length < avatarsToAdd) {
        log("Chat ID ${chat.id}: Adding avatar for ${member.username}");
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

class _BaseDrawer extends StatelessWidget {
  const _BaseDrawer({
    Key? key,
    this.child,
  }) : super(key: key);

  static const _maxDrawerWidth = 400.0;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final helper = HoverResponsiveHelper(context);
    final onMobile = helper.onMobile;
    final screenWidth = helper.screenWidth;
    return SizedBox(
      height: helper.screenHeight,
      width: helper.clampedScreenWidth(
        upperLimit: onMobile ? screenWidth : _maxDrawerWidth,
      ),
      child: HoverBaseCard(
        clipBehavior: Clip.antiAlias,
        padding: 0,
        child: child ?? const SizedBox.shrink(),
      ),
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
          return _BaseDrawer(
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
    return _BaseDrawer(
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
          backgroundColor:
              _awaitingResponse ? Colors.grey.shade200 : Colors.white,
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
    // Future.delayed(
    //   const Duration(milliseconds: 500),
    //   _scrollToEnd,
    // );

    WidgetsBinding.instance?.addPostFrameCallback((_) => _scrollToEnd());
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
    _conversationScrollController.animateTo(
      _conversationScrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 150),
    );
  }
}
