class CustomerAppointmentResponse {
  final List<CustomerAppointment> appointments;

  CustomerAppointmentResponse({required this.appointments});

  factory CustomerAppointmentResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CustomerAppointmentResponse(appointments: []);
    var appointmentsData = json['data'];
    List<CustomerAppointment> appointmentsList = [];

    if (appointmentsData is List) {
      appointmentsList = appointmentsData
          .map((item) => CustomerAppointment.fromJson(item))
          .toList();
    }

    return CustomerAppointmentResponse(appointments: appointmentsList);
  }
}

class CustomerAppointment {
  final String id;
  final BarberInfo barber;
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

  CustomerAppointment({
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
  });

  factory CustomerAppointment.fromJson(dynamic json) {
    if (json == null || json is! Map) {
      return CustomerAppointment(
        id: "",
        barber: BarberInfo.fromJson(null),
        user: UserInfo.fromJson(null),
        userName: "",
        services: [],
        price: 0.0,
        duration: 0,
        status: "pending",
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        createdAt: DateTime.now(),
        paymentMethod: "cash",
      );
    }

    // Flexible user handling
    dynamic userRaw = json['user'];
    UserInfo userInfo;
    if (userRaw is String) {
      userInfo = UserInfo(
          id: userRaw, fullName: json['userName'] ?? "", phoneNumber: "");
    } else {
      userInfo = UserInfo.fromJson(userRaw);
    }

    var serviceListRaw = json['service'];
    List<ServiceInfo> serviceList = [];
    if (serviceListRaw is List) {
      serviceList = serviceListRaw
          .map((item) => ServiceInfo.fromJson(item))
          .toList();
    }

    return CustomerAppointment(
      id: json['_id'] ?? "",
      barber: BarberInfo.fromJson(json['barber']),
      user: userInfo,
      userName: json['userName'] ?? "",
      services: serviceList,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      duration: json['duration'] ?? 0,
      status: json['status'] ?? "pending",
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      createdAt: _parseDate(json['createdAt']),
      paymentMethod: json['paymentMethod'] ?? "cash",
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is int) {
      // Handle milliseconds timestamp
      return DateTime.fromMillisecondsSinceEpoch(
          dateValue > 9999999999 ? dateValue : dateValue * 1000);
    } else if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  String get formattedDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedTime {
    final start =
        '${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}';
    final end = '${endDate.hour}:${endDate.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  String get totalConsumers {
    int total = 0;
    for (var service in services) {
      total += service.numberOfUsers;
    }
    return '$total consumer${total > 1 ? 's' : ''}';
  }

  String get serviceName {
    return services.isNotEmpty ? services.first.serviceName : "N/A";
  }
}

class UserInfo {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? profilePic;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.profilePic,
  });

  factory UserInfo.fromJson(dynamic json) {
    if (json == null) {
      return UserInfo(id: "", fullName: "", phoneNumber: "");
    }
    if (json is String) {
      return UserInfo(id: json, fullName: "", phoneNumber: "");
    }
    if (json is Map) {
      return UserInfo(
        id: json['_id'] ?? '',
        fullName: json['fullName'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        profilePic: json['profilePic'],
      );
    }
    return UserInfo(id: "", fullName: "", phoneNumber: "");
  }
}

class BarberInfo {
  final String id;
  final String fullName;
  final String userType;
  final String city;
  final String? barberShop;
  final String? profilePic;
  final String? coverPic;
  final List<double>? locationCoordinates;

  BarberInfo({
    required this.id,
    required this.fullName,
    required this.userType,
    required this.city,
    this.barberShop,
    this.profilePic,
    this.coverPic,
    this.locationCoordinates,
  });

  factory BarberInfo.fromJson(dynamic json) {
    if (json == null || json is! Map) {
      return BarberInfo(
          id: "", fullName: "", userType: "barber", city: "", barberShop: null);
    }
    List<double>? coords;
    var location = json['barberShopLocation'];
    if (location != null) {
      if (location is Map && location['coordinates'] != null) {
        coords = List<double>.from(
            location['coordinates'].map((x) => (x as num).toDouble()));
      } else if (location is List && location.isNotEmpty) {
        var loc = location[0];
        if (loc is Map && loc['coordinates'] != null) {
          coords = List<double>.from(
              loc['coordinates'].map((x) => (x as num).toDouble()));
        }
      }
    }

    return BarberInfo(
      id: json['_id'] ?? "",
      fullName: json['fullName'] ?? "",
      userType: json['userType'] ?? "barber",
      city: json['city'] ?? "",
      barberShop: json['barberShop'],
      profilePic: json['profilePic'],
      coverPic: json['coverPic'],
      locationCoordinates: coords,
    );
  }
}

class ServiceInfo {
  final String serviceId;
  final int numberOfUsers;
  final double price;
  final String serviceName;

  ServiceInfo({
    required this.serviceId,
    required this.numberOfUsers,
    required this.price,
    this.serviceName = "Hair style",
  });

  factory ServiceInfo.fromJson(dynamic json) {
    if (json == null || json is! Map) {
      return ServiceInfo(serviceId: "", numberOfUsers: 1, price: 0.0);
    }
    return ServiceInfo(
      serviceId: json['service'] ?? json['_id'] ?? "",
      numberOfUsers: json['numberOfUsers'] ?? 1,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': serviceId,
      'numberOfUsers': numberOfUsers,
      'price': price,
    };
  }
}
