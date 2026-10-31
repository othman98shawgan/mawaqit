import 'package:flutter/material.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../resources/colors.dart';
import '../services/prayer_alarm_service.dart';
import '../services/prayer_methods.dart';

class AlarmRingingPage extends StatefulWidget {
  final String prayerName;
  final String? soundType;
  final int? snoozeMinutes;

  const AlarmRingingPage({
    super.key,
    required this.prayerName,
    this.soundType,
    this.snoozeMinutes,
  });

  @override
  State<AlarmRingingPage> createState() => _AlarmRingingPageState();
}

class _AlarmRingingPageState extends State<AlarmRingingPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isDismissed = false;
  String? _soundType;

  @override
  void initState() {
    super.initState();
    _soundType = widget.soundType;
    PrayerAlarmService.wakeScreen();
    if (widget.soundType != null) {
      if (widget.soundType != 'silent') {
        PrayerAlarmService.startAlarmAudio(widget.soundType!);
      }
    } else {
      PrayerAlarmService.loadAlarmSettings(widget.prayerName).then((s) {
        if (mounted) {
          setState(() {
            _soundType = s.soundType;
          });
        }
        if (s.soundType != 'silent') {
          PrayerAlarmService.startAlarmAudio(s.soundType);
        }
      });
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    PrayerAlarmService.stopAlarmAudio();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await PrayerAlarmService.stopAlarmAudio();
    await PrayerAlarmService.dismiss(widget.prayerName);
    setState(() {
      _isDismissed = true;
    });

    if (!mounted) return;
    if (widget.prayerName != 'Fajr') {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSnooze() async {
    await PrayerAlarmService.stopAlarmAudio();
    await PrayerAlarmService.snooze(
      widget.prayerName,
      snoozeMinutes: widget.snoozeMinutes,
      soundType: _soundType,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prayerTitle = getPrayerTranslation(widget.prayerName, context);

    return WillPopScope(
      onWillPop: () async {
        // Prevent accidental back press while alarm is ringing
        if (!_isDismissed) {
          await _handleDismiss();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121824),
        body: SafeArea(
          child: _isDismissed && widget.prayerName == 'Fajr'
              ? _buildDhikrView(l10n, prayerTitle)
              : _buildRingingView(l10n, prayerTitle),
        ),
      ),
    );
  }

  Widget _buildRingingView(AppLocalizations l10n, String prayerTitle) {
    final isSilent = _soundType == 'silent';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: prayerColor.withOpacity(0.2),
                  border: Border.all(color: prayerColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: prayerColor.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  isSilent ? Icons.vibration : Icons.alarm_on,
                  size: 80,
                  color: prayerColor,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              l10n.alarmRingingTitle(prayerTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              prayerTitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            if (isSilent) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vibration, size: 16, color: prayerColor),
                  const SizedBox(width: 6),
                  Text(
                    l10n.soundSilent,
                    style: TextStyle(
                      color: prayerColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _handleSnooze,
                    child: Text(
                      l10n.alarmSnooze,
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: prayerColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                    ),
                    onPressed: _handleDismiss,
                    child: Text(
                      l10n.alarmDismiss,
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrView(AppLocalizations l10n, String prayerTitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny_outlined, size: 70, color: Colors.amber),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    "أذكار الاستيقاظ من النوم",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.alarmWakeupDhikr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: prayerColor,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                MaterialLocalizations.of(context).okButtonLabel,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
