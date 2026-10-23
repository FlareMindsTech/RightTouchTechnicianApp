// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => _TaskModel(
      jobId: json['jobId'] as String,
      location: json['location'] as String,
      faultReason: json['faultReason'] as String,
      toolsRequired: (json['toolsRequired'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rectifySteps: (json['rectifySteps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      checklistItems: (json['checklistItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      timeSpent: json['timeSpentSeconds'] == null
          ? Duration.zero
          : _durationFromSeconds(json['timeSpentSeconds']),
      customerId: json['customerId'] as String?,
      locationType: json['locationType'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'location': instance.location,
      'faultReason': instance.faultReason,
      'toolsRequired': instance.toolsRequired,
      'rectifySteps': instance.rectifySteps,
      'checklistItems': instance.checklistItems,
      'timeSpentSeconds': _durationToSeconds(instance.timeSpent),
      'customerId': instance.customerId,
      'locationType': instance.locationType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
