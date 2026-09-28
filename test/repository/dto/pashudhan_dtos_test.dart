import 'package:flutter_test/flutter_test.dart';
import 'package:pashudhan_qr/repository/dto/pashudhan_dtos.dart';

void main() {
  // ── CreatePashudhanRequest ──────────────────────────────────────────
  group('CreatePashudhanRequest', () {
    CreatePashudhanRequest make({
      String category = 'COW',
      String name = 'Gauri',
      String breed = 'Holstein',
      int lactationNumber = 2,
      double milkYield = 15.5,
      double weight = 450.0,
      double heightInCms = 140.0,
      int numCalves = 3,
      String earTagNumber = 'EAR001',
      String ageRecordedAt = '2024-01-01T00:00:00.000Z',
      int ageInMonths = 24,
      String ownerUserName = '9876543210',
    }) =>
        CreatePashudhanRequest(
          category: category,
          name: name,
          breed: breed,
          lactationNumber: lactationNumber,
          milkYield: milkYield,
          weight: weight,
          heightInCms: heightInCms,
          numCalves: numCalves,
          earTagNumber: earTagNumber,
          ageRecordedAt: ageRecordedAt,
          ageInMonths: ageInMonths,
          ownerUserName: ownerUserName,
        );

    test('toMap includes ownerUserName not ownerId', () {
      final map = make().toMap();
      expect(map['ownerUserName'], '9876543210');
      expect(map.containsKey('ownerId'), isFalse);
    });

    test('toMap serialises all fields', () {
      final req = make();
      final map = req.toMap();
      expect(map['category'], 'COW');
      expect(map['name'], 'Gauri');
      expect(map['breed'], 'Holstein');
      expect(map['lactationNumber'], 2);
      expect(map['milkYield'], 15.5);
      expect(map['weight'], 450.0);
      expect(map['heightInCms'], 140.0);
      expect(map['numCalves'], 3);
      expect(map['earTagNumber'], 'EAR001');
      expect(map['ageInMonths'], 24);
    });

    test('fromMap round-trips via toMap', () {
      final req = make();
      final decoded = CreatePashudhanRequest.fromMap(req.toMap());
      expect(decoded, req);
    });

    test('fromJson / toJson round-trip', () {
      final req = make();
      final decoded = CreatePashudhanRequest.fromJson(req.toJson());
      expect(decoded, req);
    });

    test('copyWith overrides only specified fields', () {
      final base = make();
      final copy = base.copyWith(name: 'Laxmi', weight: 500.0);
      expect(copy.name, 'Laxmi');
      expect(copy.weight, 500.0);
      expect(copy.category, base.category);
      expect(copy.ownerUserName, base.ownerUserName);
    });

    test('equality is value-based', () {
      expect(make(), equals(make()));
      expect(make(), isNot(equals(make(name: 'Other'))));
    });

    test('hashCode matches for equal instances', () {
      expect(make().hashCode, equals(make().hashCode));
    });
  });

  // ── UpdatePashudhanRequest ──────────────────────────────────────────
  group('UpdatePashudhanRequest', () {
    UpdatePashudhanRequest make({
      String category = 'BUFFALO',
      String name = 'Kali',
      String breed = 'Murrah',
      int lactationNumber = 3,
      double milkYield = 10.0,
      double weight = 500.0,
      double heightInCms = 145.0,
      int numCalves = 4,
      int ageInMonths = 36,
      String ownerUserName = '9123456780',
    }) =>
        UpdatePashudhanRequest(
          category: category,
          name: name,
          breed: breed,
          lactationNumber: lactationNumber,
          milkYield: milkYield,
          weight: weight,
          heightInCms: heightInCms,
          numCalves: numCalves,
          ageInMonths: ageInMonths,
          ownerUserName: ownerUserName,
        );

    test('toMap uses ownerUserName key, not ownerId', () {
      final map = make().toMap();
      expect(map['ownerUserName'], '9123456780');
      expect(map.containsKey('ownerId'), isFalse);
    });

    test('toMap serialises all fields', () {
      final map = make().toMap();
      expect(map['category'], 'BUFFALO');
      expect(map['name'], 'Kali');
      expect(map['breed'], 'Murrah');
      expect(map['lactationNumber'], 3);
      expect(map['milkYield'], 10.0);
      expect(map['weight'], 500.0);
      expect(map['heightInCms'], 145.0);
      expect(map['numCalves'], 4);
      expect(map['ageInMonths'], 36);
    });

    test('fromMap round-trips via toMap', () {
      final req = make();
      expect(UpdatePashudhanRequest.fromMap(req.toMap()), req);
    });

    test('fromMap defaults missing fields to empty/zero', () {
      final req = UpdatePashudhanRequest.fromMap({});
      expect(req.ownerUserName, '');
      expect(req.category, '');
      expect(req.ageInMonths, 0);
    });

    test('fromJson / toJson round-trip', () {
      final req = make();
      expect(UpdatePashudhanRequest.fromJson(req.toJson()), req);
    });

    test('copyWith overrides only specified fields', () {
      final base = make();
      final copy = base.copyWith(name: 'Bhuri', ownerUserName: '9999999999');
      expect(copy.name, 'Bhuri');
      expect(copy.ownerUserName, '9999999999');
      expect(copy.category, base.category);
      expect(copy.weight, base.weight);
    });

    test('equality is value-based', () {
      expect(make(), equals(make()));
      expect(make(), isNot(equals(make(ownerUserName: '0000000000'))));
    });

    test('hashCode matches for equal instances', () {
      expect(make().hashCode, equals(make().hashCode));
    });

    test('toString includes ownerUserName', () {
      final s = make().toString();
      expect(s, contains('ownerUserName: 9123456780'));
      expect(s, isNot(contains('ownerId')));
    });
  });

  // ── PashudhanAggregationResponseDto ────────────────────────────────
  group('PashudhanAggregationResponseDto', () {
    test('fromMap parses type and count', () {
      final dto = PashudhanAggregationResponseDto.fromMap({
        'type': 'COW',
        'count': 5,
        'breedwiseDist': {'Holstein': 3, 'Jersey': 2},
      });
      expect(dto.type, 'COW');
      expect(dto.count, 5);
      expect(dto.breedwiseDist, {'Holstein': 3, 'Jersey': 2});
    });

    test('fromMap with null breedwiseDist', () {
      final dto = PashudhanAggregationResponseDto.fromMap({
        'type': 'GOAT',
        'count': 12,
      });
      expect(dto.type, 'GOAT');
      expect(dto.count, 12);
      expect(dto.breedwiseDist, isNull);
    });

    test('fromMap defaults missing type/count', () {
      final dto = PashudhanAggregationResponseDto.fromMap({});
      expect(dto.type, '');
      expect(dto.count, 0);
    });
  });
}
