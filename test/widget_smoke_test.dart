import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/main.dart' as app_main;
import 'package:alfajr/models/prayers.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/theme_service.dart';
import 'package:alfajr/ui/mathurat_page.dart';
import 'package:alfajr/ui/more_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeNotifier(ThemeMode.light)),
      ChangeNotifierProvider(create: (_) => LocaleNotifier(const Locale('en'), 'alQuds')),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    app_main.isAndroid = true;
  });

  tearDown(() {
    app_main.isAndroid = false;
  });

  testWidgets('More bottom sheet shows Dhikr, Missed Prayers, and Mathurat without Our Apps/Contact/Share',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showMoreBottomSheet(context, PrayersModel.empty()),
                child: const Text('Open More'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open More'));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.text('Open More')))!;

    expect(find.text(l10n.dhikrString), findsOneWidget);
    expect(find.text(l10n.missedPrayersString), findsOneWidget);
    expect(find.text(l10n.mathuratTitle), findsOneWidget);

    expect(find.text(l10n.ourAppsString), findsNothing);
    expect(find.text(l10n.contactUsString), findsNothing);
    expect(find.text(l10n.shareString), findsNothing);
  });

  testWidgets('MathuratPage loads morning and evening tabs', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(const MathuratPage()));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(MathuratPage)))!;
    expect(find.text(l10n.mathuratTitle), findsOneWidget);
    expect(find.text(l10n.mathuratMorning), findsOneWidget);
    expect(find.text(l10n.mathuratEvening), findsOneWidget);
  });
}
