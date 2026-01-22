import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sq.dart';

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
    Locale('sq')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EV Charge UI'**
  String get appTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Push notifications, email alerts'**
  String get notificationsSubtitle;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @albanian.
  ///
  /// In en, this message translates to:
  /// **'Shqip'**
  String get albanian;

  /// No description provided for @personalInfoVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information & Vehicle'**
  String get personalInfoVehicleTitle;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See top eco champions'**
  String get leaderboardSubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App version, terms, privacy'**
  String get aboutSubtitle;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'EVCharge'**
  String get aboutAppName;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(Object version);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'EVCharge helps you find and manage EV charging stations across Albania with ease.'**
  String get aboutDescription;

  /// No description provided for @totalCharges.
  ///
  /// In en, this message translates to:
  /// **'Total Charges'**
  String get totalCharges;

  /// No description provided for @co2Saved.
  ///
  /// In en, this message translates to:
  /// **'CO₂ Saved'**
  String get co2Saved;

  /// No description provided for @ecoPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco Points'**
  String get ecoPointsTitle;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @noVehicle.
  ///
  /// In en, this message translates to:
  /// **'No vehicle'**
  String get noVehicle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'unlocked'**
  String get unlocked;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy. This policy explains what data we collect and how we use it.\n\nInformation we collect\n• Profile information you provide (name, email, vehicle).\n• App usage data (searches, station views, charging sessions).\n• Device info for diagnostics (model, OS version, app version).\n\nHow we use your data\n• To provide, improve, and secure the app experience.\n• To personalize station recommendations and features.\n• To detect abuse and ensure service reliability.\n\nData retention\nWe retain your data only as long as necessary for the purposes above or as required by law.\n\nYour rights\nYou may request access, correction, or deletion of your personal data. Contact us at evcharging@gmail.com.'**
  String get privacyBody;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'By using EVCharge, you agree to these terms.\n\nUse of Service\n• You must use the app lawfully and responsibly.\n• We may update features and content at any time.\n\nAccounts\n• You are responsible for maintaining the confidentiality of your account.\n\nCharging Sessions & Safety\n• Always follow station safety instructions and local regulations.\n• Prices and availability may change and can vary by location.\n\nLimitation of Liability\n• EVCharge is provided ‘as is’ without warranties. We are not liable for indirect or incidental damages.\n\nChanges\n• We may modify these terms; continued use constitutes acceptance.\n\nContact\nFor questions, contact evcharging@gmail.com or 0697777778.'**
  String get termsBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @goodbyeTitle.
  ///
  /// In en, this message translates to:
  /// **'Goodbye!'**
  String get goodbyeTitle;

  /// No description provided for @thanksWithName.
  ///
  /// In en, this message translates to:
  /// **'Thank you {firstName}!'**
  String thanksWithName(String firstName);

  /// No description provided for @thanksGeneric.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thanksGeneric;

  /// No description provided for @goodbyeMessage.
  ///
  /// In en, this message translates to:
  /// **'Thanks for choosing us. We hope to see you again soon!'**
  String get goodbyeMessage;

  /// No description provided for @greenTip.
  ///
  /// In en, this message translates to:
  /// **'Together for a greener future! 🌱'**
  String get greenTip;

  /// No description provided for @deleteConfirmWithName.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}\'s account? This will remove all your data and cannot be undone.'**
  String deleteConfirmWithName(String name);

  /// No description provided for @deleteConfirmGeneric.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This will remove all your data and cannot be undone.'**
  String get deleteConfirmGeneric;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sq'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sq': return AppLocalizationsSq();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
