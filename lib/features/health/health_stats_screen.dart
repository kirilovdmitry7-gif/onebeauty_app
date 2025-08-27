import 'package:flutter/material.dart';
import 'health_stats_service.dart';

class HealthStatsScreen extends StatefulWidget {
  const HealthStatsScreen({super.key});

  @override
  State<HealthStatsScreen> createState() => _HealthStatsScreenState();
}

class _HealthStatsScreenState extends State<HealthStatsScreen> {
  final _stats = HealthStatsService();
  bool _loading = true;

  DayStats? _today;
  DayStats? _yesterday;
  RangeStats? _week; // последние 7 дней

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest = today.subtract(const Duration(days: 1));

    final sToday = await _stats.dayStats(today);
    final sYesterday = await _stats.dayStats(yest);
    final sWeek = await _stats.rangeStats(endDay: today, daysBack: 7);

    if (!mounted) return;
    setState(() {
      _today = sToday;
      _yesterday = sYesterday;
      _week = sWeek;
      _loading = false;
    });
  }

  Widget _kpiCard(String title, String value, {String? sub}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                )),
            if (sub != null) ...[
              const SizedBox(height: 4),
              Text(sub, style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeline7() {
    final week = _week;
    if (week == null) return const SizedBox.shrink();

    // 7 капсул: серые (0%), полузаливка (0<rate<1), зелёные (100%)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final d in week.days)
          Tooltip(
            message:
                '${d.day.day}.${d.day.month.toString().padLeft(2, "0")}: ${d.doneAll}/${d.totalAll}',
            child: Container(
              width: 28,
              height: 12,
              decoration: BoxDecoration(
                color: d.dayRate >= 1.0
                    ? Colors.green
                    : (d.dayRate > 0.0 ? Colors.orange : Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          )
      ],
    );
  }

  List<MapEntry<String, int>> _topCategories(int n) {
    final m = _week?.categoryDone ?? {};
    final entries = m.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.length > n) return entries.sublist(0, n);
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    final yesterday = _yesterday;
    final week = _week;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              // KPIs
              Row(
                children: [
                  _kpiCard(
                    'Сегодня',
                    '${today?.doneAll ?? 0} из ${today?.totalAll ?? 0}',
                    sub:
                        'Каталог: ${today?.doneCatalog ?? 0}/${today?.totalCatalog ?? 0}, План: ${today?.donePlan ?? 0}/${today?.totalPlan ?? 0}',
                  ),
                  const SizedBox(width: 12),
                  _kpiCard(
                    'Вчера',
                    '${yesterday?.doneAll ?? 0} из ${yesterday?.totalAll ?? 0}',
                    sub:
                        'Каталог: ${yesterday?.doneCatalog ?? 0}/${yesterday?.totalCatalog ?? 0}, План: ${yesterday?.donePlan ?? 0}/${yesterday?.totalPlan ?? 0}',
                  ),
                  const SizedBox(width: 12),
                  _kpiCard(
                    '7 дней',
                    '${week?.days.fold<int>(0, (a, d) => a + d.doneAll) ?? 0}'
                        ' из ${week?.days.fold<int>(0, (a, d) => a + d.totalAll) ?? 0}',
                    sub: 'Серия: 🔥 ${week?.streak ?? 0}',
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text('Последние 7 дней',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _timeline7(),

              const SizedBox(height: 16),
              const Text('Топ-категории',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _topCategories(3).map((e) {
                  return Chip(
                    label: Text('${e.key} · ${e.value}'),
                    backgroundColor: Colors.black.withOpacity(0.06),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
