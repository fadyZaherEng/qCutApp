class CollectionSchedule {
  final String id;
  final String dayOfWeek;
  final int startTime;
  final int endTime;
  final bool isActive;

  CollectionSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory CollectionSchedule.fromJson(Map<String, dynamic> json) {
    return CollectionSchedule(
      id: json['_id'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      isActive: json['isActive'] ?? false,
    );
  }
}

class CollectionScheduleResponse {
  final bool success;
  final List<CollectionSchedule> data;

  CollectionScheduleResponse({
    required this.success,
    required this.data,
  });

  factory CollectionScheduleResponse.fromJson(Map<String, dynamic> json) {
    return CollectionScheduleResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => CollectionSchedule.fromJson(e))
              .toList() ??
          [],
    );
  }
}
