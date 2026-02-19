class NotificationResponse {
  final bool success;
  final String message;
  final List<NotificationModel> data;
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int limit;

  NotificationResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: List<NotificationModel>.from(
          (json['data'] ?? []).map((x) => NotificationModel.fromJson(x))),
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      limit: json['limit'] ?? 10,
    );
  }
}

class NotificationModel {
  final String id;
  final String appointmentId;
  final UserModel user;
  final String message;
  final String messageEn;
  final String messageAr;
  final String messageHe;
  final String process;
  final String processId;
  final String receiver;
  final bool sendToAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.user,
    required this.message,
    required this.process,
    required this.processId,
    required this.receiver,
    required this.sendToAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.messageEn,
    required this.messageAr,
    required this.messageHe,
    required this.appointmentId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      message: json['message'] ?? '',
      process: json['process'] ?? '',
      processId: json['process_id'] ?? '',
      receiver: json['receiver'] ?? '',
      sendToAdmin: json['sendToAdmin'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      messageEn: json['messageEn'] ?? '',
      messageAr: json['messageAr'] ?? '',
      messageHe: json['messageHe'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String profilePic;
  final String? userType;

  UserModel({
    required this.id,
    required this.fullName,
    required this.profilePic,
    this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePic: json['profilePic'] ?? '',
      userType: json['userType'],
    );
  }
}
