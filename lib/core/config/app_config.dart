import 'package:flutter/foundation.dart' show kDebugMode;

/// ========================= AI Advice =========================

/// Использовать реальный API (иначе мок-источник).
/// --dart-define=ADVICE_USE_API=true|false
const bool kUseAdviceApi =
    bool.fromEnvironment('ADVICE_USE_API', defaultValue: true);

/// Базовый URL Advice API.
/// --dart-define=ADVICE_API_BASE_URL=http://127.0.0.1:8787
const String kAdviceApiBaseUrl = String.fromEnvironment(
  'ADVICE_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8787',
);

/// Показывать бейдж “API/MOCK”.
/// --dart-define=ADVICE_BADGE=true|false
const bool kShowAdviceSourceBadge =
    bool.fromEnvironment('ADVICE_BADGE', defaultValue: kDebugMode);

/// Доп. заголовки к Advice API (если нужно — заполни).
const Map<String, String> kAdviceApiHeaders = {
  // 'Authorization': 'Bearer <token>',
};

/// ====================== AI Today Tasks =======================

/// Включить ИИ-подбор задач на СЕГОДНЯ.
/// --dart-define=AI_TODAY_TASKS=true|false
const bool kUseAiForTodayTasks =
    bool.fromEnvironment('AI_TODAY_TASKS', defaultValue: true);

/// Показывать ли секцию "AI plan" для СЕГОДНЯ (чтобы не было «двух списков» — выключаем).
/// --dart-define=SHOW_TODAY_AI_PLAN=true|false
const bool kShowTodayAiPlanSection =
    bool.fromEnvironment('SHOW_TODAY_AI_PLAN', defaultValue: false);

/// Час, после которого показываем предпросмотр «План на завтра».
const int kTomorrowPreviewHour =
    int.fromEnvironment('TOMORROW_PREVIEW_HOUR', defaultValue: 18);
