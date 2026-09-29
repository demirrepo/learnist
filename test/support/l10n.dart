import 'package:flutter/widgets.dart';
import 'package:learnist/l10n/app_localizations.dart';

/// What `LearnistApp` passes to `MaterialApp`; screens pumped on their
/// own need the same to read `context.l10n`.
const testLocalizationsDelegates = AppLocalizations.localizationsDelegates;
const testSupportedLocales = AppLocalizations.supportedLocales;

/// The app's default language.
const testLocale = Locale('uz');
