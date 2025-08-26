import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/auth/fake_auth_repository.dart';
import '../../l10n/gen/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.onSignOut,
    required this.onLocaleChange,
    super.key,
  });

  final Future<void> Function() onSignOut;
  final void Function(Locale) onLocaleChange;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _repo = FakeAuthRepository();
  AuthUser? _user;

  static const _kDisplayName = 'profile_display_name';
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final u = await _repo.currentUser();
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_kDisplayName) ?? '';
    if (mounted) {
      setState(() {
        _user = u;
        _nameCtrl.text = savedName;
      });
    }
  }

  Future<void> _saveName() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayName, _nameCtrl.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saved)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    final locales = const [
      Locale('en'),
      Locale('es'),
      Locale('ru'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(loc.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(_nameCtrl.text.isEmpty ? '—' : _nameCtrl.text),
            subtitle: Text(_user?.email != null
                ? '${loc.profileEmail}: ${_user!.email}'
                : (_user?.phone != null
                    ? '${loc.profilePhone}: ${_user!.phone}'
                    : '')),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Display name
          Text(loc.profileDisplayName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: loc.profileDisplayName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveName,
              child: _saving
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(loc.save),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Language
          Text(loc.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<Locale>(
            value: locales.firstWhere(
              (l) => l.languageCode == currentLocale.languageCode,
              orElse: () => const Locale('en'),
            ),
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('es'), child: Text('Español')),
              DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
            ],
            onChanged: (l) {
              if (l != null) widget.onLocaleChange(l);
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Account / Sign out
          Text(loc.profileAccount, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(loc.signOut),
            onTap: () async {
              await widget.onSignOut();
              if (!mounted) return;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
