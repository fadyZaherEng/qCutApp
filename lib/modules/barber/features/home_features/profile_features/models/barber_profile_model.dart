import '../profile_display/models/barber_profile_model.dart';

class BarberProfileModel {
  final String fullName;
  final List<String> offDay;
  final String barberShop;
  final String bankAccountNumber;
  final String instagramPage;
  final String phoneNumber;
  final String profilePic;
  final String coverPic;
  final String city;
  final List<WorkingDay> workingDays;
  final String locationDescription;
  final BarberShopLocation barberShopLocation;

  BarberProfileModel({
    required this.fullName,
    required this.offDay,
    required this.barberShop,
    required this.bankAccountNumber,
    required this.instagramPage,
    required this.profilePic,
    required this.coverPic,
    required this.city,
    required this.workingDays,
    required this.locationDescription,
    required this.barberShopLocation,
    required this.phoneNumber,
  });

  factory BarberProfileModel.fromJson(Map<String, dynamic> json) {
    return BarberProfileModel(
      fullName: json['fullName'] ?? '',
      offDay: List<String>.from(json['offDay'] ?? []),
      barberShop: json['barberShop'] ?? '',
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      instagramPage: json['instagramPage'] ?? '',
      profilePic: json['profilePic'] ?? '',
      coverPic: json['coverPic'] ?? '',
      city: json['city'] ?? '',
      workingDays: (json['workingDays'] as List<dynamic>?)
              ?.map((e) => WorkingDay.fromJson(e))
              .toList() ??
          [],
      barberShopLocation:
          BarberShopLocation.fromJson(json['barberShopLocation'] ?? {}),
      locationDescription: json['locationDescription'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}

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
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [],
    );
  }
}
