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
  String get signOut => 'Выйти';

  @override
  String get saved => 'Сохранено';

  @override
  String get save => 'Сохранить';

  @override
  String get language => 'Язык';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileEmail => 'Эл. почта';

  @override
  String get profilePhone => 'Телефон';

  @override
  String get profileDisplayName => 'Отображаемое имя';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get obHealthTitle => 'Ежедневное здоровье';

  @override
  String get obHealthText => 'Отслеживайте воду, шаги и сон с помощью простых ежедневных отметок.';

  @override
  String get obStudioTitle => 'Студия';

  @override
  String get obStudioText => 'Бронируйте сеансы и держите расписание в порядке.';

  @override
  String get obStoreTitle => 'Магазин';

  @override
  String get obStoreText => 'Покупайте товары и аксессуары для ухода в одном месте.';

  @override
  String get obSkip => 'Пропустить';

  @override
  String get obNext => 'Далее';

  @override
  String get obStart => 'Начать';

  @override
  String get authTitle => 'Вход / Регистрация';

  @override
  String get authLoginTab => 'Вход';

  @override
  String get authRegisterTab => 'Регистрация';

  @override
  String get authPhoneTab => 'Телефон';

  @override
  String get authContinueGoogle => 'Продолжить с Google';

  @override
  String get authEmail => 'Эл. почта';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authPhone => 'Номер телефона';

  @override
  String get authCodeHint => 'Код подтверждения';

  @override
  String get authSendCode => 'Отправить код';

  @override
  String get greetHello => 'Привет! 👋';

  @override
  String greetHelloName(String name) {
    return 'Привет, $name! 👋';
  }

  @override
  String get goalHintHealth => 'Маленькие шаги каждый день: вода, шаги, сон.';

  @override
  String get goalHintSkin => 'Трекер ухода за кожей и советы скоро.';

  @override
  String get goalHintFitness => 'Будьте активны: шаги, растяжка, сон.';

  @override
  String get healthResetTooltip => 'Сбросить отметки за сегодня';

  @override
  String get surveyTitle => 'Короткий опрос';

  @override
  String get surveyIntro => 'Займёт меньше минуты и поможет персонализировать рекомендации.';

  @override
  String get surveyBirthDate => 'Дата рождения';

  @override
  String get surveyPickDate => 'Выберите дату';

  @override
  String get surveyGender => 'Пол';

  @override
  String get surveyMale => 'Мужской';

  @override
  String get surveyFemale => 'Женский';

  @override
  String get surveyOther => 'Другое';

  @override
  String get surveyGoal => 'Основная цель';

  @override
  String get surveyGoalHealth => 'Общее здоровье';

  @override
  String get surveyGoalSkin => 'Уход за кожей';

  @override
  String get surveyGoalFitness => 'Физическая форма';

  @override
  String get surveySaveContinue => 'Сохранить и продолжить';

  @override
  String get surveyErrorFillAll => 'Пожалуйста, заполните все поля';

  @override
  String get studioMessage => 'Раздел \"Студия\" скоро будет доступен.';

  @override
  String get storeMessage => 'Раздел \"Магазин\" скоро будет доступен.';

  @override
  String get taskWater => 'Выпейте 8 стаканов воды 💧';

  @override
  String get taskSteps => 'Пройдите 6–8 тыс. шагов 🚶';

  @override
  String get taskSleep => 'Ложитесь спать до 23:00 😴';

  @override
  String get taskStretch => 'Растяжка 5–10 мин 🤸';

  @override
  String get taskMind => 'Осознанность 5 мин 🧘';

  @override
  String get authErrEmailPasswordRequired => 'Требуются email и пароль';

  @override
  String get authErrPhoneCodeRequired => 'Требуются телефон и код';

  @override
  String get authErrInvalidCode => 'Неверный код (используйте 0000)';

  @override
  String get healthBannerText => 'Привет! 👋 Скоро добавим трекер ухода за кожей и рекомендации.';

  @override
  String get resetToday => 'Сбросить отметки за сегодня';

  @override
  String healthProgress(int done, int total) {
    return '$done из $total выполнено';
  }

  @override
  String get healthAllDone => 'На сегодня всё! 🎉';

  @override
  String get streakTitle => 'Ваша серия';

  @override
  String streakDays(int days) {
    return '$days дней подряд';
  }

  @override
  String get healthWeekTitle => 'Эта неделя';

  @override
  String healthDayDone(int done, int total) {
    return '$done/$total';
  }

  @override
  String get surveyNext => 'Далее';

  @override
  String get surveyBack => 'Назад';

  @override
  String get surveySave => 'Сохранить';

  @override
  String get surveyAge => 'Возраст';

  @override
  String get surveyFitness => 'Уровень физподготовки';

  @override
  String get surveyBeginner => 'Новичок';

  @override
  String get surveyIntermediate => 'Средний';

  @override
  String get surveyAdvanced => 'Продвинутый';

  @override
  String get surveyGoals => 'Цели';

  @override
  String get goalWeightLoss => 'Похудение';

  @override
  String get goalBetterSleep => 'Лучший сон';

  @override
  String get goalEnergy => 'Больше энергии';

  @override
  String get goalDiscipline => 'Дисциплина';

  @override
  String get goalStress => 'Меньше стресса';

  @override
  String get surveyLifestyle => 'Образ жизни';

  @override
  String get lifestyleSedentary => 'Малоподвижный';

  @override
  String get lifestyleActive => 'Активный';

  @override
  String get surveyRestrictions => 'Ограничения';

  @override
  String get rVegan => 'Веган';

  @override
  String get rVegetarian => 'Вегетарианец';

  @override
  String get rNoAlcohol => 'Без алкоголя';

  @override
  String get rNoCaffeine => 'Без кофеина';

  @override
  String get rAllergyNuts => 'Аллергия на орехи';

  @override
  String get rHypertension => 'Гипертония';

  @override
  String get surveyBody => 'Параметры тела';

  @override
  String get surveyWeight => 'Вес (кг)';

  @override
  String get surveyHeight => 'Рост (см)';

  @override
  String get surveyStress => 'Уровень стресса';

  @override
  String get stressLow => 'Низкий';

  @override
  String get stressMedium => 'Средний';

  @override
  String get stressHigh => 'Высокий';

  @override
  String get surveySleep => 'Качество сна';

  @override
  String get sleepPoor => 'Плохое';

  @override
  String get sleepAverage => 'Среднее';

  @override
  String get sleepGood => 'Хорошее';

  @override
  String get planTomorrow => 'План на завтра';

  @override
  String get planToday => 'План на сегодня';

  @override
  String get aiPlan => 'AI-план';

  @override
  String get catalogTasks => 'Задачи на сегодня';

  @override
  String get addToPlan => 'Добавить в план';

  @override
  String get addedToPlan => 'Добавлено в план';

  @override
  String get close => 'Закрыть';

  @override
  String get newFeatureTitle => 'Классная новая функция';

  @override
  String get newFeatureDesc => 'Попробуйте наш AI-генератор челленджей!';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get aiTest => 'AI-тест';

  @override
  String get devTestMessage => 'Пайплайн локализации работает!';

  @override
  String get testAuto => 'Привет, мир';
}
