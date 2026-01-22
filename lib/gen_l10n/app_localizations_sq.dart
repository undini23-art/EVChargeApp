// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Albanian (`sq`).
class AppLocalizationsSq extends AppLocalizations {
  AppLocalizationsSq([String locale = 'sq']) : super(locale);

  @override
  String get appTitle => 'EV Charge UI';

  @override
  String get profileTitle => 'Profili';

  @override
  String get settingsTitle => 'Cilësimet';

  @override
  String get notificationsTitle => 'Njoftimet';

  @override
  String get notificationsSubtitle => 'Njoftime push, njoftime me email';

  @override
  String get darkModeTitle => 'Modaliteti i errët';

  @override
  String get darkModeSubtitle => 'Aktivo temën e errët';

  @override
  String get languageTitle => 'Gjuha';

  @override
  String get selectLanguageTitle => 'Zgjidh gjuhën';

  @override
  String get english => 'Anglisht';

  @override
  String get albanian => 'Shqip';

  @override
  String get personalInfoVehicleTitle => 'Informacion Personal & Automjet';

  @override
  String get achievementsTitle => 'Arritjet';

  @override
  String get leaderboardTitle => 'Renditja';

  @override
  String get leaderboardSubtitle => 'Shiko kampionët e eko‑pikëve';

  @override
  String get aboutTitle => 'Rreth Aplikacionit';

  @override
  String get aboutSubtitle => 'Versioni i aplikacionit, termat, privatësia';

  @override
  String get aboutAppName => 'EVCharge';

  @override
  String version(Object version) {
    return 'Versioni $version';
  }

  @override
  String get aboutDescription => 'EVCharge të ndihmon të gjesh dhe menaxhosh stacionet e karikimit në gjithë Shqipërinë me lehtësi.';

  @override
  String get totalCharges => 'Karikimet Totale';

  @override
  String get co2Saved => 'CO₂ e kursyer';

  @override
  String get ecoPointsTitle => 'Pikë Eko';

  @override
  String get guestUser => 'Përdorues i ftuar';

  @override
  String get noVehicle => 'Pa automjet';

  @override
  String get deleteAccount => 'Fshi llogarinë';

  @override
  String get unlocked => 'të zhbllokuara';

  @override
  String get privacyPolicy => 'Politika e Privatësisë';

  @override
  String get termsOfService => 'Kushtet e Shërbimit';

  @override
  String get contactSupport => 'Kontakto Mbështetjen';

  @override
  String get close => 'Mbyll';

  @override
  String get logOut => 'Dil';

  @override
  String get privacyBody => 'Ne respektojmë privatësinë tuaj. Kjo politikë shpjegon çfarë të dhënash mbledhim dhe si i përdorim ato.\n\nÇfarë mbledhim\n• Informacion profili që jepni (emri, emaili, automjeti).\n• Të dhëna përdorimi (kërkime, shikime stacionesh, sesione karikimi).\n• Informacion pajisjeje për diagnostikim (modeli, versioni i OS, versioni i aplikacionit).\n\nSi i përdorim të dhënat tuaja\n• Për të ofruar, përmirësuar dhe siguruar përvojën e aplikacionit.\n• Për të personalizuar rekomandimet dhe veçoritë.\n• Për të zbuluar abuzimin dhe për të siguruar besueshmërinë e shërbimit.\n\nRuajtja e të dhënave\nI ruajmë të dhënat vetëm aq sa është e nevojshme për qëllimet e mësipërme ose sipas ligjit.\n\nTë drejtat tuaja\nMund të kërkoni akses, korrigjim ose fshirje të të dhënave personale. Na kontaktoni në evcharging@gmail.com.';

  @override
  String get termsBody => 'Duke përdorur EVCharge, ju pranoni këto kushte.\n\nPërdorimi i Shërbimit\n• Duhet ta përdorni aplikacionin në mënyrë ligjore dhe me përgjegjësi.\n• Ne mund të përditësojmë veçoritë dhe përmbajtjen në çdo kohë.\n\nLlogaritë\n• Ju jeni përgjegjës për ruajtjen e konfidencialitetit të llogarisë suaj.\n\nSesione Karikimi & Siguria\n• Ndiqni gjithmonë udhëzimet e sigurisë së stacionit dhe rregullat lokale.\n• Çmimet dhe disponueshmëria mund të ndryshojnë dhe variojnë sipas vendndodhjes.\n\nKufizimi i Përgjegjësisë\n• EVCharge ofrohet “siç është” pa garanci. Ne nuk jemi përgjegjës për dëme të tërthorta ose rastësore.\n\nNdryshimet\n• Ne mund t’i modifikojmë këto kushte; vazhdimi i përdorimit nënkupton pranimin.\n\nKontakti\nPër pyetje, kontaktoni evcharging@gmail.com ose 0697777778.';

  @override
  String get cancel => 'Anulo';

  @override
  String get confirm => 'Konfirmo';

  @override
  String get continueAction => 'Vazhdo';

  @override
  String get ok => 'OK';

  @override
  String get done => 'U krye';

  @override
  String get goodbyeTitle => 'Mirupafshim!';

  @override
  String thanksWithName(String firstName) {
    return 'Faleminderit $firstName!';
  }

  @override
  String get thanksGeneric => 'Faleminderit!';

  @override
  String get goodbyeMessage => 'Ju faleminderit që na zgjodhët. Shpresojmë t\'ju shohim sërish shpejt!';

  @override
  String get greenTip => 'Së bashku për një të ardhme më të gjelbër! 🌱';

  @override
  String deleteConfirmWithName(String name) {
    return 'Jeni i sigurt që dëshironi të fshini llogarinë e $name? Kjo do të fshijë të gjitha të dhënat tuaja dhe nuk do të mund të rikthehet.';
  }

  @override
  String get deleteConfirmGeneric => 'Jeni i sigurt që dëshironi të fshini llogarinë tuaj? Kjo do të fshijë të gjitha të dhënat tuaja dhe nuk do të mund të rikthehet.';

  @override
  String get couponCodeTitle => 'Kodi kuponit';

  @override
  String get couponLockedDescription => 'Plotëso të gjitha arritjet për të zhbllokuar kuponin.';

  @override
  String couponUnlockedDescription(int amount) {
    return 'Ke zhbllokuar një shpërblim prej $amount ALL.';
  }

  @override
  String get revealCoupon => 'Shfaq kuponin';

  @override
  String get locked => 'I kyçur';

  @override
  String get rewardAlreadyRedeemed => 'Shpërblimi është përdorur tashmë.';

  @override
  String couponRevealedSnack(String code, int amount) {
    return 'Kuponi u shfaq: $code (+$amount ALL)';
  }
}
