import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: HoverBaseCard(child: Text("Profile Page")),
      ),
    );
  }
}
