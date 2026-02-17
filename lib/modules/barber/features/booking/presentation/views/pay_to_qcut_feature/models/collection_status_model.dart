class CollectionStatusModel {
  final String id;
  final String barber;
  final int weekStartDate;
  final double amountToPay;
  final String selectedDay;
  final int selectedStartTime;
  final int selectedEndTime;
  final String status;

  CollectionStatusModel({
    required this.id,
    required this.barber,
    required this.weekStartDate,
    required this.amountToPay,
    required this.selectedDay,
    required this.selectedStartTime,
    required this.selectedEndTime,
    required this.status,
  });

  factory CollectionStatusModel.fromJson(Map<String, dynamic> json) {
    return CollectionStatusModel(
      id: json['_id'] ?? '',
      barber: json['barber'] ?? '',
      weekStartDate: json['weekStartDate'] ?? 0,
      amountToPay: (json['amountToPay'] ?? 0).toDouble(),
      selectedDay: json['selectedDay'] ?? '',
      selectedStartTime: json['selectedStartTime'] ?? 0,
      selectedEndTime: json['selectedEndTime'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class CollectionStatusResponse {
  final bool success;
  final CollectionStatusModel? data;

  CollectionStatusResponse({
    required this.success,
    this.data,
  });

  factory CollectionStatusResponse.fromJson(Map<String, dynamic> json) {
    return CollectionStatusResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? CollectionStatusModel.fromJson(json['data']) : null,
    );
  }
}
