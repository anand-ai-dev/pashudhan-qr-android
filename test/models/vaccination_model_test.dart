import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/models/vaccination_model.dart';

Map<String, dynamic> _fullJson() => {
      'uuid': 'vac-uuid-1',
      'animalUuid': 'animal-1',
      'animalType': 'PASHUDHAN',
      'vaccineName': 'FMD',
      'vaccinationDate': '2024-04-01',
      'nextDueDate': '2024-10-01',
      'notes': 'First dose',
      'administratorName': 'Dr. Rao',
      'associatePartnerName': 'Partner B',
      'createdAt': '2024-04-01T08:00:00Z',
      'updatedAt': '2024-04-01T09:00:00Z',
    };

void main() {
  group('Vaccination.fromJson', () {
    test('parses all fields from complete JSON', () {
      final v = Vaccination.fromJson(_fullJson());

      expect(v.uuid, 'vac-uuid-1');
      expect(v.animalUuid, 'animal-1');
      expect(v.animalType, 'PASHUDHAN');
      expect(v.vaccineName, 'FMD');
      expect(v.vaccinationDate, '2024-04-01');
      expect(v.nextDueDate, '2024-10-01');
      expect(v.notes, 'First dose');
      expect(v.administratorName, 'Dr. Rao');
      expect(v.associatePartnerName, 'Partner B');
      expect(v.createdAt, '2024-04-01T08:00:00Z');
      expect(v.updatedAt, '2024-04-01T09:00:00Z');
    });

    test('uuid defaults to empty string when null', () {
      final v = Vaccination.fromJson({'uuid': null});
      expect(v.uuid, '');
    });

    test('optional fields are null when key absent', () {
      final v = Vaccination.fromJson({'uuid': 'vac-2'});

      expect(v.animalUuid, isNull);
      expect(v.animalType, isNull);
      expect(v.vaccineName, isNull);
      expect(v.vaccinationDate, isNull);
      expect(v.nextDueDate, isNull);
      expect(v.notes, isNull);
      expect(v.administratorName, isNull);
      expect(v.associatePartnerName, isNull);
      expect(v.createdAt, isNull);
      expect(v.updatedAt, isNull);
    });

    test('converts numeric values to string for optional fields', () {
      final json = _fullJson()..['notes'] = 42;
      final v = Vaccination.fromJson(json);

      expect(v.notes, '42');
    });
  });
}
