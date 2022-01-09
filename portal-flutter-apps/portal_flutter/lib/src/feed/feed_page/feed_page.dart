import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: HoverBaseCard(
          child: Text("Feed Page"),
        ),
      ),
    );
  }
}
