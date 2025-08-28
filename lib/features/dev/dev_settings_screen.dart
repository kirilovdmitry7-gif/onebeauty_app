import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:onebeauty_clean/core/dev/dev_flags.dart';
import 'package:onebeauty_clean/core/dev/dev_settings_service.dart';
import 'package:onebeauty_clean/core/dev/dev_features.dart';
import 'package:onebeauty_clean/core/dev/dev_feature_registry.dart';

class DevSettingsScreen extends StatefulWidget {
  const DevSettingsScreen({super.key});

  @override
  State<DevSettingsScreen> createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends State<DevSettingsScreen> {
  bool _loading = true;
  late bool aiEnabled;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // гарантируем, что все фичи зарегистрированы
    DevFeaturesCatalog.ensureRegistered();
    // подтянем сохранённые значения
    await DevSettingsService.load();
    aiEnabled = DevFlags.aiEnabled;

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Dev settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Master AI
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile.adaptive(
                    title: const Text('Master AI'),
                    subtitle:
                        const Text('Toggle all AI features on this screen'),
                    value: aiEnabled,
                    onChanged: (v) async {
                      setState(() => aiEnabled = v);
                      await DevSettingsService.setAiEnabled(v);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Автоматически сгенерированные блоки по группам
                ..._buildFeatureGroups(),

                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await DevSettingsService.resetOverrides();
                        if (!mounted) return;
                        setState(() {}); // перечитать значения из DevFlags
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Overrides reset to config')),
                        );
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset overrides'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.check),
                      label: const Text('Close'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (kIsWeb)
                  Text(
                    'Tip: open DevTools → Network to see Advice API calls',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
    );
  }

  List<Widget> _buildFeatureGroups() {
    final groups = DevFeatureRegistry.grouped();
    final widgets = <Widget>[];

    for (final entry in groups.entries) {
      final groupTitle = entry.key;
      final features = entry.value;

      widgets.add(
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.tune),
                title: Text(groupTitle),
                subtitle: const Text('Overrides (null = use config)'),
              ),
              const Divider(height: 0),
              for (int i = 0; i < features.length; i++) ...[
                _OverrideTriStateTile(
                    feature: features[i], onChanged: _onFeatureChanged),
                if (i != features.length - 1) const Divider(height: 0),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  Future<void> _onFeatureChanged(DevFeature f, bool? v) async {
    await f.setOverride(v);
    if (!mounted) return;
    setState(() {});
  }
}

class _OverrideTriStateTile extends StatelessWidget {
  final DevFeature feature;
  final Future<void> Function(DevFeature, bool?) onChanged;

  const _OverrideTriStateTile({
    required this.feature,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleText = feature.subtitle?.call();

    return ListTile(
      title: Text(feature.title),
      subtitle: subtitleText == null ? null : Text(subtitleText),
      trailing: DropdownButton<bool?>(
        value: feature.getOverride(),
        onChanged: (v) => onChanged(feature, v),
        items: const [
          DropdownMenuItem<bool?>(value: null, child: Text('Use config')),
          DropdownMenuItem<bool?>(value: true, child: Text('Override: ON')),
          DropdownMenuItem<bool?>(value: false, child: Text('Override: OFF')),
        ],
      ),
    );
  }
}
