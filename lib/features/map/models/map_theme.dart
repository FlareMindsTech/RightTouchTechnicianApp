import 'package:flutter/material.dart';
import 'package:right_touch/config/api_config.dart';

enum MapThemeType {
  streets,
  buildings,
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
  final double tileSize;
  final double zoomOffset;
  final bool isDark;
  final IconData icon;

  const AppMapTheme({
    required this.type,
    required this.name,
    required this.urlTemplate,
    this.subdomains = const ['a', 'b', 'c', 'd'],
    required this.attribution,
    this.minZoom = 1.0,
    this.maxZoom = 20.0,
    this.tileSize = 256.0,
    this.zoomOffset = 0.0,
    required this.isDark,
    required this.icon,
  });

  static AppMapTheme getTheme(MapThemeType type) {
    final mapTilerKey = ApiConfig.mapTilerKey;
    switch (type) {
      case MapThemeType.buildings:
        if (mapTilerKey.isNotEmpty) {
          return AppMapTheme(
            type: MapThemeType.buildings,
            name: '3D Building Boxes',
            urlTemplate:
                'https://api.maptiler.com/maps/bright-v2-512/{z}/{x}/{y}@2x.png?key=$mapTilerKey',
            attribution: '© MapTiler, © OpenStreetMap contributors',
            tileSize: 512.0,
            zoomOffset: -1.0,
            minZoom: 1.0,
            maxZoom: 20.0,
            isDark: false,
            icon: Icons.apartment_rounded,
          );
        }
        return const AppMapTheme(
          type: MapThemeType.buildings,
          name: 'Building Outlines',
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
          attribution: '© OpenStreetMap contributors',
          tileSize: 256.0,
          zoomOffset: 0.0,
          minZoom: 1.0,
          maxZoom: 19.0,
          isDark: false,
          icon: Icons.apartment_rounded,
        );

      case MapThemeType.streets:
        if (mapTilerKey.isNotEmpty) {
          return AppMapTheme(
            type: MapThemeType.streets,
            name: 'Detailed Streets',
            urlTemplate:
                'https://api.maptiler.com/maps/streets-v2-512/{z}/{x}/{y}@2x.png?key=$mapTilerKey',
            attribution: '© MapTiler, © OpenStreetMap contributors',
            tileSize: 512.0,
            zoomOffset: -1.0,
            minZoom: 1.0,
            maxZoom: 20.0,
            isDark: false,
            icon: Icons.map_rounded,
          );
        }
        return const AppMapTheme(
          type: MapThemeType.streets,
          name: 'OpenStreetMap',
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
          attribution: '© OpenStreetMap contributors',
          tileSize: 256.0,
          zoomOffset: 0.0,
          minZoom: 1.0,
          maxZoom: 19.0,
          isDark: false,
          icon: Icons.map_rounded,
        );

      case MapThemeType.satellite:
        if (mapTilerKey.isNotEmpty) {
          return AppMapTheme(
            type: MapThemeType.satellite,
            name: 'Satellite Hybrid',
            urlTemplate:
                'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key=$mapTilerKey',
            attribution: '© MapTiler, © OpenStreetMap contributors',
            tileSize: 512.0,
            zoomOffset: -1.0,
            minZoom: 1.0,
            maxZoom: 20.0,
            isDark: false,
            icon: Icons.satellite_alt_rounded,
          );
        }
        return const AppMapTheme(
          type: MapThemeType.satellite,
          name: 'Satellite View',
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          attribution: 'Source: Esri, Maxar, Earthstar Geographics',
          tileSize: 256.0,
          zoomOffset: 0.0,
          minZoom: 1.0,
          maxZoom: 19.0,
          isDark: false,
          icon: Icons.satellite_alt_rounded,
        );
    }
  }

  static List<AppMapTheme> get availableThemes => [
        getTheme(MapThemeType.buildings),
        getTheme(MapThemeType.streets),
        getTheme(MapThemeType.satellite),
      ];
}
