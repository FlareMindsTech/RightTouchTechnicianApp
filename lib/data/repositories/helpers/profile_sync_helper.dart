import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/data/models/user_model.dart';
import 'package:right_touch/data/repositories/helpers/profile_data_cleaner.dart';

class ProfileSyncHelper {
  static Future<UserModel> getProfile(
    DioClient client,
    FlutterSecureStorage storage,
  ) async {
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
        userResp = await client.get(
          '/api/user/me',
          options: Options(
            validateStatus: (status) =>
                status != null && (status < 400 || status == 404),
          ),
        );
        if (userResp.statusCode != null && userResp.statusCode! < 400) {
          final userData = ProfileDataCleaner.safeGet(userResp.data, 'result') ??
              ProfileDataCleaner.safeGet(userResp.data, 'data') ??
              userResp.data;

          if (userResp.data['success'] == false &&
              userResp.data['message']
                      ?.toString()
                      .toLowerCase()
                      .contains('account has been deleted') ==
                  true) {
            throw Exception('ACCOUNT_DELETED: ${userResp.data['message']}');
          }

          final userMap = ProfileDataCleaner.safeMap(userData);
          if (userMap != null) mergedData.addAll(userMap);
        }
      } catch (e) {
        if (e is DioException &&
            (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
          rethrow;
        }
        if (e.toString().contains('ACCOUNT_DELETED')) rethrow;
        debugPrint('Base user fetch handled: $e');
      }

      // 2. Try fetching technician-specific profile
      try {
        techResp = await client.get(
          '/api/technician/technician/me',
          options: Options(
            validateStatus: (status) =>
                status != null && (status < 400 || status == 404),
          ),
        );

        techSuccess = techResp.statusCode != null && techResp.statusCode! < 400;
      } catch (e) {
        if (e is DioException &&
            (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
          rethrow;
        }
        if (e.toString().contains('ACCOUNT_DELETED')) rethrow;
        debugPrint('Tech fetch handled: $e');
      }

      if (techSuccess) {
        try {
          kycResp = await client.get(
            '/api/technician/technician/kyc/me',
            options: Options(
              validateStatus: (status) =>
                  status != null && (status < 400 || status == 404),
            ),
          );

          kycSuccess = kycResp.statusCode != null && kycResp.statusCode! < 400;
        } catch (e) {
          if (e is DioException &&
              (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
            rethrow;
          }
          if (e.toString().contains('ACCOUNT_DELETED')) rethrow;
          debugPrint('KYC fetch handled: $e');
        }
      }

      if (!techSuccess && !kycSuccess) {
        final cachedProfile = await storage.read(key: 'cached_profile');

        if (cachedProfile != null) {
          try {
            final Map<String, dynamic> decoded = jsonDecode(cachedProfile);
            return UserModel.fromJson(decoded);
          } catch (e) {
            debugPrint('[AuthRepository] Failed to parse cached profile fallback: $e');
          }
        }
      }

      if (techResp.data != null) {
        final data = techResp.data;
        final techResult = ProfileDataCleaner.safeGet(data, 'result') ??
            ProfileDataCleaner.safeGet(data, 'data') ??
            data;
        final techMap = ProfileDataCleaner.safeMap(techResult);
        if (techMap != null) {
          mergedData.addAll(techMap);

          if (techMap['profileComplete'] == true) {
            mergedData['profileComplete'] = true;
          }

          final nestedUser = ProfileDataCleaner.safeGet(techMap, 'user') is Map
              ? ProfileDataCleaner.safeMap(techMap['user'])
              : ProfileDataCleaner.safeMap(techMap['userId']);

          if (nestedUser != null) {
            if (nestedUser['profileComplete'] == true) {
              mergedData['profileComplete'] = true;
            }

            nestedUser.forEach((key, value) {
              if (mergedData[key] == null && value != null) {
                mergedData[key] = value;
              }
            });

            final fname = nestedUser['fname']?.toString();
            final lname = nestedUser['lname']?.toString();
            if (fname != null && fname.isNotEmpty) mergedData['fname'] = fname;
            if (lname != null && lname.isNotEmpty) mergedData['lname'] = lname;

            if (mergedData['gender'] == null && nestedUser['gender'] != null) {
              mergedData['gender'] = nestedUser['gender'];
            }
          }

          final profileObj = ProfileDataCleaner.safeMap(techMap['profile']);
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
            profileObj.forEach((key, value) {
              if (mergedData[key] == null && value != null) {
                mergedData[key] = value;
              }
            });
          }

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
        final kycResult = ProfileDataCleaner.safeGet(data, 'result') ??
            ProfileDataCleaner.safeGet(data, 'data') ??
            data;
        final kycMap = ProfileDataCleaner.safeMap(kycResult);

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
            mergedData['bankDetails'] = ProfileDataCleaner.safeMap(kycMap['bankDetails']);
          }

          final innerTech = ProfileDataCleaner.safeMap(kycMap['technicianId']);
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

          final eligibility = ProfileDataCleaner.safeMap(kycMap['eligibility']);
          if (eligibility != null) {
            final statusParams = ProfileDataCleaner.safeMap(eligibility['status']);
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
        final profile = ProfileDataCleaner.safeMap(mergedData['profile']);
        if (profile != null && profile['averageRating'] != null) {
          mergedData['averageRating'] = profile['averageRating'];
        }
      }

      ProfileDataCleaner.sanitizeFields(mergedData);

      mergedData['rawData'] = ProfileDataCleaner.safeMap(mergedData);

      final userModel = UserModel.fromJson(mergedData);

      if (techSuccess || kycSuccess) {
        await storage.write(
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
}
