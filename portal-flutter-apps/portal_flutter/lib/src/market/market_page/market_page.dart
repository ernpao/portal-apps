import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

import '../../widgets/widgets.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalColors.transparent,
      body: HoverBaseCard(
        child: const Text("Market Page"),
      ),
    );
  }
}
