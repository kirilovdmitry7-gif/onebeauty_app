import 'package:flutter/material.dart';
import '../../l10n/gen/app_localizations.dart';
import 'auth_service.dart';
import 'auth_errors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.onSignedIn, super.key});
  final VoidCallback onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late final TabController _tab;
  final _auth = AuthService();

  // email/login
  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();

  // email/register
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();

  // phone
  final _phone = TextEditingController();
  final _code = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  String _humanizeError(Object e) {
    final loc = AppLocalizations.of(context)!;
    if (e is AuthError) {
      switch (e.code) {
        case AuthErrorCode.emailPasswordRequired:
          return loc.authErrEmailPasswordRequired;
        case AuthErrorCode.phoneCodeRequired:
          return loc.authErrPhoneCodeRequired;
        case AuthErrorCode.invalidCode:
          return loc.authErrInvalidCode;
        case AuthErrorCode.unknown:
          break;
      }
    }
    return e.toString();
  }

  Future<void> _guard(Future<void> Function() op) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await op();
      if (!mounted) return;
      widget.onSignedIn();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _humanizeError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.authTitle)),
      body: Column(
        children: [
          TabBar(
            controller: _tab,
            tabs: [
              Tab(text: loc.authLoginTab),
              Tab(text: loc.authRegisterTab),
              Tab(text: loc.authPhoneTab),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // Login
                _Pad(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : () => _guard(_auth.signInWithGoogle),
                          icon: const Icon(Icons.login),
                          label: Text(loc.authContinueGoogle),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _loginEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: loc.authEmail),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _loginPass,
                        obscureText: true,
                        decoration: InputDecoration(labelText: loc.authPassword),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading
                              ? null
                              : () => _guard(() => _auth.signInWithEmail(
                                    _loginEmail.text,
                                    _loginPass.text,
                                  )),
                          child: Text(loc.authSignIn),
                        ),
                      ),
                    ],
                  ),
                ),

                // Register
                _Pad(
                  child: Column(
                    children: [
                      TextField(
                        controller: _regEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: loc.authEmail),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _regPass,
                        obscureText: true,
                        decoration: InputDecoration(labelText: loc.authPassword),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading
                              ? null
                              : () => _guard(() => _auth.registerWithEmail(
                                    _regEmail.text,
                                    _regPass.text,
                                  )),
                          child: Text(loc.authCreateAccount),
                        ),
                      ),
                    ],
                  ),
                ),

                // Phone
                _Pad(
                  child: Column(
                    children: [
                      TextField(
                        controller: _phone,
                        decoration: InputDecoration(labelText: loc.authPhone),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _code,
                        decoration: InputDecoration(labelText: loc.authCodeHint),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _loading
                                  ? null
                                  : () => ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(loc.authCodeHint)),
                                      ),
                              child: Text(loc.authSendCode),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: _loading
                                  ? null
                                  : () => _guard(() => _auth.signInWithPhone(
                                        _phone.text,
                                        _code.text,
                                      )),
                              child: Text(loc.authSignIn),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [child],
    );
  }
}
