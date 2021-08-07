import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import '../chat_engine_chat_state.dart';
import 'buttons.dart';
import 'user_display.dart';

class ChatPreview extends StatelessWidget {
  const ChatPreview(
    this.chat, {
    Key? key,
  }) : super(key: key);

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return HoverBaseCard(
      color: Colors.grey.shade200,
      leftMargin: 0,
      rightMargin: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                chat.created.toLocal().formatDateTimeWithoutSeconds,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatListDrawer extends StatelessWidget {
  const ChatListDrawer({Key? key}) : super(key: key);

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
        child: Builder(builder: (context) {
          final chatState = Provider.of<ChatEngineChatState>(context);
          final chats = chatState.chats;
          if (chats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    return ChatPreview(chats[index]);
                  },
                ),
              ),
              CallToAction(
                text: "Create New Chat",
                onPressed: () => _createNewChat(context, chatState),
              )
            ],
          );
        }),
      ),
    );
  }

  void _createNewChat(BuildContext context, ChatEngineChatState chatState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return CreateNewChatDialog(
          chatState: chatState,
        );
      },
    );
  }
}

class CreateNewChatDialog extends StatefulWidget {
  const CreateNewChatDialog({
    Key? key,
    required this.chatState,
  }) : super(key: key);

  final ChatEngineChatState chatState;

  @override
  State<CreateNewChatDialog> createState() => _CreateNewChatDialogState();
}

class _CreateNewChatDialogState extends State<CreateNewChatDialog> {
  /// Dialog state variables
  List<ChatEngineUser> selectedUsers = [];
  List<ChatEngineUser> userSuggestions = [];
  bool awaitingResponse = false;

  @override
  void initState() {
    /// Fetch other users for suggestions
    widget.chatState.getOtherUsers().then((otherUsers) {
      setState(() => userSuggestions = otherUsers);
    });
    super.initState();
  }

  List<ChatEngineUser> _getUsernameSuggestions(String pattern) {
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
              child: TypeAheadField<ChatEngineUser>(
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
      await _createNewChat();
      Navigator.of(context).pop();
    }
  }

  Future<void> _createNewChat() async {
    String title = selectedUsers.first.username;

    if (selectedUsers.length > 1) {
      title = "${selectedUsers.first.username} and "
          "${selectedUsers.length - 1} "
          "others";
    }
    final usernamesToAdd = selectedUsers.map((user) => user.username).toList();

    await widget.chatState.createNewChat(
      title,
      usernamesToAdd,
    );
  }
}
