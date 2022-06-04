import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
          child: const CustomHeader(),
        ),
        AnimatedPositioned(
          duration: const Duration(
            milliseconds: 300,
          ),
          bottom: _isFooterVisible ? 0 : -_footerHeight,
          left: 0,
          child: const CustomFooter(),
        ),
      ],
    );
  }
}

class CustomHeader extends StatelessWidget {
  const CustomHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);
    return Container(
      height: _headerHeight,
      width: mediaQuery.screenWidth,
      decoration: const BoxDecoration(
        gradient: ThemeConstants.themeGradient,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Positioned(child: CommerceSearchBar()),
        ],
      ),
    );
  }
}

class CustomFooter extends StatelessWidget {
  const CustomFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);
    return Container(
      height: _footerHeight,
      width: mediaQuery.screenWidth,
      decoration: const BoxDecoration(
        gradient: ThemeConstants.themeGradient,
      ),
      child: Row(),
    );
  }
}

class CommerceSearchBar extends StatelessWidget {
  const CommerceSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HoverBaseCard(
      topPadding: 0,
      bottomPadding: 0,
      margin: 0,
      child: TypeAheadField<SearchSuggestion>(
        textFieldConfiguration: const TextFieldConfiguration(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "What are you looking for?",
          ),
        ),
        suggestionsCallback: (searchQuery) async {
          return _fetchSearchSuggestions(searchQuery);
        },
        itemBuilder: (context, searchSuggestion) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(searchSuggestion.name),
        ),
        onSuggestionSelected: (searchSuggestion) {},
      ),
    );
  }

  Future<List<SearchSuggestion>> _fetchSearchSuggestions(String query) async {
    return [
      SearchSuggestion("Test Product 1"),
      SearchSuggestion("Test Product 2"),
      SearchSuggestion("Test Product 3"),
    ];
  }
}

class SearchSuggestion {
  final String name;
  SearchSuggestion(this.name);
}
