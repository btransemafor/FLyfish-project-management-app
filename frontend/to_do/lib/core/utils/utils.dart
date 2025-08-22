// lib/core/utils/utils.dart
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    // final formatter = DateFormat('MMM d, yyyy'); // e.g., "Jul 28, 2025"
    final formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }

  static String formatDate2(DateTime? date) {
    if (date == null) {
      return '';
    }
    final formatter = DateFormat('dd MMM yyyy'); // chỉ cần 4 chữ M
    return formatter.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';

    // Chuyển sang múi giờ Việt Nam (UTC+7)
    final vietnamTime = date.toUtc().add(const Duration(hours: 7));

    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(vietnamTime);
  }

  static List<Map<String, Color>> priority_color = [
    {'Low': Color(0xFF81C784)}, // Xanh lá nhạt - dịu nhẹ
    {'Medium': Color(0xFFFFF176)}, // Vàng - trung bình, cảnh báo nhẹ
    {'High': Color(0xFFFFB74D)}, // Cam - cấp cao
    {'Urgent': Color(0xFFE57373)}, // Đỏ nhạt - khẩn cấp
  ];

  static const mappingColors = {
    'Low': Color.fromARGB(255, 199, 241, 201),
    'Medium': Color.fromARGB(255, 226, 206, 29),
    'High': Color.fromARGB(255, 246, 220, 181),
    'Urgent': Color(0xFFE57373)
  };

  static const mappingColorsBorder = {
    'Low': Color.fromARGB(255, 106, 213, 111),
    'Medium': Color.fromARGB(255, 216, 198, 33),
    'High': Color.fromARGB(255, 223, 147, 33),
    'Urgent': Color.fromARGB(255, 200, 33, 33)
  };

  static const mappingStatusColors = {
    'Not Started': Color.fromARGB(255, 255, 254, 254), // Gray - Trung tính
    'In Progress':
        Color.fromARGB(255, 253, 236, 187), // Amber - Nổi bật, năng động
    'Needs Review':
        Color.fromARGB(255, 253, 204, 189), // Deep Orange - Cảnh báo nhẹ
    'Completed':
        Color.fromARGB(255, 186, 249, 188), // Green - Thành công, hoàn thành
  };

  DateTime getCurrentDatetime() {
    DateTime currentDate = DateTime.now();
    return currentDate;
  }

  static String getTime(DateTime? time) {
    if (time == null) return '';

    // Add 7 hours to align with Vietnam timezone
    final vietnamTime = time.toUtc().add(const Duration(hours: 7));
    final formatterTime = DateFormat('HH:mm');
    return formatterTime.format(vietnamTime);
  }

  static Color randomColor() {
    final List<Color> colors = [
      Colors.blueAccent.shade200,
      const Color.fromARGB(255, 134, 7, 7),
      const Color.fromARGB(255, 9, 73, 42),
      const Color.fromARGB(255, 131, 85, 16),
    ];
    final Random random = Random();
    return colors[random.nextInt(colors.length)];
  }

  static bool isOverdue(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime target = DateTime(date.year, date.month, date.day);

    return target.isBefore(today);
  }
}
