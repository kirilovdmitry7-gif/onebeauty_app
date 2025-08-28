// lib/features/health/streak_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис серии (streak) c поддержкой "мягкого дня":
/// - серия растёт только когда ВСЕ задачи каталога выполнены;
/// - 1 раз в неделю можно провалить день и НЕ потерять серию (но она не вырастет);
/// - на второй провальный день в этой неделе серия сбрасывается.
class StreakService {
  static const _kStreak = 'streak_count';
  static const _kLastFull = 'streak_last_full';
  static const _kSoftWeek = 'streak_soft_week';
  static const _kSoftUsed = 'streak_soft_used';

  String _ymd(DateTime d) {
    final dd = DateTime(d.year, d.month, d.day);
    final m = dd.month.toString().padLeft(2, '0');
    final day = dd.day.toString().padLeft(2, '0');
    return '${dd.year}-$m-$day';
  }

  /// Ключ недели — дата понедельника (YYYY-MM-DD).
  String _weekKey(DateTime d) {
    final monday = DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: d.weekday - 1));
    return _ymd(monday);
  }

  Future<void> _ensureWeekKey(SharedPreferences prefs, DateTime now) async {
    final keyNow = _weekKey(now);
    final keySaved = prefs.getString(_kSoftWeek);
    if (keySaved != keyNow) {
      await prefs.setString(_kSoftWeek, keyNow);
      await prefs.setBool(
          _kSoftUsed, false); // новая неделя — мягкий день свободен
    }
  }

  DateTime? _parseYmd(String? ymd) {
    if (ymd == null || ymd.isEmpty) return null;
    final parts = ymd.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  /// Ролловер между днями — учитываем пропуски.
  Future<int> _rollover(SharedPreferences prefs, DateTime now) async {
    var s = prefs.getInt(_kStreak) ?? 0;
    final lastFullStr = prefs.getString(_kLastFull);
    final lastFull = _parseYmd(lastFullStr);
    if (lastFull == null) return s;

    final today = DateTime(now.year, now.month, now.day);
    if (_ymd(today) == _ymd(lastFull)) {
      return s; // сегодня уже полный
    }

    final gap = today.difference(lastFull).inDays;

    if (gap == 1) {
      // Вчера не было полного дня → пропуск.
      final used = prefs.getBool(_kSoftUsed) ?? false;
      if (!used) {
        await prefs.setBool(_kSoftUsed, true); // используем мягкий день
        return s; // серия сохраняется
      } else {
        // второй пропуск в этой неделе → сброс
        s = 0;
        await prefs.setInt(_kStreak, s);
        return s;
      }
    } else if (gap >= 2) {
      // Два и более дней без "полного" — сброс.
      s = 0;
      await prefs.setInt(_kStreak, s);
      return s;
    }

    return s;
  }

  /// Текущая серия (учитывает недельный ключ и пропуски).
  Future<int> getStreak(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureWeekKey(prefs, now);
    return _rollover(prefs, now);
  }

  /// Отметить сегодняшний полный день → серия +1 (один раз в день).
  Future<int> markTodayFull(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureWeekKey(prefs, now);

    var s = await _rollover(prefs, now); // учтём возможные пропуски
    final today = _ymd(now);
    final last = prefs.getString(_kLastFull);

    if (last == today) {
      return prefs.getInt(_kStreak) ?? s; // уже засчитан
    }

    s = (prefs.getInt(_kStreak) ?? s) + 1;
    await prefs.setInt(_kStreak, s);
    await prefs.setString(_kLastFull, today);
    return s;
  }

  /// День не полный: либо используем мягкий день, либо сбрасываем.
  Future<int> applySoftOrReset(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureWeekKey(prefs, now);

    var s = await _rollover(prefs, now);
    final used = prefs.getBool(_kSoftUsed) ?? false;
    if (!used) {
      await prefs.setBool(_kSoftUsed, true);
      return s; // серия сохраняется
    } else {
      s = 0;
      await prefs.setInt(_kStreak, s);
      return s;
    }
  }

  /// Публичный статус: использован ли мягкий день в текущей неделе.
  Future<bool> isSoftUsedThisWeek(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureWeekKey(prefs, now);
    return prefs.getBool(_kSoftUsed) ?? false;
  }

  /// Для дебага / сброса
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStreak);
    await prefs.remove(_kLastFull);
    await prefs.remove(_kSoftWeek);
    await prefs.remove(_kSoftUsed);
  }
}
