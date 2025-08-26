import 'package:flutter/material.dart';
import '../../core/survey/quick_survey_service.dart';
import '../../l10n/gen/app_localizations.dart';

class QuickSurveyScreen extends StatefulWidget {
  const QuickSurveyScreen({required this.onDone, super.key});
  final VoidCallback onDone;

  @override
  State<QuickSurveyScreen> createState() => _QuickSurveyScreenState();
}

class _QuickSurveyScreenState extends State<QuickSurveyScreen> {
  final _service = QuickSurveyService();

  DateTime? _birthDate;
  String? _gender; // 'male' | 'female' | 'other'
  String? _goal;   // 'health' | 'skin' | 'fitness'

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.load();
    if (!mounted) return;
    setState(() {
      _birthDate = data.birthDate;
      _gender = data.gender;
      _goal = data.goal;
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 25, 1, 1);
    final first = DateTime(now.year - 100, 1, 1);
    final last = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(last) ? last : initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  bool get _valid =>
      _birthDate != null &&
      (_gender == 'male' || _gender == 'female' || _gender == 'other') &&
      (_goal == 'health' || _goal == 'skin' || _goal == 'fitness');

  Future<void> _save() async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (!_valid) throw Exception(loc.surveyErrorFillAll);
      await _service.save(QuickSurveyData(
        birthDate: _birthDate,
        gender: _gender,
        goal: _goal,
      ));
      widget.onDone();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.surveyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(loc.surveyTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(loc.surveyIntro, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),

          // Birth date
          Text(loc.surveyBirthDate),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cake),
                  label: Text(
                    _birthDate == null
                        ? loc.surveyPickDate
                        : '${_birthDate!.day.toString().padLeft(2, '0')}.'
                          '${_birthDate!.month.toString().padLeft(2, '0')}.'
                          '${_birthDate!.year}',
                  ),
                  onPressed: _pickBirthDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Gender
          Text(loc.surveyGender),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(loc.surveyMale),
                selected: _gender == 'male',
                onSelected: (_) => setState(() => _gender = 'male'),
              ),
              ChoiceChip(
                label: Text(loc.surveyFemale),
                selected: _gender == 'female',
                onSelected: (_) => setState(() => _gender = 'female'),
              ),
              ChoiceChip(
                label: Text(loc.surveyOther),
                selected: _gender == 'other',
                onSelected: (_) => setState(() => _gender = 'other'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Goal
          Text(loc.surveyGoal),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _goal,
            items: [
              DropdownMenuItem(value: 'health', child: Text(loc.surveyGoalHealth)),
              DropdownMenuItem(value: 'skin', child: Text(loc.surveyGoalSkin)),
              DropdownMenuItem(value: 'fitness', child: Text(loc.surveyGoalFitness)),
            ],
            onChanged: (v) => setState(() => _goal = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(loc.surveySaveContinue),
            ),
          ),
        ],
      ),
    );
  }
}
