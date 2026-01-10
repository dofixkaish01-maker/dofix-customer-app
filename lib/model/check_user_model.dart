class CheckUserModel {
  final String? responseCode;
  final String? message;
  final Content? content;
  final List<dynamic>? errors;

  CheckUserModel({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  factory CheckUserModel.fromJson(Map<String, dynamic> json) => CheckUserModel(
        responseCode: json['response_code'],
        message: json['message'],
        content:
            json['content'] != null ? Content.fromJson(json['content']) : null,
        errors: json['errors'],
      );

  Map<String, dynamic> toJson() => {
        'response_code': responseCode,
        'message': message,
        'content': content?.toJson(),
        'errors': errors,
      };
}

class Content {
  final User? user;
  final String? token;
  final String? message;
  final bool? profileCompleted;

  Content({
    this.user,
    this.token,
    this.message,
    this.profileCompleted,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        token: json['token'],
        message: json['message'],
        profileCompleted: json['profile_completed'],
      );

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'token': token,
        'message': message,
        'profile_completed': profileCompleted,
      };
}

class User {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final dynamic identificationNumber;
  final String? identificationType;
  final List<dynamic>? identificationImage;
  final dynamic dateOfBirth;
  final String? gender;
  final String? profileImage;
  final dynamic fcmToken;
  final int? isPhoneVerified;
  final int? isEmailVerified;
  final dynamic phoneVerifiedAt;
  final dynamic emailVerifiedAt;
  final int? isActive;
  final String? userType;
  final dynamic rememberToken;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? walletBalance;
  final int? loyaltyPoint;
  final String? refCode;
  final dynamic referredBy;
  final int? loginHitCount;
  final int? isTempBlocked;
  final dynamic tempBlockTime;
  final String? currentLanguageKey;
  final dynamic profileImageFullPath;
  final List<dynamic>? identificationImageFullPath;
  final dynamic storage;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.identificationNumber,
    this.identificationType,
    this.identificationImage,
    this.dateOfBirth,
    this.gender,
    this.profileImage,
    this.fcmToken,
    this.isPhoneVerified,
    this.isEmailVerified,
    this.phoneVerifiedAt,
    this.emailVerifiedAt,
    this.isActive,
    this.userType,
    this.rememberToken,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.walletBalance,
    this.loyaltyPoint,
    this.refCode,
    this.referredBy,
    this.loginHitCount,
    this.isTempBlocked,
    this.tempBlockTime,
    this.currentLanguageKey,
    this.profileImageFullPath,
    this.identificationImageFullPath,
    this.storage,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        phone: json['phone'],
        identificationNumber: json['identification_number'],
        identificationType: json['identification_type'],
        identificationImage: json['identification_image'],
        dateOfBirth: json['date_of_birth'],
        gender: json['gender'],
        profileImage: json['profile_image'],
        fcmToken: json['fcm_token'],
        isPhoneVerified: json['is_phone_verified'],
        isEmailVerified: json['is_email_verified'],
        phoneVerifiedAt: json['phone_verified_at'],
        emailVerifiedAt: json['email_verified_at'],
        isActive: json['is_active'],
        userType: json['user_type'],
        rememberToken: json['remember_token'],
        deletedAt: json['deleted_at'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        walletBalance: json['wallet_balance'],
        loyaltyPoint: json['loyalty_point'],
        refCode: json['ref_code'],
        referredBy: json['referred_by'],
        loginHitCount: json['login_hit_count'],
        isTempBlocked: json['is_temp_blocked'],
        tempBlockTime: json['temp_block_time'],
        currentLanguageKey: json['current_language_key'],
        profileImageFullPath: json['profile_image_full_path'],
        identificationImageFullPath: json['identification_image_full_path'],
        storage: json['storage'],
      );

  Map<String, dynamic> toJson() => {
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
        'is_phone_verified': isPhoneVerified,
        'is_email_verified': isEmailVerified,
        'phone_verified_at': phoneVerifiedAt,
        'email_verified_at': emailVerifiedAt,
        'is_active': isActive,
        'user_type': userType,
        'remember_token': rememberToken,
        'deleted_at': deletedAt,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'wallet_balance': walletBalance,
        'loyalty_point': loyaltyPoint,
        'ref_code': refCode,
        'referred_by': referredBy,
        'login_hit_count': loginHitCount,
        'is_temp_blocked': isTempBlocked,
        'temp_block_time': tempBlockTime,
        'current_language_key': currentLanguageKey,
        'profile_image_full_path': profileImageFullPath,
        'identification_image_full_path': identificationImageFullPath,
        'storage': storage,
      };
}
