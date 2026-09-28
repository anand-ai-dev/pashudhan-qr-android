import 'dart:convert';

import 'package:flutter/foundation.dart';

class Pashudhan {
  final String uuid;
  final String category;
  final String name;
  final String breed;
  final int lactationNumber;
  final double milkYield;
  final double weight;
  final double heightInCms;
  final int numCalves;
  final String earTagNumber;
  final int ageInMonths;
  final String ageRecordedAt;
  final int ownerId;
  final List<int> visuals;

  Pashudhan({
    required this.uuid,
    required this.category,
    required this.name,
    required this.breed,
    required this.lactationNumber,
    required this.milkYield,
    required this.weight,
    required this.heightInCms,
    required this.numCalves,
    required this.earTagNumber,
    required this.ageInMonths,
    required this.ageRecordedAt,
    required this.ownerId,
    required this.visuals,
  });

  Pashudhan copyWith({
    String? uuid,
    String? category,
    String? name,
    String? breed,
    int? lactationNumber,
    double? milkYield,
    double? weight,
    double? heightInCms,
    int? numCalves,
    String? earTagNumber,
    int? ageInMonths,
    String? ageRecordedAt,
    int? ownerId,
    List<int>? visuals,
  }) {
    return Pashudhan(
      uuid: uuid ?? this.uuid,
      category: category ?? this.category,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      lactationNumber: lactationNumber ?? this.lactationNumber,
      milkYield: milkYield ?? this.milkYield,
      weight: weight ?? this.weight,
      heightInCms: heightInCms ?? this.heightInCms,
      numCalves: numCalves ?? this.numCalves,
      earTagNumber: earTagNumber ?? this.earTagNumber,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
      ownerId: ownerId ?? this.ownerId,
      visuals: visuals ?? this.visuals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'category': category,
      'name': name,
      'breed': breed,
      'lactationNumber': lactationNumber,
      'milkYield': milkYield,
      'weight': weight,
      'heightInCms': heightInCms,
      'numCalves': numCalves,
      'earTagNumber': earTagNumber,
      'ageInMonths': ageInMonths,
      'ageRecordedAt': ageRecordedAt,
      'ownerId': ownerId,
      'visuals': visuals,
    };
  }

  factory Pashudhan.fromMap(Map<String, dynamic> map) {
    return Pashudhan(
      uuid: map['uuid'] ?? '',
      category: map['category'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      lactationNumber: map['lactationNumber']?.toInt() ?? 0,
      milkYield: map['milkYield']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      heightInCms: map['heightInCms']?.toDouble() ?? 0.0,
      numCalves: map['numCalves']?.toInt() ?? 0,
      earTagNumber: map['earTagNumber'] ?? '',
      ageInMonths: map['ageInMonths']?.toInt() ?? 0,
      ageRecordedAt: map['ageRecordedAt'] ?? '',
      ownerId: map['ownerId']?.toInt() ?? 0,
      visuals: List<int>.from(map['visuals'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pashudhan.fromJson(String source) =>
      Pashudhan.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Pashudhan(uuid: $uuid, category: $category, name: $name, breed: $breed, lactationNumber: $lactationNumber, milkYield: $milkYield, weight: $weight, heightInCms: $heightInCms, numCalves: $numCalves, earTagNumber: $earTagNumber, ageInMonths: $ageInMonths, ageRecordedAt: $ageRecordedAt, ownerId: $ownerId, visuals: $visuals)';
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
        listEquals(other.visuals, visuals);
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        category.hashCode ^
        name.hashCode ^
        breed.hashCode ^
        lactationNumber.hashCode ^
        milkYield.hashCode ^
        weight.hashCode ^
        heightInCms.hashCode ^
        numCalves.hashCode ^
        earTagNumber.hashCode ^
        ageInMonths.hashCode ^
        ageRecordedAt.hashCode ^
        ownerId.hashCode ^
        visuals.hashCode;
  }
}
