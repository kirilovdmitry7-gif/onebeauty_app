import 'package:shared_preferences/shared_preferences.dart';

class QuickSurveyData {
  final DateTime? birthDate; // nullable
  final String? gender;      // 'male' | 'female' | 'other' | null
  final String? goal;        // 'health' | 'skin' | 'fitness' | null

  const QuickSurveyData({this.birthDate, this.gender, this.goal});

  Map<String, String> toMap() => {
        'birthDate': birthDate?.toIso8601String() ?? '',
        'gender': gender ?? '',
        'goal': goal ?? '',
      };

  static QuickSurveyData fromMap(Map<String, String> m) {
    DateTime? bd;
    if ((m['birthDate'] ?? '').isNotEmpty) {
      bd = DateTime.tryParse(m['birthDate']!);
    }
    String? _nz(String? s) => (s == null || s.isEmpty) ? null : s;

    return QuickSurveyData(
      birthDate: bd,
      gender: _nz(m['gender']),
      goal: _nz(m['goal']),
    );
  }
}

class QuickSurveyService {
  static const _kDone = 'quick_survey_done_v1';
  static const _kBirthDate = 'quick_survey_birth';
  static const _kGender = 'quick_survey_gender';
  static const _kGoal = 'quick_survey_goal';

  Future<bool> isDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kDone) ?? false;
  }

  Future<QuickSurveyData> load() async {
    final p = await SharedPreferences.getInstance();
    final m = <String, String>{
      'birthDate': p.getString(_kBirthDate) ?? '',
      'gender': p.getString(_kGender) ?? '',
      'goal': p.getString(_kGoal) ?? '',
    };
    return QuickSurveyData.fromMap(m);
  }

  Future<void> save(QuickSurveyData data) async {
    final p = await SharedPreferences.getInstance();
    final m = data.toMap();
    await p.setString(_kBirthDate, m['birthDate'] ?? '');
    await p.setString(_kGender, m['gender'] ?? '');
    await p.setString(_kGoal, m['goal'] ?? '');
    await p.setBool(_kDone, true);
  }

  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kDone);
    await p.remove(_kBirthDate);
    await p.remove(_kGender);
    await p.remove(_kGoal);
  }
}
