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
  String get signOut => 'Sign out';

  @override
  String get saved => 'Saved';

  @override
  String get save => 'Save';

  @override
  String get language => 'Language';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileDisplayName => 'Display name';

  @override
  String get profileAccount => 'Account';

  @override
  String get obHealthTitle => 'Daily health';

  @override
  String get obHealthText => 'Track water, steps and sleep with simple daily checks.';

  @override
  String get obStudioTitle => 'Studio';

  @override
  String get obStudioText => 'Book sessions and keep your schedule tidy.';

  @override
  String get obStoreTitle => 'Store';

  @override
  String get obStoreText => 'Buy care products and accessories in one place.';

  @override
  String get obSkip => 'Skip';

  @override
  String get obNext => 'Next';

  @override
  String get obStart => 'Start';

  @override
  String get authTitle => 'Sign in / Register';

  @override
  String get authLoginTab => 'Login';

  @override
  String get authRegisterTab => 'Register';

  @override
  String get authPhoneTab => 'Phone';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authPhone => 'Phone number';

  @override
  String get authCodeHint => 'Verification code';

  @override
  String get authSendCode => 'Send code';

  @override
  String get greetHello => 'Hello! 👋';

  @override
  String greetHelloName(String name) {
    return 'Hello, $name! 👋';
  }

  @override
  String get goalHintHealth => 'Make small daily steps: water, steps, sleep.';

  @override
  String get goalHintSkin => 'Skin-care tracker and tips are coming soon.';

  @override
  String get goalHintFitness => 'Keep active: steps, stretch, sleep.';

  @override
  String get healthResetTooltip => 'Reset today\'s checks';

  @override
  String get surveyTitle => 'Quick survey';

  @override
  String get surveyIntro => 'Takes under a minute and helps tailor recommendations.';

  @override
  String get surveyBirthDate => 'Birth date';

  @override
  String get surveyPickDate => 'Pick a date';

  @override
  String get surveyGender => 'Gender';

  @override
  String get surveyMale => 'Male';

  @override
  String get surveyFemale => 'Female';

  @override
  String get surveyOther => 'Other';

  @override
  String get surveyGoal => 'Main goal';

  @override
  String get surveyGoalHealth => 'Overall health';

  @override
  String get surveyGoalSkin => 'Skin care';

  @override
  String get surveyGoalFitness => 'Fitness shape';

  @override
  String get surveySaveContinue => 'Save and continue';

  @override
  String get surveyErrorFillAll => 'Please fill all fields';

  @override
  String get studioMessage => 'Studio is coming soon.';

  @override
  String get storeMessage => 'Store is coming soon.';

  @override
  String get taskWater => 'Drink 8 glasses of water 💧';

  @override
  String get taskSteps => 'Walk 6–8k steps 🚶';

  @override
  String get taskSleep => 'Go to bed by 23:00 😴';

  @override
  String get taskStretch => '5–10 min stretch 🤸';

  @override
  String get taskMind => '5 min mindfulness 🧘';

  @override
  String get authErrEmailPasswordRequired => 'Email and password are required';

  @override
  String get authErrPhoneCodeRequired => 'Phone and code are required';

  @override
  String get authErrInvalidCode => 'Invalid code (use 0000)';

  @override
  String get healthBannerText => 'Hi there! 👋 We’ll add a skincare tracker and recommendations soon.';

  @override
  String get resetToday => 'Reset today’s checks';

  @override
  String healthProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get healthAllDone => 'All done for today! 🎉';

  @override
  String get streakTitle => 'Your streak';

  @override
  String streakDays(int days) {
    return '$days days in a row';
  }

  @override
  String get healthWeekTitle => 'This week';

  @override
  String healthDayDone(int done, int total) {
    return '$done/$total';
  }

  @override
  String get surveyNext => 'Next';

  @override
  String get surveyBack => 'Back';

  @override
  String get surveySave => 'Save';

  @override
  String get surveyAge => 'Age';

  @override
  String get surveyFitness => 'Fitness level';

  @override
  String get surveyBeginner => 'Beginner';

  @override
  String get surveyIntermediate => 'Intermediate';

  @override
  String get surveyAdvanced => 'Advanced';

  @override
  String get surveyGoals => 'Goals';

  @override
  String get goalWeightLoss => 'Weight loss';

  @override
  String get goalBetterSleep => 'Better sleep';

  @override
  String get goalEnergy => 'More energy';

  @override
  String get goalDiscipline => 'Discipline';

  @override
  String get goalStress => 'Less stress';

  @override
  String get surveyLifestyle => 'Lifestyle';

  @override
  String get lifestyleSedentary => 'Sedentary';

  @override
  String get lifestyleActive => 'Active';

  @override
  String get surveyRestrictions => 'Restrictions';

  @override
  String get rVegan => 'Vegan';

  @override
  String get rVegetarian => 'Vegetarian';

  @override
  String get rNoAlcohol => 'No alcohol';

  @override
  String get rNoCaffeine => 'No caffeine';

  @override
  String get rAllergyNuts => 'Nut allergy';

  @override
  String get rHypertension => 'Hypertension';

  @override
  String get surveyBody => 'Body parameters';

  @override
  String get surveyWeight => 'Weight (kg)';

  @override
  String get surveyHeight => 'Height (cm)';

  @override
  String get surveyStress => 'Stress level';

  @override
  String get stressLow => 'Low';

  @override
  String get stressMedium => 'Medium';

  @override
  String get stressHigh => 'High';

  @override
  String get surveySleep => 'Sleep quality';

  @override
  String get sleepPoor => 'Poor';

  @override
  String get sleepAverage => 'Average';

  @override
  String get sleepGood => 'Good';

  @override
  String get planTomorrow => 'Plan for tomorrow';

  @override
  String get planToday => 'Plan for today';

  @override
  String get aiPlan => 'AI plan';

  @override
  String get catalogTasks => 'Today\'s tasks';

  @override
  String get addToPlan => 'Add to plan';

  @override
  String get addedToPlan => 'Added to plan';

  @override
  String get close => 'Close';

  @override
  String get newFeatureTitle => 'Awesome new feature';

  @override
  String get newFeatureDesc => 'Try our AI-based challenge generator!';

  @override
  String get statsTitle => 'Health stats';

  @override
  String get aiTest => 'AI test';

  @override
  String get devTestMessage => 'Localization pipeline works!';

  @override
  String get testAuto => 'Hello world';
}
