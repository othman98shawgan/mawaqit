import 'dart:async';
import 'dart:math' as math;

import 'package:alfajr/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../resources/colors.dart';
import '../services/locale_service.dart';
import '../services/qibla_service.dart';
import '../services/theme_service.dart';

class QiblaPage extends StatefulWidget {
  final bool isActive;

  const QiblaPage({
    super.key,
    required this.isActive,
  });

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> with WidgetsBindingObserver {
  StreamSubscription<QiblaSensorData>? _sensorSub;
  Timer? _gpsTimeoutTimer;
  QiblaSensorData _sensorData = const QiblaSensorData();
  bool _isInitializing = true;
  bool _permanentlyDenied = false;
  bool _gpsTimedOut = false;
  bool _usingCityFallback = false;

  double _unwrappedHeadingDeg = 0.0;
  double? _lastRawHeadingDeg;
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) {
      _activateQibla();
    }
  }

  @override
  void didUpdateWidget(covariant QiblaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _activateQibla();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopListening();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (state == AppLifecycleState.resumed) {
      _activateQibla(requestPermissionIfNeeded: false);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopListening();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopListening();
    super.dispose();
  }

  Future<void> _activateQibla({bool requestPermissionIfNeeded = true}) async {
    if (!mounted) return;
    setState(() {
      _isInitializing = true;
    });

    final initialStatus = await QiblaService.getStatus();
    if (!mounted) return;

    bool permGranted = initialStatus.permissionGranted;
    bool permDeniedForever = initialStatus.permanentlyDenied;

    if (!permGranted && requestPermissionIfNeeded) {
      final reqResult = await QiblaService.requestLocationPermission();
      permGranted = reqResult.granted;
      permDeniedForever = reqResult.permanentlyDenied;
    }

    if (!mounted) return;
    setState(() {
      _sensorData = initialStatus;
      _permanentlyDenied = permDeniedForever;
      _isInitializing = false;
    });

    if (permGranted || initialStatus.hasCompass) {
      _startListening();
    }
    if (permGranted && !initialStatus.hasLocation) {
      _startGpsTimeoutTimer();
    }
  }

  void _startGpsTimeoutTimer() {
    _gpsTimeoutTimer?.cancel();
    _gpsTimedOut = false;
    _gpsTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_sensorData.hasLocation) {
        setState(() {
          _gpsTimedOut = true;
        });
      }
    });
  }

  void _startListening() {
    _sensorSub?.cancel();
    _sensorSub = QiblaService.sensorStream.listen((data) {
      if (!mounted) return;

      if (data.hasLocation) {
        _gpsTimeoutTimer?.cancel();
        _gpsTimedOut = false;
        _usingCityFallback = false;
      }

      final newHeading = data.heading;
      if (newHeading != null) {
        if (_lastRawHeadingDeg == null) {
          _unwrappedHeadingDeg = newHeading;
        } else {
          final delta =
              QiblaService.shortestAngleDelta(_lastRawHeadingDeg!, newHeading);
          _unwrappedHeadingDeg += delta;
        }
        _lastRawHeadingDeg = newHeading;
      }

      // Check alignment haptics only when compass is calibrated and GPS is ready
      if (data.hasLocation &&
          newHeading != null &&
          data.hasCompass &&
          !data.needsCalibration) {
        final qiblaBearing = QiblaService.calculateQiblaBearing(
          data.latitude!,
          data.longitude!,
        );
        final diff =
            QiblaService.shortestAngleDelta(newHeading, qiblaBearing).abs();
        if (!_wasAligned && diff <= 3.0) {
          _wasAligned = true;
          HapticFeedback.mediumImpact();
        } else if (_wasAligned && diff > 4.5) {
          _wasAligned = false;
        }
      } else {
        _wasAligned = false;
      }

      setState(() {
        _sensorData = data;
        if (data.permissionGranted) {
          _permanentlyDenied = false;
        } else if (data.permanentlyDenied) {
          _permanentlyDenied = true;
        }
      });
    });
  }

  void _stopListening() {
    _gpsTimeoutTimer?.cancel();
    _gpsTimeoutTimer = null;
    _sensorSub?.cancel();
    _sensorSub = null;
  }

  Future<void> _launchGoogleQiblaFinder() async {
    final url = Uri.parse('https://qiblafinder.withgoogle.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Provider.of<ThemeNotifier>(context);
    final localeProvider = Provider.of<LocaleNotifier>(context);
    final isDark = theme.themeMode == ThemeMode.dark;
    final textDirection = localeProvider.getTextDirection(localeProvider.locale);
    final title = kDebugMode ? '[DEV] ${l10n.qiblaString}' : l10n.qiblaString;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refreshTooltip,
              onPressed: () => _activateQibla(requestPermissionIfNeeded: true),
            ),
          ],
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
          child: SafeArea(
            top: false,
            child: _buildBody(context, l10n, isDark, localeProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    LocaleNotifier localeProvider,
  ) {
    if (_isInitializing) {
      return _buildCenteredStatusCard(
        isDark: isDark,
        icon: Icons.my_location,
        title: l10n.qiblaSearchingLocation,
        showSpinner: true,
        l10n: l10n,
      );
    }

    if (!_sensorData.permissionGranted) {
      return _buildCenteredStatusCard(
        isDark: isDark,
        icon: Icons.location_off_outlined,
        title: l10n.qiblaLocationPermissionTitle,
        description: l10n.qiblaLocationPermissionDesc,
        actionLabel:
            _permanentlyDenied ? l10n.appSettings : l10n.requestPermission,
        onAction: () async {
          if (_permanentlyDenied) {
            await QiblaService.openAppPermissionSettings();
          } else {
            await _activateQibla(requestPermissionIfNeeded: true);
          }
        },
        l10n: l10n,
      );
    }

    if (!_sensorData.locationEnabled && !_sensorData.hasLocation) {
      return _buildCenteredStatusCard(
        isDark: isDark,
        icon: Icons.gps_off,
        title: l10n.qiblaLocationServicesDisabledTitle,
        description: l10n.qiblaLocationServicesDisabledDesc,
        actionLabel: l10n.enableLocationServices,
        onAction: () async {
          await QiblaService.openLocationSettings();
        },
        l10n: l10n,
      );
    }

    final cityName =
        getCitiesMap(l10n)[localeProvider.city] ?? l10n.alQuds;

    if (!_sensorData.hasLocation && !_usingCityFallback) {
      return _buildCenteredStatusCard(
        isDark: isDark,
        icon: Icons.satellite_alt_outlined,
        title: l10n.qiblaSearchingLocation,
        description: _gpsTimedOut ? l10n.qiblaWeakGpsHint : null,
        actionLabel:
            _gpsTimedOut ? l10n.useSelectedCityFallback(cityName) : null,
        onAction: _gpsTimedOut
            ? () {
                setState(() {
                  _usingCityFallback = true;
                });
              }
            : null,
        showSpinner: !_gpsTimedOut,
        l10n: l10n,
      );
    }

    final fallbackCoords = QiblaService.getCityCoordinates(localeProvider.city);
    final lat = _sensorData.hasLocation ? _sensorData.latitude! : fallbackCoords.lat;
    final lon = _sensorData.hasLocation ? _sensorData.longitude! : fallbackCoords.lon;
    final qiblaBearing = QiblaService.calculateQiblaBearing(lat, lon);
    final distanceKm = QiblaService.calculateDistanceToKaabaKm(lat, lon);
    final heading = _sensorData.heading;
    final needsCalibration = _sensorData.hasCompass && _sensorData.needsCalibration;
    final isAligned = _sensorData.hasCompass &&
        !needsCalibration &&
        heading != null &&
        QiblaService.isAlignedWithQibla(heading, qiblaBearing, toleranceDeg: 3.0);

    final formattedDistance =
        NumberFormat('#,##0', localeProvider.locale.languageCode)
            .format(distanceKm.round());

    final cardBgColor = isDark ? prayerBgColorDark : prayerBgColorLight;
    final accentColor = isAligned
        ? (isDark ? Colors.tealAccent : const Color(0xFF80FFB4))
        : Colors.amberAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final isCompact = availableHeight < 560;
        final compassSize = math
            .min(availableWidth * 0.78, availableHeight * (isCompact ? 0.44 : 0.50))
            .clamp(190.0, 320.0);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isCompact ? 8 : 14,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (availableHeight - (isCompact ? 16 : 28)).clamp(0.0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top summary card: Qibla Bearing, Heading, and Distance to Makkah
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isCompact ? 10 : 14,
                  ),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isAligned
                          ? accentColor.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.14),
                      width: isAligned ? 1.8 : 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMetricItem(
                            label: l10n.qiblaDirection,
                            value: '${qiblaBearing.round()}°',
                            icon: Icons.mosque_outlined,
                            highlightColor: accentColor,
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            color: Colors.white24,
                          ),
                          _buildMetricItem(
                            label: l10n.deviceHeading,
                            value: heading != null ? '${heading.round()}°' : '--°',
                            icon: Icons.explore_outlined,
                            highlightColor: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 16,
                              color: Colors.amberAccent,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.distanceToMakkah(formattedDistance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Alignment / Sensor status pill
                Builder(
                  builder: (context) {
                    late final IconData pillIcon;
                    late final String pillText;
                    late final Color pillBorderColor;
                    late final Color pillTextColor;
                    late final Color pillBgColor;

                    if (!_sensorData.hasCompass) {
                      pillIcon = Icons.explore_outlined;
                      pillText = l10n.qiblaStaticNorthStatus;
                      pillBorderColor = Colors.white24;
                      pillTextColor = Colors.white;
                      pillBgColor = cardBgColor;
                    } else if (heading == null) {
                      pillIcon = Icons.explore_outlined;
                      pillText = l10n.qiblaWaitingForCompass;
                      pillBorderColor = Colors.white24;
                      pillTextColor = Colors.white;
                      pillBgColor = cardBgColor;
                    } else if (needsCalibration) {
                      pillIcon = Icons.screen_rotation_alt;
                      pillText = l10n.qiblaCalibrateTitle;
                      pillBorderColor = Colors.amberAccent;
                      pillTextColor = Colors.amberAccent;
                      pillBgColor = isDark
                          ? Colors.amber.shade900.withValues(alpha: 0.72)
                          : Colors.black.withValues(alpha: 0.65);
                    } else if (isAligned) {
                      pillIcon = Icons.check_circle_rounded;
                      pillText = l10n.qiblaAligned;
                      pillBorderColor = accentColor;
                      pillTextColor = accentColor;
                      pillBgColor = isDark
                          ? Colors.teal.shade800.withValues(alpha: 0.92)
                          : color4.withValues(alpha: 0.95);
                    } else {
                      pillIcon = Icons.rotate_right_rounded;
                      pillText = l10n.qiblaTurnInstruction;
                      pillBorderColor = Colors.white24;
                      pillTextColor = Colors.white;
                      pillBgColor = cardBgColor;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: pillBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: pillBorderColor,
                          width: (isAligned || needsCalibration) ? 1.6 : 1.0,
                        ),
                        boxShadow: isAligned
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            pillIcon,
                            color: (isAligned || needsCalibration)
                                ? pillTextColor
                                : Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              pillText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: pillTextColor,
                                fontWeight: (isAligned || needsCalibration)
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Interactive Compass Dial
                Center(
                  child: SizedBox(
                    width: compassSize,
                    height: compassSize,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: _unwrappedHeadingDeg,
                        end: _unwrappedHeadingDeg,
                      ),
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      builder: (context, animatedHeadingDeg, _) {
                        return CustomPaint(
                          size: Size(compassSize, compassSize),
                          painter: _QiblaCompassPainter(
                            headingDeg:
                                _sensorData.hasCompass ? animatedHeadingDeg : 0.0,
                            qiblaBearingDeg: qiblaBearing,
                            isAligned: isAligned,
                            isDark: isDark,
                            northLabel: l10n.northShort,
                            eastLabel: l10n.eastShort,
                            southLabel: l10n.southShort,
                            westLabel: l10n.westShort,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Optional warning banner (no compass sensor OR city fallback active)
                if (!_sensorData.hasCompass)
                  _buildWarningBanner(
                    icon: Icons.info_outline,
                    message: l10n.qiblaNoCompassSensor,
                    isDark: isDark,
                  )
                else if (_usingCityFallback && !_sensorData.hasLocation)
                  _buildWarningBanner(
                    icon: Icons.location_searching,
                    message: l10n.usingCityFallbackBanner(cityName),
                    isDark: isDark,
                  ),

                // Bottom secondary button: Google AR Qibla Finder
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: cardBgColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    onPressed: _launchGoogleQiblaFinder,
                    icon: const Icon(Icons.view_in_ar_rounded, size: 19),
                    label: Text(
                      l10n.openArQiblaFinder,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color highlightColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlightColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBanner({
    required IconData icon,
    required String message,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.shade900.withValues(alpha: 0.75)
            : Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amberAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredStatusCard({
    required bool isDark,
    required IconData icon,
    required String title,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    bool showSpinner = false,
    required AppLocalizations l10n,
  }) {
    final cardBgColor = isDark ? prayerBgColorDark : prayerBgColorLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSpinner)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 38, color: Colors.amberAccent),
                ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.teal : color5,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: onAction,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(
                    actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                onPressed: _launchGoogleQiblaFinder,
                icon: const Icon(Icons.view_in_ar_rounded, size: 18),
                label: Text(l10n.openArQiblaFinder),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QiblaCompassPainter extends CustomPainter {
  final double headingDeg;
  final double qiblaBearingDeg;
  final bool isAligned;
  final bool isDark;
  final String northLabel;
  final String eastLabel;
  final String southLabel;
  final String westLabel;

  _QiblaCompassPainter({
    required this.headingDeg,
    required this.qiblaBearingDeg,
    required this.isAligned,
    required this.isDark,
    required this.northLabel,
    required this.eastLabel,
    required this.southLabel,
    required this.westLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (math.min(size.width, size.height) / 2) - 10;
    final dialRadius = outerRadius - 8;

    final activeColor =
        isAligned ? (isDark ? Colors.tealAccent : const Color(0xFF69F0AE)) : Colors.amberAccent;

    // 1. Outer Glow when aligned
    if (isAligned) {
      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(center, dialRadius + 6, glowPaint);
    }

    // 2. Dial Background Circle
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [const Color(0xFF28313A), const Color(0xFF161A1E)]
            : [color4.withValues(alpha: 0.94), color5.withValues(alpha: 0.98)],
      ).createShader(Rect.fromCircle(center: center, radius: dialRadius));
    canvas.drawCircle(center, dialRadius, bgPaint);

    // 3. Outer Border Ring
    final borderPaint = Paint()
      ..color = isAligned ? activeColor : Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 3.0 : 1.8;
    canvas.drawCircle(center, dialRadius, borderPaint);

    // 4. Fixed Top Alignment Pointer (12 o'clock phone heading indicator)
    final topPointerPath = Path()
      ..moveTo(center.dx, center.dy - dialRadius - 9)
      ..lineTo(center.dx - 7, center.dy - dialRadius + 2)
      ..lineTo(center.dx + 7, center.dy - dialRadius + 2)
      ..close();
    final topPointerPaint = Paint()
      ..color = isAligned ? activeColor : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPointerPath, topPointerPaint);

    // 5. Rotate Canvas by -headingDeg so North & Qibla rotate with the device
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final headingRad = -headingDeg * (math.pi / 180.0);
    canvas.rotate(headingRad);

    // 6. Draw Degree Ticks (every 5°, major every 30°, cardinal every 90°)
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    final tickOuterR = dialRadius - 10;

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = (deg - 90) * (math.pi / 180.0);
      final isCardinal = deg % 90 == 0;
      final isMajor = deg % 30 == 0;

      final tickLen = isCardinal ? 13.0 : (isMajor ? 9.0 : 5.0);
      tickPaint.strokeWidth = isCardinal ? 2.4 : (isMajor ? 1.6 : 1.0);
      tickPaint.color = deg == 0
          ? Colors.redAccent
          : (isCardinal
              ? Colors.white
              : Colors.white.withValues(alpha: isMajor ? 0.65 : 0.30));

      final p1 = Offset(
        math.cos(rad) * tickOuterR,
        math.sin(rad) * tickOuterR,
      );
      final p2 = Offset(
        math.cos(rad) * (tickOuterR - tickLen),
        math.sin(rad) * (tickOuterR - tickLen),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 7. Draw Cardinal Labels (kept upright for readability)
    final cardinalRadius = tickOuterR - 27;
    final cardinals = [
      (deg: 0.0, label: northLabel, color: Colors.redAccent),
      (deg: 90.0, label: eastLabel, color: Colors.white),
      (deg: 180.0, label: southLabel, color: Colors.white),
      (deg: 270.0, label: westLabel, color: Colors.white),
    ];

    for (final c in cardinals) {
      final rad = (c.deg - 90.0) * (math.pi / 180.0);
      final pos = Offset(
        math.cos(rad) * cardinalRadius,
        math.sin(rad) * cardinalRadius,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(-headingRad); // Keep text upright

      final tp = TextPainter(
        text: TextSpan(
          text: c.label,
          style: TextStyle(
            color: c.color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // 8. Draw Inner Subtle Guide Ring
    final innerRingRadius = cardinalRadius - 22;
    final innerRingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset.zero, innerRingRadius, innerRingPaint);

    // 9. Rotate to Qibla Bearing to draw the Qibla Needle & Kaaba Badge
    final qiblaRad = qiblaBearingDeg * (math.pi / 180.0);
    canvas.save();
    canvas.rotate(qiblaRad);

    // Qibla Needle pointing toward (0, -innerRingRadius)
    final needleTipY = -(innerRingRadius - 6);
    final needleTailY = innerRingRadius * 0.38;

    final needlePath = Path()
      ..moveTo(0, needleTipY)
      ..lineTo(9, -8)
      ..lineTo(3.5, needleTailY)
      ..lineTo(-3.5, needleTailY)
      ..lineTo(-9, -8)
      ..close();

    final needlePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(needlePath, needlePaint);

    // Kaaba Marker Badge on the perimeter at the Qibla angle
    final kaabaCenter = Offset(0, -(tickOuterR - 6));
    final badgeBgPaint = Paint()
      ..color = isAligned ? activeColor : const Color(0xFF1E242B)
      ..style = PaintingStyle.fill;
    final badgeBorderPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(kaabaCenter, 14, badgeBgPaint);
    canvas.drawCircle(kaabaCenter, 14, badgeBorderPaint);

    // Draw Kaaba cube icon inside the badge
    final kaabaRect = Rect.fromCenter(
      center: kaabaCenter,
      width: 13,
      height: 13,
    );
    final kaabaCubePaint = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(kaabaRect, const Radius.circular(2.5)),
      kaabaCubePaint,
    );
    // Golden Kiswah band on the Kaaba cube
    final kiswahPaint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 2.2;
    canvas.drawLine(
      Offset(kaabaRect.left + 1.5, kaabaRect.top + 4.2),
      Offset(kaabaRect.right - 1.5, kaabaRect.top + 4.2),
      kiswahPaint,
    );

    canvas.restore(); // Restore from qiblaRad

    // 10. Center Pivot Cap
    canvas.drawCircle(
      Offset.zero,
      10,
      Paint()..color = isDark ? const Color(0xFF1E242B) : color5,
    );
    canvas.drawCircle(
      Offset.zero,
      6,
      Paint()..color = activeColor,
    );

    canvas.restore(); // Restore from -headingDeg
  }

  @override
  bool shouldRepaint(covariant _QiblaCompassPainter oldDelegate) {
    return oldDelegate.headingDeg != headingDeg ||
        oldDelegate.qiblaBearingDeg != qiblaBearingDeg ||
        oldDelegate.isAligned != isAligned ||
        oldDelegate.isDark != isDark ||
        oldDelegate.northLabel != northLabel;
  }
}
