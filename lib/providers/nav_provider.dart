import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavNotifier extends Notifier<int> {
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  int build() => 0;

  @override
  set state(int value) => super.state = value;

  GlobalKey<NavigatorState> get currentNavigatorKey => navigatorKeys[state];
}

final navProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);
