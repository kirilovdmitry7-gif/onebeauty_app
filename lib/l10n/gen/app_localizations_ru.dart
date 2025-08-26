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
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Телефон';

  @override
  String get profileDisplayName => 'Отображаемое имя';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get obHealthTitle => 'Ежедневное здоровье';

  @override
  String get obHealthText => 'Отмечай воду, шаги и сон — простые ежедневные цели.';

  @override
  String get obStudioTitle => 'Студия';

  @override
  String get obStudioText => 'Записывайся на сессии и веди расписание.';

  @override
  String get obStoreTitle => 'Магазин';

  @override
  String get obStoreText => 'Покупай уход и аксессуары в одном месте.';

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
  String get authContinueGoogle => 'Продолжить через Google';

  @override
  String get authEmail => 'Email';

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
  String get goalHintHealth => 'Делай маленькие шаги каждый день: вода, шаги, сон.';

  @override
  String get goalHintSkin => 'Скоро добавим трекер ухода за кожей и рекомендации.';

  @override
  String get goalHintFitness => 'Поддерживай активность: шаги, растяжка, сон.';

  @override
  String get healthResetTooltip => 'Сбросить отметки на сегодня';

  @override
  String get surveyTitle => 'Анкета здоровья';

  @override
  String get surveyIntro => 'Займёт менее минуты и поможет подобрать рекомендации.';

  @override
  String get surveyBirthDate => 'Дата рождения';

  @override
  String get surveyPickDate => 'Выбрать дату';

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
  String get surveyGoalFitness => 'Фитнес‑форма';

  @override
  String get surveySaveContinue => 'Сохранить и продолжить';

  @override
  String get surveyErrorFillAll => 'Пожалуйста, заполните все поля';

  @override
  String get studioMessage => 'Studio появится совсем скоро.';

  @override
  String get storeMessage => 'Store появится совсем скоро.';

  @override
  String get taskWater => 'Выпей 8 стаканов воды 💧';

  @override
  String get taskSteps => 'Пройди 6–8 тысяч шагов 🚶';

  @override
  String get taskSleep => 'Ложись спать до 23:00 😴';

  @override
  String get taskStretch => 'Растяжка 5–10 минут 🤸';

  @override
  String get taskMind => 'Осознанность 5 минут 🧘';

  @override
  String get authErrEmailPasswordRequired => 'Нужны email и пароль';

  @override
  String get authErrPhoneCodeRequired => 'Нужны телефон и код';

  @override
  String get authErrInvalidCode => 'Неверный код (используйте 0000)';

  @override
  String get healthBannerText => 'Привет, ага! 👋 Скоро добавим трекер ухода за кожей и рекомендации.';

  @override
  String get resetToday => 'Сбросить отметки за сегодня';

  @override
  String healthProgress(int done, int total) {
    return 'Выполнено $done из $total';
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
  String get surveyFitness => 'Уровень подготовки';

  @override
  String get surveyBeginner => 'Новичок';

  @override
  String get surveyIntermediate => 'Средний';

  @override
  String get surveyAdvanced => 'Продвинутый';

  @override
  String get surveyGoals => 'Цели';

  @override
  String get goalWeightLoss => 'Снижение веса';

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
  String get lifestyleSedentary => 'Сидячий';

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
  String get sleepPoor => 'Плохой';

  @override
  String get sleepAverage => 'Средний';

  @override
  String get sleepGood => 'Хороший';

  @override
  String get planTomorrow => 'План на завтра';

  @override
  String get close => 'Закрыть';

  @override
  String get newFeatureTitle => '';

  @override
  String get newFeatureDesc => '';

  @override
  String get planToday => '';

  @override
  String get aiPlan => 'AI plan';

  @override
  String get catalogTasks => '';

  @override
  String get addToPlan => '';

  @override
  String get addedToPlan => '';

  @override
  String get devTestMessage => '';

  @override
  String get testAuto => '';
}
