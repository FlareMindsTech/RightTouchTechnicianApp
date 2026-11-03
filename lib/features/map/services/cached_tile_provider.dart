import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Dedicated persistent disk cache manager for map tiles.
/// Retains tiles for up to 30 days and stores up to 8,000 tile objects
/// in local SQLite/device storage for offline reliability.
class MapTileCacheManager {
  static const String key = 'right_touch_map_tiles_cache';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 8000,
    ),
  );
}

/// High-reliability persistent disk-cached TileProvider for flutter_map.
/// Eliminates blank tile grids when the technician is driving through
/// low-connectivity areas or working offline.
class CachedTileProvider extends TileProvider {
  final CacheManager cacheManager;

  CachedTileProvider({
    super.headers,
    CacheManager? customCacheManager,
  }) : cacheManager = customCacheManager ?? MapTileCacheManager.instance;

  static final CachedTileProvider instance = CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return CachedNetworkImageProvider(
      url,
      headers: headers,
      cacheManager: cacheManager,
    );
  }
}

