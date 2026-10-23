import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/data/models/job.dart';

import 'package:right_touch/data/repositories/job_repository.dart';

// Provides current active jobs
final currentJobsProvider =
    AsyncNotifierProvider<CurrentJobsNotifier, List<Job>>(() {
  return CurrentJobsNotifier();
});

class CurrentJobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  FutureOr<List<Job>> build() async {
    ref.keepAlive();

    // Fetch only once, then rely on manual refresh or socket events
    return _fetch();
  }

  Future<List<Job>> _fetch({bool forceRefresh = false}) async {
    final repository = ref.read(jobRepositoryProvider);
    final jobsJson = await repository.getCurrentJobs(
      forceRefresh: forceRefresh,
    );
    return jobsJson.map((json) => Job.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(forceRefresh: true));
  }
}

// Provides job history
final historyJobsProvider =
    AsyncNotifierProvider<HistoryJobsNotifier, List<Job>>(() {
  return HistoryJobsNotifier();
});

class HistoryJobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  FutureOr<List<Job>> build() async {
    ref.keepAlive();
    return _fetch();
  }

  Future<List<Job>> _fetch({bool forceRefresh = false}) async {
    final repository = ref.read(jobRepositoryProvider);
    final jobsJson = await repository.getJobHistory(forceRefresh: forceRefresh);
    return jobsJson.map((json) => Job.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(forceRefresh: true));
  }
}

// Provides broadcasted (available) jobs
final broadcastJobsProvider =
    AsyncNotifierProvider<BroadcastJobsNotifier, List<Job>>(() {
  return BroadcastJobsNotifier();
});

class BroadcastJobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  FutureOr<List<Job>> build() async {
    // We don't necessarily need to keep broadcast jobs alive forever,
    // but a short cache is good.
    final link = ref.keepAlive();
    final timer = Timer(const Duration(minutes: 5), () => link.close());
    ref.onDispose(() => timer.cancel());

    return _fetch();
  }

  Future<List<Job>> _fetch({bool forceRefresh = false}) async {
    final repository = ref.read(jobRepositoryProvider);
    final jobsJson = await repository.getBroadcastJobs(
      forceRefresh: forceRefresh,
    );
    return jobsJson.map((json) => Job.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(forceRefresh: true));
  }
}
