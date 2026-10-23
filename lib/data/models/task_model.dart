import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String jobId,
    required String location,
    required String faultReason,
    @Default([]) List<String> toolsRequired,
    @Default([]) List<String> rectifySteps,
    @Default([]) List<String> checklistItems,
    @JsonKey(
      name: 'timeSpentSeconds',
      fromJson: _durationFromSeconds,
      toJson: _durationToSeconds,
    )
    @Default(Duration.zero)
    Duration timeSpent,
    String? customerId,
    String? locationType,
    double? latitude,
    double? longitude,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}

Duration _durationFromSeconds(dynamic seconds) {
  if (seconds is int) return Duration(seconds: seconds);
  if (seconds is num) return Duration(seconds: seconds.toInt());
  return Duration.zero;
}

int _durationToSeconds(Duration duration) => duration.inSeconds;
