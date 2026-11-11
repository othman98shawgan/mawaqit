import 'package:alfajr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/prayers.dart';
import '../resources/colors.dart';
import '../services/locale_service.dart';
import '../services/prayer_methods.dart';
import '../services/theme_service.dart';

Future<void> showMoreBottomSheet(
  BuildContext context,
  PrayersModel prayersToday,
) {
  final theme = Provider.of<ThemeNotifier>(context, listen: false);
  final isDark = theme.themeMode == ThemeMode.dark;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: isDark ? appBarColor : color1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                if (!isIOS)
                  ListTile(
                    leading: Icon(Icons.apps, color: iconColor),
                    title: Text(
                      l10n.ourAppsString,
                      style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, '/apps');
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.email, color: iconColor),
                  title: Text(
                    l10n.contactUsString,
                    style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final subject = Uri.encodeComponent(l10n.contactUsEmailSubject);
                    final body = Uri.encodeComponent(l10n.contactUsEmailBody);
                    final url = Uri.parse('mailto:oth1998@gmail.com?subject=$subject&body=$body');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch $url';
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share, color: iconColor),
                  title: Text(
                    l10n.shareString,
                    style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    sharePrayerTimes(
                      context,
                      localeProvider,
                      prayersToday,
                      DateTime.now(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
