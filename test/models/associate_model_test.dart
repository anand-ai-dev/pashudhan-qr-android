import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/models/associate.dart';

Map<String, dynamic> _fullJson() => {
      'id': 5,
      'userName': '9123456789',
      'idNo': 'ID-2024-001',
      'associatePartnerId': 3,
      'approved': true,
      'fullName': 'Ravi Verma',
      'associateType': 'LIVESTOCK',
      'partnerType': 'DAIRY',
    };

void main() {
  group('Associate.fromJson', () {
    test('parses all fields correctly', () {
      final a = Associate.fromJson(_fullJson());

      expect(a.id, 5);
      expect(a.userName, '9123456789');
      expect(a.idNo, 'ID-2024-001');
      expect(a.associatePartnerId, 3);
      expect(a.approved, isTrue);
      expect(a.fullName, 'Ravi Verma');
      expect(a.associateType, 'LIVESTOCK');
      expect(a.partnerType, 'DAIRY');
    });

    test('approved is false when JSON value is false', () {
      final json = _fullJson()..['approved'] = false;
      final a = Associate.fromJson(json);

      expect(a.approved, isFalse);
    });

    test('approved parses string "true"', () {
      final json = _fullJson()..['approved'] = 'true';
      final a = Associate.fromJson(json);

      expect(a.approved, isTrue);
    });

    test('approved parses int 0 as false', () {
      final json = _fullJson()..['approved'] = 0;
      final a = Associate.fromJson(json);

      expect(a.approved, isFalse);
    });

    test('id parses string to int', () {
      final json = _fullJson()..['id'] = '99';
      final a = Associate.fromJson(json);

      expect(a.id, 99);
    });

    test('partnerType is null when absent', () {
      final json = _fullJson()..remove('partnerType');
      final a = Associate.fromJson(json);

      expect(a.partnerType, isNull);
    });

    test('associateType is empty string when null via JsonParsers', () {
      final json = _fullJson()..['associateType'] = null;
      final a = Associate.fromJson(json);

      expect(a.associateType, '');
    });
  });

  group('Associate.toJson', () {
    test('includes all expected keys', () {
      final map = Associate.fromJson(_fullJson()).toJson();

      expect(map.keys, containsAll([
        'id', 'userName', 'idNo', 'associatePartnerId',
        'approved', 'fullName', 'associateType', 'partnerType',
      ]));
    });

    test('round-trips core fields', () {
      final original = Associate.fromJson(_fullJson());
      final map = original.toJson();
      final restored = Associate.fromJson(map);

      expect(restored.id, original.id);
      expect(restored.userName, original.userName);
      expect(restored.approved, original.approved);
      expect(restored.partnerType, original.partnerType);
    });
  });
}
