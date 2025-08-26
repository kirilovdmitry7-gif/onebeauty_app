import 'package:flutter/material.dart';
import '../../l10n/gen/app_localizations.dart';
import 'user_profile_service.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _svc = UserProfileService();
  late UserProfile _p;
  bool _loading = true;
  int _step = 0; // 0..2

  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _svc.load();
    _p = p;
    _weightCtrl.text = p.weight?.toString() ?? '';
    _heightCtrl.text = p.height?.toString() ?? '';
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step = (_step + 1).clamp(0, 2));
  void _back() => setState(() => _step = (_step - 1).clamp(0, 2));

  Future<void> _save() async {
    double? w, h;
    if (_weightCtrl.text.trim().isNotEmpty) {
      w = double.tryParse(_weightCtrl.text.trim());
    }
    if (_heightCtrl.text.trim().isNotEmpty) {
      h = double.tryParse(_heightCtrl.text.trim());
    }
    final updated = _p.copyWith(weight: w, height: h);
    await _svc.save(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.saved)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.surveyTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: _buildStep(context, loc)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_step > 0)
                        OutlinedButton(onPressed: _back, child: Text(loc.surveyBack)),
                      const Spacer(),
                      if (_step < 2)
                        FilledButton(onPressed: _next, child: Text(loc.surveyNext))
                      else
                        FilledButton(onPressed: _save, child: Text(loc.surveySave)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStep(BuildContext context, AppLocalizations loc) {
    switch (_step) {
      case 0:
        return _stepBasics(loc);
      case 1:
        return _stepLifestyle(loc);
      default:
        return _stepBody(loc);
    }
  }

  // Шаг 0: базовые
  Widget _stepBasics(AppLocalizations loc) {
    return ListView(
      children: [
        Text(loc.surveyAge, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Slider(
          value: _p.age.toDouble(),
          min: 10,
          max: 100,
          divisions: 90,
          label: '${_p.age}',
          onChanged: (v) => setState(() => _p = _p.copyWith(age: v.round())),
        ),
        const SizedBox(height: 16),
        Text(loc.surveyGender, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(loc.surveyMale),
              selected: _p.gender == 'male',
              onSelected: (_) => setState(() => _p = _p.copyWith(gender: 'male')),
            ),
            ChoiceChip(
              label: Text(loc.surveyFemale),
              selected: _p.gender == 'female',
              onSelected: (_) => setState(() => _p = _p.copyWith(gender: 'female')),
            ),
            ChoiceChip(
              label: Text(loc.surveyOther),
              selected: _p.gender == 'other',
              onSelected: (_) => setState(() => _p = _p.copyWith(gender: 'other')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(loc.surveyFitness, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(loc.surveyBeginner),
              selected: _p.fitnessLevel == 'beginner',
              onSelected: (_) => setState(() => _p = _p.copyWith(fitnessLevel: 'beginner')),
            ),
            ChoiceChip(
              label: Text(loc.surveyIntermediate),
              selected: _p.fitnessLevel == 'intermediate',
              onSelected: (_) =>
                  setState(() => _p = _p.copyWith(fitnessLevel: 'intermediate')),
            ),
            ChoiceChip(
              label: Text(loc.surveyAdvanced),
              selected: _p.fitnessLevel == 'advanced',
              onSelected: (_) => setState(() => _p = _p.copyWith(fitnessLevel: 'advanced')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(loc.surveyGoals, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._goalTiles(loc),
      ],
    );
  }

  // Шаг 1: образ жизни и ограничения
  Widget _stepLifestyle(AppLocalizations loc) {
    return ListView(
      children: [
        Text(loc.surveyLifestyle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(loc.lifestyleSedentary),
              selected: _p.lifestyle == 'sedentary',
              onSelected: (_) => setState(() => _p = _p.copyWith(lifestyle: 'sedentary')),
            ),
            ChoiceChip(
              label: Text(loc.lifestyleActive),
              selected: _p.lifestyle == 'active',
              onSelected: (_) => setState(() => _p = _p.copyWith(lifestyle: 'active')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(loc.surveyRestrictions, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._restrictionTiles(loc),
      ],
    );
  }

  // Шаг 2: параметры тела + стресс/сон
  Widget _stepBody(AppLocalizations loc) {
    return ListView(
      children: [
        Text(loc.surveyBody, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),

        // Вес/Рост (опционально)
        TextField(
          controller: _weightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: loc.surveyWeight),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _heightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: loc.surveyHeight),
        ),
        const SizedBox(height: 20),

        // Уровень стресса
        Text(loc.surveyStress, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(loc.stressLow),
              selected: _p.stressLevel == 'low',
              onSelected: (_) => setState(() => _p = _p.copyWith(stressLevel: 'low')),
            ),
            ChoiceChip(
              label: Text(loc.stressMedium),
              selected: _p.stressLevel == 'medium',
              onSelected: (_) => setState(() => _p = _p.copyWith(stressLevel: 'medium')),
            ),
            ChoiceChip(
              label: Text(loc.stressHigh),
              selected: _p.stressLevel == 'high',
              onSelected: (_) => setState(() => _p = _p.copyWith(stressLevel: 'high')),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Качество сна
        Text(loc.surveySleep, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(loc.sleepPoor),
              selected: _p.sleepQuality == 'poor',
              onSelected: (_) => setState(() => _p = _p.copyWith(sleepQuality: 'poor')),
            ),
            ChoiceChip(
              label: Text(loc.sleepAverage),
              selected: _p.sleepQuality == 'average',
              onSelected: (_) => setState(() => _p = _p.copyWith(sleepQuality: 'average')),
            ),
            ChoiceChip(
              label: Text(loc.sleepGood),
              selected: _p.sleepQuality == 'good',
              onSelected: (_) => setState(() => _p = _p.copyWith(sleepQuality: 'good')),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _goalTiles(AppLocalizations loc) {
    final items = <String, String>{
      'weight_loss': loc.goalWeightLoss,
      'better_sleep': loc.goalBetterSleep,
      'energy': loc.goalEnergy,
      'discipline': loc.goalDiscipline,
      'stress': loc.goalStress,
    };
    return items.entries.map((e) {
      final selected = _p.goals.contains(e.key);
      return CheckboxListTile(
        value: selected,
        onChanged: (v) {
          final set = _p.goals.toSet();
          if (v == true) {
            set.add(e.key);
          } else {
            set.remove(e.key);
          }
          setState(() => _p = _p.copyWith(goals: set.toList()));
        },
        title: Text(e.value),
      );
    }).toList();
  }

  List<Widget> _restrictionTiles(AppLocalizations loc) {
    final items = <String, String>{
      'vegan': loc.rVegan,
      'vegetarian': loc.rVegetarian,
      'no_alcohol': loc.rNoAlcohol,
      'no_caffeine': loc.rNoCaffeine,
      'allergy_nuts': loc.rAllergyNuts,
      'hypertension': loc.rHypertension,
    };
    return items.entries.map((e) {
      final selected = _p.restrictions.contains(e.key);
      return CheckboxListTile(
        value: selected,
        onChanged: (v) {
          final set = _p.restrictions.toSet();
          if (v == true) {
            set.add(e.key);
          } else {
            set.remove(e.key);
          }
          setState(() => _p = _p.copyWith(restrictions: set.toList()));
        },
        title: Text(e.value),
      );
    }).toList();
  }
}
