// lib/features/advice/ai_advice.dart
import 'package:flutter/foundation.dart';

class AiAdvice {
  final String adviceToday;
  final List<String> tomorrowPlan;
  final String weeklySummary;
  final List<Nudge> nudges;
  final String tone;

  /// Короткое объяснение “почему именно такой совет”
  /// Опционально, может отсутствовать (особенно на старом API/моке).
  final String? why;

  const AiAdvice({
    required this.adviceToday,
    this.tomorrowPlan = const [],
    this.weeklySummary = '',
    this.nudges = const [],
    this.tone = 'neutral',
    this.why,
  });

  AiAdvice copyWith({
    String? adviceToday,
    List<String>? tomorrowPlan,
    String? weeklySummary,
    List<Nudge>? nudges,
    String? tone,
    String? why,
  }) {
    return AiAdvice(
      adviceToday: adviceToday ?? this.adviceToday,
      tomorrowPlan: tomorrowPlan ?? this.tomorrowPlan,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      nudges: nudges ?? this.nudges,
      tone: tone ?? this.tone,
      why: why ?? this.why,
    );
  }

  factory AiAdvice.fromJson(Map<String, dynamic> json) {
    return AiAdvice(
      adviceToday:
          (json['advice_today'] ?? json['adviceToday'] ?? '').toString(),
      tomorrowPlan: ((json['tomorrow_plan'] ?? json['tomorrowPlan']) as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      weeklySummary:
          (json['weekly_summary'] ?? json['weeklySummary'] ?? '').toString(),
      nudges: ((json['nudges'] as List?) ?? const [])
          .map((e) => Nudge.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      tone: (json['advice_tone'] ?? json['tone'] ?? 'neutral').toString(),
      // поддержим разные названия поля:
      why: (json['why'] ?? json['reason'] ?? json['because'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'advice_today': adviceToday,
      'tomorrow_plan': tomorrowPlan,
      'weekly_summary': weeklySummary,
      'nudges': nudges.map((e) => e.toJson()).toList(),
      'advice_tone': tone,
      if (why != null && why!.isNotEmpty) 'why': why,
    };
  }
}

class Nudge {
  final String at;
  final String message;

  const Nudge({required this.at, required this.message});

  factory Nudge.fromJson(Map<String, dynamic> json) {
    return Nudge(
      at: (json['at'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'at': at, 'message': message};
}

/// Входные агрегаты на сегодня
class AdviceInput {
  final String tz;
  final int doneToday;
  final int totalToday;
  final int streak;

  const AdviceInput({
    required this.tz,
    required this.doneToday,
    required this.totalToday,
    required this.streak,
  });

  factory AdviceInput.placeholder() =>
      const AdviceInput(tz: 'UTC', doneToday: 0, totalToday: 5, streak: 0);

  Map<String, dynamic> toJson() => {
        'tz': tz,
        'today': {'done': doneToday, 'total': totalToday},
        'streak': streak,
      };
}
