import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:right_touch/core/network/dio_client.dart';
import 'package:right_touch/data/repositories/helpers/repo_error_helper.dart';

class KycRepoHelper {
  static MediaType? getMediaType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) return MediaType('image', 'png');
    if (lowerPath.endsWith('.pdf')) return MediaType('application', 'pdf');
    return MediaType('image', 'jpeg');
  }

  static Future<Map<String, dynamic>> submitKYC(
    DioClient client, {
    required String aadhaarNumber,
    required String panNumber,
    required String drivingLicenseNumber,
    Map<String, dynamic>? bankDetails,
  }) async {
    try {
      final response = await client.post(
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
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'KYC submission failed'),
      );
    }
  }

  static Future<Map<String, dynamic>> uploadKYCDocuments(
    DioClient client, {
    required List<String> aadhaarPaths,
    required String panPath,
    required String dlPath,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {};

      if (aadhaarPaths.isNotEmpty) {
        final List<MultipartFile> files = [];
        for (var i = 0; i < aadhaarPaths.length; i++) {
          if (aadhaarPaths[i].isNotEmpty &&
              !aadhaarPaths[i].startsWith('http')) {
            files.add(await MultipartFile.fromFile(
              aadhaarPaths[i],
              filename: 'aadhaar_${i == 0 ? "front" : "back"}.jpg',
              contentType: getMediaType(aadhaarPaths[i]),
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
          contentType: getMediaType(panPath),
        );
      }

      if (dlPath.isNotEmpty && !dlPath.startsWith('http')) {
        formDataMap['dlImage'] = await MultipartFile.fromFile(
          dlPath,
          filename: 'dl.jpg',
          contentType: getMediaType(dlPath),
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await client.post(
        '/api/technician/technician/kyc/upload',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        RepoErrorHelper.getErrorMessage(e, 'KYC upload failed'),
      );
    }
  }
}
