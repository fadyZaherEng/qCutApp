class MonthlyBooking {
  final String month;
  final int totalBookings;

  MonthlyBooking({
    required this.month,
    required this.totalBookings,
  });

  factory MonthlyBooking.fromJson(Map<String, dynamic> json) {
    return MonthlyBooking(
      month: json['month'] as String,
      totalBookings: json['totalBookings'] as int,
    );
  }
}

class MonthlyStats {
  final List<MonthlyBooking> bookings;

  MonthlyStats({
    required this.bookings,
  });

  factory MonthlyStats.fromJson(List<dynamic> json) {
    List<MonthlyBooking> bookingsList = [];
    for (var item in json) {
      if (item is Map<String, dynamic>) {
        bookingsList.add(MonthlyBooking.fromJson(item));
      }
    }
    return MonthlyStats(bookings: bookingsList);
  }

  factory MonthlyStats.empty() {
    return MonthlyStats(bookings: []);
  }

  // Helper method to get booking count for a specific month (by name)
  int getBookingsByMonth(String monthName) {
    final booking = bookings.firstWhere(
      (element) => element.month.toLowerCase() == monthName.toLowerCase(),
      orElse: () => MonthlyBooking(month: monthName, totalBookings: 0),
    );
    return booking.totalBookings;
  }

  // Helper method to get booking count by month index (0-11)
  int getBookingsByMonthIndex(int monthIndex) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    if (monthIndex < 0 || monthIndex >= months.length) {
      return 0;
    }

    return getBookingsByMonth(months[monthIndex]);
  }

  // Get maximum booking count for scale calculation
  int get maxBookings {
    if (bookings.isEmpty) return 10; // Default value if no data

    int max = 0;
    for (var booking in bookings) {
      if (booking.totalBookings > max) {
        max = booking.totalBookings;
      }
    }
    return max > 0 ? max : 10; // Ensure non-zero value
  }
}
