// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OneBeauty';

  @override
  String get tabHealth => 'Health';

  @override
  String get tabStudio => 'Studio';

  @override
  String get tabStore => 'Store';

  @override
  String get healthMessage => 'Your wellness hub is coming soon.';

  @override
  String get studioMessage => 'Studio is coming soon.';

  @override
  String get storeMessage => 'Store is coming soon.';
}
