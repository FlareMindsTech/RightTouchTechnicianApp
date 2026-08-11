// Job model defines the structure of a job/booking
class Job {
  final String id;
  final String? bookingId;
  final String title;
  final String? serviceName;
  final String? serviceId;
  final String? technicianId;
  final String description;
  final String location;
  final String? customerName;
  final String? customerPhone;
  final double? earnings;
  final double? totalAmount;
  final String? scheduledTime;
  final String? scheduledAt;
  final String status;
  final String? bookingStatus;
  final String? paymentStatus;
  final String? paymentMode;
  final bool isExclusive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;
  final String? customerId;
  final String? locationType;
  final List<String>? faultReasonsList;
  final List<String>? toolsEquipments;
  final List<String>? rectifyMethod;
  final List<String>? serviceChecklist;
  final double? basePrice;
  final double? technicianAmount;

  Job({
    required this.id,
    this.bookingId,
    required this.title,
    this.serviceName,
    this.serviceId,
    this.technicianId,
    required this.description,
    required this.location,
    this.customerName,
    this.customerPhone,
    this.earnings,
    this.totalAmount,
    this.scheduledTime,
    this.scheduledAt,
    required this.status,
    this.bookingStatus,
    this.paymentStatus,
    this.paymentMode,
    this.isExclusive = false,
    required this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.customerId,
    this.locationType,
    this.faultReasonsList,
    this.toolsEquipments,
    this.rectifyMethod,
    this.serviceChecklist,
    this.basePrice,
    this.technicianAmount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Check if data is nested inside "bookingId" or "booking"
    var bookingRaw = json['bookingId'] ?? json['booking'] ?? json;
    // Safe cast to Map, fallback to json if it's a String or other type
    final Map<String, dynamic> booking =
        (bookingRaw is Map<String, dynamic>) ? bookingRaw : json;

    // Helper to safely get map or null
    Map<String, dynamic>? getMap(dynamic val) {
      if (val is Map<String, dynamic>) return val;
      if (val is Map) return Map<String, dynamic>.from(val);
      return null;
    }

    // Check for nested customer profile
    final customerProfile = getMap(booking['customerProfileId']) ??
        getMap(json['customerProfileId']) ??
        getMap(booking['customer']) ??
        getMap(json['customer']);

    // Check for nested address
    final addressDataRaw = booking['addressId'] ??
        json['addressId'] ??
        booking['address'] ??
        json['address'];
    final addressData = getMap(addressDataRaw);

    // Check for nested service
    final serviceData = getMap(booking['serviceId']) ??
        getMap(json['serviceId']) ??
        getMap(booking['service']) ??
        getMap(json['service']);

    // Check for addressSnapshot
    final addressSnapshot =
        getMap(booking['addressSnapshot']) ?? getMap(json['addressSnapshot']);

    // Extract basic fields
    String id = json['bookingId'] ??
        json['jobId'] ??
        json['_id'] ??
        json['id'] ??
        booking['_id'] ??
        booking['id'] ??
        '';

    // Extract Title
    String title = 'Service Request';
    if (serviceData != null && serviceData['serviceName'] != null) {
      title = serviceData['serviceName'];
    } else if (booking['serviceName'] != null) {
      title = booking['serviceName'];
    } else if (json['serviceName'] != null) {
      title = json['serviceName'];
    } else {
      title = json['title'] ?? title;
    }

    String description = booking['description'] ??
        json['description'] ??
        booking['serviceDescription'] ??
        json['serviceDescription'] ??
        'No description provided';

    // Extract location
    String location = 'Unknown Location';

    // 1. Priority: Address Snapshot
    if (addressSnapshot != null) {
      final line = addressSnapshot['addressLine']?.toString() ?? '';
      final city = addressSnapshot['city']?.toString() ?? '';
      final state = addressSnapshot['state']?.toString() ?? '';
      final zip = addressSnapshot['pincode']?.toString() ?? '';
      // Construct a readable address string
      location = [line, city, state, zip].where((s) => s.isNotEmpty).join(', ');
    }
    // 2. Address Data
    else if (addressData != null) {
      location = addressData['addressLine'] ??
          addressData['city'] ??
          addressData['locality'] ??
          'Unknown Location';
    } else if (addressDataRaw is String) {
      location = addressDataRaw;
    } else if (booking['location'] != null) {
      location = booking['location'];
    } else if (json['location'] != null) {
      location = json['location'];
    } else if (customerProfile != null && customerProfile['locality'] != null) {
      location = customerProfile['locality'];
    } else if (booking['addressLine'] != null) {
      location = booking['addressLine'];
    }

    // Extract Coordinates - Enhanced to handle multiple formats
    double? lat;
    double? lng;

    // Helper to extract from location object (GeoJSON style)
    void extractFromGeo(dynamic loc) {
      if (loc is Map &&
          loc['coordinates'] != null &&
          loc['coordinates'] is List) {
        final coords = loc['coordinates'] as List;
        if (coords.length >= 2) {
          // GeoJSON is [longitude, latitude]
          lng = _parseDouble(coords[0]);
          lat = _parseDouble(coords[1]);
        }
      }
    }

    // Attempt 1: From address object
    if (addressData != null) {
      lat = _parseDouble(addressData['latitude'] ?? addressData['lat']);
      lng = _parseDouble(
        addressData['longitude'] ?? addressData['lng'] ?? addressData['long'],
      );
      // Also check if address object has a nested location object
      if (lat == null || lng == null) extractFromGeo(addressData['location']);
    }

    // Attempt 2: Direct location object in booking or root
    if (lat == null || lng == null) extractFromGeo(booking['location']);
    if (lat == null || lng == null) extractFromGeo(json['location']);

    // Attempt 3: Root level lat/lng
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

    // Attempt 4: Check if customerProfile has location
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

    // Attempt 5: Check serviceId for location
    if ((lat == null || lng == null) && serviceData != null) {
      lat = _parseDouble(serviceData['latitude'] ?? serviceData['lat']);
      lng = _parseDouble(
        serviceData['longitude'] ?? serviceData['lng'] ?? serviceData['long'],
      );
      if (lat == null || lng == null) {
        extractFromGeo(serviceData['location']);
      }
    }

    // Extract Customer Name - Enhanced to check multiple common field names
    String? cName;

    // Helper to extract name from a map
    String? extractName(Map<String, dynamic>? data) {
      if (data == null) return null;
      final first = data['firstName'] ?? data['fname'] ?? '';
      final last = data['lastName'] ?? data['lname'] ?? '';
      if (first.isNotEmpty || last.isNotEmpty) {
        return "$first $last".trim();
      }
      return data['name'] ??
          data['fullName'] ??
          data['userName'] ??
          data['display_name'] ??
          data['customerName'];
    }

    // 0. Priority: Address Snapshot
    if (addressSnapshot != null && addressSnapshot['name'] != null) {
      cName = addressSnapshot['name'];
    }

    // 1. Try customerProfile
    cName ??= extractName(customerProfile);

    // 2. Try customer object
    if (cName == null || cName.isEmpty) {
      final customerObj =
          getMap(json['customer']) ?? getMap(booking['customer']);
      cName = extractName(customerObj);
    }

    // 3. Try booking object
    if (cName == null || cName.isEmpty) {
      cName = extractName(booking);
    }

    // 4. Try root object
    if (cName == null || cName.isEmpty) {
      cName = extractName(json);
    }

    // 5. Fallback to direct fields if not found by helper
    cName ??= booking['customerName'] ??
        booking['name'] ??
        booking['fullName'] ??
        json['customerName'] ??
        json['name'] ??
        json['fullName'] ??
        json['userName'] ??
        "";

    // Extract Earnings/Price
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

    // Mobile Number - Enhanced extraction
    String? cPhone;

    // 0. Priority: Address Snapshot
    if (addressSnapshot != null && addressSnapshot['phone'] != null) {
      cPhone = addressSnapshot['phone'];
    }

    if (cPhone == null && customerProfile != null) {
      cPhone = customerProfile['mobileNumber'] ??
          customerProfile['phone'] ??
          customerProfile['phoneNumber'];
    }

    // Check address object (where it is in the log)
    if (cPhone == null && addressData != null) {
      cPhone = addressData['phone'] ??
          addressData['mobileResult'] ??
          addressData['mobile'];
    }

    // Check customer object if present
    final customerObj = getMap(json['customer']) ?? getMap(booking['customer']);
    if (cPhone == null && customerObj != null) {
      cPhone = customerObj['mobileNumber'] ??
          customerObj['phone'] ??
          customerObj['phoneNumber'];
    }

    // Fallback to direct fields
    cPhone ??= booking['customerPhone'] ??
        booking['phone'] ??
        booking['mobileNumber'] ??
        json['customerPhone'] ??
        json['phone'] ??
        json['mobileNumber'];

    // Extract new fields
    String? bookingId = _extractStringId(
      booking['bookingId'] ?? json['bookingId'],
    );
    String? serviceId = _extractStringId(
      serviceData?['_id'] ?? serviceData?['id'],
    );
    String? sName = serviceData?['serviceName'] ??
        booking['serviceName'] ??
        json['serviceName'];
    String? techId = _extractStringId(
      booking['technicianId'] ?? json['technicianId'],
    );
    String? bStatus = booking['bookingStatus'] ??
        json['bookingStatus'] ??
        booking['status'] ??
        json['status'];
    String? sAt = booking['scheduledAt'] ??
        json['scheduledAt'] ??
        booking['scheduledTime'] ??
        json['scheduledTime'];
    String? pStatus = booking['paymentStatus'] ?? json['paymentStatus'];
    String? pMode = booking['paymentMode'] ?? json['paymentMode'];
    double? tAmount =
        _parseDouble(booking['totalAmount'] ?? json['totalAmount']) ??
            earningsVal;
    DateTime? uAt = (booking['updatedAt'] ?? json['updatedAt']) != null
        ? DateTime.parse(booking['updatedAt'] ?? json['updatedAt'])
        : null;

    return Job(
      id: id,
      bookingId: bookingId,
      title: title,
      serviceName: sName,
      serviceId: serviceId,
      technicianId: techId,
      description: description,
      location: location,
      customerName: cName,
      customerPhone: cPhone,
      earnings: earningsVal,
      totalAmount: tAmount,
      scheduledTime: sAt,
      scheduledAt: sAt,
      status: bStatus ?? 'pending',
      bookingStatus: bStatus,
      paymentStatus: pStatus,
      paymentMode: pMode,
      isExclusive: json['isExclusive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: uAt,
      latitude: lat,
      longitude: lng,
      customerId: _extractStringId(
        customerProfile?['_id'] ??
            customerProfile?['id'] ??
            booking['customerId'] ??
            json['customerId'],
      ),
      locationType: _extractString(
            addressData?['locationType'] ??
                booking['locationType'] ??
                json['locationType'],
          ) ??
          'home',
      faultReasonsList: _parseStringList(
        serviceData?['faultReasons'] ?? booking['faultReasons'] ?? json['faultReasons'],
      ),
      toolsEquipments: _parseStringList(
        serviceData?['toolsEquipments'] ?? booking['toolsEquipments'] ?? json['toolsEquipments'],
      ),
      rectifyMethod: _parseStringList(
        serviceData?['rectifyMethod'] ?? booking['rectifyMethod'] ?? json['rectifyMethod'],
      ),
      serviceChecklist: _parseStringList(
        serviceData?['serviceChecklist'] ?? booking['serviceChecklist'] ?? json['serviceChecklist'],
      ),
      basePrice: bPrice,
      technicianAmount: techAmount,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove any non-numeric characters except dot and minus (e.g. "° N")
      String clean = value.replaceAll(RegExp(r'[^0-9.-]'), '');
      return double.tryParse(clean);
    }
    return null;
  }

  // Helper to safely extract String ID from potentially nested objects
  static String? _extractStringId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      // If it's a Map, try to get _id or id
      return value['_id']?.toString() ?? value['id']?.toString();
    }
    return value.toString();
  }

  // Helper to safely extract String from any type
  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return [value];
    }
    return null;
  }

  static String? _extractString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return null; // Don't convert Maps to strings
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'title': title,
      'serviceName': serviceName,
      'serviceId': serviceId,
      'technicianId': technicianId,
      'description': description,
      'location': location,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'earnings': earnings,
      'totalAmount': totalAmount,
      'scheduledTime': scheduledTime,
      'scheduledAt': scheduledAt,
      'status': status,
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'paymentMode': paymentMode,
      'isExclusive': isExclusive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'customerId': customerId,
      'locationType': locationType,
      'faultReasons': faultReasonsList,
      'toolsEquipments': toolsEquipments,
      'rectifyMethod': rectifyMethod,
      'serviceChecklist': serviceChecklist,
      'basePrice': basePrice,
      'technicianAmount': technicianAmount,
    };
  }
}
