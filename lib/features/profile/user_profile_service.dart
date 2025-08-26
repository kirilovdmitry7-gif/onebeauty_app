import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final int age;                    // 10..100
  final String gender;              // male | female | other
  final double? weight;             // кг (опционально)
  final double? height;             // см (опционально)
  final String fitnessLevel;        // beginner | intermediate | advanced
  final List<String> restrictions;  // e.g. ["no_alcohol","vegan"]
  final String lifestyle;           // sedentary | active
  final List<String> goals;         // e.g. ["weight_loss","better_sleep"]
  final String stressLevel;         // low | medium | high
  final String sleepQuality;        // poor | average | good

  const UserProfile({
    required this.age,
    required this.gender,
    this.weight,
    this.height,
    required this.fitnessLevel,
    required this.restrictions,
    required this.lifestyle,
    required this.goals,
    required this.stressLevel,
    required this.sleepQuality,
  });

  factory UserProfile.empty() => const UserProfile(
        age: 30,
        gender: 'other',
        weight: null,
        height: null,
        fitnessLevel: 'beginner',
        restrictions: <String>[],
        lifestyle: 'sedentary',
        goals: <String>[],
        stressLevel: 'medium',
        sleepQuality: 'average',
      );

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'weight': weight,
        'height': height,
        'fitnessLevel': fitnessLevel,
        'restrictions': restrictions,
        'lifestyle': lifestyle,
        'goals': goals,
        'stressLevel': stressLevel,
        'sleepQuality': sleepQuality,
      };

  factory UserProfile.fromJson(Map<String, dynamic> map) => UserProfile(
        age: (map['age'] ?? 30) as int,
        gender: (map['gender'] ?? 'other') as String,
        weight: (map['weight'] as num?)?.toDouble(),
        height: (map['height'] as num?)?.toDouble(),
        fitnessLevel: (map['fitnessLevel'] ?? 'beginner') as String,
        restrictions: (map['restrictions'] as List?)?.cast<String>() ?? <String>[],
        lifestyle: (map['lifestyle'] ?? 'sedentary') as String,
        goals: (map['goals'] as List?)?.cast<String>() ?? <String>[],
        stressLevel: (map['stressLevel'] ?? 'medium') as String,
        sleepQuality: (map['sleepQuality'] ?? 'average') as String,
      );

  UserProfile copyWith({
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? fitnessLevel,
    List<String>? restrictions,
    String? lifestyle,
    List<String>? goals,
    String? stressLevel,
    String? sleepQuality,
  }) {
    return UserProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      restrictions: restrictions ?? this.restrictions,
      lifestyle: lifestyle ?? this.lifestyle,
      goals: goals ?? this.goals,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
    );
  }
}

class UserProfileService {
  static const _key = 'user_profile_v1';

  Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return UserProfile.empty();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProfile.empty();
    }
  }

  Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
