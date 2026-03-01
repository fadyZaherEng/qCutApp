class BarberServiceResponse {
  final String message;
  final List<BarberServices> services;

  BarberServiceResponse({required this.message, required this.services});

  factory BarberServiceResponse.fromJson(Map<String, dynamic> json) {
    final servicesList = json['services'] ?? json['service'] ?? [];
    return BarberServiceResponse(
      message: json['message'] ?? '',
      services: (servicesList as List)
          .map((service) => BarberServices.fromJson(service))
          .toList(),
    );
  }
}

class BarberServices {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final int minTime;
  final int maxTime;
  final int? duration;
  final String barber;

  BarberServices({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.minTime,
    required this.maxTime,
    this.duration,
    required this.barber,
  });

  factory BarberServices.fromJson(Map<String, dynamic> json) {
    return BarberServices(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: json['price'] ?? 0,
      minTime: json['minTime'] ?? 0,
      maxTime: json['maxTime'] ?? 0,
      duration: json['duration'],
      barber: json['barber'] is Map
          ? json['barber']['_id'] ?? ''
          : json['barber'] ?? '',
    );
  }

  int getDisplayDuration() {
    // if (duration != null) {
    //   return duration!;
    // }
    return minTime ~/ 60000;
  }
}
