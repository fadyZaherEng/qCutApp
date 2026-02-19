import 'package:q_cut/modules/barber/features/home_features/profile_features/models/barber_profile_model.dart';

class BarberProfileResponse {
  final BarberProfileData data;

  BarberProfileResponse({required this.data});

  factory BarberProfileResponse.fromJson(Map<String, dynamic> json) {
    return BarberProfileResponse(
        data: BarberProfileData.fromJson(json['data']));
  }
}

class BarberProfileData {
  String id;
  String fullName;
  String phoneNumber;
  String city;
  String profilePic;
  String coverPic;
  List<String> favoritePhotos;
  String userType;
  String status;
  List<String> offDay;
  List<WorkingDay> workingDays;
  List<BreakTime> breakTime;
  List<dynamic> favorites;
  String barberShop;
  String bankAccountNumber;
  String instagramPage;
  BarberShopLocation barberShopLocation;
  String locationDescription;
  List<WalkInRecord>? walkIn;
  final int? hashtag;

  BarberProfileData({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.city,
    required this.profilePic,
    required this.coverPic,
    required this.favoritePhotos,
    required this.userType,
    required this.status,
    required this.offDay,
    required this.workingDays,
    required this.breakTime,
    required this.favorites,
    required this.barberShop,
    required this.bankAccountNumber,
    required this.instagramPage,
    required this.barberShopLocation,
    required this.locationDescription,
    this.walkIn,
    this.hashtag,
  });

  factory BarberProfileData.fromJson(Map<String, dynamic> json) {
    // Handle workingDays which might be empty or null
    List<WorkingDay> workingDays = [];
    if (json['workingDays'] != null) {
      if (json['workingDays'] is List) {
        workingDays = List<WorkingDay>.from(
            (json['workingDays'] as List).map((x) => WorkingDay.fromJson(x)));
      }
    }

    // Handle empty lists with defaults
    List<String> offDay = [];
    if (json['offDay'] != null) {
      if (json['offDay'] is List) {
        offDay = List<String>.from(json['offDay'].map((x) => x.toString()));
      }
    }

    return BarberProfileData(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      city: json['city'] ?? '',
      profilePic: json['profilePic'] ?? '',
      coverPic: json['coverPic'] ?? '',
      favoritePhotos: json['favoritePhotos'] != null
          ? List<String>.from(json['favoritePhotos'].map((x) => x.toString()))
          : [],
      userType: json['userType'] ?? '',
      status: json['status'] ?? '',
      offDay: offDay,
      barberShopLocation: json['barberShopLocation'] != null
          ? BarberShopLocation.fromJson(json['barberShopLocation'])
          : BarberShopLocation(type: 'Point', coordinates: [0, 0]),
      workingDays: workingDays,
      breakTime: json['breakTime'] != null
          ? List<BreakTime>.from(
              json['breakTime'].map((x) => BreakTime.fromJson(x)))
          : [],
      favorites: json['favorites'] != null
          ? List<dynamic>.from(json['favorites'].map((x) => x))
          : [],
      barberShop: json['barberShop'] ?? '',
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      instagramPage: json['instagramPage'] ?? '',
      locationDescription: json['locationDescription'] ?? '',
      walkIn: json['walkIn'] != null
          ? List<WalkInRecord>.from(
              json['walkIn'].map((x) => WalkInRecord.fromJson(x)))
          : null,
      hashtag: json['hashtag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'city': city,
      'status': status,
      'workingDays': workingDays.map((x) => x.toJson()).toList(),
      'barberShopLocation': barberShopLocation,
      'bankAccountNumber': bankAccountNumber,
      'barberShop': barberShop,
      'coverPic': coverPic,
      'instagramPage': instagramPage,
      'locationDescription': locationDescription,
      'offDay': offDay,
      'profilePic': profilePic,
      'breakTime': breakTime.map((x) => x.toJson()).toList(),
      if (walkIn != null) 'walkIn': walkIn!.map((x) => x.toJson()).toList(), 
      'hashtag': hashtag,
    };
  }
}

class Otp {
  final String code;
  final int expireTime;

  Otp({
    required this.code,
    required this.expireTime,
  });

  factory Otp.fromJson(Map<String, dynamic> json) {
    return Otp(
      code: json['code'],
      expireTime: json['expireTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'expireTime': expireTime,
    };
  }
}

class WorkingDay {
  final String day;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  WorkingDay({
    required this.day,
    required this.startHour,
    this.startMinute = 0,
    required this.endHour,
    this.endMinute = 0,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      day: json['day'] as String,
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int? ?? 0,
      endHour: json['endHour'] as int,
      endMinute: json['endMinute'] as int? ?? 0,
    );
  }

  // Add toJson method to ensure proper serialization
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
  }

  String get workingHours =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')} - ${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
}

class BreakTime {
  final int startDate;
  final int endDate;
  final String id;

  BreakTime({
    required this.startDate,
    required this.endDate,
    required this.id,
  });

  factory BreakTime.fromJson(Map<String, dynamic> json) {
    return BreakTime(
      startDate: json['startDate'],
      endDate: json['endDate'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      '_id': id,
    };
  }

  // Format the break time to a readable string (convert from timestamp to time)
  String get formattedBreakTime {
    final start = DateTime.fromMillisecondsSinceEpoch(startDate * 1000);
    final end = DateTime.fromMillisecondsSinceEpoch(endDate * 1000);
    return '${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted date
  String get formattedDate {
    final date = DateTime.fromMillisecondsSinceEpoch(startDate * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }
}

class WalkInRecord {
  final int startDate; // timestamp in milliseconds
  final int endDate;   // timestamp in milliseconds
  final String? id;

  WalkInRecord({
    required this.startDate,
    required this.endDate,
    this.id,
  });

  factory WalkInRecord.fromJson(Map<String, dynamic> json) {
    return WalkInRecord(
      startDate: json['startDate'] ?? 0,
      endDate: json['endDate'] ?? 0,
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      if (id != null) '_id': id,
    };
  }

  // Check if a date falls within this walk-in range
  bool containsDate(DateTime date) {
    final dateTimestamp = date.millisecondsSinceEpoch;
    return dateTimestamp >= startDate && dateTimestamp <= endDate;
  }

  // Get formatted date range
  String get formattedRange {
    final start = DateTime.fromMillisecondsSinceEpoch(startDate);
    final end = DateTime.fromMillisecondsSinceEpoch(endDate);
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }
}

