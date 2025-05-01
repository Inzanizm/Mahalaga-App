import 'package:flutter/material.dart';

bool isOpenNow(Map<String, dynamic> place) {
  final now = DateTime.now();
  final today = now.weekday; // 1 = Monday, 7 = Sunday

  final openDays = (place['open_days'] ?? []) as List;
  if (!openDays.contains(today)) return false;

  final openTimeStr = place['open_time']; // e.g., "09:00"
  final closeTimeStr = place['close_time']; // e.g., "18:00"

  if (openTimeStr == null || closeTimeStr == null) return false;

  final openTime = TimeOfDay(
    hour: int.parse(openTimeStr.split(":")[0]),
    minute: int.parse(openTimeStr.split(":")[1]),
  );

  final closeTime = TimeOfDay(
    hour: int.parse(closeTimeStr.split(":")[0]),
    minute: int.parse(closeTimeStr.split(":")[1]),
  );

  final nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

  return _isTimeInRange(nowTime, openTime, closeTime);
}

bool _isTimeInRange(TimeOfDay now, TimeOfDay start, TimeOfDay end) {
  final nowMinutes = now.hour * 60 + now.minute;
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;

  return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
}
