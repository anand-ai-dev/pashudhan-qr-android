import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/models/breeding_model.dart';

Map<String, dynamic> _fullJson() => {
      'uuid': 'br-uuid-1',
      'pashudhanUuid': 'p-uuid-1',
      'dateOfInsemination': '2024-03-01',
      'inseminationType': 'AI',
      'bullBreed': 'HF',
      'strawNo': 'STR-007',
      'numberOfCalves': '1',
      'dateOfCalving': '2024-12-01',
      'administratorName': 'Dr. Sharma',
      'associatePartnerName': 'Partner A',
      'createdAt': '2024-03-01T10:00:00Z',
      'updatedAt': '2024-03-02T10:00:00Z',
    };

void main() {
  group('BreedingReport.fromJson', () {
    test('parses all fields from complete JSON', () {
      final report = BreedingReport.fromJson(_fullJson());

      expect(report.uuid, 'br-uuid-1');
      expect(report.pashudhanUuid, 'p-uuid-1');
      expect(report.dateOfInsemination, '2024-03-01');
      expect(report.inseminationType, 'AI');
      expect(report.bullBreed, 'HF');
      expect(report.strawNo, 'STR-007');
      expect(report.numberOfCalves, '1');
      expect(report.dateOfCalving, '2024-12-01');
      expect(report.administratorName, 'Dr. Sharma');
      expect(report.associatePartnerName, 'Partner A');
      expect(report.createdAt, '2024-03-01T10:00:00Z');
      expect(report.updatedAt, '2024-03-02T10:00:00Z');
    });

    test('uuid defaults to empty string when null', () {
      final json = _fullJson()..['uuid'] = null;
      final report = BreedingReport.fromJson(json);

      expect(report.uuid, '');
    });

    test('optional fields are null when absent', () {
      final report = BreedingReport.fromJson({'uuid': 'br-1'});

      expect(report.pashudhanUuid, isNull);
      expect(report.dateOfInsemination, isNull);
      expect(report.inseminationType, isNull);
      expect(report.bullBreed, isNull);
      expect(report.strawNo, isNull);
      expect(report.numberOfCalves, isNull);
      expect(report.dateOfCalving, isNull);
      expect(report.administratorName, isNull);
      expect(report.associatePartnerName, isNull);
      expect(report.createdAt, isNull);
      expect(report.updatedAt, isNull);
    });

    test('converts non-string types to string for optional fields', () {
      final json = _fullJson()
        ..['numberOfCalves'] = 2
        ..['inseminationType'] = 1;
      final report = BreedingReport.fromJson(json);

      expect(report.numberOfCalves, '2');
      expect(report.inseminationType, '1');
    });
  });
}
