import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// Strings for the active locale, which follows `appLanguageProvider`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
