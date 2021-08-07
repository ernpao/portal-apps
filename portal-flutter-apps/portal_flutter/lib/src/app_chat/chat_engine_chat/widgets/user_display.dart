import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar(
    this.user, {
    Key? key,
  }) : super(key: key);

  final ChatEngineUser user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.blue,
      child: user.avatar == null
          ? const Icon(Icons.person)
          : const SizedBox.shrink(),
      foregroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
    );
  }
}

class UserListTile extends StatelessWidget {
  const UserListTile(
    this.user, {
    Key? key,
  }) : super(key: key);

  final ChatEngineUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          UserAvatar(user),
          HoverText(user.username),
        ],
      ),
    );
  }
}

class UserCardTile extends StatelessWidget {
  const UserCardTile(
    this.user, {
    Key? key,
  }) : super(key: key);

  final ChatEngineUser user;

  @override
  Widget build(BuildContext context) {
    return HoverBaseCard(
      padding: 0,
      child: UserListTile(user),
    );
  }
}
