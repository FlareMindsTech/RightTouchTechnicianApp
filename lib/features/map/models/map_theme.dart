import 'package:flutter/material.dart';
import 'package:right_touch/config/api_config.dart';

enum MapThemeType {
  streets,
  satellite,
}

class AppMapTheme {
  final MapThemeType type;
  final String name;
  final String urlTemplate;
  final List<String> subdomains;
  final String attribution;
  final double minZoom;
  final double maxZoom;
  final bool isDark;
  final IconData icon;

  const AppMapTheme({
    required this.type,
    required this.name,
    required this.urlTemplate,
    this.subdomains = const ['a', 'b', 'c', 'd'],
    required this.attribution,
    this.minZoom = 1.0,
    this.maxZoom = 19.0,
    required this.isDark,
    required this.icon,
  });

  static AppMapTheme getTheme(MapThemeType type) {
    final mapTilerKey = ApiConfig.mapTilerKey;
    switch (type) {
      case MapThemeType.satellite:
        if (mapTilerKey.isNotEmpty) {
          return AppMapTheme(
            type: MapThemeType.satellite,
            name: 'Satellite View',
            urlTemplate: 'https://api.maptiler.com/maps/satellite/{z}/{x}/{y}.jpg?key=$mapTilerKey',
            attribution: '© MapTiler, © OpenStreetMap contributors',
            isDark: false,
            icon: Icons.satellite_alt_rounded,
          );
        }
        return const AppMapTheme(
          type: MapThemeType.satellite,
          name: 'Satellite View',
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          attribution: 'Source: Esri, Maxar, Earthstar Geographics',
          isDark: false,
          icon: Icons.satellite_alt_rounded,
        );

      case MapThemeType.streets:
        if (mapTilerKey.isNotEmpty) {
          return AppMapTheme(
            type: MapThemeType.streets,
            name: 'OpenStreetMap',
            urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$mapTilerKey',
            attribution: '© OpenStreetMap contributors, © MapTiler',
            isDark: false,
            icon: Icons.map,
          );
        }
        return const AppMapTheme(
          type: MapThemeType.streets,
          name: 'OpenStreetMap',
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          attribution: '© OpenStreetMap contributors',
          isDark: false,
          icon: Icons.map,
        );
    }
  }

  static List<AppMapTheme> get availableThemes => [
        getTheme(MapThemeType.streets),
        getTheme(MapThemeType.satellite),
      ];
}
