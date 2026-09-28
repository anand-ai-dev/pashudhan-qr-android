import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pashudhan_qr/core/json_parsers.dart';

class Pet {
  final String uuid;
  final String category;
  final String name;
  final String? petName;
  final String breed;
  final String? gender;
  final double weight;
  final double heightInCms;
  final String petIdNumber;
  final int? ageMonthsAtRecord;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerLocation;
  final List<String> visuals;

  String get displayGender =>
      (gender == null || gender!.toUpperCase() == 'UNKNOWN') ? 'NA' : gender!;

  String get displayAge {
    if (ageMonthsAtRecord == null) return 'NA';
    final years = ageMonthsAtRecord! ~/ 12;
    final months = ageMonthsAtRecord! % 12;
    if (years > 0 && months > 0) return '$years yr $months mo';
    if (years > 0) return '$years yr';
    return '$months mo';
  }

  Pet({
    required this.uuid,
    required this.category,
    required this.name,
    this.petName,
    required this.breed,
    this.gender,
    required this.weight,
    required this.heightInCms,
    required this.petIdNumber,
    this.ageMonthsAtRecord,
    this.ownerName,
    this.ownerPhone,
    this.ownerLocation,
    required this.visuals,
  });

  Pet copyWith({
    String? uuid,
    String? category,
    String? name,
    String? petName,
    String? breed,
    String? gender,
    double? weight,
    double? heightInCms,
    String? petIdNumber,
    int? ageMonthsAtRecord,
    String? ownerName,
    String? ownerPhone,
    String? ownerLocation,
    List<String>? visuals,
  }) {
    return Pet(
      uuid: uuid ?? this.uuid,
      category: category ?? this.category,
      name: name ?? this.name,
      petName: petName ?? this.petName,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      heightInCms: heightInCms ?? this.heightInCms,
      petIdNumber: petIdNumber ?? this.petIdNumber,
      ageMonthsAtRecord: ageMonthsAtRecord ?? this.ageMonthsAtRecord,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerLocation: ownerLocation ?? this.ownerLocation,
      visuals: visuals ?? this.visuals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'category': category,
      'name': name,
      'petName': petName,
      'breed': breed,
      'gender': gender,
      'weight': weight,
      'heightInCms': heightInCms,
      'petIdNumber': petIdNumber,
      'ageMonthsAtRecord': ageMonthsAtRecord,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerLocation': ownerLocation,
      'visuals': visuals,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      uuid: JsonParsers.parseString(map['uuid']),
      category: JsonParsers.parseString(map['category']),
      name: JsonParsers.parseString(map['name'] ?? map['petName']),
      petName: map['petName']?.toString(),
      breed: JsonParsers.parseString(map['breed']),
      gender: map['gender']?.toString(),
      weight: JsonParsers.parseDouble(map['weight']),
      heightInCms: JsonParsers.parseDouble(map['heightInCms']),
      petIdNumber: JsonParsers.parseString(map['petIdNumber']),
      ageMonthsAtRecord: map['ageMonthsAtRecord'] != null ? (map['ageMonthsAtRecord'] as num).toInt() : null,
      ownerName: map['ownerName']?.toString(),
      ownerPhone: map['ownerPhone']?.toString(),
      ownerLocation: map['ownerLocation']?.toString(),
      visuals: List<String>.from(map['visuals'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pet.fromJson(String source) => Pet.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Pet(uuid: $uuid, category: $category, name: $name, petName: $petName, breed: $breed, weight: $weight, heightInCms: $heightInCms, petIdNumber: $petIdNumber, ageMonthsAtRecord: $ageMonthsAtRecord, ownerName: $ownerName, visuals: $visuals)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pet &&
        other.uuid == uuid &&
        other.category == category &&
        other.name == name &&
        other.petName == petName &&
        other.breed == breed &&
        other.weight == weight &&
        other.heightInCms == heightInCms &&
        other.petIdNumber == petIdNumber &&
        other.ageMonthsAtRecord == ageMonthsAtRecord &&
        other.ownerName == ownerName &&
        other.ownerPhone == ownerPhone &&
        other.ownerLocation == ownerLocation &&
        listEquals(other.visuals, visuals);
  }

  @override
  int get hashCode {
    return Object.hash(
      uuid,
      category,
      name,
      petName,
      breed,
      weight,
      heightInCms,
      petIdNumber,
      ageMonthsAtRecord,
      ownerName,
      ownerPhone,
      ownerLocation,
      Object.hashAll(visuals),
    );
  }
}
