import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const _kLastFull = 'streak.lastFullDate';
  static const _kCount = 'streak.count';

  String _fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  DateTime _yesterday(DateTime today) =>
      today.subtract(const Duration(days: 1));

  Future<int> getStreak(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_kLastFull);
    final count = prefs.getInt(_kCount) ?? 0;
    if (last == null) return 0;

    final todayStr = _fmt(now);
    final yestStr = _fmt(_yesterday(now));

    if (last == todayStr || last == yestStr) {
      return count;
    }
    // Пропуск дня — сбросим к 0 (и сохраним)
    await prefs.setInt(_kCount, 0);
    return 0;
  }

  /// Вызывай, когда сегодня впервые достигнут done == total > 0
  Future<int> markTodayFull(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _fmt(now);
    final yestStr = _fmt(_yesterday(now));
    final last = prefs.getString(_kLastFull);
    var count = prefs.getInt(_kCount) ?? 0;

    if (last == todayStr) {
      // уже считали сегодня
      return count;
    } else if (last == yestStr) {
      count += 1;
    } else {
      count = 1;
    }

    await prefs.setString(_kLastFull, todayStr);
    await prefs.setInt(_kCount, count);
    return count;
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastFull);
    await prefs.remove(_kCount);
  }
}
