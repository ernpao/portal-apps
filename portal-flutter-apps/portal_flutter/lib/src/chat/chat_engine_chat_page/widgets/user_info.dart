import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar(
    this.user, {
    Key? key,
  }) : super(key: key);

  final Person user;
  @override
  Widget build(BuildContext context) {
    final noAvatar = user.avatar == null;
    return CircleAvatar(
      backgroundColor: noAvatar ? Colors.blue : Colors.transparent,
      child: noAvatar
          ? Center(
              child: HoverText(
                user.initials,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : const SizedBox.shrink(),
      backgroundImage: noAvatar ? null : NetworkImage(user.avatar!),
    );
  }
}

/// A a tile for displaying a user's name
/// and avatar in lists.
class UserListTile extends StatelessWidget {
  const UserListTile(
    this.user, {
    Key? key,
  }) : super(key: key);

  final Person user;

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

  final Person user;

  @override
  Widget build(BuildContext context) {
    return HoverBaseCard(
      padding: 0,
      child: UserListTile(user),
    );
  }
}
