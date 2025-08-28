import 'dart:convert';

class Nudge {
  final String at; // "21:15"
  final String message; // текст напоминания

  Nudge({required this.at, required this.message});

  factory Nudge.fromJson(Map<String, dynamic> j) =>
      Nudge(at: j['at'] as String, message: j['message'] as String);

  Map<String, dynamic> toJson() => {'at': at, 'message': message};
}

class AiAdvice {
  final String adviceToday;
  final List<String> tomorrowPlan;
  final String weeklySummary;
  final List<Nudge> nudges;
  final String tone; // "warm" | "neutral"...

  AiAdvice({
    required this.adviceToday,
    required this.tomorrowPlan,
    required this.weeklySummary,
    required this.nudges,
    required this.tone,
  });

  factory AiAdvice.fromJson(Map<String, dynamic> j) => AiAdvice(
        adviceToday: (j['advice_today'] ?? '') as String,
        tomorrowPlan:
            (j['tomorrow_plan'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
        weeklySummary: (j['weekly_summary'] ?? '') as String,
        nudges: (j['nudges'] as List?)
                ?.map((e) => Nudge.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        tone: (j['advice_tone'] ?? 'neutral') as String,
      );

  Map<String, dynamic> toJson() => {
        'advice_today': adviceToday,
        'tomorrow_plan': tomorrowPlan,
        'weekly_summary': weeklySummary,
        'nudges': nudges.map((e) => e.toJson()).toList(),
        'advice_tone': tone,
      };

  @override
  String toString() => jsonEncode(toJson());
}

/// Минимальный набор агрегатов на вход "ИИ"
class AdviceInput {
  final String tz; // пример: "America/New_York"
  final int doneToday; // выполнено сегодня
  final int totalToday; // всего задач сегодня
  final int streak; // серия полных дней

  AdviceInput({
    required this.tz,
    required this.doneToday,
    required this.totalToday,
    required this.streak,
  });

  /// Простая заготовка, пока не подключили реальные данные
  factory AdviceInput.placeholder() => AdviceInput(
      tz: 'America/New_York', doneToday: 0, totalToday: 5, streak: 0);
}
