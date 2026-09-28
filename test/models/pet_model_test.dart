import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/models/pet_model.dart';

Map<String, dynamic> _validMap() => {
      'uuid': 'pet-uuid-1',
      'category': 'DOG',
      'name': 'Bruno',
      'petName': 'Bruno',
      'breed': 'Labrador',
      'weight': 30.0,
      'heightInCms': 60.0,
      'petIdNumber': 'PID-001',
      'visuals': ['url1', 'url2'],
    };

void main() {
  group('Pet.fromMap', () {
    test('parses all fields correctly', () {
      final pet = Pet.fromMap(_validMap());

      expect(pet.uuid, 'pet-uuid-1');
      expect(pet.category, 'DOG');
      expect(pet.name, 'Bruno');
      expect(pet.petName, 'Bruno');
      expect(pet.breed, 'Labrador');
      expect(pet.weight, 30.0);
      expect(pet.heightInCms, 60.0);
      expect(pet.petIdNumber, 'PID-001');
      expect(pet.visuals, ['url1', 'url2']);
    });

    test('falls back to petName when name is absent', () {
      final map = _validMap()..remove('name');
      map['petName'] = 'Buddy';
      final pet = Pet.fromMap(map);

      expect(pet.name, 'Buddy');
    });

    test('uses name field when both name and petName are present', () {
      final map = _validMap()
        ..['name'] = 'Max'
        ..['petName'] = 'Buddy';
      final pet = Pet.fromMap(map);

      expect(pet.name, 'Max');
    });

    test('handles null visuals as empty list', () {
      final map = _validMap()..['visuals'] = null;
      final pet = Pet.fromMap(map);

      expect(pet.visuals, isEmpty);
    });

    test('uses defaults for null numeric fields', () {
      final map = _validMap()
        ..['weight'] = null
        ..['heightInCms'] = null;
      final pet = Pet.fromMap(map);

      expect(pet.weight, 0.0);
      expect(pet.heightInCms, 0.0);
    });

    test('petName is null when key absent', () {
      final map = _validMap()..remove('petName');
      final pet = Pet.fromMap(map);

      expect(pet.petName, isNull);
    });
  });

  group('Pet JSON round-trip', () {
    test('toJson → fromJson restores original', () {
      final original = Pet.fromMap(_validMap());
      final json = original.toJson();
      final restored = Pet.fromJson(json);

      expect(restored, original);
    });

    test('toJson produces valid JSON', () {
      final json = Pet.fromMap(_validMap()).toJson();
      expect(() => jsonDecode(json), returnsNormally);
    });
  });

  group('Pet.copyWith', () {
    test('returns equal object when nothing overridden', () {
      final original = Pet.fromMap(_validMap());
      expect(original.copyWith(), original);
    });

    test('overrides specific fields', () {
      final original = Pet.fromMap(_validMap());
      final copy = original.copyWith(breed: 'Poodle', weight: 5.0);

      expect(copy.breed, 'Poodle');
      expect(copy.weight, 5.0);
      expect(copy.uuid, original.uuid);
    });
  });

  group('Pet equality', () {
    test('equal when all fields match', () {
      final a = Pet.fromMap(_validMap());
      final b = Pet.fromMap(_validMap());

      expect(a, equals(b));
    });

    test('not equal when uuid differs', () {
      final a = Pet.fromMap(_validMap());
      final b = Pet.fromMap(_validMap()..['uuid'] = 'other-uuid');

      expect(a, isNot(equals(b)));
    });

    test('hashCode consistent for equal objects', () {
      final a = Pet.fromMap(_validMap());
      final b = Pet.fromMap(_validMap());

      expect(a.hashCode, b.hashCode);
    });
  });

  group('Pet.toString', () {
    test('includes uuid and name', () {
      final pet = Pet.fromMap(_validMap());
      expect(pet.toString(), contains('pet-uuid-1'));
      expect(pet.toString(), contains('Bruno'));
    });
  });
}
