import 'package:right_touch/data/models/user_model.dart';
import 'package:right_touch/screens/kyc/utils/kyc_image_helper.dart';

class KycPrefillData {
  final String? aadharNumber;
  final String? panNumber;
  final String? dlNumber;
  final String? aadharPath;
  final String? aadharBackPath;
  final String? panPath;
  final String? dlPath;

  KycPrefillData({
    this.aadharNumber,
    this.panNumber,
    this.dlNumber,
    this.aadharPath,
    this.aadharBackPath,
    this.panPath,
    this.dlPath,
  });
}

class KycPrefillHelper {
  static KycPrefillData extract(UserModel user) {
    final kyc = user.kycDetails;
    if (kyc == null) return KycPrefillData();

    String? aadharPath = KycImageHelper.getImg(kyc, [
      'aadhaarFront',
      'aadhaar_front',
      'aadharFront',
      'aadhar_front',
      'aadhaarImage',
      'aadhaarUrl',
      'aadharImage',
      'aadharUrl'
    ]);

    String? aadharBackPath = KycImageHelper.getImg(kyc, [
      'aadhaarBack',
      'aadhaar_back',
      'aadharBack',
      'aadhar_back',
      'aadhaarBackUrl',
      'aadharBackUrl',
    ]);

    if (aadharBackPath == null) {
      final aadharVal = kyc['aadhaarImage'] ??
          kyc['aadhaarUrl'] ??
          kyc['aadharImage'] ??
          kyc['aadharUrl'] ??
          (kyc['documents'] is Map ? kyc['documents']['aadhaarUrl'] : null) ??
          (kyc['documents'] is Map ? kyc['documents']['aadhaarImage'] : null);

      if (aadharVal is List && aadharVal.length > 1) {
        aadharBackPath = KycImageHelper.parseImgValue(aadharVal[1]);
      }
    }

    String? panPath = KycImageHelper.getImg(kyc, [
      'panImage',
      'panUrl',
      'panFront',
      'pan_front',
      'pan_image',
      'pan_url',
      'panCardFront'
    ]);

    String? dlPath = KycImageHelper.getImg(kyc, [
      'dlImage',
      'dlUrl',
      'dlFront',
      'dl_front',
      'dl_image',
      'dl_url',
      'drivingLicenseUrl',
      'drivingLicenseImage'
    ]);

    return KycPrefillData(
      aadharNumber: kyc['aadhaarNumber']?.toString(),
      panNumber: kyc['panNumber']?.toString(),
      dlNumber: kyc['drivingLicenseNumber']?.toString(),
      aadharPath: aadharPath,
      aadharBackPath: aadharBackPath,
      panPath: panPath,
      dlPath: dlPath,
    );
  }
}
