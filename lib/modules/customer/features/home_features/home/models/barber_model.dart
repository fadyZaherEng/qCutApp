import 'package:q_cut/modules/barber/features/home_features/profile_features/profile_display/models/barber_profile_model.dart';

class BarbersResponse {
  final int page;
  final int limit;
  final int totalBarbers;
  final int totalPages;
  final List<Barber> barbers;

  BarbersResponse({
    required this.page,
    required this.limit,
    required this.totalBarbers,
    required this.totalPages,
    required this.barbers,
  });

  factory BarbersResponse.fromJson(Map<String, dynamic> json) {
    return BarbersResponse(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalBarbers: json['totalBarbers'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      barbers: List<Barber>.from(
          (json['barbers'] ?? []).map((x) => Barber.fromJson(x))),
    );
  }
}

class Barber {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String userType;
  final String city;
  final String status;
  final String? barberShop;
  final String? profilePic;
  final String? coverPic;
  final String? instagramPage;
  final List<String> offDay;
  final List<WorkingDay> workingDays;
  final String? locationDescription;
  final BarberShopLocation? barberShopLocation; // ✅ أضفنا اللوكيشن
  bool isFavorite;

  Barber({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.userType,
    required this.city,
    required this.isFavorite,
    required this.status,
    this.barberShop,
    this.profilePic,
    this.coverPic,
    required this.instagramPage,
    required this.offDay,
    required this.workingDays,
    this.locationDescription,
    this.barberShopLocation,
  });

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? '',
      city: json['city'] ?? '',
      status: json['status'] ?? '',
      barberShop: json['barberShop'],
      profilePic: json['profilePic'],
      coverPic: json['coverPic'],
      instagramPage: json['instagramPage'],
      isFavorite: json['isFavorite'] ?? false,
      offDay: (json['offDay'] is List)
          ? List<String>.from(json['offDay'])
          : <String>[],
      workingDays: (json['workingDays'] is List)
          ? List<WorkingDay>.from(
              json['workingDays'].map((x) => WorkingDay.fromJson(x)))
          : <WorkingDay>[],
      barberShopLocation: json['barberShopLocation'] != null
          ? (json['barberShopLocation'] is List &&
                  json['barberShopLocation'].isNotEmpty)
              ? BarberShopLocation.fromJson(json['barberShopLocation'][0])
              : (json['barberShopLocation'] is Map<String, dynamic>)
                  ? BarberShopLocation.fromJson(json['barberShopLocation'])
                  : null
          : null,
      locationDescription: json['locationDescription'],
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
      'barberShop': barberShop,
      'profilePic': profilePic,
      'coverPic': coverPic,
      'instagramPage': instagramPage,
      'isFavorite': isFavorite,
      'offDay': offDay,
      'workingDays': workingDays.map((x) => x.toJson()).toList(),
      'locationDescription': locationDescription,
      'barberShopLocation': barberShopLocation?.toJson(), // ✅
    };
  }
}

/// ✅ كلاس جديد للوكيشن
class BarberShopLocation {
  final String type;
  final List<double> coordinates;

  BarberShopLocation({
    required this.type,
    required this.coordinates,
  });

  factory BarberShopLocation.fromJson(Map<String, dynamic> json) {
    return BarberShopLocation(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] as List)
          .map((c) => (c as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double? get latitude => coordinates.length == 2 ? coordinates[1] : null;

  double? get longitude => coordinates.length == 2 ? coordinates[0] : null;
}
