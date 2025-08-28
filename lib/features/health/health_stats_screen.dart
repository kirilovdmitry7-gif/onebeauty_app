import 'package:flutter/material.dart';
import '../../l10n/gen/app_localizations.dart';
import 'health_tasks_service.dart';

class HealthStatsScreen extends StatefulWidget {
  const HealthStatsScreen({super.key});

  @override
  State<HealthStatsScreen> createState() => _HealthStatsScreenState();
}

class _HealthStatsScreenState extends State<HealthStatsScreen> {
  final _service = HealthTasksService();
  bool _loading = true;

  int _todayDone = 0;
  int _todayTotal = 0;

  int _yesterdayDone = 0;
  int _yesterdayTotal = 0;

  int _weekDone = 0;
  int _weekTotal = 0;

  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _load() async {
    setState(() => _loading = true);

    final today = _dayOnly(DateTime.now());

    Future<List<HealthTask>> loadDay(DateTime d) => _service.load(d);

    // Сегодня
    final t0 = await loadDay(today);
    final td = t0.where((t) => t.done).length;
    final tt = t0.length;

    // Вчера
    final yDate = today.subtract(const Duration(days: 1));
    final t1 = await loadDay(yDate);
    final yd = t1.where((t) => t.done).length;
    final yt = t1.length;

    // Последние 7 дней + streak
    int wd = 0, wt = 0;
    int streak = 0;
    bool counting = true;
    for (int i = 0; i < 7; i++) {
      final d = today.subtract(Duration(days: i));
      final items = await loadDay(d);
      final done = items.where((t) => t.done).length;
      final total = items.length;
      wd += done;
      wt += total;

      if (counting) {
        final full = total > 0 && done == total;
        if (full) {
          streak += 1;
        } else {
          counting = false;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _todayDone = td;
      _todayTotal = tt;
      _yesterdayDone = yd;
      _yesterdayTotal = yt;
      _weekDone = wd;
      _weekTotal = wt;
      _streak = streak;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.statsTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _StatCard(
                title: loc.statsToday,
                done: _todayDone,
                total: _todayTotal,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: loc.statsYesterday,
                done: _yesterdayDone,
                total: _yesterdayTotal,
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.stats7days,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(loc.healthProgress(_weekDone, _weekTotal)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: _weekTotal == 0 ? 0.0 : _weekDone / _weekTotal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(loc.streakTitle,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(loc.streakDays(_streak)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int done;
  final int total;

  const _StatCard({
    required this.title,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final loc = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(loc.healthProgress(done, total)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
