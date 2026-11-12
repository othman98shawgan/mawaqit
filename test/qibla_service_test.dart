import 'package:alfajr/services/qibla_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QiblaService Geodesic Calculations', () {
    test('calculates accurate Qibla bearing for Al-Quds and global cities', () {
      // Al-Quds (Dome of the Rock / Al-Aqsa): 31.7780° N, 35.2354° E -> ~157.2° SE
      final alQudsBearing = QiblaService.calculateQiblaBearing(31.7780, 35.2354);
      expect(alQudsBearing, closeTo(157.2, 0.5));

      // Haifa: 32.7940° N, 34.9896° E -> ~158.6° SE
      final haifaBearing = QiblaService.calculateQiblaBearing(32.7940, 34.9896);
      expect(haifaBearing, closeTo(158.6, 0.5));

      // Gaza: 31.5017° N, 34.4668° E -> ~153.5° SE
      final gazaBearing = QiblaService.calculateQiblaBearing(31.5017, 34.4668);
      expect(gazaBearing, closeTo(153.5, 0.5));

      // New York: 40.7128° N, -74.0060° W -> ~58.5° NE
      final nyBearing = QiblaService.calculateQiblaBearing(40.7128, -74.0060);
      expect(nyBearing, closeTo(58.5, 0.5));

      // Tokyo: 35.6762° N, 139.6503° E -> ~293.0° WNW
      final tokyoBearing = QiblaService.calculateQiblaBearing(35.6762, 139.6503);
      expect(tokyoBearing, closeTo(293.0, 0.5));
    });

    test('calculates accurate Haversine distance to Kaaba in km', () {
      // Distance from Al-Quds to Kaaba is ~1,238 km
      final alQudsDistance =
          QiblaService.calculateDistanceToKaabaKm(31.7780, 35.2354);
      expect(alQudsDistance, closeTo(1238.0, 5.0));

      // Distance from Kaaba to itself is 0 km
      final zeroDistance = QiblaService.calculateDistanceToKaabaKm(
        QiblaService.kaabaLatitude,
        QiblaService.kaabaLongitude,
      );
      expect(zeroDistance, closeTo(0.0, 0.001));
    });

    test('shortestAngleDelta wraps smoothly across 0/360 North boundary', () {
      expect(QiblaService.shortestAngleDelta(358.0, 2.0), closeTo(4.0, 1e-6));
      expect(QiblaService.shortestAngleDelta(2.0, 358.0), closeTo(-4.0, 1e-6));
      expect(QiblaService.shortestAngleDelta(150.0, 157.0), closeTo(7.0, 1e-6));
    });

    test('isAlignedWithQibla detects alignment within tolerance', () {
      expect(
        QiblaService.isAlignedWithQibla(155.0, 157.2, toleranceDeg: 3.0),
        isTrue,
      );
      expect(
        QiblaService.isAlignedWithQibla(150.0, 157.2, toleranceDeg: 3.0),
        isFalse,
      );
      // Across 0/360 boundary
      expect(
        QiblaService.isAlignedWithQibla(359.0, 1.5, toleranceDeg: 3.0),
        isTrue,
      );
    });

    test('getCityCoordinates returns city coords and defaults to Al-Quds', () {
      final gaza = QiblaService.getCityCoordinates('gaza');
      expect(gaza.lat, closeTo(31.5017, 1e-4));
      expect(gaza.lon, closeTo(34.4668, 1e-4));

      final fallback = QiblaService.getCityCoordinates('min1BeforeAlQuds');
      expect(fallback.lat, closeTo(31.7780, 1e-4));
      expect(fallback.lon, closeTo(35.2354, 1e-4));
    });
  });
}
