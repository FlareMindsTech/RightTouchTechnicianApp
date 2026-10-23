import 'package:flutter/material.dart';
import 'package:right_touch/data/models/user_model.dart';

class ProfilePrefillHelper {
  static void prefillControllers({
    required UserModel user,
    required TextEditingController fname,
    required TextEditingController lname,
    required TextEditingController email,
    required TextEditingController address,
    required TextEditingController city,
    required TextEditingController state,
    required TextEditingController pincode,
    required TextEditingController locality,
    required TextEditingController exp,
    required TextEditingController specialization,
    required Function(String gender) onGender,
  }) {
    final raw = user.rawData ?? {};
    if (fname.text.isEmpty) {
      fname.text = (user.firstName?.isNotEmpty ?? false)
          ? user.firstName ?? ''
          : raw['fname']?.toString() ?? '';
    }
    if (lname.text.isEmpty) {
      lname.text = (user.lastName?.isNotEmpty ?? false)
          ? user.lastName ?? ''
          : raw['lname']?.toString() ?? '';
    }
    if (email.text.isEmpty) {
      email.text = (user.email?.isNotEmpty ?? false)
          ? user.email ?? ''
          : raw['email']?.toString() ?? '';
    }
    if (address.text.isEmpty) {
      address.text = user.address ?? raw['address']?.toString() ?? '';
    }
    if (city.text.isEmpty) {
      city.text = user.city ?? raw['city']?.toString() ?? '';
    }
    if (state.text.isEmpty) {
      state.text = user.state ?? raw['state']?.toString() ?? '';
    }
    if (pincode.text.isEmpty) {
      pincode.text = user.pincode ?? raw['pincode']?.toString() ?? '';
    }
    if (locality.text.isEmpty) {
      locality.text = user.locality ?? raw['locality']?.toString() ?? '';
    }
    if (exp.text.isEmpty) {
      exp.text = (user.experienceYears ?? raw['experienceYears'])?.toString() ?? '';
    }
    if (specialization.text.isEmpty) {
      specialization.text =
          user.specialization ?? raw['specialization']?.toString() ?? '';
    }
    final genderVal = user.gender?.isNotEmpty == true
        ? user.gender
        : raw['gender']?.toString();
    if (genderVal != null && genderVal.isNotEmpty) {
      onGender(genderVal);
    }
  }

  static List<Map<String, dynamic>> resolveInitialSkills({
    required UserModel user,
    required List<dynamic> services,
  }) {
    final skillObjects = user.rawData?['skillObjects'];
    if (skillObjects is List && skillObjects.isNotEmpty) {
      final resolved = <Map<String, dynamic>>[];
      for (var s in skillObjects) {
        if (s is Map && s['_id']?.toString().isNotEmpty == true) {
          resolved.add({
            '_id': s['_id'].toString(),
            'serviceName': s['serviceName']?.toString() ?? '',
          });
        }
      }
      if (resolved.isNotEmpty) return resolved;
    }

    final rawSkills = user.rawData?['skills'];
    if (rawSkills is List && rawSkills.isNotEmpty && services.isNotEmpty) {
      final resolved = <Map<String, dynamic>>[];
      for (var skill in rawSkills) {
        final id = skill is String
            ? skill
            : (skill is Map ? skill['_id']?.toString() : null);
        if (id == null || id.isEmpty) continue;
        final match = services.firstWhere(
          (s) => (s['_id'] ?? s['id'])?.toString() == id,
          orElse: () => <String, dynamic>{},
        );
        if (match.isNotEmpty) {
          resolved.add(Map<String, dynamic>.from(match));
        }
      }
      return resolved;
    }

    return [];
  }

  static Map<String, dynamic> buildProfilePayload({
    required UserModel user,
    required String fname,
    required String lname,
    required String email,
    required String gender,
    required String locality,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String exp,
    required String specialization,
    required List<Map<String, dynamic>> selectedServices,
  }) {
    final skills = selectedServices.map((s) {
      final id = s['_id']?.toString() ?? s['id']?.toString();
      return {
        "serviceId": id,
        "experienceYears": int.tryParse(exp.trim()) ?? 0,
      };
    }).toList();

    return {
      "fname": fname.trim(),
      "lname": lname.trim(),
      "email": email.trim(),
      "mobileNumber": user.mobileNumber ?? "",
      "gender": gender,
      "locality": locality.trim(),
      "address": address.trim(),
      "city": city.trim(),
      "state": state.trim(),
      "pincode": pincode.trim(),
      "experienceYears": int.tryParse(exp.trim()) ?? 0,
      "specialization": specialization.trim(),
      "skills": skills,
      "profileComplete": true,
    };
  }
}
