import 'dart:convert';

import 'package:flutter/foundation.dart';

class Pet {
  final String uuid;
  final String category;
  final String name;
  final String breed;
  final double weight;
  final double heightInCms;
  final String petIdNumber;
  final List<String> visuals;

  Pet({
    required this.uuid,
    required this.category,
    required this.name,
    required this.breed,
    required this.weight,
    required this.heightInCms,
    required this.petIdNumber,
    required this.visuals,
  });

  Pet copyWith({
    String? uuid,
    String? category,
    String? name,
    String? breed,
    double? weight,
    double? heightInCms,
    String? petIdNumber,
    List<String>? visuals,
  }) {
    return Pet(
      uuid: uuid ?? this.uuid,
      category: category ?? this.category,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      weight: weight ?? this.weight,
      heightInCms: heightInCms ?? this.heightInCms,
      petIdNumber: petIdNumber ?? this.petIdNumber,
      visuals: visuals ?? this.visuals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'category': category,
      'name': name,
      'breed': breed,
      'weight': weight,
      'heightInCms': heightInCms,
      'petIdNumber': petIdNumber,
      'visuals': visuals,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      uuid: map['uuid'] ?? '',
      category: map['category'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      weight: map['weight']?.toDouble() ?? 0.0,
      heightInCms: map['heightInCms']?.toDouble() ?? 0.0,
      petIdNumber: map['petIdNumber'] ?? '',
      visuals: List<String>.from(map['visuals'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pet.fromJson(String source) => Pet.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Pet(uuid: $uuid, category: $category, name: $name, breed: $breed, weight: $weight, heightInCms: $heightInCms, petIdNumber: $petIdNumber, visuals: $visuals)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pet &&
        other.uuid == uuid &&
        other.category == category &&
        other.name == name &&
        other.breed == breed &&
        other.weight == weight &&
        other.heightInCms == heightInCms &&
        other.petIdNumber == petIdNumber &&
        listEquals(other.visuals, visuals);
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        category.hashCode ^
        name.hashCode ^
        breed.hashCode ^
        weight.hashCode ^
        heightInCms.hashCode ^
        petIdNumber.hashCode ^
        visuals.hashCode;
  }
}
