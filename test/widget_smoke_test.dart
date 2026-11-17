import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/main.dart' as app_main;
import 'package:alfajr/models/prayers.dart';
import 'package:alfajr/services/haptic_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/theme_service.dart';
import 'package:alfajr/ui/mathurat_page.dart';
import 'package:alfajr/ui/more_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    rootBundle.evict('lib/data/mathurat.json');
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
    expect(find.byTooltip(l10n.mathuratVibrateOn), findsOneWidget);
  });

  testWidgets('MathuratPage vibrate toggle persists preference and gates haptic feedback',
      (WidgetTester tester) async {
    final hapticCalls = <String>[];
    HapticService.debugOnVibrate = hapticCalls.add;
    addTearDown(() => HapticService.debugOnVibrate = null);

    await tester.pumpWidget(_buildTestApp(const MathuratPage()));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(MathuratPage)))!;

    // Vibration starts enabled: tapping a card triggers haptic feedback.
    await tester.tap(find.byType(MathuratCard).first);
    await tester.pumpAndSettle();
    expect(hapticCalls.length, 1);

    // Toggle vibration off: no haptic feedback and preference persisted as false.
    await tester.tap(find.byTooltip(l10n.mathuratVibrateOn));
    await tester.pumpAndSettle();
    expect(find.byTooltip(l10n.mathuratVibrateOff), findsOneWidget);
    expect(hapticCalls.length, 1);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('MathuratVibrate'), isFalse);

    // Tapping a card while vibration is off does not trigger haptic feedback.
    await tester.tap(find.byType(MathuratCard).first);
    await tester.pumpAndSettle();
    expect(hapticCalls.length, 1);

    // Toggle vibration back on: triggers tap confirmation and persists true.
    await tester.tap(find.byTooltip(l10n.mathuratVibrateOff));
    await tester.pumpAndSettle();
    expect(find.byTooltip(l10n.mathuratVibrateOn), findsOneWidget);
    expect(hapticCalls.length, 2);
    expect(hapticCalls.last, 'tap');
    expect(prefs.getBool('MathuratVibrate'), isTrue);
  });

  testWidgets('MathuratPage loads persisted disabled vibration preference on start',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'MathuratVibrate': false});
    final hapticCalls = <String>[];
    HapticService.debugOnVibrate = hapticCalls.add;
    addTearDown(() => HapticService.debugOnVibrate = null);

    await tester.pumpWidget(_buildTestApp(const MathuratPage()));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(MathuratPage)))!;
    expect(find.byTooltip(l10n.mathuratVibrateOff), findsOneWidget);

    await tester.tap(find.byType(MathuratCard).first);
    await tester.pumpAndSettle();
    expect(hapticCalls, isEmpty);
  });
}
