import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import 'state/state.dart';
import 'buttons.dart';
import 'user_display.dart';

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
        child: ChatPageStateConsumer(builder: (context, chatState) {
          if (chatState.fetchingChats) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = chatState.chats;
          return Column(
            children: [
              Expanded(
                child: UserChatListView(
                  chats: chats,
                  onItemTapped: (chat) {
                    if (chatState.activeChatId != chat.id) {
                      chatState.setActiveChat(chat);
                    }
                  },
                ),
              ),
              CallToAction(
                text: "Create New Chat",
                onPressed: () => _createNewChat(context, chatState),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _createNewChat(BuildContext context, ChatPageStateManagement chatState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return CreateNewChatDialog(
          stateManagement: chatState,
        );
      },
    );
  }
}

class UserChatListView extends StatelessWidget {
  const UserChatListView({
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

class CreateNewChatDialog extends StatefulWidget {
  const CreateNewChatDialog({
    Key? key,
    required this.stateManagement,
  }) : super(key: key);

  final ChatPageStateManagement stateManagement;

  @override
  State<CreateNewChatDialog> createState() => _CreateNewChatDialogState();
}

class _CreateNewChatDialogState extends State<CreateNewChatDialog> {
  /// Dialog state variables
  People selectedUsers = [];
  People userSuggestions = [];
  bool awaitingResponse = false;

  @override
  void initState() {
    _resetDialog();
    super.initState();
  }

  People _getUsernameSuggestions(String pattern) {
    if (pattern.isEmpty) {
      return userSuggestions;
    } else {
      return userSuggestions
          .where(
            (user) => user.username.contains(pattern),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Dialog dimensions
    final mediaQuery = HoverResponsiveHelper(context);
    final screenWidth = mediaQuery.screenWidth;
    final screenHeight = mediaQuery.screenHeight;
    final dialogWidth = mediaQuery.clampedScreenWidth(
      upperLimit: 500.0,
      scale: 0.8,
    );
    final dialogHeight = mediaQuery.clampedScreenHeight(
      upperLimit: 600.0,
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ((screenWidth - dialogWidth) / 2),
        vertical: ((screenHeight - dialogHeight) / 2),
      ),
      child: HoverBaseCard(
        width: dialogWidth,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Header and cancel button
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HoverHeading("Create New Chat"),
                    HoverText("Search for users to add to the chat"),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: HoverCircleIconButton(
                    iconData: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),

            /// Username input and autocomplete options

            HoverBaseCard(
              color: Colors.grey.shade200,
              child: TypeAheadField<Person>(
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                textFieldConfiguration: const TextFieldConfiguration(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search for users to start a chat with",
                  ),
                ),
                suggestionsCallback: _getUsernameSuggestions,
                itemBuilder: (context, userData) {
                  return UserListTile(userData);
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    selectedUsers.add(suggestion);
                    userSuggestions.remove(suggestion);
                  });
                },
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: ScrollController(),
                itemBuilder: (context, index) {
                  final selectedUser = selectedUsers[index];
                  return HoverBaseCard(
                    padding: 0,
                    child: UserListTile(selectedUser),
                  );
                },
                itemCount: selectedUsers.length,
              ),
            ),
            CallToAction(
              enabled: awaitingResponse ? false : selectedUsers.isNotEmpty,
              text: "Create Chat",
              onPressed: _onCreateChatButtonPresed,
            ),
          ],
        ),
      ),
    );
  }

  void _onCreateChatButtonPresed() async {
    if (selectedUsers.isNotEmpty) {
      setState(() => awaitingResponse = true);
      await _sendRequestToCreateNewChat();
      Navigator.of(context).pop();
    }
  }

  Future<void> _resetDialog() async {
    /// Reset suggestions and selected users
    userSuggestions.clear();
    selectedUsers.clear();

    /// Fetch other users for suggestions
    final otherUsers = await widget.stateManagement.getOtherUsers();
    setState(() => userSuggestions = otherUsers);
  }

  /// Use the API to send a request to create a new chat.
  Future<void> _sendRequestToCreateNewChat() async {
    String title = selectedUsers.first.username;

    final numberOfUsersToAdd = selectedUsers.length;

    assert(numberOfUsersToAdd > 0);
    if (numberOfUsersToAdd == 2) {
      final firstUsername = selectedUsers.first.username;
      final secondUsername = selectedUsers.last.username;
      title = "$firstUsername and $secondUsername";
    } else if (numberOfUsersToAdd > 2) {
      title = "${selectedUsers.first.username} and "
          "${numberOfUsersToAdd - 1} "
          "others";
    }

    final usernamesToAdd = selectedUsers.map((user) => user.username).toList();

    await widget.stateManagement.createNewChat(title, usernamesToAdd);
  }
}

/// A widget for displaying the messages of the `activeChat` in
/// the [ChatPageStateManagement]. Automatically updates when messages are received and
/// sent.
class ConversationContent extends StatelessWidget {
  ConversationContent({Key? key}) : super(key: key);

  final _conversationScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return ChatPageStateConsumer(
      builder: (context, chatDisplayState) {
        if (chatDisplayState.activeChat != null) {
          final selectedChat = chatDisplayState.activeChat!;
          final selectedChatMessages = chatDisplayState.activeChatMessages;

          Widget content;
          final messageFieldController = TextEditingController();

          if (selectedChatMessages == null) {
            content = const Center(child: CircularProgressIndicator());
          } else if (selectedChatMessages.isEmpty) {
            content = const Center(child: Text("Start the conversation!"));
          } else {
            Future.delayed(
              const Duration(milliseconds: 150),
              _scrollToEnd,
            );
            content = ListView.builder(
              controller: _conversationScrollController,
              itemCount: selectedChatMessages.length,
              itemBuilder: (context, index) {
                final message = selectedChatMessages[index];
                final messageIsfromMyself =
                    message.sender.username == chatDisplayState.username;
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
                              if (!messageIsfromMyself)
                                UserAvatar(message.sender),
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
          return Column(
            children: [
              Expanded(
                child: HoverBaseCard(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          HoverTitle(
                            selectedChat.title,
                            topPadding: 24,
                            bottomPadding: 8,
                            color: Colors.blue,
                            fontWeight: FontWeight.w900,
                          ),
                          if (selectedChat.lastMessage.created != null)
                            HoverText(
                              "Active:  ${selectedChat.lastMessage.created!.formatDateTimeWithoutSeconds}",
                              color: Colors.grey.shade400,
                              bottomPadding: 24.0,
                            )
                        ],
                      ),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ),
              HoverTextInput(
                controller: messageFieldController,
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

  void _scrollToEnd() {
    debugPrint("Scrolling chat to end of conversation...");
    _conversationScrollController.animateTo(
      _conversationScrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 150),
    );
  }
}
