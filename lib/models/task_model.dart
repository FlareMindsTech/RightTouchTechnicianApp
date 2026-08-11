class TaskModel {
  final String jobId;
  final String location;
  final String faultReason;
  final List<String> toolsRequired;
  final List<String> rectifySteps;
  final List<String> checklistItems;
  final Duration timeSpent;
  final String? customerId; // Added for backend validation
  final String? locationType; // Added for backend validation
  final double? latitude;
  final double? longitude;

  TaskModel({
    required this.jobId,
    required this.location,
    required this.faultReason,
    required this.toolsRequired,
    required this.rectifySteps,
    required this.checklistItems,
    required this.timeSpent,
    this.customerId,
    this.locationType,
    this.latitude,
    this.longitude,
  });

  /// Factory constructor to create a TaskModel from a Map (API ready)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      jobId: json['jobId'] ?? '',
      location: json['location'] ?? '',
      faultReason: json['faultReason'] ?? '',
      toolsRequired: List<String>.from(json['toolsRequired'] ?? []),
      rectifySteps: List<String>.from(json['rectifySteps'] ?? []),
      checklistItems: List<String>.from(json['checklistItems'] ?? []),
      timeSpent: Duration(seconds: json['timeSpentSeconds'] ?? 0),
      customerId: json['customerId'],
      locationType: json['locationType'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  /// CopyWith method for state management updates
  TaskModel copyWith({
    String? jobId,
    String? location,
    String? faultReason,
    List<String>? toolsRequired,
    List<String>? rectifySteps,
    List<String>? checklistItems,
    Duration? timeSpent,
    String? customerId,
    String? locationType,
    double? latitude,
    double? longitude,
  }) {
    return TaskModel(
      jobId: jobId ?? this.jobId,
      location: location ?? this.location,
      faultReason: faultReason ?? this.faultReason,
      toolsRequired: toolsRequired ?? this.toolsRequired,
      rectifySteps: rectifySteps ?? this.rectifySteps,
      checklistItems: checklistItems ?? this.checklistItems,
      timeSpent: timeSpent ?? this.timeSpent,
      customerId: customerId ?? this.customerId,
      locationType: locationType ?? this.locationType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
