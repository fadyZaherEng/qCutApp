class SignUpResponse {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String userType;
  final String status;
  final bool verified;

  SignUpResponse({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.userType,
    required this.status,
    required this.verified,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? '',
      status: json['status'] ?? '',
      verified: json['verified'] ?? false,
    );
  }
}

class UserOffer {
  final int dealDateStart;
  final int dealDateEnd;
  final int qCuteSubscription;
  final int? freeUntilDate;
  final String status;

  UserOffer({
    required this.dealDateStart,
    required this.dealDateEnd,
    required this.qCuteSubscription,
    this.freeUntilDate,
    required this.status,
  });

  factory UserOffer.fromJson(Map<String, dynamic> json) {
    return UserOffer(
      dealDateStart: json['dealDateStart'] ?? 0,
      dealDateEnd: json['dealDateEnd'] ?? 0,
      qCuteSubscription: json['QCuteSubscription'] ?? 0,
      freeUntilDate: json['freeUntilDate'],
      status: json['status'] ?? '',
    );
  }
}

class LoginResponse {
  final String accessToken;
  final String id;
  final String fullName;
  final String phoneNumber;
  final String userType;
  final String profilePic;
  final String coverPic;
  final String barberShop;
  final String status;
  final bool isBanned;
  final int? bannedUntil;
  final String? banReason;
  final int? daysRemaining;
  final bool? isInFreePeriod;
  final UserOffer? userOffer;
  final String? archiveReason;
  final int? deleteDate;
  final String? deleteReason;

  LoginResponse({
    required this.accessToken,
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.userType,
    required this.profilePic,
    required this.coverPic,
    this.barberShop = '',
    this.status = '',
    this.isBanned = false,
    this.bannedUntil,
    this.banReason,
    this.daysRemaining,
    this.isInFreePeriod,
    this.userOffer,
    this.archiveReason,
    this.deleteDate,
    this.deleteReason,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? '',
      profilePic: json['profilePic'] ?? '',
      coverPic: json['coverPic'] ?? '',
      barberShop: json['barberShop'] ?? '',
      status: json['status'] ?? '',
      isBanned: json['isBanned'] ?? false,
      bannedUntil: json['bannedUntil'],
      banReason: json['banReason'] ?? '',
      daysRemaining: json['daysRemaining'],
      isInFreePeriod: json['isInFreePeriod'],
      userOffer: json['userOffer'] != null
          ? UserOffer.fromJson(json['userOffer'])
          : null,
      archiveReason: json['archiveReason'],
      deleteDate: json['deleteDate'],
      deleteReason: json['deleteReason'],
    );
  }
}
