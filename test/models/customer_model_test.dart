import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/models/customer.dart';

Map<String, dynamic> _fullJson() => {
      'id': 10,
      'userName': '9876543210',
      'fatherName': 'Ram Kumar',
      'name': 'Shyam Kumar',
      'address': '123 Village Road',
      'pincode': 110001,
      'aadharNumber': '1234-5678-9012',
      'profilePic': 'https://example.com/pic.jpg',
      'gender': 'MALE',
      'caste': 'OBC',
      'deviceId': 'device-abc',
      'aadharVerified': true,
    };

void main() {
  group('Customer.fromJson', () {
    test('parses all fields correctly', () {
      final c = Customer.fromJson(_fullJson());

      expect(c.id, 10);
      expect(c.userName, '9876543210');
      expect(c.fatherName, 'Ram Kumar');
      expect(c.name, 'Shyam Kumar');
      expect(c.address, '123 Village Road');
      expect(c.pincode, 110001);
      expect(c.aadharNumber, '1234-5678-9012');
      expect(c.profilePic, 'https://example.com/pic.jpg');
      expect(c.gender, 'MALE');
      expect(c.caste, 'OBC');
      expect(c.deviceId, 'device-abc');
      expect(c.aadharVerified, isTrue);
    });

    test('aadharVerified parses false correctly', () {
      final json = _fullJson()..['aadharVerified'] = false;
      final c = Customer.fromJson(json);

      expect(c.aadharVerified, isFalse);
    });

    test('aadharVerified parses string "true"', () {
      final json = _fullJson()..['aadharVerified'] = 'true';
      final c = Customer.fromJson(json);

      expect(c.aadharVerified, isTrue);
    });

    test('aadharVerified parses int 1 as true', () {
      final json = _fullJson()..['aadharVerified'] = 1;
      final c = Customer.fromJson(json);

      expect(c.aadharVerified, isTrue);
    });

    test('aadharVerified parses int 0 as false', () {
      final json = _fullJson()..['aadharVerified'] = 0;
      final c = Customer.fromJson(json);

      expect(c.aadharVerified, isFalse);
    });

    test('id parses string to int', () {
      final json = _fullJson()..['id'] = '42';
      final c = Customer.fromJson(json);

      expect(c.id, 42);
    });

    test('pincode parses string to int', () {
      final json = _fullJson()..['pincode'] = '110002';
      final c = Customer.fromJson(json);

      expect(c.pincode, 110002);
    });

    test('profilePic preserves null', () {
      final json = _fullJson()..['profilePic'] = null;
      final c = Customer.fromJson(json);

      expect(c.profilePic, isNull);
    });

    test('optional string fields are empty string when null via JsonParsers', () {
      final json = _fullJson()
        ..['fatherName'] = null
        ..['address'] = null
        ..['gender'] = null;
      final c = Customer.fromJson(json);

      // JsonParsers.parseString(null) → ''
      expect(c.fatherName, '');
      expect(c.address, '');
      expect(c.gender, '');
    });
  });

  group('Customer.toJson', () {
    test('round-trips through toJson → fromJson', () {
      final original = Customer.fromJson(_fullJson());
      final map = original.toJson();
      final restored = Customer.fromJson(map);

      expect(restored.id, original.id);
      expect(restored.userName, original.userName);
      expect(restored.name, original.name);
      expect(restored.aadharVerified, original.aadharVerified);
    });

    test('includes all expected keys', () {
      final map = Customer.fromJson(_fullJson()).toJson();

      expect(map.keys, containsAll([
        'id', 'userName', 'name', 'aadharVerified',
        'fatherName', 'address', 'pincode', 'aadharNumber',
        'profilePic', 'gender', 'caste', 'deviceId',
      ]));
    });
  });
}
