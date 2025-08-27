import 'package:onebeauty_clean/features/plan/daily_plan_service.dart';
import 'package:onebeauty_clean/features/health/health_tasks_service.dart';

class DayStats {
  final DateTime day;
  final int totalCatalog;
  final int doneCatalog;
  final int totalPlan;
  final int donePlan;

  DayStats({
    required this.day,
    required this.totalCatalog,
    required this.doneCatalog,
    required this.totalPlan,
    required this.donePlan,
  });

  int get doneAll => doneCatalog + donePlan;
  int get totalAll => totalCatalog + totalPlan;

  double get catalogRate =>
      totalCatalog == 0 ? 0.0 : doneCatalog / totalCatalog;
  double get planRate => totalPlan == 0 ? 0.0 : donePlan / totalPlan;
  double get dayRate => totalAll == 0 ? 0.0 : doneAll / totalAll;
}

class RangeStats {
  final List<DayStats> days; // старые -> новые
  final int streak; // серия дней подряд (условие ниже)
  final Map<String, int> categoryDone; // category -> сколько выполнено

  RangeStats({
    required this.days,
    required this.streak,
    required this.categoryDone,
  });
}

class HealthStatsService {
  final HealthTasksService catalog;
  final DailyPlanService plan;

  /// Условие «день засчитан» для streak: выполненных задач (каталог+план) >= goalPerDay
  final int goalPerDay;

  HealthStatsService({
    HealthTasksService? catalog,
    DailyPlanService? plan,
    this.goalPerDay = 3,
  })  : catalog = catalog ?? HealthTasksService(),
        plan = plan ?? DailyPlanService();

  // Маппинг id задач каталога -> категории (для статистики категорий)
  static const Map<String, String> _catalogCat = {
    'water': 'water',
    'steps': 'activity',
    'sleep': 'mind', // можно позже уточнить
    'stretch': 'care',
    'mind': 'mind',
  };

  Future<DayStats> dayStats(DateTime day) async {
    final catTasks = await catalog.load(day);
    final planItems = await plan.load(day);

    final totalCatalog = catTasks.length;
    final doneCatalog = catTasks.where((t) => t.done).length;

    final totalPlan = planItems.length;
    final donePlan = planItems.where((t) => t.done).length;

    return DayStats(
      day: DateTime(day.year, day.month, day.day),
      totalCatalog: totalCatalog,
      doneCatalog: doneCatalog,
      totalPlan: totalPlan,
      donePlan: donePlan,
    );
  }

  /// Статистика за [daysBack] дней (включая [endDay]).
  /// Например, endDay=сегодня, daysBack=7 -> последние 7 дней (сегодня и 6 назад).
  Future<RangeStats> rangeStats({
    required DateTime endDay,
    required int daysBack,
  }) async {
    final days = <DayStats>[];
    final categoryDone = <String, int>{};

    for (int i = daysBack - 1; i >= 0; i--) {
      final d = DateTime(
        endDay.year,
        endDay.month,
        endDay.day,
      ).subtract(Duration(days: i));

      final catTasks = await catalog.load(d);
      final planItems = await plan.load(d);

      // day stats:
      final totalCatalog = catTasks.length;
      final doneCatalog = catTasks.where((t) => t.done).length;

      final totalPlan = planItems.length;
      final donePlan = planItems.where((t) => t.done).length;

      days.add(DayStats(
        day: d,
        totalCatalog: totalCatalog,
        doneCatalog: doneCatalog,
        totalPlan: totalPlan,
        donePlan: donePlan,
      ));

      // категории: из плана — по полю category,
      for (final p in planItems) {
        if (p.done) {
          categoryDone[p.category] = (categoryDone[p.category] ?? 0) + 1;
        }
      }
      // из каталога — по ID -> категории (_catalogCat)
      for (final t in catTasks) {
        if (t.done) {
          final cat = _catalogCat[t.id];
          if (cat != null) {
            categoryDone[cat] = (categoryDone[cat] ?? 0) + 1;
          }
        }
      }
    }

    // streak: считаем от конца (сегодня -> назад), пока выполняется порог
    int streak = 0;
    for (int i = days.length - 1; i >= 0; i--) {
      final ds = days[i];
      if (ds.doneAll >= goalPerDay) {
        streak++;
      } else {
        break;
      }
    }

    return RangeStats(days: days, streak: streak, categoryDone: categoryDone);
  }
}
