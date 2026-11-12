class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // job, payment, withdrawal, system
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['_id'] ?? json['id'] ?? json['notificationId'] ?? '').toString(),
      title: (json['title'] ?? json['heading'] ?? 'Notification').toString(),
      message: (json['message'] ?? json['body'] ?? json['text'] ?? '').toString(),
      type: (json['type'] ?? json['category'] ?? 'system').toString().toLowerCase(),
      isRead: json['isRead'] == true || json['read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : (json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      data: data,
    );
  }
}

