import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:onebeauty_clean/core/dev/dev_flags.dart';

import 'package:onebeauty_clean/core/ai/ai_client.dart';
import 'package:onebeauty_clean/core/config/app_config.dart';
import 'package:onebeauty_clean/features/advice/ai_advice.dart';
import 'package:onebeauty_clean/features/advice/widgets/advice_card.dart';
import 'package:onebeauty_clean/features/dev/dev_settings_screen.dart';

import '../../l10n/gen/app_localizations.dart';
import '../ai/ai_task_generator.dart';
import '../plan/daily_plan_service.dart';
import '../profile/survey_screen.dart';
import '../profile/user_profile_service.dart';
import 'health_stats_screen.dart' as stats;
import 'streak_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  // AI-план на сегодня
  final _planSvc = DailyPlanService();
  bool _planLoading = true;
  List<DailyPlanItem> _plan = const [];

  // Профиль + генератор (лампочка)
  final _profileSvc = UserProfileService();
  final AiTaskGenerator _ai = ApiAiTaskGenerator(AiClient());

  // Тест-пинг
  final AiClient _aiClient = AiClient();

  // Streak
  final StreakService _streakSvc = StreakService();
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadPlanToday();
  }

  Future<void> _loadPlanToday() async {
    setState(() => _planLoading = true);

    final today = DateTime.now();
    var plan = await _planSvc.load(today);

    // seed: если план пуст (новая origin / GH Pages), положим базовые пункты
    if (plan.isEmpty) {
      final seed = _seedForLocale(Localizations.localeOf(context).languageCode);
      if (seed.isNotEmpty) {
        await _planSvc.addMany(today, seed);
        plan = await _planSvc.load(today);
      }
    }

    final s = await _streakSvc.getStreak(today);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _streak = s;
      _planLoading = false;
    });
  }

  List<PlannedTask> _seedForLocale(String code) {
    switch (code) {
      case 'ru':
        return [
          PlannedTask(
              title: 'Вода 3×250 мл до 16:00', category: 'water', level: 1),
          PlannedTask(
              title: '7 мин растяжки после ужина',
              category: 'activity',
              level: 1),
          PlannedTask(title: '5 мин осознанности', category: 'mind', level: 1),
          PlannedTask(
              title: 'Экран-детокс 30 мин перед сном',
              category: 'productivity',
              level: 1),
        ];
      case 'es':
        return [
          PlannedTask(
              title: 'Agua 3×250 ml antes de las 16:00',
              category: 'water',
              level: 1),
          PlannedTask(
              title: 'Estiramiento 7 min después de la cena',
              category: 'activity',
              level: 1),
          PlannedTask(title: 'Mindfulness 5 min', category: 'mind', level: 1),
          PlannedTask(
              title: 'Detox de pantallas 30 min antes de dormir',
              category: 'productivity',
              level: 1),
        ];
      default: // en
        return [
          PlannedTask(
              title: 'Water 3×250ml before 4pm', category: 'water', level: 1),
          PlannedTask(
              title: 'Stretch 7 min after dinner',
              category: 'activity',
              level: 1),
          PlannedTask(title: 'Mindfulness 5 min', category: 'mind', level: 1),
          PlannedTask(
              title: 'Screen detox 30 min before bed',
              category: 'productivity',
              level: 1),
        ];
    }
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

    // Пересчёт streak — по AI-плану
    final doneNow = _plan.where((x) => x.done).length;
    final totalNow = _plan.length;
    final allDone = totalNow > 0 && doneNow == totalNow;

    final now = DateTime.now();
    final s = allDone
        ? await _streakSvc.markTodayFull(now)
        : await _streakSvc.applySoftOrReset(now);

    if (!mounted) return;
    setState(() => _streak = s);
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
    final forDay = DateTime.now();
    final recent = _plan.map((e) => e.title).toList();

    try {
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('AI недоступен — используются локальные задания')),
      );
    }
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

  Future<void> _toggleAiEnabled() async {
    final newValue = !DevFlags.aiEnabled;
    await DevFlags.setAiEnabled(newValue);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(newValue ? 'AI включён' : 'AI выключен')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final total = _plan.length;
    final done = _plan.where((t) => t.done).length;
    final progress = total == 0 ? 0.0 : done / total;
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPlanToday,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // БАННЕР + ИКОНКИ
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

                      // Лампочка — генерация плана (выключаем, если AI отключён)
                      IconButton(
                        tooltip:
                            DevFlags.aiEnabled ? loc.planToday : 'AI выключен',
                        onPressed: DevFlags.aiEnabled
                            ? () => _openAiSuggestions(loc)
                            : null,
                        icon: Icon(Icons.lightbulb, color: iconColor, size: 24),
                      ),

                      // Статистика
                      IconButton(
                        tooltip: loc.statsTitle,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const stats.HealthStatsScreen(),
                          ),
                        ),
                        icon: kIsWeb
                            ? const Text('📊',
                                style: TextStyle(fontSize: 20, height: 1.1))
                            : Icon(Icons.query_stats,
                                color: iconColor, size: 24),
                      ),

                      // Переключатель AI — доступен всегда (и в проде)
                      PopupMenuButton<String>(
                        tooltip: 'Опции',
                        onSelected: (v) async {
                          if (v == 'toggle_ai') {
                            await _toggleAiEnabled();
                          } else if (v == 'open_dev') {
                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const DevSettingsScreen()),
                            );
                          } else if (v == 'ai_ping' && kDebugMode) {
                            await _aiPing();
                          }
                        },
                        itemBuilder: (ctx) => [
                          CheckedPopupMenuItem(
                            value: 'toggle_ai',
                            checked: DevFlags.aiEnabled,
                            child: const Text('AI включён'),
                          ),
                          const PopupMenuItem(
                            value: 'open_dev',
                            child: Text('Dev Settings'),
                          ),
                          if (kDebugMode)
                            const PopupMenuItem(
                              value: 'ai_ping',
                              child: Text('AI ping (debug)'),
                            ),
                        ],
                        icon: Icon(Icons.more_vert, color: iconColor, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ПРОГРЕСС (по AI-плану)
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

            // ⚡ ADVICE CARD — показываем только если AI включён
            if (DevFlags.aiEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AdviceSection(
                  input: AdviceInput(
                    tz: 'America/New_York',
                    doneToday: done,
                    totalToday: total,
                    streak: _streak,
                  ),
                  useApi: kUseAdviceApi && DevFlags.aiEnabled,
                  apiBaseUrl: kAdviceApiBaseUrl,
                  apiHeaders: kAdviceApiHeaders,
                  showSourceBadge:
                      kDebugMode ? DevFlags.showSourceBadge : false,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: Colors.grey.withOpacity(.12),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                        'AI выключен — советы и генерация временно недоступны'),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ЕДИНСТВЕННЫЙ СПИСОК — AI PLAN
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
