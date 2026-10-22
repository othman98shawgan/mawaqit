import 'package:flutter_test/flutter_test.dart';
import 'package:alfajr/services/day_of_year_service.dart';

void main() {
  test('dayOfYear calculation test', () {
    final day = DateTime(2023, 1, 1);
    expect(dayOfYear(day), 0);
  });
}
