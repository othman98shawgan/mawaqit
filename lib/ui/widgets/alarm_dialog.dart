import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alfajr/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../data/prayer_times.dart';
import '../../models/prayer_alarm.dart';
import '../../models/prayers.dart';
import '../../resources/colors.dart';
import '../../services/day_of_year_service.dart';
import '../../services/daylight_time_service.dart';
import '../../services/locale_service.dart';
import '../../services/prayer_alarm_service.dart';
import '../../services/prayer_methods.dart';
import '../../services/store_manager.dart';

Future<void> showAlarmBottomSheet(
  BuildContext context, {
  required String initialPrayerName,
  VoidCallback? onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AlarmBottomSheet(
      initialPrayerName: initialPrayerName,
      onSaved: onSaved,
    ),
  );
}

class AlarmBottomSheet extends StatefulWidget {
  final String initialPrayerName;
  final VoidCallback? onSaved;

  const AlarmBottomSheet({
    super.key,
    required this.initialPrayerName,
    this.onSaved,
  });

  @override
  State<AlarmBottomSheet> createState() => _AlarmBottomSheetState();
}

class _AlarmBottomSheetState extends State<AlarmBottomSheet> with WidgetsBindingObserver {
  static const List<String> _prayers = ['Fajr', 'Shuruq', 'Duhr', 'Asr', 'Maghrib', 'Isha'];
  static const List<String> _adhanOptions = [
    'alaqsa',
    'makkah',
    'madina',
    'abdulbasit',
    'minshawi',
    'hussary',
    'nafees',
  ];
  static const List<int> _snoozeOptions = [0, 5, 10, 15];

  late String _selectedPrayer;
  Map<String, PrayerAlarmSettings> _allSettings = {};
  Map<String, DateTime> _todayPrayerTimes = {};
  final Map<String, String> _lastAdhanByPrayer = {};
  final Map<String, GlobalKey> _tabKeys = {
    for (final p in _prayers) p: GlobalKey(),
  };
  bool _isLoading = true;
  bool _batteryOptimizationIgnored = true;
  bool _fullScreenIntentGranted = true;
  bool _isDevMode = false;
  bool _isTestingAlarm = false;
  String? _previewingSound;
  bool _showAppliedBanner = false;
  Timer? _rescheduleDebounce;
  Timer? _appliedBannerTimer;

  @override
  void initState() {
    super.initState();
    _selectedPrayer = _prayers.contains(widget.initialPrayerName) ? widget.initialPrayerName : 'Fajr';
    WidgetsBinding.instance.addObserver(this);
    _loadAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rescheduleDebounce?.cancel();
    _appliedBannerTimer?.cancel();
    if (_previewingSound != null) {
      PrayerAlarmService.stopPreviewAudio();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _loadAll() async {
    final loaded = await PrayerAlarmService.loadAllAlarmSettings();
    final ignored = await PrayerAlarmService.isBatteryOptimizationIgnored();
    final fullScreen = await PrayerAlarmService.canUseFullScreenIntent();
    final devRaw = await StorageManager.readData('isDevMode');
    final isDev = devRaw is bool && devRaw;

    final Map<String, DateTime> todayTimes = {};
    try {
      if (mounted) {
        final dst = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime();
        final diff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;
        final now = DateTime.now();
        final data = json.decode(prayersJson) as List;
        final idx = dayOfYear(now);
        if (idx >= 0 && idx < data.length) {
          final model = PrayersModel.fromJson(data[idx]);
          for (final p in getDayPrayers(now, model, dst, diff)) {
            todayTimes[p.label] = p.time;
          }
        }
      }
    } catch (_) {}

    if (!mounted) return;
    for (final entry in loaded.entries) {
      if (_adhanOptions.contains(entry.value.soundType)) {
        _lastAdhanByPrayer[entry.key] = entry.value.soundType;
      }
    }
    setState(() {
      _allSettings = loaded;
      _todayPrayerTimes = todayTimes;
      _batteryOptimizationIgnored = ignored;
      _fullScreenIntentGranted = fullScreen;
      _isDevMode = isDev;
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedTab(animate: false));
  }

  void _scrollToSelectedTab({bool animate = true}) {
    final ctx = _tabKeys[_selectedPrayer]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: animate ? const Duration(milliseconds: 220) : Duration.zero,
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _refreshPermissions() async {
    final ignored = await PrayerAlarmService.isBatteryOptimizationIgnored();
    final fullScreen = await PrayerAlarmService.canUseFullScreenIntent();
    if (mounted) {
      setState(() {
        _batteryOptimizationIgnored = ignored;
        _fullScreenIntentGranted = fullScreen;
      });
    }
  }

  PrayerAlarmSettings get _current =>
      _allSettings[_selectedPrayer] ?? PrayerAlarmSettings(prayerName: _selectedPrayer);

  bool _isAdhanMode(PrayerAlarmSettings s) => s.isEnabled && _adhanOptions.contains(s.soundType);

  bool _isDefaultMode(PrayerAlarmSettings s) =>
      s.isEnabled && (s.soundType == 'system' || s.soundType == 'silent');

  String _getSoundTitle(String soundKey, AppLocalizations l10n) {
    switch (soundKey) {
      case 'alaqsa':
        return l10n.soundAlaqsa;
      case 'makkah':
        return l10n.soundMakkah;
      case 'madina':
        return l10n.soundMadina;
      case 'abdulbasit':
        return l10n.soundAbdulbasit;
      case 'minshawi':
        return l10n.soundMinshawi;
      case 'hussary':
        return l10n.soundHussary;
      case 'nafees':
        return l10n.soundNafees;
      case 'system':
        return l10n.soundSystem;
      case 'silent':
        return l10n.soundSilent;
      default:
        return l10n.soundAlaqsa;
    }
  }

  Future<void> _updateCurrent(PrayerAlarmSettings updated, {bool checkPermissions = false}) async {
    if (_adhanOptions.contains(updated.soundType)) {
      _lastAdhanByPrayer[_selectedPrayer] = updated.soundType;
    }
    if (_previewingSound != null && (!updated.isEnabled || !_adhanOptions.contains(updated.soundType))) {
      await _stopPreviewAudio();
    }
    setState(() {
      _allSettings[_selectedPrayer] = updated;
    });

    await PrayerAlarmService.saveAlarmSettings(updated);
    if (!kIsWeb && Platform.isAndroid && !updated.isEnabled) {
      await PrayerAlarmService.cancelAlarm(_selectedPrayer);
    }

    if (checkPermissions && updated.isEnabled && !kIsWeb && Platform.isAndroid) {
      await _promptPermissionsIfNeeded();
    }

    _scheduleDebouncedReschedule();
    widget.onSaved?.call();
  }

  Future<void> _stopPreviewAudio() async {
    if (_previewingSound == null) return;
    await PrayerAlarmService.stopPreviewAudio();
    if (mounted) {
      setState(() => _previewingSound = null);
    }
  }

  Future<void> _togglePreviewAudio(String soundType) async {
    if (_previewingSound == soundType) {
      await _stopPreviewAudio();
      return;
    }
    await PrayerAlarmService.startPreviewAudio(soundType);
    if (mounted) {
      setState(() => _previewingSound = soundType);
    }
  }

  Future<void> _triggerQuickTestAlarm() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isTestingAlarm = true);
    await _stopPreviewAudio();

    await PrayerAlarmService.scheduleTestAlarm(
      soundType: _current.soundType,
      delaySeconds: 5,
      snoozeMinutes: _current.snoozeMinutes,
      title: l10n.testAlarmTitle,
      body: _getSoundTitle(_current.soundType, l10n),
      dismissLabel: l10n.alarmDismiss,
      snoozeLabel: l10n.alarmSnooze,
    );

    if (mounted) {
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted) setState(() => _isTestingAlarm = false);
      });
    }
  }

  Future<void> _promptPermissionsIfNeeded() async {
    if (!_batteryOptimizationIgnored) {
      final granted = await PrayerAlarmService.requestIgnoreBatteryOptimization();
      if (mounted) {
        setState(() => _batteryOptimizationIgnored = granted);
      }
    }
  }

  void _scheduleDebouncedReschedule() {
    _rescheduleDebounce?.cancel();
    _rescheduleDebounce = Timer(const Duration(milliseconds: 350), _rescheduleAllAlarms);
  }

  Future<void> _rescheduleAllAlarms() async {
    if (!mounted || kIsWeb || !Platform.isAndroid) return;
    final dstNotifier = Provider.of<DaylightSavingNotifier>(context, listen: false);
    final diff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;
    final localizedTitles = getLocalizedPrayerAlarmTitles(context);
    final offsets = _allSettings.map((k, v) => MapEntry(k, v.offsetMinutes));
    final localizedBodies = getLocalizedPrayerAlarmMessages(context, offsets);

    await PrayerAlarmService.scheduleUpcomingAlarms(
      summerTime: dstNotifier.getSummerTime(),
      timeDiff: diff,
      localizedTitles: localizedTitles,
      localizedBodies: localizedBodies,
    );
  }

  Future<void> _applyToAllPrayers() async {
    final template = _current;
    final updatedMap = <String, PrayerAlarmSettings>{};
    for (final prayer in _prayers) {
      updatedMap[prayer] = template.copyWith(prayerName: prayer);
    }

    setState(() {
      _allSettings = updatedMap;
      _showAppliedBanner = true;
    });

    _appliedBannerTimer?.cancel();
    _appliedBannerTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showAppliedBanner = false);
    });

    for (final settings in updatedMap.values) {
      await PrayerAlarmService.saveAlarmSettings(settings);
    }

    if (!kIsWeb && Platform.isAndroid && !template.isEnabled) {
      for (final prayer in _prayers) {
        await PrayerAlarmService.cancelAlarm(prayer);
      }
    } else if (template.isEnabled && !kIsWeb && Platform.isAndroid) {
      await _promptPermissionsIfNeeded();
    }

    _rescheduleDebounce?.cancel();
    await _rescheduleAllAlarms();
    widget.onSaved?.call();
  }

  void _stepOffset(int deltaMinutes) {
    final currentAbs = _current.offsetMinutes.abs();
    final nextAbs = (currentAbs + deltaMinutes).clamp(0, 60);
    _updateCurrent(_current.copyWith(offsetMinutes: nextAbs == 0 ? 0 : -nextAbs));
  }

  void _stepSnooze(int direction) {
    final idx = _snoozeOptions.indexOf(_current.snoozeMinutes);
    final safeIdx = idx == -1 ? 2 : idx;
    final nextIdx = (safeIdx + direction).clamp(0, _snoozeOptions.length - 1);
    _updateCurrent(_current.copyWith(snoozeMinutes: _snoozeOptions[nextIdx]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    final textDirection = localeNotifier.getTextDirection(localeNotifier.locale);

    final sheetBg = isDark ? const Color(0xFF1A2026) : const Color(0xFFFDFCF9);
    final cardBg = isDark ? const Color(0xFF242B33) : const Color(0xFFF3F1EC);
    final innerTileBg = isDark ? const Color(0xFF2D3640) : const Color(0xFFE7E4DC);
    final primaryAccent = isDark ? Colors.teal.shade600 : color3;
    final softAccent = isDark ? Colors.teal.withValues(alpha: 0.22) : color3.withValues(alpha: 0.14);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E2421);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF5F6863);

    return Directionality(
      textDirection: textDirection,
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header with centered title and close button
                Row(
                  children: [
                    const SizedBox(width: 36),
                    Expanded(
                      child: Text(
                        l10n.alarmSection,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Material(
                      color: cardBg,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(Icons.close, size: 20, color: textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  // Horizontal Prayer Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _prayers.map((prayer) {
                        final isSelected = prayer == _selectedPrayer;
                        final prayerSettings = _allSettings[prayer];
                        final hasAlarm = prayerSettings?.isEnabled ?? false;

                        return Padding(
                          key: _tabKeys[prayer],
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPrayer = prayer);
                              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedTab());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    getPrayerTranslation(prayer, context),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? Colors.white : textSecondary,
                                    ),
                                  ),
                                  if (hasAlarm && !isSelected) ...[
                                    const SizedBox(width: 5),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: primaryAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Exact prayer & alarm ring time preview
                  if (_todayPrayerTimes.containsKey(_selectedPrayer)) ...[
                    Builder(builder: (context) {
                      final prayerDt = _todayPrayerTimes[_selectedPrayer]!;
                      final prayerTimeStr = DateFormat('HH:mm').format(prayerDt);
                      final ringDt = prayerDt.add(Duration(minutes: _current.offsetMinutes));
                      final ringTimeStr = DateFormat('HH:mm').format(ringDt);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, size: 14, color: textSecondary),
                            const SizedBox(width: 5),
                            Text(
                              _current.isEnabled
                                  ? '${getPrayerTranslation(_selectedPrayer, context)} $prayerTimeStr  •  ${l10n.alarmRingsAt(ringTimeStr)}'
                                  : '${getPrayerTranslation(_selectedPrayer, context)} $prayerTimeStr',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _current.isEnabled ? primaryAccent : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else
                    const SizedBox(height: 4),

                  // Full-screen intent permission card (Android 14+ when not granted)
                  if (!kIsWeb && Platform.isAndroid && !_fullScreenIntentGranted) ...[
                    _buildInfoBannerCard(
                      cardBg: cardBg,
                      icon: Icons.screen_lock_portrait,
                      iconColor: Colors.redAccent,
                      title: l10n.fullScreenIntentTitle,
                      subtitle: l10n.fullScreenIntentDesc,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () async {
                        await PrayerAlarmService.openFullScreenIntentSettings();
                        Future.delayed(const Duration(seconds: 1), _refreshPermissions);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 3-Card Mode Selector Container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildModeCard(
                                label: l10n.alarmModeAdhan,
                                icon: Icons.mosque_outlined,
                                isSelected: _isAdhanMode(_current),
                                primaryAccent: primaryAccent,
                                inactiveBg: innerTileBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onTap: () {
                                  final lastAdhan = _lastAdhanByPrayer[_selectedPrayer] ?? 'alaqsa';
                                  _updateCurrent(
                                    _current.copyWith(isEnabled: true, soundType: lastAdhan),
                                    checkPermissions: true,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildModeCard(
                                label: l10n.alarmModeDefault,
                                icon: Icons.notifications_none,
                                isSelected: _isDefaultMode(_current),
                                primaryAccent: primaryAccent,
                                inactiveBg: innerTileBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onTap: () {
                                  _updateCurrent(
                                    _current.copyWith(isEnabled: true, soundType: 'system'),
                                    checkPermissions: true,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildModeCard(
                                label: l10n.alarmModeSilent,
                                icon: Icons.notifications_off_outlined,
                                isSelected: !_current.isEnabled,
                                primaryAccent: primaryAccent,
                                inactiveBg: innerTileBg,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onTap: () {
                                  _updateCurrent(_current.copyWith(isEnabled: false));
                                },
                              ),
                            ),
                          ],
                        ),

                        // Muezzin selector + audio preview when Adhan mode is active
                        if (_isAdhanMode(_current)) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownMenu<String>(
                                  initialSelection: _adhanOptions.contains(_current.soundType)
                                      ? _current.soundType
                                      : 'alaqsa',
                                  expandedInsets: EdgeInsets.zero,
                                  trailingIcon: Icon(Icons.keyboard_arrow_down, color: textSecondary),
                                  selectedTrailingIcon: Icon(Icons.keyboard_arrow_up, color: textSecondary),
                                  textStyle: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: innerTileBg,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  menuStyle: MenuStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      isDark ? const Color(0xFF2B343E) : Colors.white,
                                    ),
                                  ),
                                  dropdownMenuEntries: _adhanOptions.map((sound) {
                                    return DropdownMenuEntry<String>(
                                      value: sound,
                                      label: _getSoundTitle(sound, l10n),
                                    );
                                  }).toList(),
                                  onSelected: (val) async {
                                    if (val != null) {
                                      final wasPreviewing = _previewingSound != null;
                                      await _updateCurrent(_current.copyWith(isEnabled: true, soundType: val));
                                      if (wasPreviewing) {
                                        await _togglePreviewAudio(val);
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: _previewingSound == _current.soundType ? primaryAccent : innerTileBg,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => _togglePreviewAudio(_current.soundType),
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Icon(
                                      _previewingSound == _current.soundType
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                      color: _previewingSound == _current.soundType ? Colors.white : primaryAccent,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Vibrate-only toggle when Default mode is active
                        if (_isDefaultMode(_current)) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: innerTileBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.vibration, size: 18, color: textSecondary),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.alarmVibrateOnly,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch.adaptive(
                                  value: _current.soundType == 'silent',
                                  activeTrackColor: primaryAccent,
                                  onChanged: (vibrateOnly) {
                                    _updateCurrent(
                                      _current.copyWith(
                                        isEnabled: true,
                                        soundType: vibrateOnly ? 'silent' : 'system',
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pre-prayer offset & Snooze steppers
                  Opacity(
                    opacity: _current.isEnabled ? 1.0 : 0.45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
                          child: Text(
                            l10n.alarmBeforePrayerSection,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        _buildStepperRow(
                          cardBg: cardBg,
                          softAccent: softAccent,
                          primaryAccent: primaryAccent,
                          textPrimary: textPrimary,
                          label: l10n.alarmBeforeLabel,
                          valueText: _current.offsetMinutes == 0
                              ? l10n.alarmNoPreAlert
                              : l10n.alarmMinutesValue(_current.offsetMinutes.abs()),
                          canDecrement: _current.isEnabled && _current.offsetMinutes.abs() > 0,
                          canIncrement: _current.isEnabled && _current.offsetMinutes.abs() < 60,
                          onDecrement: () => _stepOffset(-5),
                          onIncrement: () => _stepOffset(5),
                        ),
                        const SizedBox(height: 10),
                        _buildStepperRow(
                          cardBg: cardBg,
                          softAccent: softAccent,
                          primaryAccent: primaryAccent,
                          textPrimary: textPrimary,
                          label: l10n.alarmSnoozeDuration,
                          valueText: _current.snoozeMinutes <= 0
                              ? l10n.alarmSnoozeOff
                              : l10n.alarmMinutesValue(_current.snoozeMinutes),
                          canDecrement: _current.isEnabled && _snoozeOptions.indexOf(_current.snoozeMinutes) > 0,
                          canIncrement: _current.isEnabled &&
                              _snoozeOptions.indexOf(_current.snoozeMinutes) < _snoozeOptions.length - 1,
                          onDecrement: () => _stepSnooze(-1),
                          onIncrement: () => _stepSnooze(1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Apply to all prayers pill button
                  Material(
                    color: _showAppliedBanner ? primaryAccent : cardBg,
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _applyToAllPrayers,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showAppliedBanner
                                  ? Icons.check_circle_outline
                                  : (!_current.isEnabled
                                      ? Icons.notifications_off_outlined
                                      : (_isAdhanMode(_current)
                                          ? Icons.mosque_outlined
                                          : Icons.notifications_none)),
                              size: 20,
                              color: _showAppliedBanner ? Colors.white : textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _showAppliedBanner ? l10n.alarmAppliedToAll : l10n.alarmApplyToAll,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _showAppliedBanner ? Colors.white : textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Dev-mode quick test button
                  if (_isDevMode && _current.isEnabled && !kIsWeb && Platform.isAndroid) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryAccent,
                        side: BorderSide(color: primaryAccent.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isTestingAlarm ? null : _triggerQuickTestAlarm,
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: Text(
                        _isTestingAlarm ? l10n.alarmScheduledInSeconds(5) : l10n.testAlarmButton,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],

                  // Battery optimization troubleshooting card (Android only when not exempted)
                  if (!kIsWeb && Platform.isAndroid && !_batteryOptimizationIgnored) ...[
                    const SizedBox(height: 14),
                    _buildInfoBannerCard(
                      cardBg: cardBg,
                      icon: Icons.help_outline,
                      iconColor: primaryAccent,
                      title: l10n.alarmsNotRingingTitle,
                      subtitle: l10n.alarmsNotRingingDesc,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () async {
                        final granted = await PrayerAlarmService.requestIgnoreBatteryOptimization();
                        if (mounted) {
                          setState(() => _batteryOptimizationIgnored = granted);
                        }
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color primaryAccent,
    required Color inactiveBg,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryAccent : inactiveBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : textSecondary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperRow({
    required Color cardBg,
    required Color softAccent,
    required Color primaryAccent,
    required Color textPrimary,
    required String label,
    required String valueText,
    required bool canDecrement,
    required bool canIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          _buildCircleStepButton(
            icon: Icons.remove,
            enabled: canDecrement,
            softAccent: softAccent,
            primaryAccent: primaryAccent,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 108,
            child: Text(
              valueText,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          _buildCircleStepButton(
            icon: Icons.add,
            enabled: canIncrement,
            softAccent: softAccent,
            primaryAccent: primaryAccent,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleStepButton({
    required IconData icon,
    required bool enabled,
    required Color softAccent,
    required Color primaryAccent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: enabled ? softAccent : softAccent.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? primaryAccent : primaryAccent.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBannerCard({
    required Color cardBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: textSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
