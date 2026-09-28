import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pashudhan_qr/core/json_parsers.dart';

class Pashudhan {
  final String uuid;
  final String category;
  final String name;
  final String breed;
  final String? gender;
  final int lactationNumber;
  final double milkYield;
  final double weight;
  final double heightInCms;
  final int numCalves;
  final String earTagNumber;
  final int ageInMonths;
  final String ageRecordedAt;
  final int ownerId;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerLocation;
  final List<int> visuals;

  String get displayGender =>
      (gender == null || gender!.toUpperCase() == 'UNKNOWN') ? 'NA' : gender!;

  Pashudhan({
    required this.uuid,
    required this.category,
    required this.name,
    required this.breed,
    this.gender,
    required this.lactationNumber,
    required this.milkYield,
    required this.weight,
    required this.heightInCms,
    required this.numCalves,
    required this.earTagNumber,
    required this.ageInMonths,
    required this.ageRecordedAt,
    required this.ownerId,
    this.ownerName,
    this.ownerPhone,
    this.ownerLocation,
    required this.visuals,
  });

  Pashudhan copyWith({
    String? uuid,
    String? category,
    String? name,
    String? breed,
    String? gender,
    int? lactationNumber,
    double? milkYield,
    double? weight,
    double? heightInCms,
    int? numCalves,
    String? earTagNumber,
    int? ageInMonths,
    String? ageRecordedAt,
    int? ownerId,
    String? ownerName,
    String? ownerPhone,
    String? ownerLocation,
    List<int>? visuals,
  }) {
    return Pashudhan(
      uuid: uuid ?? this.uuid,
      category: category ?? this.category,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      lactationNumber: lactationNumber ?? this.lactationNumber,
      milkYield: milkYield ?? this.milkYield,
      weight: weight ?? this.weight,
      heightInCms: heightInCms ?? this.heightInCms,
      numCalves: numCalves ?? this.numCalves,
      earTagNumber: earTagNumber ?? this.earTagNumber,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
      ownerId: ownerId ?? this.ownerId,
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
      'breed': breed,
      'gender': gender,
      'lactationNumber': lactationNumber,
      'milkYield': milkYield,
      'weight': weight,
      'heightInCms': heightInCms,
      'numCalves': numCalves,
      'earTagNumber': earTagNumber,
      'ageInMonths': ageInMonths,
      'ageRecordedAt': ageRecordedAt,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerLocation': ownerLocation,
      'visuals': visuals,
    };
  }

  factory Pashudhan.fromMap(Map<String, dynamic> map) {
    return Pashudhan(
      uuid: JsonParsers.parseString(map['uuid']),
      category: JsonParsers.parseString(map['category']),
      name: JsonParsers.parseString(map['name']),
      breed: JsonParsers.parseString(map['breed']),
      gender: map['gender']?.toString(),
      lactationNumber: JsonParsers.parseInt(map['lactationNumber']),
      milkYield: JsonParsers.parseDouble(map['milkYield']),
      weight: JsonParsers.parseDouble(map['weight']),
      heightInCms: JsonParsers.parseDouble(map['heightInCms']),
      numCalves: JsonParsers.parseInt(map['numCalves']),
      earTagNumber: JsonParsers.parseString(map['earTagNumber']),
      ageInMonths: JsonParsers.parseInt(map['ageInMonths']),
      ageRecordedAt: JsonParsers.parseString(map['ageRecordedAt']),
      ownerId: JsonParsers.parseInt(map['ownerId']),
      ownerName: map['ownerName'] as String?,
      ownerPhone: map['ownerPhone'] as String?,
      ownerLocation: map['ownerLocation'] as String?,
      visuals: List<int>.from(map['visuals'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pashudhan.fromJson(String source) =>
      Pashudhan.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Pashudhan(uuid: $uuid, category: $category, name: $name, breed: $breed, lactationNumber: $lactationNumber, milkYield: $milkYield, weight: $weight, heightInCms: $heightInCms, numCalves: $numCalves, earTagNumber: $earTagNumber, ageInMonths: $ageInMonths, ageRecordedAt: $ageRecordedAt, ownerId: $ownerId, ownerName: $ownerName, ownerPhone: $ownerPhone, ownerLocation: $ownerLocation, visuals: $visuals)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pashudhan &&
        other.uuid == uuid &&
        other.category == category &&
        other.name == name &&
        other.breed == breed &&
        other.lactationNumber == lactationNumber &&
        other.milkYield == milkYield &&
        other.weight == weight &&
        other.heightInCms == heightInCms &&
        other.numCalves == numCalves &&
        other.earTagNumber == earTagNumber &&
        other.ageInMonths == ageInMonths &&
        other.ageRecordedAt == ageRecordedAt &&
        other.ownerId == ownerId &&
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
      breed,
      lactationNumber,
      milkYield,
      weight,
      heightInCms,
      numCalves,
      earTagNumber,
      ageInMonths,
      ageRecordedAt,
      ownerId,
      ownerName,
      ownerPhone,
      ownerLocation,
      Object.hashAll(visuals),
    );
  }
}
