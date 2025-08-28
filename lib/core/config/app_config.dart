import 'package:flutter/foundation.dart' show kDebugMode;

/// Использовать ли реальный API (иначе мок)
const bool kUseAdviceApi =
    bool.fromEnvironment('ADVICE_USE_API', defaultValue: true);

/// Базовый URL для Advice API
const String kAdviceApiBaseUrl = String.fromEnvironment(
  'ADVICE_API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8787',
);

/// Показать бейдж источника (по умолчанию только в debug)
const bool kShowAdviceSourceBadge =
    bool.fromEnvironment('ADVICE_BADGE', defaultValue: kDebugMode);

/// Доп. заголовки (например, Authorization)
const Map<String, String> kAdviceApiHeaders = {
  // 'Authorization': 'Bearer <token>',
};
