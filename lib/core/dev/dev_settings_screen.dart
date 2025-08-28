import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:onebeauty_clean/core/config/app_config.dart';
import 'package:onebeauty_clean/core/dev/dev_flags.dart';
import 'package:onebeauty_clean/core/dev/dev_settings_service.dart';

class DevSettingsScreen extends StatefulWidget {
  const DevSettingsScreen({super.key});

  @override
  State<DevSettingsScreen> createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends State<DevSettingsScreen> {
  bool _loading = true;

  late bool aiEnabled;
  bool? adviceUseApiOverride;
  bool? adviceShowBadgeOverride;
  bool? aiFilterTodayOverride;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await DevSettingsService.load();
    aiEnabled = DevFlags.aiEnabled;
    adviceUseApiOverride = DevFlags.adviceUseApiOverride;
    adviceShowBadgeOverride = DevFlags.adviceShowBadgeOverride;
    aiFilterTodayOverride = DevFlags.aiFilterTodayOverride;

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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile.adaptive(
                    title: const Text('Master AI'),
                    subtitle: const Text('Toggle all AI features on this screen'),
                    value: aiEnabled,
                    onChanged: (v) async {
                      setState(() => aiEnabled = v);
                      await DevSettingsService.setAiEnabled(v);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Advice
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.auto_awesome),
                        title: const Text('Advice (AI)'),
                        subtitle: Text('Base URL: ${kAdviceApiBaseUrl.isEmpty ? '—' : kAdviceApiBaseUrl}'),
                      ),
                      const Divider(height: 0),
                      _OverrideSwitchTile(
                        title: 'Use API (override)',
                        subtitle: 'Config: ${kUseAdviceApi ? 'ON' : 'OFF'}',
                        value: adviceUseApiOverride,
                        onChanged: (bool? v) async {
                          setState(() => adviceUseApiOverride = v);
                          await DevSettingsService.setAdviceUseApiOverride(v);
                        },
                      ),
                      const Divider(height: 0),
                      _OverrideSwitchTile(
                        title: 'Show source badge (override)',
                        subtitle: 'Config: ${kShowAdviceSourceBadge ? 'ON' : 'OFF'}',
                        value: adviceShowBadgeOverride,
                        onChanged: (bool? v) async {
                          setState(() => adviceShowBadgeOverride = v);
                          await DevSettingsService.setAdviceShowBadgeOverride(v);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Today’s tasks
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.today),
                        title: Text('Today’s tasks'),
                        subtitle: Text('AI filter vs full catalog'),
                      ),
                      const Divider(height: 0),
                      _OverrideSwitchTile(
                        title: 'Use AI filter (override)',
                        subtitle: 'Config: ${kUseAiForTodayTasks ? 'ON' : 'OFF'}',
                        value: aiFilterTodayOverride,
                        onChanged: (bool? v) async {
                          setState(() => aiFilterTodayOverride = v);
                          await DevSettingsService.setAiFilterTodayOverride(v);
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await DevSettingsService.resetOverrides();
                        setState(() {
                          adviceUseApiOverride = null;
                          adviceShowBadgeOverride = null;
                          aiFilterTodayOverride = null;
                        });
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Overrides reset to config')),
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
}

class _OverrideSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool? value; // null → use config, true/false → override
  final ValueChanged<bool?> onChanged;

  const _OverrideSwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: DropdownButton<bool?>(
        value: value,
        onChanged: onChanged,
        items: const [
          DropdownMenuItem<bool?>(value: null, child: Text('Use config')),
          DropdownMenuItem<bool?>(value: true, child: Text('Override: ON')),
          DropdownMenuItem<bool?>(value: false, child: Text('Override: OFF')),
        ],
      ),
    );
  }
}
