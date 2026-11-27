import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/theme_service.dart';
import 'package:alfajr/ui/calendar_page.dart';
import 'package:alfajr/ui/widgets/light_swipe_page_physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DaylightSavingNotifier()),
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

String _formatDate(DateTime date) => DateFormat('dd MMM yyyy', 'en').format(date);

void _setPortraitViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CalendarPage renders today and hides Today button initially', (WidgetTester tester) async {
    _setPortraitViewport(tester);
    await tester.pumpWidget(_buildTestApp(const CalendarPage()));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final l10n = AppLocalizations.of(tester.element(find.byType(CalendarPage)))!;

    expect(find.text(_formatDate(today)), findsOneWidget);
    expect(find.byTooltip(l10n.todayTooltip), findsNothing);
    expect(find.byType(PageView), findsOneWidget);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.pageSnapping, isFalse);
    expect(pageView.physics, isA<LightSwipePagePhysics>());
  });

  testWidgets('CalendarPage swipes left to next day and right to previous day', (WidgetTester tester) async {
    _setPortraitViewport(tester);
    await tester.pumpWidget(_buildTestApp(const CalendarPage()));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final l10n = AppLocalizations.of(tester.element(find.byType(CalendarPage)))!;

    // Swipe left -> tomorrow
    await tester.fling(find.byType(PageView), const Offset(-200, 0), 800);
    await tester.pumpAndSettle();

    expect(find.text(_formatDate(tomorrow)), findsOneWidget);
    expect(find.byTooltip(l10n.todayTooltip), findsOneWidget);

    // Swipe right -> back to today
    await tester.fling(find.byType(PageView), const Offset(200, 0), 800);
    await tester.pumpAndSettle();

    expect(find.text(_formatDate(today)), findsOneWidget);
    expect(find.byTooltip(l10n.todayTooltip), findsNothing);

    // Swipe right again -> yesterday
    await tester.fling(find.byType(PageView), const Offset(200, 0), 800);
    await tester.pumpAndSettle();

    expect(find.text(_formatDate(yesterday)), findsOneWidget);
    expect(find.byTooltip(l10n.todayTooltip), findsOneWidget);
  });

  testWidgets('CalendarPage arrow buttons and Today button navigate via PageController', (WidgetTester tester) async {
    _setPortraitViewport(tester);
    await tester.pumpWidget(_buildTestApp(const CalendarPage()));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final dayAfterTomorrow = DateTime(today.year, today.month, today.day + 2);
    final l10n = AppLocalizations.of(tester.element(find.byType(CalendarPage)))!;

    // Tap next day twice
    await tester.tap(find.byTooltip(l10n.nextDayTooltip));
    await tester.pumpAndSettle();
    expect(find.text(_formatDate(tomorrow)), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.nextDayTooltip));
    await tester.pumpAndSettle();
    expect(find.text(_formatDate(dayAfterTomorrow)), findsOneWidget);

    // Tap previous day once
    await tester.tap(find.byTooltip(l10n.prevoiusDayTooltip));
    await tester.pumpAndSettle();
    expect(find.text(_formatDate(tomorrow)), findsOneWidget);

    // Tap Today button to jump back
    await tester.tap(find.byTooltip(l10n.todayTooltip));
    await tester.pumpAndSettle();
    expect(find.text(_formatDate(today)), findsOneWidget);
    expect(find.byTooltip(l10n.todayTooltip), findsNothing);
  });

  test('LightSwipePagePhysics configures light fling and spring parameters', () {
    const physics = LightSwipePagePhysics();
    expect(physics.minFlingVelocity, 20.0);
    expect(physics.spring.mass, 0.5);
    expect(physics.spring.stiffness, 200.0);
    expect(physics.spring.damping, 21.0);
  });
}
