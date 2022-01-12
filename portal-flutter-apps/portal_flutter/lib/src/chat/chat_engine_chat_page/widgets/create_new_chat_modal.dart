import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

import '../../../widgets/widgets.dart';
import '../state/state.dart';
import 'user_info.dart';

class CreateNewChatModal extends StatefulWidget {
  const CreateNewChatModal({
    Key? key,
    required this.stateManager,
  }) : super(key: key);

  final ChatPageStateManagement stateManager;

  @override
  State<CreateNewChatModal> createState() => _CreateNewChatModalState();
}

class _CreateNewChatModalState extends State<CreateNewChatModal> {
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
          .where((user) => user.username.contains(pattern))
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
                    // HoverText("Search for users to add to the chat"),
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
              color: PortalColors.searchBackground,
              padding: 8,
              child: TypeAheadField<Person>(
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                textFieldConfiguration: const TextFieldConfiguration(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search for users to start a chat with",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      contentPadding: EdgeInsets.all(8)),
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
    final otherUsers = await widget.stateManager.getOtherUsers();

    setState(() {
      userSuggestions = otherUsers;
    });
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

    final chatUsers = selectedUsers.map((user) => user.username).toList();

    await widget.stateManager.createNewChat(title, chatUsers);
  }
}
