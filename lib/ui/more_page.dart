import 'dart:ui' as ui;

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

class MorePage extends StatelessWidget {
  const MorePage({
    super.key,
    required this.prayersToday,
  });

  final PrayersModel prayersToday;

  Future<void> _contactUs(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final subject = Uri.encodeComponent(l10n.contactUsEmailSubject);
    final body = Uri.encodeComponent(l10n.contactUsEmailBody);
    final url = Uri.parse('mailto:oth1998@gmail.com?subject=$subject&body=$body');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildMoreTile({
    required BuildContext context,
    required Widget leading,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      color: isDark ? prayerBgColorDark : color3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: leading,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: textColor,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: textColor.withValues(alpha: 0.7),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer2<ThemeNotifier, LocaleNotifier>(
      builder: (context, theme, localeProvider, _) {
        final isDark = theme.themeMode == ThemeMode.dark;
        final textColor = isDark ? colorTextDark : colorTextLight;
        final textDirection = localeProvider.getTextDirection(localeProvider.locale);

        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.moreString,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(theme.backgroundImage!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Directionality(
                textDirection: textDirection,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    if (isAndroid || isWindows || isIOS)
                      _buildMoreTile(
                        context: context,
                        leading: Image.asset(
                          'images/misbaha.png',
                          height: 28,
                          width: 28,
                        ),
                        title: l10n.dhikrString,
                        isDark: isDark,
                        textColor: textColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/counter');
                        },
                      ),
                    if (isAndroid || isWindows || isIOS)
                      _buildMoreTile(
                        context: context,
                        leading: Image.asset(
                          'images/salah.png',
                          height: 28,
                          width: 28,
                        ),
                        title: l10n.missedPrayersString,
                        isDark: isDark,
                        textColor: textColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/missed_prayer');
                        },
                      ),
                    if (!isIOS)
                      _buildMoreTile(
                        context: context,
                        leading: Icon(Icons.apps, color: textColor, size: 28),
                        title: l10n.ourAppsString,
                        isDark: isDark,
                        textColor: textColor,
                        onTap: () {
                          Navigator.pushNamed(context, '/apps');
                        },
                      ),
                    _buildMoreTile(
                      context: context,
                      leading: Icon(Icons.email, color: textColor, size: 28),
                      title: l10n.contactUsString,
                      isDark: isDark,
                      textColor: textColor,
                      onTap: () async {
                        await _contactUs(context);
                      },
                    ),
                    _buildMoreTile(
                      context: context,
                      leading: Icon(Icons.share, color: textColor, size: 28),
                      title: l10n.shareString,
                      isDark: isDark,
                      textColor: textColor,
                      onTap: () {
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
          ),
        );
      },
    );
  }
}
