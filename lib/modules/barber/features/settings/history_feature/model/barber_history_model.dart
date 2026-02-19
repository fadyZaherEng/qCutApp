import 'package:intl/intl.dart';

class BarberHistoryResponse {
  final bool success;
  final List<BarberHistory> history;

  BarberHistoryResponse({
    required this.success,
    required this.history,
  });

  factory BarberHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BarberHistoryResponse(
      success: json['success'] ?? false,
      history: (json['history'] as List)
          .map((item) => BarberHistory.fromJson(item))
          .toList(),
    );
  }
}

class BarberHistory {
  final String id;
  final String barber;
  final UserInfo user;
  final String userName;
  final List<ServiceInfo> services;
  final double price;
  final int duration;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final String paymentMethod;
  final double priceAfterTax;

  BarberHistory({
    required this.id,
    required this.barber,
    required this.user,
    required this.userName,
    required this.services,
    required this.price,
    required this.duration,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.paymentMethod,
    required this.priceAfterTax,
  });

  factory BarberHistory.fromJson(Map<String, dynamic> json) {
    return BarberHistory(
      id: json['_id'] ?? '',
      barber: json['barber'] ?? '',
      user: UserInfo.fromJson(json['user'] ?? {}),
      userName: json['userName'] ?? '',
      services: (json['service'] as List)
          .map((item) => ServiceInfo.fromJson(item))
          .toList(),
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      paymentMethod: json['paymentMethod'] ?? '',
      priceAfterTax: (json['priceAfterTax'] ?? 0).toDouble(),
    );
  }

  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(startDate);
  }

  String get formattedTime {
    final start = DateFormat('h:mm a').format(startDate);
    final end = DateFormat('h:mm a').format(endDate);
    return '$start - $end';
  }

  String get formattedDay {
    return DateFormat('E d/M/yyyy').format(startDate);
  }

  // Get total number of users
  int get totalUsers {
    return services.fold(0, (sum, service) => sum + service.numberOfUsers);
  }

  // Get all service names
  String get serviceNames {
    return services.map((s) => s.service.name).join(', ');
  }
}

class UserInfo {
  final String id;
  final String fullName;
  final String profilePic;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.profilePic,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePic: json['profilePic'] ?? '',
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
    var serviceData = json['service'];
    Map<String, dynamic> serviceMap = {};
    if (serviceData is List && serviceData.isNotEmpty) {
      serviceMap = serviceData.first;
    } else if (serviceData is Map<String, dynamic>) {
      serviceMap = serviceData;
    }

    return ServiceInfo(
      service: ServiceDetails.fromJson(serviceMap),
      numberOfUsers: json['numberOfUsers'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      id: json['_id'] ?? '',
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
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
