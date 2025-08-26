// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'OneBeauty';

  @override
  String get tabHealth => 'Здоровье';

  @override
  String get tabStudio => 'Студия';

  @override
  String get tabStore => 'Магазин';

  @override
  String get healthMessage => 'Ваш центр здоровья скоро будет готов.';

  @override
  String get studioMessage => 'Студия скоро будет готова.';

  @override
  String get storeMessage => 'Магазин скоро будет готов.';
}
