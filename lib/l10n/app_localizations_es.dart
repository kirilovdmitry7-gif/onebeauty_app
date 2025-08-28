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
  String get signOut => 'Cerrar sesión';

  @override
  String get saved => 'Guardado';

  @override
  String get save => 'Guardar';

  @override
  String get language => 'Idioma';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEmail => 'Correo electrónico';

  @override
  String get profilePhone => 'Teléfono';

  @override
  String get profileDisplayName => 'Nombre para mostrar';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get obHealthTitle => 'Salud diaria';

  @override
  String get obHealthText => 'Controla agua, pasos y sueño con comprobaciones diarias simples.';

  @override
  String get obStudioTitle => 'Estudio';

  @override
  String get obStudioText => 'Reserva sesiones y mantén tu agenda en orden.';

  @override
  String get obStoreTitle => 'Tienda';

  @override
  String get obStoreText => 'Compra productos y accesorios de cuidado en un solo lugar.';

  @override
  String get obSkip => 'Omitir';

  @override
  String get obNext => 'Siguiente';

  @override
  String get obStart => 'Empezar';

  @override
  String get authTitle => 'Iniciar sesión / Registrarse';

  @override
  String get authLoginTab => 'Iniciar sesión';

  @override
  String get authRegisterTab => 'Registrarse';

  @override
  String get authPhoneTab => 'Teléfono';

  @override
  String get authContinueGoogle => 'Continuar con Google';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authPhone => 'Número de teléfono';

  @override
  String get authCodeHint => 'Código de verificación';

  @override
  String get authSendCode => 'Enviar código';

  @override
  String get greetHello => '¡Hola! 👋';

  @override
  String greetHelloName(String name) {
    return '¡Hola, $name! 👋';
  }

  @override
  String get goalHintHealth => 'Pequeños pasos diarios: agua, pasos, sueño.';

  @override
  String get goalHintSkin => 'El rastreador de cuidado de la piel y los consejos llegarán pronto.';

  @override
  String get goalHintFitness => 'Mantente activo: pasos, estiramiento, sueño.';

  @override
  String get healthResetTooltip => 'Restablecer comprobaciones de hoy';

  @override
  String get surveyTitle => 'Encuesta rápida';

  @override
  String get surveyIntro => 'Toma menos de un minuto y ayuda a personalizar las recomendaciones.';

  @override
  String get surveyBirthDate => 'Fecha de nacimiento';

  @override
  String get surveyPickDate => 'Elige una fecha';

  @override
  String get surveyGender => 'Género';

  @override
  String get surveyMale => 'Hombre';

  @override
  String get surveyFemale => 'Mujer';

  @override
  String get surveyOther => 'Otro';

  @override
  String get surveyGoal => 'Objetivo principal';

  @override
  String get surveyGoalHealth => 'Salud general';

  @override
  String get surveyGoalSkin => 'Cuidado de la piel';

  @override
  String get surveyGoalFitness => 'Forma física';

  @override
  String get surveySaveContinue => 'Guardar y continuar';

  @override
  String get surveyErrorFillAll => 'Por favor, completa todos los campos';

  @override
  String get studioMessage => 'La sección \"Estudio\" estará disponible pronto.';

  @override
  String get storeMessage => 'La sección \"Tienda\" estará disponible pronto.';

  @override
  String get taskWater => 'Bebe 8 vasos de agua 💧';

  @override
  String get taskSteps => 'Camina 6–8 mil pasos 🚶';

  @override
  String get taskSleep => 'Acuéstate antes de las 23:00 😴';

  @override
  String get taskStretch => 'Estiramiento 5–10 min 🤸';

  @override
  String get taskMind => 'Atención plena 5 min 🧘';

  @override
  String get authErrEmailPasswordRequired => 'Se requieren correo y contraseña';

  @override
  String get authErrPhoneCodeRequired => 'Se requieren teléfono y código';

  @override
  String get authErrInvalidCode => 'Código inválido (usa 0000)';

  @override
  String get healthBannerText => '¡Hola! 👋 Pronto añadiremos un rastreador de cuidado de la piel y recomendaciones.';

  @override
  String get resetToday => 'Restablecer comprobaciones de hoy';

  @override
  String healthProgress(int done, int total) {
    return '$done de $total completado';
  }

  @override
  String get healthAllDone => '¡Todo hecho por hoy! 🎉';

  @override
  String get streakTitle => 'Tu racha';

  @override
  String streakDays(int days) {
    return '$days días seguidos';
  }

  @override
  String get healthWeekTitle => 'Esta semana';

  @override
  String healthDayDone(int done, int total) {
    return '$done/$total';
  }

  @override
  String get surveyNext => 'Siguiente';

  @override
  String get surveyBack => 'Atrás';

  @override
  String get surveySave => 'Guardar';

  @override
  String get surveyAge => 'Edad';

  @override
  String get surveyFitness => 'Nivel de condición física';

  @override
  String get surveyBeginner => 'Principiante';

  @override
  String get surveyIntermediate => 'Intermedio';

  @override
  String get surveyAdvanced => 'Avanzado';

  @override
  String get surveyGoals => 'Objetivos';

  @override
  String get goalWeightLoss => 'Pérdida de peso';

  @override
  String get goalBetterSleep => 'Mejor sueño';

  @override
  String get goalEnergy => 'Más energía';

  @override
  String get goalDiscipline => 'Disciplina';

  @override
  String get goalStress => 'Menos estrés';

  @override
  String get surveyLifestyle => 'Estilo de vida';

  @override
  String get lifestyleSedentary => 'Sedentario';

  @override
  String get lifestyleActive => 'Activo';

  @override
  String get surveyRestrictions => 'Restricciones';

  @override
  String get rVegan => 'Vegano';

  @override
  String get rVegetarian => 'Vegetariano';

  @override
  String get rNoAlcohol => 'Sin alcohol';

  @override
  String get rNoCaffeine => 'Sin cafeína';

  @override
  String get rAllergyNuts => 'Alergia a los frutos secos';

  @override
  String get rHypertension => 'Hipertensión';

  @override
  String get surveyBody => 'Parámetros corporales';

  @override
  String get surveyWeight => 'Peso (kg)';

  @override
  String get surveyHeight => 'Altura (cm)';

  @override
  String get surveyStress => 'Nivel de estrés';

  @override
  String get stressLow => 'Bajo';

  @override
  String get stressMedium => 'Medio';

  @override
  String get stressHigh => 'Alto';

  @override
  String get surveySleep => 'Calidad del sueño';

  @override
  String get sleepPoor => 'Mala';

  @override
  String get sleepAverage => 'Media';

  @override
  String get sleepGood => 'Buena';

  @override
  String get planTomorrow => 'Plan para mañana';

  @override
  String get planToday => 'Plan para hoy';

  @override
  String get aiPlan => 'Plan de IA';

  @override
  String get catalogTasks => 'Tareas de hoy';

  @override
  String get addToPlan => 'Agregar al plan';

  @override
  String get addedToPlan => 'Agregado al plan';

  @override
  String get close => 'Cerrar';

  @override
  String get newFeatureTitle => 'Función nueva increíble';

  @override
  String get newFeatureDesc => '¡Prueba nuestro generador de retos con IA!';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get aiTest => 'Prueba de IA';

  @override
  String get devTestMessage => '¡El pipeline de localización funciona!';

  @override
  String get testAuto => 'Hola mundo';
}
