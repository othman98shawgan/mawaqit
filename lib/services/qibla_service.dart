import 'dart:async';
import 'dart:math' as math;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

class QiblaSensorData {
  final double? heading;
  final double? latitude;
  final double? longitude;
  final bool hasCompass;
  final bool needsCalibration;
  final bool permissionGranted;
  final bool permanentlyDenied;
  final bool locationEnabled;

  const QiblaSensorData({
    this.heading,
    this.latitude,
    this.longitude,
    this.hasCompass = false,
    this.needsCalibration = false,
    this.permissionGranted = false,
    this.permanentlyDenied = false,
    this.locationEnabled = true,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory QiblaSensorData.fromMap(Map<dynamic, dynamic> map) {
    return QiblaSensorData(
      heading: (map['heading'] as num?)?.toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      hasCompass: (map['hasCompass'] as bool?) ?? false,
      needsCalibration: (map['needsCalibration'] as bool?) ?? false,
      permissionGranted: (map['permissionGranted'] as bool?) ?? false,
      permanentlyDenied: (map['permanentlyDenied'] as bool?) ?? false,
      locationEnabled: (map['locationEnabled'] as bool?) ?? true,
    );
  }
}

class QiblaService {
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;
  static const double _earthRadiusKm = 6371.0;

  static const Map<String, ({double lat, double lon})> _cityCoordinates = {
    'alQuds': (lat: 31.7780, lon: 35.2354),
    'kfarKama': (lat: 32.7214, lon: 35.4414),
    'ramallah': (lat: 31.9038, lon: 35.2034),
    'bethlehem': (lat: 31.7054, lon: 35.2024),
    'jenin': (lat: 32.4609, lon: 35.2981),
    'nablus': (lat: 32.2211, lon: 35.2544),
    'nazareth': (lat: 32.6996, lon: 35.3035),
    'ummAlFahm': (lat: 32.5173, lon: 35.1535),
    'jericho': (lat: 31.8611, lon: 35.4618),
    'tiberias': (lat: 32.7922, lon: 35.5312),
    'safad': (lat: 32.9646, lon: 35.4960),
    'beisan': (lat: 32.4972, lon: 35.4975),
    'haifa': (lat: 32.7940, lon: 34.9896),
    'acre': (lat: 32.9278, lon: 35.0818),
    'tulkarm': (lat: 32.3104, lon: 35.0286),
    'kafrQasim': (lat: 32.1141, lon: 34.9762),
    'tayibe': (lat: 32.2662, lon: 35.0089),
    'alKhalil': (lat: 31.5326, lon: 35.0998),
    'alLid': (lat: 31.9514, lon: 34.8953),
    'ramla': (lat: 31.9292, lon: 34.8656),
    'qalqilya': (lat: 32.1897, lon: 34.9706),
    'birAsSaba': (lat: 31.2530, lon: 34.7915),
    'jaffa': (lat: 32.0504, lon: 34.7522),
    'gaza': (lat: 31.5017, lon: 34.4668),
    'rafah': (lat: 31.2969, lon: 34.2435),
    'khanYunis': (lat: 31.3462, lon: 34.3060),
    'deirAlBalah': (lat: 31.4171, lon: 34.3509),
  };

  /// Returns fallback coordinates for the given [cityKey], defaulting to Al-Quds.
  static ({double lat, double lon}) getCityCoordinates(String cityKey) {
    return _cityCoordinates[cityKey] ?? _cityCoordinates['alQuds']!;
  }

  static const MethodChannel _methodChannel =
      MethodChannel('com.othman.mawaqitquds/qibla');
  static const EventChannel _eventChannel =
      EventChannel('com.othman.mawaqitquds/qibla_stream');

  /// Calculates the initial Great-Circle bearing (in degrees [0, 360))
  /// from [latitude], [longitude] to the Kaaba in Makkah.
  static double calculateQiblaBearing(double latitude, double longitude) {
    final phi1 = _degToRad(latitude);
    final phi2 = _degToRad(kaabaLatitude);
    final deltaLambda = _degToRad(kaabaLongitude - longitude);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final thetaRad = math.atan2(y, x);
    return (_radToDeg(thetaRad) + 360.0) % 360.0;
  }

  /// Calculates the Haversine distance in kilometers from [latitude], [longitude]
  /// to the Kaaba in Makkah.
  static double calculateDistanceToKaabaKm(double latitude, double longitude) {
    final phi1 = _degToRad(latitude);
    final phi2 = _degToRad(kaabaLatitude);
    final deltaPhi = _degToRad(kaabaLatitude - latitude);
    final deltaLambda = _degToRad(kaabaLongitude - longitude);

    final sinHalfDPhi = math.sin(deltaPhi / 2.0);
    final sinHalfDLambda = math.sin(deltaLambda / 2.0);

    final a = sinHalfDPhi * sinHalfDPhi +
        math.cos(phi1) * math.cos(phi2) * sinHalfDLambda * sinHalfDLambda;
    final c = 2.0 * math.atan2(math.sqrt(a), math.sqrt((1.0 - a).clamp(0.0, 1.0)));

    return _earthRadiusKm * c;
  }

  /// Returns the signed shortest angular difference in degrees [-180, 180]
  /// to get from [fromDeg] to [toDeg].
  static double shortestAngleDelta(double fromDeg, double toDeg) {
    double diff = (toDeg - fromDeg) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff;
  }

  /// Returns true if the current [headingDeg] is within [toleranceDeg] of [qiblaBearingDeg].
  static bool isAlignedWithQibla(
    double headingDeg,
    double qiblaBearingDeg, {
    double toleranceDeg = 3.0,
  }) {
    return shortestAngleDelta(headingDeg, qiblaBearingDeg).abs() <= toleranceDeg;
  }

  static Stream<QiblaSensorData> get sensorStream {
    if (!isAndroid && !isIOS) {
      // Desktop fallback (Al-Quds coordinates if no GPS hardware)
      return Stream.value(
        const QiblaSensorData(
          heading: null,
          latitude: 31.7780,
          longitude: 35.2354,
          hasCompass: false,
          needsCalibration: false,
          permissionGranted: true,
          locationEnabled: true,
        ),
      );
    }
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return QiblaSensorData.fromMap(event);
      }
      return const QiblaSensorData();
    });
  }

  static Future<QiblaSensorData> getStatus() async {
    if (!isAndroid && !isIOS) {
      return const QiblaSensorData(
        heading: null,
        latitude: 31.7780,
        longitude: 35.2354,
        hasCompass: false,
        permissionGranted: true,
        locationEnabled: true,
      );
    }
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getStatus');
      if (result != null) {
        return QiblaSensorData.fromMap(result);
      }
    } catch (_) {}
    return const QiblaSensorData();
  }

  static Future< ({bool granted, bool permanentlyDenied}) > requestLocationPermission() async {
    if (isAndroid) {
      final status = await Permission.locationWhenInUse.request();
      await refreshLocation();
      return (
        granted: status.isGranted,
        permanentlyDenied: status.isPermanentlyDenied,
      );
    } else if (isIOS) {
      try {
        await _methodChannel.invokeMethod('requestPermission');
        final status = await getStatus();
        return (
          granted: status.permissionGranted,
          permanentlyDenied: status.permanentlyDenied,
        );
      } catch (_) {
        return (granted: false, permanentlyDenied: false);
      }
    }
    return (granted: true, permanentlyDenied: false);
  }

  static Future<void> refreshLocation() async {
    if (!isAndroid && !isIOS) return;
    try {
      await _methodChannel.invokeMethod('refreshLocation');
    } catch (_) {}
  }

  static Future<void> openLocationSettings() async {
    if (isAndroid || isIOS) {
      try {
        await _methodChannel.invokeMethod('openLocationSettings');
        return;
      } catch (_) {}
    }
    await AppSettings.openAppSettings(type: AppSettingsType.location);
  }

  static Future<void> openAppPermissionSettings() async {
    await openAppSettings();
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
