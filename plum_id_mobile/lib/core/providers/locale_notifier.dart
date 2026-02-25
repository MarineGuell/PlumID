import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_notifier.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    // Par défaut, on choisit le français.
    // Plus tard, on pourra lire cette valeur depuis les SharedPreferences
    return const Locale('fr');
  }

  void setLocale(Locale newLocale) {
    state = newLocale;
    // Plus tard, on pourra sauvegarder ce choix dans SharedPreferences ici
  }
}
