class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? identificationNumber;
  final String identificationType;
  final List<String> identificationImage;
  final String? dateOfBirth;
  final String gender;
  final String profileImage;
  final String? fcmToken;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String? phoneVerifiedAt;
  final String? emailVerifiedAt;
  final bool isActive;
  final String userType;
  final String? rememberToken;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final double walletBalance;
  final int loyaltyPoint;
  final String refCode;
  final String? referredBy;
  final int loginHitCount;
  final bool isTempBlocked;
  final String? tempBlockTime;
  final String currentLanguageKey;
  final String? profileImageFullPath;
  final List<String> identificationImageFullPath;
  final String? storage;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.identificationNumber,
    required this.identificationType,
    required this.identificationImage,
    required this.dateOfBirth,
    required this.gender,
    required this.profileImage,
    required this.fcmToken,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.phoneVerifiedAt,
    required this.emailVerifiedAt,
    required this.isActive,
    required this.userType,
    required this.rememberToken,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.walletBalance,
    required this.loyaltyPoint,
    required this.refCode,
    required this.referredBy,
    required this.loginHitCount,
    required this.isTempBlocked,
    required this.tempBlockTime,
    required this.currentLanguageKey,
    required this.profileImageFullPath,
    required this.identificationImageFullPath,
    required this.storage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      identificationNumber: json['identification_number'],
      identificationType: json['identification_type'],
      identificationImage:
          List<String>.from(json['identification_image'] ?? []),
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      profileImage: json['profile_image'],
      fcmToken: json['fcm_token'],
      isPhoneVerified: json['is_phone_verified'] == 1,
      isEmailVerified: json['is_email_verified'] == 1,
      phoneVerifiedAt: json['phone_verified_at'],
      emailVerifiedAt: json['email_verified_at'],
      isActive: json['is_active'] == 1,
      userType: json['user_type'],
      rememberToken: json['remember_token'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      walletBalance: (json['wallet_balance'] is int)
          ? (json['wallet_balance'] as int).toDouble()
          : (json['wallet_balance'] as double? ?? 0.0),
      loyaltyPoint: json['loyalty_point'],
      refCode: json['ref_code'],
      referredBy: json['referred_by'],
      loginHitCount: json['login_hit_count'],
      isTempBlocked: json['is_temp_blocked'] == 1,
      tempBlockTime: json['temp_block_time'],
      currentLanguageKey: json['current_language_key'],
      profileImageFullPath: json['profile_image_full_path'],
      identificationImageFullPath:
          List<String>.from(json['identification_image_full_path'] ?? []),
      storage: json['storage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'identification_number': identificationNumber,
      'identification_type': identificationType,
      'identification_image': identificationImage,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'profile_image': profileImage,
      'fcm_token': fcmToken,
      'is_phone_verified': isPhoneVerified ? 1 : 0,
      'is_email_verified': isEmailVerified ? 1 : 0,
      'phone_verified_at': phoneVerifiedAt,
      'email_verified_at': emailVerifiedAt,
      'is_active': isActive ? 1 : 0,
      'user_type': userType,
      'remember_token': rememberToken,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'wallet_balance': walletBalance,
      'loyalty_point': loyaltyPoint,
      'ref_code': refCode,
      'referred_by': referredBy,
      'login_hit_count': loginHitCount,
      'is_temp_blocked': isTempBlocked ? 1 : 0,
      'temp_block_time': tempBlockTime,
      'current_language_key': currentLanguageKey,
      'profile_image_full_path': profileImageFullPath,
      'identification_image_full_path': identificationImageFullPath,
      'storage': storage,
    };
  }
}
