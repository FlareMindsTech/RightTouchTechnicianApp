class ProfileDataCleaner {
  static String? ensureString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      if (value.containsKey('status')) return value['status']?.toString();
      if (value.containsKey('_id')) return value['_id']?.toString();
      if (value.containsKey('id')) return value['id']?.toString();
      if (value.containsKey('name')) return value['name']?.toString();
    }
    return value.toString();
  }

  static Map<String, dynamic>? safeMap(dynamic value) {
    if (value == null || value is! Map) return null;
    try {
      return Map<String, dynamic>.from(value);
    } catch (e) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.toString()] = v;
      });
      return result;
    }
  }

  static dynamic safeGet(dynamic data, String key) {
    if (data == null || data is! Map) return null;
    return data[key];
  }

  static void sanitizeFields(Map<String, dynamic> mergedData) {
    final stringFields = <String>{
      '_id',
      'id',
      'userId',
      'technicianProfileId',
      'mobileNumber',
      'role',
      'kycStatus',
      'verificationStatus',
      'workStatus',
      'bankVerificationStatus',
      'firstName',
      'lastName',
      'fname',
      'lname',
      'gender',
      'address',
      'city',
      'state',
      'pincode',
      'locality',
      'technicianId',
      'customerId',
      'fullName',
      'email',
      'profileImage',
      'status',
      'defaultAddressId',
      'specialization',
    };

    for (var field in stringFields) {
      if (mergedData.containsKey(field) && mergedData[field] != null) {
        mergedData[field] = ensureString(mergedData[field]);
      }
    }

    final knownMapFields = <String>{
      'availability',
      'profile',
      'technician',
      'rawData',
      'bankDetails',
      'eligibility',
    };

    for (var key in mergedData.keys.toList()) {
      final value = mergedData[key];
      if (value is Map && !knownMapFields.contains(key)) {
        mergedData[key] = ensureString(value);
      } else if (value is Map && knownMapFields.contains(key)) {
        mergedData[key] = safeMap(value);
      }
    }

    if (mergedData['skills'] != null && mergedData['skills'] is List) {
      final rawSkillsList = mergedData['skills'] as List;

      final skillObjects = rawSkillsList
          .map((e) {
            if (e is Map) {
              final serviceId = e['serviceId'];
              String? sid;
              String? sname;
              if (serviceId is Map) {
                sid = serviceId['_id']?.toString() ??
                    serviceId['id']?.toString();
                sname = serviceId['serviceName']?.toString() ??
                    serviceId['name']?.toString();
              } else if (serviceId is String) {
                sid = serviceId;
              }
              if (sid != null) {
                return {'_id': sid, 'serviceName': sname ?? ''};
              }
            } else if (e is String) {
              return {'_id': e, 'serviceName': ''};
            }
            return null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();
      if (skillObjects.isNotEmpty) {
        mergedData['skillObjects'] = skillObjects;
      }

      mergedData['skills'] = rawSkillsList.map((e) {
        if (e is String) return e;
        if (e is Map) {
          final sid = e['serviceId'];
          if (sid is Map) {
            return (sid['_id'] ?? sid['id'] ?? e.toString()).toString();
          }
          return (e['serviceId'] ?? e['_id'] ?? e['id'] ?? e.toString())
              .toString();
        }
        return e.toString();
      }).toList();
    }

    for (var dateField in ['createdAt', 'updatedAt']) {
      if (mergedData[dateField] != null && mergedData[dateField] is! String) {
        final val = mergedData[dateField];
        if (val is Map) {
          mergedData[dateField] = null;
        } else {
          mergedData[dateField] = val.toString();
        }
      }
    }

    if (mergedData['experienceYears'] != null) {
      final exp = mergedData['experienceYears'];
      if (exp is String) {
        mergedData['experienceYears'] = int.tryParse(exp) ?? 0;
      } else if (exp is num) {
        mergedData['experienceYears'] = exp.toInt();
      } else if (exp is Map) {
        mergedData['experienceYears'] = null;
      }
    }

    for (var ratingField in ['rating', 'averageRating']) {
      if (mergedData[ratingField] != null) {
        final r = mergedData[ratingField];
        if (r is String) {
          mergedData[ratingField] = double.tryParse(r);
        } else if (r is Map) {
          mergedData[ratingField] = safeMap(r);
        }
      }
    }
  }
}
