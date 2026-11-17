import 'package:alfajr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/prayers.dart';
import '../resources/colors.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';

Future<void> showMoreBottomSheet(
  BuildContext context,
  PrayersModel prayersToday,
) {
  final theme = Provider.of<ThemeNotifier>(context, listen: false);
  final isDark = theme.themeMode == ThemeMode.dark;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: isDark ? appBarColor : color1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      final localeProvider = Provider.of<LocaleNotifier>(sheetContext, listen: false);
      final textDirection = localeProvider.getTextDirection(localeProvider.locale);
      final textColor = isDark ? colorTextDark : Colors.black87;
      final iconColor = isDark ? Colors.white : color5;

      return Directionality(
        textDirection: textDirection,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAndroid || isWindows || isIOS)
                  ListTile(
                    leading: Image.asset(
                      'images/misbaha.png',
                      height: 24,
                      width: 24,
                      color: isDark ? null : color5,
                    ),
                    title: Text(
                      l10n.dhikrString,
                      style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, '/counter');
                    },
                  ),
                if (isAndroid || isWindows || isIOS)
                  ListTile(
                    leading: Image.asset(
                      'images/salah.png',
                      height: 24,
                      width: 24,
                      color: isDark ? null : color5,
                    ),
                    title: Text(
                      l10n.missedPrayersString,
                      style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, '/missed_prayer');
                    },
                  ),
                if (isAndroid || isWindows || isIOS)
                  ListTile(
                    leading: Icon(Icons.menu_book_outlined, color: iconColor),
                    title: Text(
                      l10n.mathuratTitle,
                      style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, '/mathurat');
                    },
                  ),
                // TODO: Restore Our Apps, Contact Us, and Share items when ready.
              ],
            ),
          ),
        ),
      );
    },
  );
}
