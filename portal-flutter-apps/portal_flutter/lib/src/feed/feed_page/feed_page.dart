import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

import '../../widgets/widgets.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.transparent,
      body: HoverBaseCard(
        child: const Text("Feed Page"),
      ),
    );
  }
}
