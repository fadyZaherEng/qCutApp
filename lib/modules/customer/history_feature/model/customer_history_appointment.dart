class CustomerHistoryAppointment {
  final String id;
  final BarberInfo barber;
  final String userId;
  final String userName;
  final List<ServiceInfo> services;
  final double price;
  final int duration;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final String paymentMethod;

  CustomerHistoryAppointment({
    required this.id,
    required this.barber,
    required this.userId,
    required this.userName,
    required this.services,
    required this.price,
    required this.duration,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.paymentMethod,
  });

  factory CustomerHistoryAppointment.fromJson(Map<String, dynamic> json) {
    return CustomerHistoryAppointment(
      id: json['_id'] ?? "",
      barber: BarberInfo.fromJson(json['barber'] ?? {}),
      userId: json['user'] ?? "",
      userName: json['userName'] ?? "",
      services: (json['service'] as List?)
              ?.map((service) => ServiceInfo.fromJson(service))
              .toList() ??
          [],
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      status: json['status'] ?? "",
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      paymentMethod: json['paymentMethod'] ?? "",
    );
  }
}

class BarberInfo {
  final String id;
  final String fullName;
  final String userType;
  final String barberShop;
  final String profilePic;

  BarberInfo({
    required this.id,
    required this.fullName,
    required this.userType,
    required this.barberShop,
    required this.profilePic,
  });

  factory BarberInfo.fromJson(Map<String, dynamic> json) {
    return BarberInfo(
      id: json['_id'] ?? "",
      fullName: json['fullName'] ?? "",
      userType: json['userType'] ?? "",
      barberShop: json['barberShop'] ?? json['fullName'] ?? "",
      profilePic: json['profilePic'] ?? "",
    );
  }
}

class ServiceInfo {
  final ServiceDetails service;
  final int numberOfUsers;
  final double price;
  final String id;

  ServiceInfo({
    required this.service,
    required this.numberOfUsers,
    required this.price,
    required this.id,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      service: ServiceDetails.fromJson(json['service'] ?? {}),
      numberOfUsers: json['numberOfUsers'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      id: json['_id'] ?? "",
    );
  }
}

class ServiceDetails {
  final String id;
  final String name;
  final double price;

  ServiceDetails({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
