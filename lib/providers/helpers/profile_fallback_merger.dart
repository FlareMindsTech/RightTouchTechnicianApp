import 'package:right_touch/data/models/user_model.dart';

class ProfileFallbackMerger {
  static UserModel apply(
    UserModel? previousUser,
    Map<String, dynamic> profileData,
    UserModel user,
  ) {
    final userData =
        profileData['user'] as Map<String, dynamic>? ?? profileData;
    final mobile = userData['mobileNumber']?.toString() ?? "";
    final email = userData['email']?.toString() ?? "";

    return user.copyWith(
      firstName: userData['fname']?.toString() ??
          userData['firstName']?.toString() ??
          user.firstName ??
          previousUser?.firstName,
      lastName: userData['lname']?.toString() ??
          userData['lastName']?.toString() ??
          user.lastName ??
          previousUser?.lastName,
      mobileNumber: (mobile.isNotEmpty)
          ? mobile
          : (user.mobileNumber ?? previousUser?.mobileNumber),
      email: (email.isNotEmpty) ? email : (user.email ?? previousUser?.email),
      gender: userData['gender']?.toString() ??
          user.gender ??
          previousUser?.gender,
      locality: profileData['locality']?.toString() ??
          user.locality ??
          previousUser?.locality,
      address: profileData['address']?.toString() ??
          user.address ??
          previousUser?.address,
      city: profileData['city']?.toString() ?? user.city ?? previousUser?.city,
      state:
          profileData['state']?.toString() ?? user.state ?? previousUser?.state,
      specialization: profileData['specialization']?.toString() ??
          user.specialization ??
          previousUser?.specialization,
      profileComplete: true,
    );
  }
}
