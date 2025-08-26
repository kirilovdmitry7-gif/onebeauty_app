// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OneBeauty';

  @override
  String get tabHealth => 'Salud';

  @override
  String get tabStudio => 'Estudio';

  @override
  String get tabStore => 'Tienda';

  @override
  String get healthMessage => 'Tu centro de bienestar llegará pronto.';

  @override
  String get studioMessage => 'El estudio estará disponible pronto.';

  @override
  String get storeMessage => 'La tienda estará disponible pronto.';
}
