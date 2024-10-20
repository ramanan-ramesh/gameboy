import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsExt on BuildContext {
  AppLocalizations withLocale() {
    return AppLocalizations.of(this)!;
  }
}
