// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Job _$JobFromJson(Map<String, dynamic> json) => _Job(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String?,
      title: json['title'] as String? ?? 'Service Request',
      serviceName: json['serviceName'] as String?,
      serviceId: json['serviceId'] as String?,
      technicianId: json['technicianId'] as String?,
      description: json['description'] as String? ?? 'No description provided',
      location: json['location'] as String? ?? 'Unknown Location',
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      earnings: (json['earnings'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      scheduledTime: json['scheduledTime'] as String?,
      scheduledAt: json['scheduledAt'] as String?,
      status: json['status'] as String? ?? 'pending',
      bookingStatus: json['bookingStatus'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      paymentMode: json['paymentMode'] as String?,
      isExclusive: json['isExclusive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      customerId: json['customerId'] as String?,
      locationType: json['locationType'] as String? ?? 'home',
      faultReasonsList: (json['faultReasonsList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      toolsEquipments: (json['toolsEquipments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rectifyMethod: (json['rectifyMethod'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      serviceChecklist: (json['serviceChecklist'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      technicianAmount: (json['technicianAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$JobToJson(_Job instance) => <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'title': instance.title,
      'serviceName': instance.serviceName,
      'serviceId': instance.serviceId,
      'technicianId': instance.technicianId,
      'description': instance.description,
      'location': instance.location,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'earnings': instance.earnings,
      'totalAmount': instance.totalAmount,
      'scheduledTime': instance.scheduledTime,
      'scheduledAt': instance.scheduledAt,
      'status': instance.status,
      'bookingStatus': instance.bookingStatus,
      'paymentStatus': instance.paymentStatus,
      'paymentMode': instance.paymentMode,
      'isExclusive': instance.isExclusive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'customerId': instance.customerId,
      'locationType': instance.locationType,
      'faultReasonsList': instance.faultReasonsList,
      'toolsEquipments': instance.toolsEquipments,
      'rectifyMethod': instance.rectifyMethod,
      'serviceChecklist': instance.serviceChecklist,
      'basePrice': instance.basePrice,
      'technicianAmount': instance.technicianAmount,
    };
