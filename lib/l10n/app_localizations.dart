import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OneBeauty'**
  String get appTitle;

  /// No description provided for @tabHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get tabHealth;

  /// No description provided for @tabStudio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get tabStudio;

  /// No description provided for @tabStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get tabStore;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileDisplayName;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @obHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily health'**
  String get obHealthTitle;

  /// No description provided for @obHealthText.
  ///
  /// In en, this message translates to:
  /// **'Track water, steps and sleep with simple daily checks.'**
  String get obHealthText;

  /// No description provided for @obStudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get obStudioTitle;

  /// No description provided for @obStudioText.
  ///
  /// In en, this message translates to:
  /// **'Book sessions and keep your schedule tidy.'**
  String get obStudioText;

  /// No description provided for @obStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get obStoreTitle;

  /// No description provided for @obStoreText.
  ///
  /// In en, this message translates to:
  /// **'Buy care products and accessories in one place.'**
  String get obStoreText;

  /// No description provided for @obSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get obSkip;

  /// No description provided for @obNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get obNext;

  /// No description provided for @obStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get obStart;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in / Register'**
  String get authTitle;

  /// No description provided for @authLoginTab.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginTab;

  /// No description provided for @authRegisterTab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTab;

  /// No description provided for @authPhoneTab.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authPhoneTab;

  /// No description provided for @authContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhone;

  /// No description provided for @authCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authCodeHint;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @greetHello.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋'**
  String get greetHello;

  /// No description provided for @greetHelloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}! 👋'**
  String greetHelloName(String name);

  /// No description provided for @goalHintHealth.
  ///
  /// In en, this message translates to:
  /// **'Make small daily steps: water, steps, sleep.'**
  String get goalHintHealth;

  /// No description provided for @goalHintSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin-care tracker and tips are coming soon.'**
  String get goalHintSkin;

  /// No description provided for @goalHintFitness.
  ///
  /// In en, this message translates to:
  /// **'Keep active: steps, stretch, sleep.'**
  String get goalHintFitness;

  /// No description provided for @healthResetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset today\'s checks'**
  String get healthResetTooltip;

  /// No description provided for @surveyTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick survey'**
  String get surveyTitle;

  /// No description provided for @surveyIntro.
  ///
  /// In en, this message translates to:
  /// **'Takes under a minute and helps tailor recommendations.'**
  String get surveyIntro;

  /// No description provided for @surveyBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get surveyBirthDate;

  /// No description provided for @surveyPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get surveyPickDate;

  /// No description provided for @surveyGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get surveyGender;

  /// No description provided for @surveyMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get surveyMale;

  /// No description provided for @surveyFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get surveyFemale;

  /// No description provided for @surveyOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get surveyOther;

  /// No description provided for @surveyGoal.
  ///
  /// In en, this message translates to:
  /// **'Main goal'**
  String get surveyGoal;

  /// No description provided for @surveyGoalHealth.
  ///
  /// In en, this message translates to:
  /// **'Overall health'**
  String get surveyGoalHealth;

  /// No description provided for @surveyGoalSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin care'**
  String get surveyGoalSkin;

  /// No description provided for @surveyGoalFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness shape'**
  String get surveyGoalFitness;

  /// No description provided for @surveySaveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get surveySaveContinue;

  /// No description provided for @surveyErrorFillAll.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get surveyErrorFillAll;

  /// No description provided for @studioMessage.
  ///
  /// In en, this message translates to:
  /// **'Studio is coming soon.'**
  String get studioMessage;

  /// No description provided for @storeMessage.
  ///
  /// In en, this message translates to:
  /// **'Store is coming soon.'**
  String get storeMessage;

  /// No description provided for @taskWater.
  ///
  /// In en, this message translates to:
  /// **'Drink 8 glasses of water 💧'**
  String get taskWater;

  /// No description provided for @taskSteps.
  ///
  /// In en, this message translates to:
  /// **'Walk 6–8k steps 🚶'**
  String get taskSteps;

  /// No description provided for @taskSleep.
  ///
  /// In en, this message translates to:
  /// **'Go to bed by 23:00 😴'**
  String get taskSleep;

  /// No description provided for @taskStretch.
  ///
  /// In en, this message translates to:
  /// **'5–10 min stretch 🤸'**
  String get taskStretch;

  /// No description provided for @taskMind.
  ///
  /// In en, this message translates to:
  /// **'5 min mindfulness 🧘'**
  String get taskMind;

  /// No description provided for @authErrEmailPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password are required'**
  String get authErrEmailPasswordRequired;

  /// No description provided for @authErrPhoneCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone and code are required'**
  String get authErrPhoneCodeRequired;

  /// No description provided for @authErrInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code (use 0000)'**
  String get authErrInvalidCode;

  /// No description provided for @healthBannerText.
  ///
  /// In en, this message translates to:
  /// **'Hi there! 👋 We’ll add a skincare tracker and recommendations soon.'**
  String get healthBannerText;

  /// No description provided for @resetToday.
  ///
  /// In en, this message translates to:
  /// **'Reset today’s checks'**
  String get resetToday;

  /// No description provided for @healthProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String healthProgress(int done, int total);

  /// No description provided for @healthAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done for today! 🎉'**
  String get healthAllDone;

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Your streak'**
  String get streakTitle;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days in a row'**
  String streakDays(int days);

  /// No description provided for @healthWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get healthWeekTitle;

  /// No description provided for @healthDayDone.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String healthDayDone(int done, int total);

  /// No description provided for @surveyNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get surveyNext;

  /// No description provided for @surveyBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get surveyBack;

  /// No description provided for @surveySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get surveySave;

  /// No description provided for @surveyAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get surveyAge;

  /// No description provided for @surveyFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness level'**
  String get surveyFitness;

  /// No description provided for @surveyBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get surveyBeginner;

  /// No description provided for @surveyIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get surveyIntermediate;

  /// No description provided for @surveyAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get surveyAdvanced;

  /// No description provided for @surveyGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get surveyGoals;

  /// No description provided for @goalWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight loss'**
  String get goalWeightLoss;

  /// No description provided for @goalBetterSleep.
  ///
  /// In en, this message translates to:
  /// **'Better sleep'**
  String get goalBetterSleep;

  /// No description provided for @goalEnergy.
  ///
  /// In en, this message translates to:
  /// **'More energy'**
  String get goalEnergy;

  /// No description provided for @goalDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get goalDiscipline;

  /// No description provided for @goalStress.
  ///
  /// In en, this message translates to:
  /// **'Less stress'**
  String get goalStress;

  /// No description provided for @surveyLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get surveyLifestyle;

  /// No description provided for @lifestyleSedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get lifestyleSedentary;

  /// No description provided for @lifestyleActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get lifestyleActive;

  /// No description provided for @surveyRestrictions.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get surveyRestrictions;

  /// No description provided for @rVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get rVegan;

  /// No description provided for @rVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get rVegetarian;

  /// No description provided for @rNoAlcohol.
  ///
  /// In en, this message translates to:
  /// **'No alcohol'**
  String get rNoAlcohol;

  /// No description provided for @rNoCaffeine.
  ///
  /// In en, this message translates to:
  /// **'No caffeine'**
  String get rNoCaffeine;

  /// No description provided for @rAllergyNuts.
  ///
  /// In en, this message translates to:
  /// **'Nut allergy'**
  String get rAllergyNuts;

  /// No description provided for @rHypertension.
  ///
  /// In en, this message translates to:
  /// **'Hypertension'**
  String get rHypertension;

  /// No description provided for @surveyBody.
  ///
  /// In en, this message translates to:
  /// **'Body parameters'**
  String get surveyBody;

  /// No description provided for @surveyWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get surveyWeight;

  /// No description provided for @surveyHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get surveyHeight;

  /// No description provided for @surveyStress.
  ///
  /// In en, this message translates to:
  /// **'Stress level'**
  String get surveyStress;

  /// No description provided for @stressLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get stressLow;

  /// No description provided for @stressMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get stressMedium;

  /// No description provided for @stressHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get stressHigh;

  /// No description provided for @surveySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get surveySleep;

  /// No description provided for @sleepPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get sleepPoor;

  /// No description provided for @sleepAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get sleepAverage;

  /// No description provided for @sleepGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get sleepGood;

  /// No description provided for @planTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Plan for tomorrow'**
  String get planTomorrow;

  /// No description provided for @planToday.
  ///
  /// In en, this message translates to:
  /// **'Plan for today'**
  String get planToday;

  /// No description provided for @aiPlan.
  ///
  /// In en, this message translates to:
  /// **'AI plan'**
  String get aiPlan;

  /// No description provided for @catalogTasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks'**
  String get catalogTasks;

  /// No description provided for @addToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to plan'**
  String get addToPlan;

  /// No description provided for @addedToPlan.
  ///
  /// In en, this message translates to:
  /// **'Added to plan'**
  String get addedToPlan;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @newFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Awesome new feature'**
  String get newFeatureTitle;

  /// No description provided for @newFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Try our AI-based challenge generator!'**
  String get newFeatureDesc;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health stats'**
  String get statsTitle;

  /// No description provided for @aiTest.
  ///
  /// In en, this message translates to:
  /// **'AI test'**
  String get aiTest;

  /// No description provided for @devTestMessage.
  ///
  /// In en, this message translates to:
  /// **'Localization pipeline works!'**
  String get devTestMessage;

  /// No description provided for @testAuto.
  ///
  /// In en, this message translates to:
  /// **'Hello world'**
  String get testAuto;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
