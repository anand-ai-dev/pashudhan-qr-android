import 'dart:convert';
import 'package:pashudhan_qr/core/json_parsers.dart';


// Since listing API returns List<PetResponse>, we can use List<Pet> directly or wrap it if needed.
// Sticking to single object DTOs for create/update requests.

class CreatePetRequest {
  final String ownerUserName;
  final String category;
  final String name;
  final String breed;
  final String? gender;
  final double weight;
  final double heightInCms;
  final int numberOfOffspring;
  final String petIdNumber;
  final int ageMonthsAtRecord;
  final String ageRecordedAt;

  CreatePetRequest({
    required this.ownerUserName,
    required this.category,
    required this.name,
    required this.breed,
    this.gender,
    required this.weight,
    required this.heightInCms,
    required this.numberOfOffspring,
    required this.petIdNumber,
    required this.ageMonthsAtRecord,
    required this.ageRecordedAt,
  });

  CreatePetRequest copyWith({
    String? ownerUserName,
    String? category,
    String? name,
    String? breed,
    String? gender,
    double? weight,
    double? heightInCms,
    int? numberOfOffspring,
    String? petIdNumber,
    int? ageMonthsAtRecord,
    String? ageRecordedAt,
  }) {
    return CreatePetRequest(
      ownerUserName: ownerUserName ?? this.ownerUserName,
      category: category ?? this.category,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      heightInCms: heightInCms ?? this.heightInCms,
      numberOfOffspring: numberOfOffspring ?? this.numberOfOffspring,
      petIdNumber: petIdNumber ?? this.petIdNumber,
      ageMonthsAtRecord: ageMonthsAtRecord ?? this.ageMonthsAtRecord,
      ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUserName': ownerUserName,
      'category': category,
      'name': name,
      'breed': breed,
      'gender': gender,
      'weight': weight,
      'heightInCms': heightInCms,
      'numberOfOffspring': numberOfOffspring,
      'petIdNumber': petIdNumber,
      'ageMonthsAtRecord': ageMonthsAtRecord,
      'ageRecordedAt': ageRecordedAt,
    };
  }

  factory CreatePetRequest.fromMap(Map<String, dynamic> map) {
    return CreatePetRequest(
      ownerUserName: JsonParsers.parseString(map['ownerUserName']),
      category: JsonParsers.parseString(map['category']),
      name: JsonParsers.parseString(map['name']),
      breed: JsonParsers.parseString(map['breed']),
      gender: map['gender']?.toString(),
      weight: JsonParsers.parseDouble(map['weight']),
      heightInCms: JsonParsers.parseDouble(map['heightInCms']),
      numberOfOffspring: JsonParsers.parseInt(map['numberOfOffspring']),
      petIdNumber: JsonParsers.parseString(map['petIdNumber']),
      ageMonthsAtRecord: JsonParsers.parseInt(map['ageMonthsAtRecord']),
      ageRecordedAt: JsonParsers.parseString(map['ageRecordedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CreatePetRequest.fromJson(String source) =>
      CreatePetRequest.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CreatePetRequest(ownerUserName: $ownerUserName, category: $category, name: $name, breed: $breed, weight: $weight, heightInCms: $heightInCms, numberOfOffspring: $numberOfOffspring, petIdNumber: $petIdNumber, ageMonthsAtRecord: $ageMonthsAtRecord, ageRecordedAt: $ageRecordedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreatePetRequest &&
        other.ownerUserName == ownerUserName &&
        other.category == category &&
        other.name == name &&
        other.breed == breed &&
        other.weight == weight &&
        other.heightInCms == heightInCms &&
        other.numberOfOffspring == numberOfOffspring &&
        other.petIdNumber == petIdNumber &&
        other.ageMonthsAtRecord == ageMonthsAtRecord &&
        other.ageRecordedAt == ageRecordedAt;
  }

  @override
  int get hashCode {
    return ownerUserName.hashCode ^
        category.hashCode ^
        name.hashCode ^
        breed.hashCode ^
        weight.hashCode ^
        heightInCms.hashCode ^
        numberOfOffspring.hashCode ^
        petIdNumber.hashCode ^
        ageMonthsAtRecord.hashCode ^
        ageRecordedAt.hashCode;
  }
}

class UpdatePetRequest {
  final String ownerUserName;
  final String category;
  final String name;
  final String breed;
  final double weight;
  final double heightInCms;
  final int numberOfOffspring;
  final String petIdNumber;
  final int ageMonthsAtRecord;
  final String ageRecordedAt;

  UpdatePetRequest({
    required this.ownerUserName,
    required this.category,
    required this.name,
    required this.breed,
    required this.weight,
    required this.heightInCms,
    required this.numberOfOffspring,
    required this.petIdNumber,
    required this.ageMonthsAtRecord,
    required this.ageRecordedAt,
  });

  UpdatePetRequest copyWith({
    String? ownerUserName,
    String? category,
    String? name,
    String? breed,
    double? weight,
    double? heightInCms,
    int? numberOfOffspring,
    String? petIdNumber,
    int? ageMonthsAtRecord,
    String? ageRecordedAt,
  }) {
    return UpdatePetRequest(
      ownerUserName: ownerUserName ?? this.ownerUserName,
      category: category ?? this.category,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      weight: weight ?? this.weight,
      heightInCms: heightInCms ?? this.heightInCms,
      numberOfOffspring: numberOfOffspring ?? this.numberOfOffspring,
      petIdNumber: petIdNumber ?? this.petIdNumber,
      ageMonthsAtRecord: ageMonthsAtRecord ?? this.ageMonthsAtRecord,
      ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUserName': ownerUserName,
      'category': category,
      'name': name,
      'breed': breed,
      'weight': weight,
      'heightInCms': heightInCms,
      'numberOfOffspring': numberOfOffspring,
      'petIdNumber': petIdNumber,
      'ageMonthsAtRecord': ageMonthsAtRecord,
      'ageRecordedAt': ageRecordedAt,
    };
  }

  factory UpdatePetRequest.fromMap(Map<String, dynamic> map) {
    return UpdatePetRequest(
      ownerUserName: JsonParsers.parseString(map['ownerUserName']),
      category: JsonParsers.parseString(map['category']),
      name: JsonParsers.parseString(map['name']),
      breed: JsonParsers.parseString(map['breed']),
      weight: JsonParsers.parseDouble(map['weight']),
      heightInCms: JsonParsers.parseDouble(map['heightInCms']),
      numberOfOffspring: JsonParsers.parseInt(map['numberOfOffspring']),
      petIdNumber: JsonParsers.parseString(map['petIdNumber']),
      ageMonthsAtRecord: JsonParsers.parseInt(map['ageMonthsAtRecord']),
      ageRecordedAt: JsonParsers.parseString(map['ageRecordedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdatePetRequest.fromJson(String source) =>
      UpdatePetRequest.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UpdatePetRequest(ownerUserName: $ownerUserName, category: $category, name: $name, breed: $breed, weight: $weight, heightInCms: $heightInCms, numberOfOffspring: $numberOfOffspring, petIdNumber: $petIdNumber, ageMonthsAtRecord: $ageMonthsAtRecord, ageRecordedAt: $ageRecordedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpdatePetRequest &&
        other.ownerUserName == ownerUserName &&
        other.category == category &&
        other.name == name &&
        other.breed == breed &&
        other.weight == weight &&
        other.heightInCms == heightInCms &&
        other.numberOfOffspring == numberOfOffspring &&
        other.petIdNumber == petIdNumber &&
        other.ageMonthsAtRecord == ageMonthsAtRecord &&
        other.ageRecordedAt == ageRecordedAt;
  }

  @override
  int get hashCode {
    return ownerUserName.hashCode ^
        category.hashCode ^
        name.hashCode ^
        breed.hashCode ^
        weight.hashCode ^
        heightInCms.hashCode ^
        numberOfOffspring.hashCode ^
        petIdNumber.hashCode ^
        ageMonthsAtRecord.hashCode ^
        ageRecordedAt.hashCode;
  }
}

class PetAggregationResponseDto {
  final String type;
  final int count;
  final Map<String, dynamic>? breedwiseDist;

  PetAggregationResponseDto({
    required this.type,
    required this.count,
    this.breedwiseDist,
  });

  factory PetAggregationResponseDto.fromMap(Map<String, dynamic> map) {
    return PetAggregationResponseDto(
      type: JsonParsers.parseString(map['type']),
      count: JsonParsers.parseInt(map['count']),
      breedwiseDist: map['breedwiseDist'],
    );
  }
}
