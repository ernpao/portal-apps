import 'package:flutter/material.dart';
import 'package:hover/hover.dart';

import 'state/auth_state/auth_state.dart';
import 'state/navigation_state/navigation_state.dart';
import 'widgets/widgets.dart';

class PortalFlutterBody extends StatefulWidget {
  const PortalFlutterBody({Key? key}) : super(key: key);

  @override
  State<PortalFlutterBody> createState() => _PortalFlutterBodyState();
}

class _PortalFlutterBodyState extends State<PortalFlutterBody> {
  @override
  Widget build(BuildContext context) {
    return NavigationStateConsumer(
      builder: (context, navigationState) {
        return Container(
          color: PortalColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (navigationState.showHeader) const _Header(),
              Expanded(child: navigationState.selectedItemContent),
              const _FooterNavigation(),
            ],
          ),
        );
      },
    );
  }
}

class _FooterNavigation extends StatelessWidget {
  const _FooterNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationStateConsumer(
      builder: (context, navigationState) {
        final navItems = navigationState.items;
        final selectedItemName = navigationState.selectedItemName;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HoverBaseCard(
              // color: PortalColors.transparent,

              color: PortalColors.base,
              width: HoverResponsiveHelper(context)
                  .clampedScreenWidth(upperLimit: 600),
              // margin: 0,
              // cornerRadius: 0,
              // elevation: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: navItems.map((navItem) {
                  final isSelected = navItem.name == selectedItemName;
                  return GestureDetector(
                    onTap: () {
                      navigationState.moveToPageByName(navItem.name);
                    },
                    child: Icon(
                      navItem.icon,
                      color: isSelected
                          ? PortalColors.baseDarker
                          : PortalColors.baseDark,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  bool _isPopupMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = HoverResponsiveHelper(context);
    return SizedBox(
      height: 100,
      width: Hover.getScreenWidth(context),
      child: HoverBaseCard(
        padding: 4,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: HoverSearchBar(
                backgroundColor: PortalColors.background,
              ),
            ),
            SizedBox(
              width: mediaQuery.onPhone
                  ? 0
                  : (Hover.getScreenWidth(context) -
                      HoverResponsiveHelper.defaultPhoneBreakpoint),
            ),
            HoverCircleIconButton(
              onTap: () {
                _openHeaderMenu(context, mediaQuery);
                setState(() {
                  _isPopupMenuOpen = true;
                });
              },
              color: _isPopupMenuOpen
                  ? PortalColors.base
                  : PortalColors.inactiveWidgetDarker,
              iconColor: PortalColors.white,
              iconData: Icons.menu,
            ),
          ],
        ),
      ),
    );
  }

  void _openHeaderMenu(
    BuildContext context,
    HoverResponsiveHelper mediaQuery,
  ) async {
    final screenWidth = mediaQuery.screenWidth;
    final screenHeight = mediaQuery.screenHeight;
    const top = 54.0;
    const right = 36.0;
    final left = screenWidth - right;

    final authState = Provider.of<AuthState>(context, listen: false);

    const _kIcon = "icon";
    const _kCallback = "callback";
    const _kColor = "color";

    final Map<String, Map> menuItems = {
      "Profile": {
        _kIcon: Icons.verified_user,
        _kCallback: () {},
        _kColor: PortalColors.inactiveWidgetDarker,
      },
      "Settings": {
        _kIcon: Icons.settings,
        _kCallback: () {},
        _kColor: PortalColors.inactiveWidgetDarker,
      },
      "Privacy Policy": {
        _kIcon: Icons.privacy_tip,
        _kCallback: () {},
        _kColor: PortalColors.inactiveWidgetDarker,
      },
      "Logout": {
        _kIcon: Icons.logout,
        _kCallback: authState.logOut,
        _kColor: PortalColors.inactiveWidgetDarker,
      },
    };

    final menuItemWidgets = <_HeaderPopupMenuItem>[];

    menuItems.forEach((label, menuItem) {
      menuItemWidgets.add(
        _HeaderPopupMenuItem(
          label: label,
          icon: menuItem[_kIcon],
          iconColor: menuItem[_kColor],
          callback: menuItem[_kCallback],
        ),
      );
    });

    final callback = await showMenu<Function>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, right, screenHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      items: menuItemWidgets,
    );

    callback?.call();
    setState(() {
      _isPopupMenuOpen = false;
    });
  }
}

class _HeaderPopupMenuItem extends PopupMenuItem<Function> {
  _HeaderPopupMenuItem({
    required IconData icon,
    required String label,
    required Function()? callback,
    Color? iconColor,
  }) : super(
          height: 60,
          value: callback,
          child: Row(
            children: [
              HoverCircleIconButton(
                iconData: icon,
                color: iconColor,
                iconColor: PortalColors.white,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(label),
                ),
              ),
            ],
          ),
        );
}
