// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profileTitle => 'Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get language => 'Language';

  @override
  String get rateUs => 'Rate Us';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get feedback => 'Feedback';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get logout => 'Logout';

  @override
  String get version => 'Version';

  @override
  String get about => 'About';

  @override
  String get logoutNotImplemented => 'Logout not yet implemented';

  @override
  String get deleteAccountNotImplemented =>
      'Delete account not yet implemented';

  @override
  String get logoutConfirmationTitle => 'Logout';

  @override
  String get logoutConfirmationMessage => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteAccountConfirmationTitle => 'Delete Account';

  @override
  String get deleteAccountConfirmationMessage =>
      'Are you sure you want to permanently delete your account? This action cannot be undone.';
}
