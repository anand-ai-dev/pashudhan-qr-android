import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';

Map<String, dynamic> _validMap() => {
      'uuid': 'abc-123',
      'category': 'COW',
      'name': 'Ganga',
      'breed': 'HF',
      'lactationNumber': 3,
      'milkYield': 12.5,
      'weight': 450.0,
      'heightInCms': 140.0,
      'numCalves': 2,
      'earTagNumber': 'ET-001',
      'ageInMonths': 48,
      'ageRecordedAt': '2024-01-01',
      'ownerId': 7,
      'visuals': [1, 2, 3],
    };

void main() {
  group('Pashudhan.fromMap', () {
    test('parses all fields correctly', () {
      final p = Pashudhan.fromMap(_validMap());

      expect(p.uuid, 'abc-123');
      expect(p.category, 'COW');
      expect(p.name, 'Ganga');
      expect(p.breed, 'HF');
      expect(p.lactationNumber, 3);
      expect(p.milkYield, 12.5);
      expect(p.weight, 450.0);
      expect(p.heightInCms, 140.0);
      expect(p.numCalves, 2);
      expect(p.earTagNumber, 'ET-001');
      expect(p.ageInMonths, 48);
      expect(p.ageRecordedAt, '2024-01-01');
      expect(p.ownerId, 7);
      expect(p.visuals, [1, 2, 3]);
    });

    test('uses defaults for null fields', () {
      final p = Pashudhan.fromMap({
        'uuid': null,
        'category': null,
        'name': null,
        'breed': null,
        'lactationNumber': null,
        'milkYield': null,
        'weight': null,
        'heightInCms': null,
        'numCalves': null,
        'earTagNumber': null,
        'ageInMonths': null,
        'ageRecordedAt': null,
        'ownerId': null,
        'visuals': null,
      });

      expect(p.uuid, '');
      expect(p.lactationNumber, 0);
      expect(p.milkYield, 0.0);
      expect(p.ownerId, 0);
      expect(p.visuals, isEmpty);
    });

    test('parses int fields supplied as strings', () {
      final map = _validMap()
        ..['lactationNumber'] = '5'
        ..['ownerId'] = '42';
      final p = Pashudhan.fromMap(map);

      expect(p.lactationNumber, 5);
      expect(p.ownerId, 42);
    });

    test('parses double fields supplied as strings', () {
      final map = _validMap()
        ..['milkYield'] = '8.75'
        ..['weight'] = '500';
      final p = Pashudhan.fromMap(map);

      expect(p.milkYield, 8.75);
      expect(p.weight, 500.0);
    });

    test('handles empty visuals list', () {
      final map = _validMap()..['visuals'] = [];
      final p = Pashudhan.fromMap(map);
      expect(p.visuals, isEmpty);
    });
  });

  group('Pashudhan.toMap', () {
    test('round-trips through toMap → fromMap', () {
      final original = Pashudhan.fromMap(_validMap());
      final roundTripped = Pashudhan.fromMap(original.toMap());

      expect(roundTripped, original);
    });

    test('includes all expected keys', () {
      final map = Pashudhan.fromMap(_validMap()).toMap();

      expect(map.keys, containsAll([
        'uuid', 'category', 'name', 'breed', 'lactationNumber',
        'milkYield', 'weight', 'heightInCms', 'numCalves',
        'earTagNumber', 'ageInMonths', 'ageRecordedAt', 'ownerId', 'visuals',
      ]));
    });
  });

  group('Pashudhan JSON', () {
    test('round-trips through toJson → fromJson', () {
      final original = Pashudhan.fromMap(_validMap());
      final json = original.toJson();
      final restored = Pashudhan.fromJson(json);

      expect(restored, original);
    });

    test('toJson produces valid JSON string', () {
      final json = Pashudhan.fromMap(_validMap()).toJson();
      expect(() => jsonDecode(json), returnsNormally);
    });
  });

  group('Pashudhan.copyWith', () {
    test('returns identical object when nothing overridden', () {
      final original = Pashudhan.fromMap(_validMap());
      expect(original.copyWith(), original);
    });

    test('overrides specific fields', () {
      final original = Pashudhan.fromMap(_validMap());
      final copy = original.copyWith(name: 'Yamuna', milkYield: 20.0);

      expect(copy.name, 'Yamuna');
      expect(copy.milkYield, 20.0);
      // unchanged fields preserved
      expect(copy.uuid, original.uuid);
      expect(copy.breed, original.breed);
    });
  });

  group('Pashudhan equality', () {
    test('equal when all fields match', () {
      final a = Pashudhan.fromMap(_validMap());
      final b = Pashudhan.fromMap(_validMap());

      expect(a, equals(b));
    });

    test('not equal when uuid differs', () {
      final a = Pashudhan.fromMap(_validMap());
      final b = Pashudhan.fromMap(_validMap()..['uuid'] = 'different');

      expect(a, isNot(equals(b)));
    });

    test('not equal when visuals differ', () {
      final a = Pashudhan.fromMap(_validMap());
      final b = Pashudhan.fromMap(_validMap()..['visuals'] = [9, 8]);

      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent for equal objects', () {
      final a = Pashudhan.fromMap(_validMap());
      final b = Pashudhan.fromMap(_validMap());

      expect(a.hashCode, b.hashCode);
    });

    test('identical reference equals itself', () {
      final a = Pashudhan.fromMap(_validMap());
      // ignore: unrelated_type_equality_checks
      expect(a == a, isTrue);
    });
  });

  group('Pashudhan.toString', () {
    test('includes uuid and name', () {
      final p = Pashudhan.fromMap(_validMap());
      expect(p.toString(), contains('abc-123'));
      expect(p.toString(), contains('Ganga'));
    });
  });
}
