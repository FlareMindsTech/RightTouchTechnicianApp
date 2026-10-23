import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const appSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(resetOnError: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return appSecureStorage;
});
