// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EV Charge UI';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Push notifications, email alerts';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Enable dark theme';

  @override
  String get languageTitle => 'Language';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get albanian => 'Shqip';

  @override
  String get personalInfoVehicleTitle => 'Personal Information & Vehicle';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardSubtitle => 'See top eco champions';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSubtitle => 'App version, terms, privacy';

  @override
  String get aboutAppName => 'EVCharge';

  @override
  String version(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription => 'EVCharge helps you find and manage EV charging stations across Albania with ease.';

  @override
  String get totalCharges => 'Total Charges';

  @override
  String get co2Saved => 'CO₂ Saved';

  @override
  String get ecoPointsTitle => 'Eco Points';

  @override
  String get guestUser => 'Guest User';

  @override
  String get noVehicle => 'No vehicle';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get unlocked => 'unlocked';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get close => 'Close';

  @override
  String get logOut => 'Log out';

  @override
  String get privacyBody => 'We respect your privacy. This policy explains what data we collect and how we use it.\n\nInformation we collect\n• Profile information you provide (name, email, vehicle).\n• App usage data (searches, station views, charging sessions).\n• Device info for diagnostics (model, OS version, app version).\n\nHow we use your data\n• To provide, improve, and secure the app experience.\n• To personalize station recommendations and features.\n• To detect abuse and ensure service reliability.\n\nData retention\nWe retain your data only as long as necessary for the purposes above or as required by law.\n\nYour rights\nYou may request access, correction, or deletion of your personal data. Contact us at evcharging@gmail.com.';

  @override
  String get termsBody => 'By using EVCharge, you agree to these terms.\n\nUse of Service\n• You must use the app lawfully and responsibly.\n• We may update features and content at any time.\n\nAccounts\n• You are responsible for maintaining the confidentiality of your account.\n\nCharging Sessions & Safety\n• Always follow station safety instructions and local regulations.\n• Prices and availability may change and can vary by location.\n\nLimitation of Liability\n• EVCharge is provided ‘as is’ without warranties. We are not liable for indirect or incidental damages.\n\nChanges\n• We may modify these terms; continued use constitutes acceptance.\n\nContact\nFor questions, contact evcharging@gmail.com or 0697777778.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get continueAction => 'Continue';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get goodbyeTitle => 'Goodbye!';

  @override
  String thanksWithName(String firstName) {
    return 'Thank you $firstName!';
  }

  @override
  String get thanksGeneric => 'Thank you!';

  @override
  String get goodbyeMessage => 'Thanks for choosing us. We hope to see you again soon!';

  @override
  String get greenTip => 'Together for a greener future! 🌱';

  @override
  String deleteConfirmWithName(String name) {
    return 'Are you sure you want to delete $name\'s account? This will remove all your data and cannot be undone.';
  }

  @override
  String get deleteConfirmGeneric => 'Are you sure you want to delete your account? This will remove all your data and cannot be undone.';

  @override
  String get couponCodeTitle => 'Coupon code';

  @override
  String get couponLockedDescription => 'Complete all achievements to unlock your coupon.';

  @override
  String couponUnlockedDescription(int amount) {
    return 'You unlocked a reward of $amount ALL.';
  }

  @override
  String get revealCoupon => 'Reveal coupon';

  @override
  String get locked => 'Locked';

  @override
  String get rewardAlreadyRedeemed => 'Reward already redeemed.';

  @override
  String couponRevealedSnack(String code, int amount) {
    return 'Coupon revealed: $code (+$amount ALL)';
  }
}
