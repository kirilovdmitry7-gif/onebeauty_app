import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:onebeauty_clean/l10n/gen/app_localizations.dart';

import '../ai_advice.dart';
import '../advice_source.dart';

class AdviceSection extends StatelessWidget {
  /// Актуальные агрегаты (done/total/streak).
  final AdviceInput? input;

  /// Включает вызов реального API (по умолчанию false).
  final bool useApi;

  /// Базовый URL API (например, http://127.0.0.1:8787).
  final String? apiBaseUrl;

  /// Доп. заголовки (например, {'Authorization': 'Bearer xyz'})
  final Map<String, String>? apiHeaders;

  /// Показывать бейдж источника в карточке (по умолчанию только в debug).
  final bool showSourceBadge;

  /// Колбэк "добавить все пункты из tomorrow_plan в план".
  /// Если null — кнопка не показывается.
  final Future<void> Function(List<String> items)? onAddAllToPlan;

  const AdviceSection({
    super.key,
    this.input,
    this.useApi = false,
    this.apiBaseUrl,
    this.apiHeaders,
    this.showSourceBadge = kDebugMode,
    this.onAddAllToPlan,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Пустую строку baseUrl считаем отсутствием API
    final String? base = (apiBaseUrl != null && apiBaseUrl!.trim().isNotEmpty)
        ? apiBaseUrl
        : null;

    final bool isApi = (useApi && base != null);
    final AdviceSource source = isApi
        ? ApiAdviceSource(baseUrl: base!, headers: apiHeaders)
        : MockAdviceSource();

    final AdviceInput effectiveInput = input ?? AdviceInput.placeholder();

    return FutureBuilder<AiAdvice>(
      future: source.getAdvice(effectiveInput),
      builder: (context, snap) {
        // Спиннер/скелетон на время загрузки
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 80,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }

        // Ошибка → мягкий фоллбэк на мок + бейдж API ⚠ + тултип
        if (snap.hasError) {
          final fallback = MockAdviceSource();
          final rawErr = (snap.error ?? 'Unknown error').toString();
          final warn =
              rawErr.length > 200 ? '${rawErr.substring(0, 200)}…' : rawErr;

          return FutureBuilder<AiAdvice>(
            future: fallback.getAdvice(effectiveInput),
            builder: (context, fb) {
              if (!fb.hasData) return const SizedBox.shrink();
              final advice = fb.data!;
              return _AdviceCard(
                locText: loc,
                advice: advice,
                sourceLabel: isApi ? 'API ⚠' : 'MOCK',
                showSourceBadge: showSourceBadge,
                warnMessage: isApi ? warn : null,
                onAddAllToPlan: onAddAllToPlan,
              );
            },
          );
        }

        // Состояние done, но данных нет → фоллбэк на мок
        if (!snap.hasData) {
          final fallback = MockAdviceSource();
          return FutureBuilder<AiAdvice>(
            future: fallback.getAdvice(effectiveInput),
            builder: (context, fb) {
              if (!fb.hasData) return const SizedBox.shrink();
              final advice = fb.data!;
              return _AdviceCard(
                locText: loc,
                advice: advice,
                sourceLabel: 'MOCK',
                showSourceBadge: showSourceBadge,
                onAddAllToPlan: onAddAllToPlan,
              );
            },
          );
        }

        // Успешно
        final advice = snap.data!;
        return _AdviceCard(
          locText: loc,
          advice: advice,
          sourceLabel: isApi ? 'API' : 'MOCK',
          showSourceBadge: showSourceBadge,
          onAddAllToPlan: onAddAllToPlan,
        );
      },
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final AppLocalizations locText;
  final AiAdvice advice;
  final String sourceLabel;
  final bool showSourceBadge;
  final String? warnMessage; // если был фоллбэк из-за ошибки API
  final Future<void> Function(List<String> items)? onAddAllToPlan;

  const _AdviceCard({
    required this.locText,
    required this.advice,
    required this.sourceLabel,
    required this.showSourceBadge,
    this.warnMessage,
    this.onAddAllToPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок + бейдж + (опц.) иконка ошибки
            Row(
              children: [
                Text(
                  locText.aiAdviceToday,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (showSourceBadge) _SourceBadge(label: sourceLabel),
                if (showSourceBadge && warnMessage != null) ...[
                  const SizedBox(width: 6),
                  Tooltip(
                    message: warnMessage!,
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              advice.adviceToday,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // План на завтра
            if (advice.tomorrowPlan.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                locText.planTomorrow,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Column(
                children: advice.tomorrowPlan.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.circle, size: 6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (onAddAllToPlan != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: () => onAddAllToPlan!(advice.tomorrowPlan),
                    icon: const Icon(Icons.playlist_add_check),
                    label: Text(locText.addToPlan),
                  ),
                ),
              ],
            ],

            // Weekly summary
            if (advice.weeklySummary.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                locText.aiAdviceWeekly,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                advice.weeklySummary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Nudges
            if (advice.nudges.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                locText.aiAdviceNudge,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Column(
                children: advice.nudges.map((n) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          child: Text(
                            n.at,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            n.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
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

class _SourceBadge extends StatelessWidget {
  final String label;
  const _SourceBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isWarn = label.contains('⚠');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isWarn ? scheme.errorContainer : scheme.surfaceVariant,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isWarn ? scheme.onErrorContainer : scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
