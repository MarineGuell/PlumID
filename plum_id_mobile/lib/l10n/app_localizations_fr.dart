// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get profileTitle => 'Profil';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get language => 'Langue';

  @override
  String get rateUs => 'Notez nous';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get feedback => 'Feedback';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get logout => 'Déconnexion';

  @override
  String get version => 'Version';

  @override
  String get about => 'À propos';

  @override
  String get logoutNotImplemented => 'Déconnexion à implémenter';

  @override
  String get deleteAccountNotImplemented =>
      'Suppression du compte à implémenter';
}
