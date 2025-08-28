import 'package:shared_preferences/shared_preferences.dart';
import 'dev_flags.dart';

class DevSettingsService {
  static const _kAiEnabled = 'dev.aiEnabled';
  static const _kAdviceUseApi = 'dev.advice.useApi.override';
  static const _kAdviceShowBadge = 'dev.advice.showBadge.override';
  static const _kAiFilterToday = 'dev.ai.filterToday.override';

  /// Загружаем флаги из SharedPreferences в DevFlags.
  static Future<void> load() async {
    final sp = await SharedPreferences.getInstance();

    DevFlags.aiEnabled = sp.getBool(_kAiEnabled) ?? DevFlags.aiEnabled;

    DevFlags.adviceUseApiOverride =
        sp.containsKey(_kAdviceUseApi) ? sp.getBool(_kAdviceUseApi) : null;

    DevFlags.adviceShowBadgeOverride = sp.containsKey(_kAdviceShowBadge)
        ? sp.getBool(_kAdviceShowBadge)
        : null;

    DevFlags.aiFilterTodayOverride =
        sp.containsKey(_kAiFilterToday) ? sp.getBool(_kAiFilterToday) : null;
  }

  static Future<void> setAiEnabled(bool v) async {
    final sp = await SharedPreferences.getInstance();
    DevFlags.aiEnabled = v;
    await sp.setBool(_kAiEnabled, v);
  }

  static Future<void> setAdviceUseApiOverride(bool? v) async {
    final sp = await SharedPreferences.getInstance();
    DevFlags.adviceUseApiOverride = v;
    if (v == null) {
      await sp.remove(_kAdviceUseApi);
    } else {
      await sp.setBool(_kAdviceUseApi, v);
    }
  }

  static Future<void> setAdviceShowBadgeOverride(bool? v) async {
    final sp = await SharedPreferences.getInstance();
    DevFlags.adviceShowBadgeOverride = v;
    if (v == null) {
      await sp.remove(_kAdviceShowBadge);
    } else {
      await sp.setBool(_kAdviceShowBadge, v);
    }
  }

  static Future<void> setAiFilterTodayOverride(bool? v) async {
    final sp = await SharedPreferences.getInstance();
    DevFlags.aiFilterTodayOverride = v;
    if (v == null) {
      await sp.remove(_kAiFilterToday);
    } else {
      await sp.setBool(_kAiFilterToday, v);
    }
  }

  /// Сбросить все оверрайды к значениям по конфигу.
  static Future<void> resetOverrides() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kAdviceUseApi);
    await sp.remove(_kAdviceShowBadge);
    await sp.remove(_kAiFilterToday);

    DevFlags.adviceUseApiOverride = null;
    DevFlags.adviceShowBadgeOverride = null;
    DevFlags.aiFilterTodayOverride = null;
  }
}
