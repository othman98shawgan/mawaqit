import 'dart:convert';
import 'dart:io';

import 'package:alfajr/models/mathurat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MathuratModel unit tests', () {
    test('fromJson and toJson round-trip preserves fields', () {
      final jsonMap = {
        'Id': 'm1',
        'Count': 3,
        'Text': 'أذكار الصباح',
        'EveningText': 'أذكار المساء',
        'English': 'Morning remembrance',
        'EnglishEvening': 'Evening remembrance',
        'Period': 'both',
        'Hadith': 'Narrated by Muslim',
      };

      final model = MathuratModel.fromJson(jsonMap);
      expect(model.id, 'm1');
      expect(model.count, 3);
      expect(model.text, 'أذكار الصباح');
      expect(model.eveningText, 'أذكار المساء');
      expect(model.english, 'Morning remembrance');
      expect(model.englishEvening, 'Evening remembrance');
      expect(model.period, 'both');
      expect(model.hadith, 'Narrated by Muslim');

      expect(model.toJson(), jsonMap);
    });

    test('textFor and englishFor switch based on isEvening', () {
      final model = MathuratModel(
        '1',
        1,
        'Morning AR',
        eveningText: 'Evening AR',
        english: 'Morning EN',
        englishEvening: 'Evening EN',
      );

      expect(model.textFor(isEvening: false), 'Morning AR');
      expect(model.textFor(isEvening: true), 'Evening AR');
      expect(model.englishFor(isEvening: false), 'Morning EN');
      expect(model.englishFor(isEvening: true), 'Evening EN');
    });

    test('textFor and englishFor fall back to morning text when evening text is null or empty', () {
      final model = MathuratModel(
        '2',
        1,
        'Shared AR',
        eveningText: '',
        english: 'Shared EN',
        englishEvening: null,
      );

      expect(model.textFor(isEvening: true), 'Shared AR');
      expect(model.englishFor(isEvening: true), 'Shared EN');
    });
  });

  group('mathurat.json asset validation', () {
    test('all entries parse cleanly with valid fields and periods', () {
      final raw = File('lib/data/mathurat.json').readAsStringSync();
      final decoded = json.decode(raw) as List<dynamic>;
      expect(decoded, isNotEmpty);

      final items = decoded
          .map((e) => MathuratModel.fromJson(e as Map<String, dynamic>))
          .toList();

      const validPeriods = {'morning', 'evening', 'both'};
      final ids = <String>{};

      for (final item in items) {
        expect(item.id.trim(), isNotEmpty);
        expect(ids.add(item.id), isTrue, reason: 'Duplicate id: ${item.id}');
        expect(item.count, greaterThan(0), reason: 'Invalid count for ${item.id}');
        expect(item.text.trim(), isNotEmpty, reason: 'Empty text for ${item.id}');
        expect(validPeriods.contains(item.period), isTrue,
            reason: 'Invalid period ${item.period} for ${item.id}');
      }

      final morningItems =
          items.where((e) => e.period == 'morning' || e.period == 'both').toList();
      final eveningItems =
          items.where((e) => e.period == 'evening' || e.period == 'both').toList();
      expect(morningItems, isNotEmpty);
      expect(eveningItems, isNotEmpty);
    });
  });
}
