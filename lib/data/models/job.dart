import 'package:freezed_annotation/freezed_annotation.dart';

part 'job.freezed.dart';
part 'job.g.dart';

@freezed
abstract class Job with _$Job {
  const factory Job({
    required String id,
    String? bookingId,
    @Default('Service Request') String title,
    String? serviceName,
    String? serviceId,
    String? technicianId,
    @Default('No description provided') String description,
    @Default('Unknown Location') String location,
    String? customerName,
    String? customerPhone,
    double? earnings,
    double? totalAmount,
    String? scheduledTime,
    String? scheduledAt,
    @Default('pending') String status,
    String? bookingStatus,
    String? paymentStatus,
    String? paymentMode,
    @Default(false) bool isExclusive,
    required DateTime createdAt,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    String? customerId,
    @Default('home') String? locationType,
    List<String>? faultReasonsList,
    List<String>? toolsEquipments,
    List<String>? rectifyMethod,
    List<String>? serviceChecklist,
    double? basePrice,
    double? technicianAmount,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) =>
      _$JobFromJson(_normalizeJson(json));
}

Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
  var bookingRaw = json['bookingId'] ?? json['booking'] ?? json;
  final Map<String, dynamic> booking = (bookingRaw is Map<String, dynamic>)
      ? bookingRaw
      : (bookingRaw is Map ? Map<String, dynamic>.from(bookingRaw) : json);

  Map<String, dynamic>? getMap(dynamic val) {
    if (val is Map<String, dynamic>) return val;
    if (val is Map) return Map<String, dynamic>.from(val);
    return null;
  }

  final customerProfile = getMap(booking['customerProfileId']) ??
      getMap(json['customerProfileId']) ??
      getMap(booking['customer']) ??
      getMap(json['customer']);

  final addressDataRaw = booking['addressId'] ??
      json['addressId'] ??
      booking['address'] ??
      json['address'];
  final addressData = getMap(addressDataRaw);

  final serviceData = getMap(booking['serviceId']) ??
      getMap(json['serviceId']) ??
      getMap(booking['service']) ??
      getMap(json['service']);

  final addressSnapshot =
      getMap(booking['addressSnapshot']) ?? getMap(json['addressSnapshot']);

  String id = _extractStringId(json['jobId']) ??
      _extractStringId(booking['_id']) ??
      _extractStringId(booking['id']) ??
      _extractStringId(json['bookingId']) ??
      _extractStringId(json['_id']) ??
      _extractStringId(json['id']) ??
      '';


  String title = 'Service Request';
  if (serviceData != null && serviceData['serviceName'] != null) {
    title = serviceData['serviceName'].toString();
  } else if (booking['serviceName'] != null) {
    title = booking['serviceName'].toString();
  } else if (json['serviceName'] != null) {
    title = json['serviceName'].toString();
  } else if (json['title'] != null) {
    title = json['title'].toString();
  }

  String description = (booking['description'] ??
          json['description'] ??
          booking['serviceDescription'] ??
          json['serviceDescription'] ??
          'No description provided')
      .toString();

  String location = 'Unknown Location';
  if (addressSnapshot != null) {
    final line = addressSnapshot['addressLine']?.toString() ?? '';
    final city = addressSnapshot['city']?.toString() ?? '';
    final state = addressSnapshot['state']?.toString() ?? '';
    final zip = addressSnapshot['pincode']?.toString() ?? '';
    location = [line, city, state, zip].where((s) => s.isNotEmpty).join(', ');
  } else if (addressData != null) {
    location = (addressData['addressLine'] ??
            addressData['city'] ??
            addressData['locality'] ??
            'Unknown Location')
        .toString();
  } else if (addressDataRaw is String) {
    location = addressDataRaw;
  } else if (booking['location'] != null && booking['location'] is String) {
    location = booking['location'].toString();
  } else if (json['location'] != null && json['location'] is String) {
    location = json['location'].toString();
  } else if (customerProfile != null && customerProfile['locality'] != null) {
    location = customerProfile['locality'].toString();
  } else if (booking['addressLine'] != null) {
    location = booking['addressLine'].toString();
  }

  double? lat;
  double? lng;

  void extractFromGeo(dynamic loc) {
    if (loc is Map &&
        loc['coordinates'] != null &&
        loc['coordinates'] is List) {
      final coords = loc['coordinates'] as List;
      if (coords.length >= 2) {
        lng = _parseDouble(coords[0]);
        lat = _parseDouble(coords[1]);
      }
    }
  }

  if (addressData != null) {
    lat = _parseDouble(addressData['latitude'] ?? addressData['lat']);
    lng = _parseDouble(
      addressData['longitude'] ?? addressData['lng'] ?? addressData['long'],
    );
    if (lat == null || lng == null) extractFromGeo(addressData['location']);
  }
  if (lat == null || lng == null) extractFromGeo(booking['location']);
  if (lat == null || lng == null) extractFromGeo(json['location']);
  if (lat == null || lng == null) {
    lat = _parseDouble(
      json['latitude'] ??
          json['lat'] ??
          booking['latitude'] ??
          booking['lat'],
    );
    lng = _parseDouble(
      json['longitude'] ??
          json['lng'] ??
          booking['longitude'] ??
          booking['lng'],
    );
  }
  if ((lat == null || lng == null) && customerProfile != null) {
    lat = _parseDouble(customerProfile['latitude'] ?? customerProfile['lat']);
    lng = _parseDouble(
      customerProfile['longitude'] ??
          customerProfile['lng'] ??
          customerProfile['long'],
    );
    if (lat == null || lng == null) {
      extractFromGeo(customerProfile['location']);
    }
  }
  if ((lat == null || lng == null) && serviceData != null) {
    lat = _parseDouble(serviceData['latitude'] ?? serviceData['lat']);
    lng = _parseDouble(
      serviceData['longitude'] ?? serviceData['lng'] ?? serviceData['long'],
    );
    if (lat == null || lng == null) {
      extractFromGeo(serviceData['location']);
    }
  }

  String? cName;
  String? extractName(Map<String, dynamic>? data) {
    if (data == null) return null;
    final first = data['firstName'] ?? data['fname'] ?? '';
    final last = data['lastName'] ?? data['lname'] ?? '';
    if (first.toString().isNotEmpty || last.toString().isNotEmpty) {
      return "$first $last".trim();
    }
    return data['name']?.toString() ??
        data['fullName']?.toString() ??
        data['userName']?.toString() ??
        data['display_name']?.toString() ??
        data['customerName']?.toString();
  }

  if (addressSnapshot != null && addressSnapshot['name'] != null) {
    cName = addressSnapshot['name']?.toString();
  }
  cName ??= extractName(customerProfile);
  if (cName == null || cName.isEmpty) {
    final customerObj = getMap(json['customer']) ?? getMap(booking['customer']);
    cName = extractName(customerObj);
  }
  if (cName == null || cName.isEmpty) {
    cName = extractName(booking);
  }
  if (cName == null || cName.isEmpty) {
    cName = extractName(json);
  }
  cName ??= (booking['customerName'] ??
          booking['name'] ??
          booking['fullName'] ??
          json['customerName'] ??
          json['name'] ??
          json['fullName'] ??
          json['userName'] ??
          '')
      .toString();

  double? earningsVal;
  if (booking['totalAmount'] != null) {
    earningsVal = _parseDouble(booking['totalAmount']);
  } else if (booking['baseAmount'] != null) {
    earningsVal = _parseDouble(booking['baseAmount']);
  } else {
    earningsVal = _parseDouble(
      json['earnings'] ??
          json['price'] ??
          json['totalAmount'] ??
          booking['earnings'] ??
          booking['price'],
    );
  }

  double? bPrice = _parseDouble(
    json['basePrice'] ??
        booking['basePrice'] ??
        json['price'] ??
        booking['price'],
  );

  double? techAmount = _parseDouble(
    json['technicianAmount'] ?? booking['technicianAmount'],
  );

  String? cPhone;
  if (addressSnapshot != null && addressSnapshot['phone'] != null) {
    cPhone = addressSnapshot['phone']?.toString();
  }
  if (cPhone == null && customerProfile != null) {
    cPhone = (customerProfile['mobileNumber'] ??
            customerProfile['phone'] ??
            customerProfile['phoneNumber'])
        ?.toString();
  }
  if (cPhone == null && addressData != null) {
    cPhone = (addressData['phone'] ??
            addressData['mobileResult'] ??
            addressData['mobile'])
        ?.toString();
  }
  final customerObj = getMap(json['customer']) ?? getMap(booking['customer']);
  if (cPhone == null && customerObj != null) {
    cPhone = (customerObj['mobileNumber'] ??
            customerObj['phone'] ??
            customerObj['phoneNumber'])
        ?.toString();
  }
  cPhone ??= (booking['customerPhone'] ??
          booking['phone'] ??
          booking['mobileNumber'] ??
          json['customerPhone'] ??
          json['phone'] ??
          json['mobileNumber'])
      ?.toString();

  String? bookingId = _extractStringId(booking['bookingId'] ?? json['bookingId']);
  String? serviceId = _extractStringId(serviceData?['_id'] ?? serviceData?['id']);
  String? sName = (serviceData?['serviceName'] ??
          booking['serviceName'] ??
          json['serviceName'])
      ?.toString();
  String? techId = _extractStringId(booking['technicianId'] ?? json['technicianId']);
  String? bStatus = (booking['bookingStatus'] ??
          json['bookingStatus'] ??
          booking['status'] ??
          json['status'])
      ?.toString();
  String? sAt = (booking['scheduledAt'] ??
          json['scheduledAt'] ??
          booking['scheduledTime'] ??
          json['scheduledTime'])
      ?.toString();
  String? pStatus = (booking['paymentStatus'] ?? json['paymentStatus'])?.toString();
  String? pMode = (booking['paymentMode'] ?? json['paymentMode'])?.toString();
  double? tAmount =
      _parseDouble(booking['totalAmount'] ?? json['totalAmount']) ?? earningsVal;
  String? uAtStr = (booking['updatedAt'] ?? json['updatedAt'])?.toString();
  String cAtStr = (json['createdAt'] ?? DateTime.now().toIso8601String()).toString();

  return {
    'id': id,
    'bookingId': bookingId,
    'title': title,
    'serviceName': sName,
    'serviceId': serviceId,
    'technicianId': techId,
    'description': description,
    'location': location,
    'customerName': cName,
    'customerPhone': cPhone,
    'earnings': earningsVal,
    'totalAmount': tAmount,
    'scheduledTime': sAt,
    'scheduledAt': sAt,
    'status': bStatus ?? 'pending',
    'bookingStatus': bStatus,
    'paymentStatus': pStatus,
    'paymentMode': pMode,
    'isExclusive': json['isExclusive'] ?? false,
    'createdAt': cAtStr,
    'updatedAt': uAtStr,
    'latitude': lat,
    'longitude': lng,
    'customerId': _extractStringId(
      customerProfile?['_id'] ??
          customerProfile?['id'] ??
          booking['customerId'] ??
          json['customerId'],
    ),
    'locationType': _extractString(
          addressData?['locationType'] ??
              booking['locationType'] ??
              json['locationType'],
        ) ??
        'home',
    'faultReasonsList': _parseStringList(
      serviceData?['faultReasons'] ?? booking['faultReasons'] ?? json['faultReasons'],
    ),
    'toolsEquipments': _parseStringList(
      serviceData?['toolsEquipments'] ?? booking['toolsEquipments'] ?? json['toolsEquipments'],
    ),
    'rectifyMethod': _parseStringList(
      serviceData?['rectifyMethod'] ?? booking['rectifyMethod'] ?? json['rectifyMethod'],
    ),
    'serviceChecklist': _parseStringList(
      serviceData?['serviceChecklist'] ?? booking['serviceChecklist'] ?? json['serviceChecklist'],
    ),
    'basePrice': bPrice,
    'technicianAmount': techAmount,
  };
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    String clean = value.replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(clean);
  }
  return null;
}

String? _extractStringId(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    return value['_id']?.toString() ?? value['id']?.toString();
  }
  return value.toString();
}

List<String>? _parseStringList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String && value.isNotEmpty) {
    return [value];
  }
  return null;
}

String? _extractString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) return null;
  return value.toString();
}
