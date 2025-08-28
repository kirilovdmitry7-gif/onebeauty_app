import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:onebeauty_clean/core/ai/ai_client.dart';
import 'package:onebeauty_clean/features/advice/ai_advice.dart';
import 'package:onebeauty_clean/features/advice/widgets/advice_card.dart';

import 'package:onebeauty_clean/core/config/app_config.dart'; // ← добавили

import '../../l10n/gen/app_localizations.dart';
import '../ai/ai_task_generator.dart';
import '../plan/daily_plan_service.dart';
import '../profile/survey_screen.dart';
import '../profile/user_profile_service.dart';
import 'health_stats_screen.dart' as stats; // алиас
import 'health_tasks_service.dart';
import 'streak_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  // Каталог привычек
  final _service = HealthTasksService();
  bool _loading = true;
  List<HealthTask> _tasks = const [];

  // План ИИ
  final _planSvc = DailyPlanService();
  bool _planLoading = true;
  List<DailyPlanItem> _plan = const [];

  // Профиль + генератор задач
  final _profileSvc = UserProfileService();
  final AiTaskGenerator _ai = ApiAiTaskGenerator(AiClient());

  // Клиент к прокси (пинг)
  final AiClient _aiClient = AiClient();

  // Простой streak
  final StreakService _streakSvc = StreakService();
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadToday(), _loadPlanToday()]);
  }

  Future<void> _loadToday() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final tasks = await _service.load(now);

    // пересчёт прогресса и обновление streak
    final doneNow = tasks.where((t) => t.done).length;
    final totalNow = tasks.length;
    if (totalNow > 0 && doneNow == totalNow) {
      await _streakSvc.markTodayFull(now);
    }
    final s = await _streakSvc.getStreak(now);

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _streak = s;
      _loading = false;
    });
  }

  Future<void> _loadPlanToday() async {
    setState(() => _planLoading = true);
    final plan = await _planSvc.load(DateTime.now());
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _planLoading = false;
    });
  }

  Future<void> _resetToday() async {
    await _service.resetAll(DateTime.now());
    await _loadToday();
  }

  Future<void> _toggleTask(int index, bool value) async {
    final t = _tasks[index];
    setState(() {
      _tasks = [
        for (int i = 0; i < _tasks.length; i++)
          i == index ? _tasks[i].copyWith(done: value) : _tasks[i],
      ];
    });
    await _service.toggle(DateTime.now(), t.id, value);

    // пересчёт прогресса и streak после изменения
    final now = DateTime.now();
    final doneNow = _tasks.where((t) => t.done).length;
    final totalNow = _tasks.length;

    int s;
    if (totalNow > 0 && doneNow == totalNow) {
      s = await _streakSvc.markTodayFull(now);
    } else {
      s = await _streakSvc.getStreak(now);
    }
    if (!mounted) return;
    setState(() => _streak = s);
  }

  Future<void> _togglePlanItem(int index, bool value) async {
    final item = _plan[index];
    setState(() {
      _plan = [
        for (int i = 0; i < _plan.length; i++)
          i == index ? _plan[i].copyWith(done: value) : _plan[i],
      ];
    });
    await _planSvc.toggle(DateTime.now(), item.id, value);
  }

  String _titleForTask(AppLocalizations loc, String id) {
    switch (id) {
      case 'water':
        return loc.taskWater;
      case 'steps':
        return loc.taskSteps;
      case 'sleep':
        return loc.taskSleep;
      case 'stretch':
        return loc.taskStretch;
      case 'mind':
        return loc.taskMind;
      default:
        return id;
    }
  }

  Future<void> _openAiSuggestions(AppLocalizations loc) async {
    final profile = await _profileSvc.load();
    final requestedLevel = switch (profile.fitnessLevel) {
      'beginner' => 1,
      'intermediate' => 2,
      'advanced' => 3,
      _ => 1,
    };
    final cats = {'water', 'activity', 'mind', 'care', 'productivity'};
    final recent = _tasks.map((t) => _titleForTask(loc, t.id)).toList();
    final forDay = DateTime.now();

    final suggestions = await _ai.generate(
      locale: Localizations.localeOf(context).languageCode,
      level: requestedLevel,
      enabledCats: cats,
      forDay: forDay,
      recentTitles: recent,
      profile: profile,
      count: 5,
    );

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.planToday,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...suggestions.map((s) => ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: Text(s.title),
                    subtitle: Text(
                      '${loc.catalogTasks.replaceAll(":", "")}: ${s.category} • ${loc.aiPlan.split(" ").first}: ${s.level}',
                    ),
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.close),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () async {
                      final toSave = suggestions
                          .map((s) => PlannedTask(
                                title: s.title,
                                category: s.category,
                                level: s.level,
                              ))
                          .toList();
                      await _planSvc.addMany(forDay, toSave);
                      if (!mounted) return;
                      Navigator.pop(context);
                      await _loadPlanToday();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.addedToPlan)),
                      );
                    },
                    icon: const Icon(Icons.add_task),
                    label: Text(loc.addToPlan),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _aiPing() async {
    try {
      final reply = await _aiClient.ping();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI: $reply')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final total = _tasks.length;
    final done = _tasks.where((t) => t.done).length;
    final progress = total == 0 ? 0.0 : done / total;

    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadAll(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Баннер + иконки
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Material(
                color: Colors.pink.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.pink),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.healthBannerText,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      // Профиль
                      IconButton(
                        tooltip: loc.surveyTitle,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SurveyScreen(),
                          ),
                        ),
                        icon: Icon(Icons.account_circle,
                            color: iconColor, size: 24),
                      ),
                      // Лампочка — генерация плана
                      IconButton(
                        tooltip: loc.planToday,
                        onPressed: () => _openAiSuggestions(loc),
                        icon: Icon(Icons.lightbulb, color: iconColor, size: 24),
                      ),
                      // Статистика
                      IconButton(
                        tooltip: loc.statsTitle,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => stats.HealthStatsScreen(),
                          ),
                        ),
                        icon: kIsWeb
                            ? const Text('📊',
                                style: TextStyle(fontSize: 20, height: 1.1))
                            : Icon(Icons.query_stats,
                                color: iconColor, size: 24),
                      ),
                      // AI-пинг (тест)
                      IconButton(
                        tooltip: loc.aiTest,
                        onPressed: _aiPing,
                        icon: Icon(Icons.smart_toy, color: iconColor, size: 24),
                      ),
                      // Сброс каталога
                      IconButton(
                        tooltip: loc.resetToday,
                        onPressed: _loading ? null : _resetToday,
                        icon: Icon(Icons.refresh, color: iconColor, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Прогресс каталога
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (done == total && total > 0)
                    Text(
                      loc.healthAllDone,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.green),
                    )
                  else
                    Text(
                      loc.healthProgress(done, total),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
            const SizedBox(height: 12),

            // ⚡ ИИ-совет (источник настраивается в app_config.dart)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AdviceSection(
                input: AdviceInput(
                  tz: 'America/New_York',
                  doneToday: done,
                  totalToday: total,
                  streak: _streak,
                ),
                useApi: kUseAdviceApi,
                apiBaseUrl: kAdviceApiBaseUrl,
                apiHeaders: kAdviceApiHeaders,
                showSourceBadge: kShowAdviceSourceBadge,
              ),
            ),

            const SizedBox(height: 12),

            // Каталог задач (ручные)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(loc.catalogTasks,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...List<Widget>.generate(_tasks.length, (index) {
                final t = _tasks[index];
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: t.done,
                  onChanged: (v) {
                    if (v == null) return;
                    _toggleTask(index, v);
                  },
                  title: Text(_titleForTask(loc, t.id)),
                );
              }),

            const SizedBox(height: 16),

            // План ИИ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(loc.aiPlan,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            if (_planLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_plan.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '—',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              )
            else
              ...List<Widget>.generate(_plan.length, (index) {
                final item = _plan[index];
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: item.done,
                  onChanged: (v) {
                    if (v == null) return;
                    _togglePlanItem(index, v);
                  },
                  title: Text(item.title),
                  subtitle: Text(
                      'Категория: ${item.category} • Уровень: ${item.level}'),
                );
              }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
