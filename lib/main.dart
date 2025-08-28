import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Локализация
import 'package:onebeauty_clean/l10n/gen/app_localizations.dart';

// Экраны (ИСПОЛЬЗУЕМ package:-импорты)
import 'package:onebeauty_clean/features/health/health_screen.dart';
import 'package:onebeauty_clean/features/studio/studio_screen.dart';
import 'package:onebeauty_clean/features/store/store_screen.dart';
import 'package:onebeauty_clean/features/onboarding/onboarding_screen.dart';
import 'package:onebeauty_clean/features/onboarding/quick_survey_screen.dart';
import 'package:onebeauty_clean/features/auth/auth_screen.dart';
import 'package:onebeauty_clean/features/profile/profile_screen.dart';

// Auth (мок)
import 'package:onebeauty_clean/features/auth/auth_service.dart';

// Survey
import 'package:onebeauty_clean/core/survey/quick_survey_service.dart';

// Dev flags
import 'package:onebeauty_clean/features/dev/dev_flags.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Загружаем dev-флаги до старта приложения,
  // чтобы в рантайме иметь корректные значения.
  await DevFlags.load();
  runApp(const OneBeauty());
}

class OneBeauty extends StatefulWidget {
  const OneBeauty({super.key});
  @override
  State<OneBeauty> createState() => _OneBeautyState();
}

class _OneBeautyState extends State<OneBeauty> {
  Locale? _locale;
  bool _bootLoading = true; // загрузка состояния приложения
  bool _showOnboarding = false; // показывать ли онбординг до входа
  bool _needSurvey = false; // нужна ли анкета после входа

  final _auth = AuthService();
  final _survey = QuickSurveyService();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding_v1') ?? false;

    final user = await _auth.currentUser(); // проверка «сессии»
    final surveyDone = await _survey.isDone();

    setState(() {
      _showOnboarding = user == null && !seenOnboarding;
      _needSurvey = user != null && !surveyDone;
      _bootLoading = false;
    });
  }

  // смена языка
  void _setLocale(Locale locale) => setState(() => _locale = locale);

  // завершение онбординга
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding_v1', true);
    setState(() => _showOnboarding = false);
  }

  // колбэк после успешного входа
  Future<void> _onSignedIn() async {
    final surveyDone = await _survey.isDone();
    setState(() {
      _showOnboarding = false;
      _needSurvey = !surveyDone;
    });
  }

  // выход
  Future<void> _onSignOut() async {
    await _auth.signOut();
    setState(() {
      _needSurvey = false;
      _showOnboarding = true; // после выхода можно снова показать онбординг
    });
  }

  // анкета завершена
  void _onSurveyDone() => setState(() => _needSurvey = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneBeauty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      home: _bootLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_showOnboarding) {
      return OnboardingScreen(onFinish: _finishOnboarding);
    }

    // Проверяем текущего пользователя каждый раз, чтобы
    // после signOut/signIn корректно переключаться.
    return FutureBuilder<AuthUser?>(
      future: _auth.currentUser(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snap.data;
        if (user == null) {
          return AuthScreen(onSignedIn: _onSignedIn);
        }
        if (_needSurvey) {
          return QuickSurveyScreen(onDone: _onSurveyDone);
        }
        return _Root(
          onLocaleChange: _setLocale,
          onSignOut: _onSignOut,
        );
      },
    );
  }
}

class _Root extends StatefulWidget {
  const _Root({
    required this.onLocaleChange,
    required this.onSignOut,
    super.key,
  });
  final void Function(Locale) onLocaleChange;
  final Future<void> Function() onSignOut;

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  int index = 0;

  // ВАЖНО: без const перед HealthScreen(); используем package:-импорты выше
  final pages = <Widget>[
    HealthScreen(),
    StudioScreen(),
    StoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final labels = [loc.tabHealth, loc.tabStudio, loc.tabStore];
    final current = KeyedSubtree(key: ValueKey(index), child: pages[index]);

    return Scaffold(
      appBar: AppBar(
        title: Text(labels[index]),
        actions: [
          // выбор языка
          PopupMenuButton<Locale>(
            tooltip: 'Language',
            icon: const Icon(Icons.language),
            onSelected: widget.onLocaleChange,
            itemBuilder: (context) => const [
              PopupMenuItem(value: Locale('en'), child: Text('English')),
              PopupMenuItem(value: Locale('es'), child: Text('Español')),
              PopupMenuItem(value: Locale('ru'), child: Text('Русский')),
            ],
          ),
          const SizedBox(width: 4),
          // профиль
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    onSignOut: widget.onSignOut,
                    onLocaleChange: widget.onLocaleChange,
                  ),
                ),
              );
            },
          ),
          // выход
          IconButton(
            tooltip: loc.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.onSignOut();
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(loc.signOut)));
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final slide =
              Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                  .animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: current,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.favorite),
            label: loc.tabHealth,
          ),
          NavigationDestination(
            icon: const Icon(Icons.spa),
            label: loc.tabStudio,
          ),
          NavigationDestination(
            icon: const Icon(Icons.store),
            label: loc.tabStore,
          ),
        ],
      ),
    );
  }
}
