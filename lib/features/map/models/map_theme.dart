import 'package:flutter/material.dart';

enum MapThemeType {
  buildings,
  satellite,
}

class AppMapTheme {
  final MapThemeType type;
  final String name;
  final String description;
  final String urlTemplate;
  final List<String> subdomains;
  final String attribution;
  final double minZoom;
  final double maxZoom;
  final double tileSize;
  final double zoomOffset;
  final bool isDark;
  final IconData icon;

  const AppMapTheme({
    required this.type,
    required this.name,
    this.description = '',
    required this.urlTemplate,
    this.subdomains = const ['0', '1', '2', '3'],
    required this.attribution,
    this.minZoom = 1.0,
    this.maxZoom = 21.0,
    this.tileSize = 256.0,
    this.zoomOffset = 0.0,
    required this.isDark,
    required this.icon,
  });

  static AppMapTheme getTheme(MapThemeType type) {
    switch (type) {
      case MapThemeType.buildings:
        return const AppMapTheme(
          type: MapThemeType.buildings,
          name: 'Google Streets',
          description: 'Roads & building outlines',
          urlTemplate:
              'https://mt{s}.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}',
          subdomains: ['0', '1', '2', '3'],
          attribution: '© Google Maps',
          tileSize: 256.0,
          zoomOffset: 0.0,
          minZoom: 1.0,
          maxZoom: 21.0,
          isDark: false,
          icon: Icons.map_rounded,
        );

      case MapThemeType.satellite:
        return const AppMapTheme(
          type: MapThemeType.satellite,
          name: 'Google Satellite',
          description: 'High-res satellite hybrid',
          urlTemplate:
              'https://mt{s}.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}',
          subdomains: ['0', '1', '2', '3'],
          attribution: '© Google Maps',
          tileSize: 256.0,
          zoomOffset: 0.0,
          minZoom: 1.0,
          maxZoom: 21.0,
          isDark: false,
          icon: Icons.satellite_alt_rounded,
        );
    }
  }

  static List<AppMapTheme> get availableThemes => [
        getTheme(MapThemeType.buildings),
        getTheme(MapThemeType.satellite),
      ];
}
