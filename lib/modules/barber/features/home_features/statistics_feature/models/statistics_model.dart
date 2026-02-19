class BarberStats {
  final int totalAppointments;
  final double totalIncome;
  final double workingHours;
  final int newConsumers;
  final int returningConsumers;
  final int notComeTotal;

  BarberStats({
    required this.totalAppointments,
    required this.totalIncome,
    required this.workingHours,
    required this.newConsumers,
    required this.returningConsumers,
    required this.notComeTotal,
  });

  factory BarberStats.fromJson(Map<String, dynamic> json) {
    double hours = (json['workingHours'] ?? 0).toDouble();
    // Convert milliseconds to hours if value is large
    if (hours > 10000) {
      hours = hours / (1000 * 60 * 60);
    }
    return BarberStats(
      totalAppointments: json['totalAppointments'] ?? 0,
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      workingHours: hours,
      newConsumers: json['newConsumers'] ?? 0,
      returningConsumers: json['returningConsumers'] ?? 0,
      notComeTotal: (json['notComeTotal'] ?? 0).toInt(),
    );
  }

  factory BarberStats.empty() {
    return BarberStats(
      totalAppointments: 0,
      totalIncome: 0,
      workingHours: 0,
      newConsumers: 0,
      returningConsumers: 0,
      notComeTotal: 0,
    );
  }
}
