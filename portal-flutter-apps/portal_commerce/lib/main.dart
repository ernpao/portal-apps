import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';
import 'package:hover/hover.dart';
import 'theme_constants.dart';

void main() {
  runApp(const PortalCommerce());
}

const double _headerHeight = 80;
const double _footerHeight = 80;

class PortalCommerce extends StatelessWidget {
  const PortalCommerce({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Application(
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Index(),
        ),
      ),
    );
  }
}

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool _isHeaderVisible = true;
  bool _isFooterVisible = true;

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    _handleHeaderVisibility();
    _handleFooterVisibility();
  }

  void _handleHeaderVisibility() {
    final scrollY = _scrollController.offset.toDouble();
    if (scrollY > 200) {
      if (_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = false;
        });
      }
    } else {
      if (!_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = true;
        });
      }
    }
  }

  void _handleFooterVisibility() {
    final scrollY = _scrollController.offset.toDouble();
    if (scrollY > 200) {
      if (_isFooterVisible) {
        setState(() {
          _isFooterVisible = false;
        });
      }
    } else {
      if (!_isFooterVisible) {
        setState(() {
          _isFooterVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [];

    for (var i = 0; i < 10; i++) {
      _children.add(HoverBaseCard(
        height: 100,
      ));
    }

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _children,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(
            milliseconds: 300,
          ),
          top: _isHeaderVisible ? 0 : -_headerHeight,
          left: 0,
          child: const Header(),
        ),
        AnimatedPositioned(
          duration: const Duration(
            milliseconds: 300,
          ),
          bottom: _isFooterVisible ? 0 : -_footerHeight,
          left: 0,
          child: const Footer(),
        ),
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);
    return HoverBaseCard(
      padding: 0,
      margin: 0,
      child: Container(
        height: _headerHeight,
        width: mediaQuery.screenWidth,
        decoration: const BoxDecoration(
          gradient: ThemeConstants.themeGradient,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              // bottom: -36.0,
              child: HoverSearchBar(
                hintText: "What are you looking for?",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);
    return HoverBaseCard(
      padding: 0,
      margin: 0,
      child: Container(
        height: _footerHeight,
        width: mediaQuery.screenWidth,
        decoration: const BoxDecoration(
          gradient: ThemeConstants.themeGradient,
        ),
      ),
    );
  }
}
