import 'package:flutter/material.dart';

class TabNavigator extends StatefulWidget {
  final Widget root;
  final GlobalKey<NavigatorState> navigatorKey;

  const TabNavigator({
    super.key,
    required this.root,
    required this.navigatorKey,
  });

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Essential for PageView caching

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => widget.root,
          settings: settings,
        );
      },
    );
  }
}
