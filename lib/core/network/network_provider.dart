import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    onUnauthorized: () async {
      await ref.read(authProvider.notifier).logout();
    },
  );
});

