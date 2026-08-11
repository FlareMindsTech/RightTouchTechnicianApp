import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/core/network/network_provider.dart';
import 'package:right_touch/data/models/user_model.dart';
import 'package:right_touch/config/api_config.dart';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  AuthRepository(this._client, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // --- SharedPreferences Logic ---

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  Future<void> markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  Future<void> saveAvailabilityStatus(bool isOnline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_online', isOnline);
  }

  Future<bool> loadAvailabilityStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_online') ?? true;
  }

  Future<UserModel> getProfile() async {
    String? ensureString(dynamic value) {
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

    Map<String, dynamic>? safeMap(dynamic value) {
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

    dynamic safeGet(dynamic data, String key) {
      if (data == null || data is! Map) return null;
      return data[key];
    }

    try {
      Map<String, dynamic> mergedData = {};
      bool techSuccess = false;
      bool kycSuccess = false;

      Response techResp = Response(
        requestOptions: RequestOptions(path: ''),
        data: {},
        statusCode: 500,
      );
      Response userResp = Response(
        requestOptions: RequestOptions(path: ''),
        data: {},
        statusCode: 500,
      );
      Response kycResp = Response(
        requestOptions: RequestOptions(path: ''),
        data: {},
        statusCode: 500,
      );

      // 1. Try fetching base user profile
      try {
        userResp = await _client.get(
          '/api/user/me',
          options: Options(
            validateStatus: (status) =>
                status != null &&
                (status < 400 || status == 401 || status == 404),
          ),
        );
        if (userResp.statusCode != null && userResp.statusCode! < 400) {
          final userData = safeGet(userResp.data, 'result') ??
              safeGet(userResp.data, 'data') ??
              userResp.data;

          // CRITICAL FIX: If account is deleted, throw strictly
          if (userResp.data['success'] == false &&
              userResp.data['message']
                      ?.toString()
                      .toLowerCase()
                      .contains('account has been deleted') ==
                  true) {
            throw Exception('ACCOUNT_DELETED: ${userResp.data['message']}');
          }

          final userMap = safeMap(userData);
          if (userMap != null) mergedData.addAll(userMap);
        }
      } catch (e) {
        if (e.toString().contains('ACCOUNT_DELETED')) rethrow;
        debugPrint('Base user fetch handled: $e');
      }

      // 2. Try fetching technician-specific profile
      try {
        techResp = await _client.get(
          '/api/technician/technician/me',
          options: Options(
            validateStatus: (status) =>
                status != null &&
                (status < 400 ||
                    status == 401 ||
                    status == 403 ||
                    status == 404),
          ),
        );

        // Check for 403 Forbidden specifically (Account deactivated/deleted)
        if (techResp.statusCode == 403 ||
            (techResp.data != null &&
                techResp.data['message']
                        ?.toString()
                        .toLowerCase()
                        .contains('deactivated') ==
                    true)) {
          throw Exception(
              'ACCOUNT_DELETED: Your account has been deactivated or deleted.');
        }

        techSuccess = techResp.statusCode != null && techResp.statusCode! < 400;
      } catch (e) {
        if (e.toString().contains('ACCOUNT_DELETED')) rethrow;
        debugPrint('Tech fetch handled: $e');
      }

      if (techSuccess) {
        try {
          kycResp = await _client.get(
            '/api/technician/technician/kyc/me',
            options: Options(
              validateStatus: (status) =>
                  status != null &&
                  (status < 400 ||
                      status == 401 ||
                      status == 403 ||
                      status == 404),
            ),
          );

          if (kycResp.statusCode == 403) {
            throw Exception(
                'ACCOUNT_DELETED: Your account has been deactivated or deleted.');
          }

          kycSuccess = kycResp.statusCode != null && kycResp.statusCode! < 400;
        } catch (e) {
          if (e.toString().contains('ACCOUNT_DELETED')) rethrow;
          debugPrint('KYC fetch handled: $e');
        }
      }

      if (!techSuccess && !kycSuccess) {
        // If we failed because of a 403, we ALREADY threw ACCOUNT_DELETED above.
        // If we failed because of a 401, we should also probably not use cache.
        if (techResp.statusCode == 401 || kycResp.statusCode == 401) {
          throw Exception('UNAUTHENTICATED');
        }

        final cachedProfile = await _storage.read(key: 'cached_profile');
        if (cachedProfile != null) {
          try {
            final Map<String, dynamic> decoded = jsonDecode(cachedProfile);
            return UserModel.fromJson(decoded);
          } catch (_) {}
        }
      }

      if (techResp.data != null) {
        final data = techResp.data;
        final techResult =
            safeGet(data, 'result') ?? safeGet(data, 'data') ?? data;
        final techMap = safeMap(techResult);
        if (techMap != null) {
          mergedData.addAll(techMap);

          // Explicitly check for profileComplete in root of tech response
          if (techMap['profileComplete'] == true) {
            mergedData['profileComplete'] = true;
          }

          // Flatten nested user object names if present (check both 'user' and 'userId')
          final nestedUser = safeGet(techMap, 'user') is Map
              ? safeMap(techMap['user'])
              : safeMap(techMap['userId']);

          if (nestedUser != null) {
            // Check for profileComplete inside nested user too
            if (nestedUser['profileComplete'] == true) {
              mergedData['profileComplete'] = true;
            }

            // Merge all nested user fields if they are missing in the root
            nestedUser.forEach((key, value) {
              if (mergedData[key] == null && value != null) {
                mergedData[key] = value;
              }
            });

            final fname = nestedUser['fname']?.toString();
            final lname = nestedUser['lname']?.toString();
            if (fname != null && fname.isNotEmpty) mergedData['fname'] = fname;
            if (lname != null && lname.isNotEmpty) mergedData['lname'] = lname;

            // Ensure gender is captured from nested user too
            if (mergedData['gender'] == null && nestedUser['gender'] != null) {
              mergedData['gender'] = nestedUser['gender'];
            }
          }

          // Also check if they are in the 'profile' object
          final profileObj = safeMap(techMap['profile']);
          if (profileObj != null) {
            if (profileObj['profileComplete'] == true) {
              mergedData['profileComplete'] = true;
            }

            final pfname = profileObj['fname']?.toString();
            final plname = profileObj['lname']?.toString();
            if (mergedData['fname'] == null && pfname != null) {
              mergedData['fname'] = pfname;
            }
            if (mergedData['lname'] == null && plname != null) {
              mergedData['lname'] = plname;
            }
            // Merge other profile fields too
            profileObj.forEach((key, value) {
              if (mergedData[key] == null && value != null) {
                mergedData[key] = value;
              }
            });
          }

          // Generate fullName if missing
          if (mergedData['fullName'] == null ||
              mergedData['fullName'].toString().isEmpty) {
            final f = mergedData['fname'] ?? '';
            final l = mergedData['lname'] ?? '';
            if (f.isNotEmpty || l.isNotEmpty) {
              mergedData['fullName'] = "$f $l".trim();
            }
          }
        }
      }

      if (kycResp.data != null) {
        final data = kycResp.data;
        final kycResult =
            safeGet(data, 'result') ?? safeGet(data, 'data') ?? data;
        final kycMap = safeMap(kycResult);

        if (kycMap != null) {
          if (kycMap['kycVerified'] != null) {
            mergedData['kycVerified'] = kycMap['kycVerified'];
          }

          if (kycMap['verificationStatus'] != null) {
            mergedData['kycStatus'] = kycMap['verificationStatus'];
            mergedData['verificationStatus'] = kycMap['verificationStatus'];
          }

          if (kycMap['bankVerified'] != null) {
            mergedData['bankVerified'] = kycMap['bankVerified'];
          }
          if (kycMap['bankDetails'] != null) {
            mergedData['bankDetails'] = safeMap(kycMap['bankDetails']);
          }

          final innerTech = safeMap(kycMap['technicianId']);
          if (innerTech != null) {
            if (innerTech['profileComplete'] == true) {
              mergedData['profileComplete'] = true;
            }
            if (innerTech['workStatus'] != null) {
              mergedData['workStatus'] = innerTech['workStatus'];
            }
            if (mergedData['kycVerified'] == null &&
                innerTech['kycVerified'] != null) {
              mergedData['kycVerified'] = innerTech['kycVerified'];
            }
          }

          final eligibility = safeMap(kycMap['eligibility']);
          if (eligibility != null) {
            final statusParams = safeMap(eligibility['status']);
            if (statusParams != null) {
              if (statusParams['profileComplete'] == true) {
                mergedData['profileComplete'] = true;
              }
              if (statusParams['kycStatus'] != null) {
                mergedData['kycStatus'] = statusParams['kycStatus'];
              }
              if (statusParams['workStatus'] != null) {
                mergedData['workStatus'] = statusParams['workStatus'];
              }
            }
          }

          mergedData['technician'] = kycMap;
        }
      }

      if (mergedData['averageRating'] == null) {
        final profile = safeMap(mergedData['profile']);
        if (profile != null && profile['averageRating'] != null) {
          mergedData['averageRating'] = profile['averageRating'];
        }
      }

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

        // Save full skill objects BEFORE normalization so ProfileSetupScreen
        // can resolve service names without a secondary API call.
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

        // Normalize skills to plain ID strings for the UserModel
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
            // Keep the map, UserModel will handle it via RatingModel.fromJson
            mergedData[ratingField] = safeMap(r);
          }
        }
      }

      mergedData['rawData'] = safeMap(mergedData);

      final userModel = UserModel.fromJson(mergedData);

      if (techSuccess || kycSuccess) {
        await _storage.write(
          key: 'cached_profile',
          value: jsonEncode(mergedData),
        );
      }

      return userModel;
    } catch (e) {
      if (e.toString().contains('ACCOUNT_DELETED')) rethrow;
      throw Exception('Failed to synchronize profile: ${e.toString()}');
    }
  }

  Future<UserModel> completeProfile(Map<String, dynamic> profileData) async {
    try {
      // Step 1: Save all technician profile data (name, address, skills etc.)
      await _client.post(ApiConfig.technicianDataEndpoint, data: profileData);

      // Step 2: Explicitly call the completeProfile endpoint so the server
      // sets profileComplete: true in the database (required for KYC access)
      try {
        await _client.post(
          ApiConfig.completeProfileEndpoint,
          data: {'profileComplete': true},
        );
      } catch (e) {
        // Non-fatal — log but continue. Profile data is already saved.
        debugPrint('completeProfile endpoint failed (non-fatal): $e');
      }

      return await getProfile();
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to complete profile'));
    }
  }

  Future<Map<String, dynamic>> submitKYC({
    required String aadhaarNumber,
    required String panNumber,
    required String drivingLicenseNumber,
    Map<String, dynamic>? bankDetails,
  }) async {
    try {
      final response = await _client.post(
        '/api/technician/technician/kyc',
        data: {
          'aadhaarNumber': aadhaarNumber,
          'panNumber': panNumber,
          'drivingLicenseNumber': drivingLicenseNumber,
          ...?bankDetails != null ? {'bankDetails': bankDetails} : null,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'KYC submission failed'));
    }
  }

  MediaType? _getMediaType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) return MediaType('image', 'png');
    if (lowerPath.endsWith('.pdf')) return MediaType('application', 'pdf');
    return MediaType('image', 'jpeg');
  }

  Future<Map<String, dynamic>> uploadKYCDocuments({
    required List<String> aadhaarPaths,
    required String panPath,
    required String dlPath,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {};

      if (aadhaarPaths.isNotEmpty) {
        final List<MultipartFile> files = [];
        for (var i = 0; i < aadhaarPaths.length; i++) {
          if (aadhaarPaths[i].isNotEmpty && !aadhaarPaths[i].startsWith('http')) {
            files.add(await MultipartFile.fromFile(
              aadhaarPaths[i],
              filename: 'aadhaar_${i == 0 ? "front" : "back"}.jpg',
              contentType: _getMediaType(aadhaarPaths[i]),
            ));
          }
        }
        if (files.isNotEmpty) {
          formDataMap['aadhaarImage'] = files;
        }
      }

      if (panPath.isNotEmpty && !panPath.startsWith('http')) {
        formDataMap['panImage'] = await MultipartFile.fromFile(
          panPath,
          filename: 'pan_front.jpg',
          contentType: _getMediaType(panPath),
        );
      }

      if (dlPath.isNotEmpty && !dlPath.startsWith('http')) {
        formDataMap['dlImage'] = await MultipartFile.fromFile(
          dlPath,
          filename: 'dl.jpg',
          contentType: _getMediaType(dlPath),
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _client.post(
        '/api/technician/technician/kyc/upload',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'KYC upload failed'));
    }
  }

  Future<Map<String, dynamic>> submitBankOnly({
    required Map<String, dynamic> bankDetails,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.bankDetailsEndpoint,
        data: bankDetails,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Bank verification failed'));
    }
  }

  Future<Map<String, dynamic>> getKYC() async {
    try {
      final response = await _client.get('/api/technician/technician/kyc/me');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch KYC details'));
    }
  }

  Future<Map<String, dynamic>> signup(
    String identifier, {
    bool termsAndServices = true,
    bool privacyPolicy = true,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.signupEndpoint,
        data: {
          'identifier': identifier,
          'role': 'Technician',
          'termsAndServices': termsAndServices,
          'privacyPolicy': privacyPolicy,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Signup failed'));
    }
  }

  Future<Map<String, dynamic>> loginRequest(
    String identifier, {
    bool termsAndServices = true,
    bool privacyPolicy = true,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.loginEndpoint,
        data: {
          'identifier': identifier,
          'termsAndServices': termsAndServices,
          'privacyPolicy': privacyPolicy,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Login failed'));
    }
  }

  Future<Map<String, dynamic>> resendOtp(String identifier) async {
    try {
      final response = await _client.post(
        '/api/user/resend-otp',
        data: {'identifier': identifier},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to resend OTP'));
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String identifier, String otp) async {
    try {
      final response = await _client.post(
        ApiConfig.verifyOtpEndpoint,
        data: {'identifier': identifier, 'role': 'Technician', 'otp': otp},
      );
      final data = response.data;
      final result = data['result'] ?? data;
      final token = result['token'] ??
          result['accessToken'] ??
          data['token'] ??
          data['accessToken'];

      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
      }
      return data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'OTP verification failed'));
    }
  }

  // Removed extracted methods (Jobs & Wallet) - moved to JobRepository and DashboardRepository

  Future<Map<String, dynamic>> updateTechnicianProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.put(
        ApiConfig.updateTechnicianEndpoint,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        _getErrorMessage(e, 'Failed to update technician profile'),
      );
    }
  }

  Future<Map<String, dynamic>> addSkill(
    String serviceId,
    int experienceYears,
  ) async {
    try {
      final response = await _client.put(
        '/api/technician/technician/skills/add',
        data: {
          'serviceIds': [serviceId],
          'experienceYears': experienceYears,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to add skill'));
    }
  }

  Future<Map<String, dynamic>> uploadProfileImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imagePath,
          contentType: _getMediaType(imagePath),
        ),
      });
      final response = await _client.post(
        '/api/technician/technician/profile-image',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to upload profile image'));
    }
  }

  Future<Map<String, dynamic>> resendRegistrationOtp(
    String mobileNumber,
  ) async {
    try {
      final response = await _client.post(
        '/api/user/resend-otp',
        data: {'mobileNumber': mobileNumber, 'role': 'Technician'},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to resend OTP'));
    }
  }

  Future<Map<String, dynamic>> getTechnicianData() async {
    try {
      final response = await _client.get('/api/technician/technicianData');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch technician data'));
    }
  }

  Future<Map<String, dynamic>> updateTechnicianData(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiConfig.technicianDataEndpoint,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to update technician data'));
    }
  }

  Future<dynamic> getAllServices() async {
    try {
      final response = await _client.get('/api/user/getAllServices');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to fetch services'));
    }
  }

  // Wallet methods removed - moved to DashboardRepository

  Future<Map<String, dynamic>> deleteMyAccount() async {
    try {
      final response = await _client.delete('/api/user/delete-my-account');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e, 'Failed to delete account'));
    }
  }

  String _getErrorMessage(DioException e, String fallback) {
    // If it's a connection/timeout/cancel error, show a generic friendly message
    if (e.type != DioExceptionType.badResponse) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet.';
      }
      return 'Unable to connect. Please check your network.';
    }

    final statusCode = e.response?.statusCode ?? 500;
    final responseData = e.response?.data;

    // For 500+ errors, hide the raw technical message if it looks too detailed
    if (statusCode >= 500) {
      return 'Something went wrong on our end. Please try again later.';
    }

    if (responseData == null) return fallback;

    if (responseData is Map) {
      // Return specific API messages for 400-level errors (like "User already registered")
      final message = responseData['message']?.toString() ??
          responseData['error']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    if (responseData is List && responseData.isNotEmpty) {
      final first = responseData.first;
      if (first is Map) {
        final message =
            first['message']?.toString() ?? first['error']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
    }

    // Default to fallback for other cases to avoid exposing raw HTML or stack traces
    return fallback;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRepository(client);
});
