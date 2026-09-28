import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/core/json_parsers.dart';

class PashudhanResponse {
  final List<Pashudhan> results;

  PashudhanResponse({
    required this.results,
  });

  PashudhanResponse copyWith({
    List<Pashudhan>? results,
  }) {
    return PashudhanResponse(
      results: results ?? this.results,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'results': results.map((x) => x.toMap()).toList(),
    };
  }

  factory PashudhanResponse.fromMap(List<dynamic> list) {
    return PashudhanResponse(
      results: list.map((x) => Pashudhan.fromMap(x as Map<String, dynamic>)).toList(),
    );
  }
   
  // Note: Since the API returns specific object for single get and List for list get, 
  // We might handle those differently in repository or have consistent wrapper in DTO if API structure allows.
  // Based on Swagger: 
  // GET /v1/pashudhan -> List<PashudhanResponse> (Actually API returns List of objects directly)
  // So this DTO might be useful if we want to wrap the list, but for specific endpoints responding with one object we reuse Pashudhan model.

  String toJson() => json.encode(toMap());

  // factory PashudhanResponse.fromJson(String source) => PashudhanResponse.fromMap(json.decode(source));

  @override
  String toString() => 'PashudhanResponse(results: $results)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PashudhanResponse && listEquals(other.results, results);
  }

  @override
  int get hashCode => results.hashCode;
}


class CreatePashudhanRequest {
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
  final String ageRecordedAt;
  final int ageInMonths;
  final String ownerUserName;

  CreatePashudhanRequest({
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
    required this.ageRecordedAt,
    required this.ageInMonths,
    required this.ownerUserName,
  });

  CreatePashudhanRequest copyWith({
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
    String? ageRecordedAt,
    int? ageInMonths,
    String? ownerUserName,
  }) {
    return CreatePashudhanRequest(
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
      ageRecordedAt: ageRecordedAt ?? this.ageRecordedAt,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      ownerUserName: ownerUserName ?? this.ownerUserName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'ageRecordedAt': ageRecordedAt,
      'ageInMonths': ageInMonths,
      'ownerUserName': ownerUserName,
    };
  }

  factory CreatePashudhanRequest.fromMap(Map<String, dynamic> map) {
    return CreatePashudhanRequest(
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
      ageRecordedAt: JsonParsers.parseString(map['ageRecordedAt']),
      ageInMonths: JsonParsers.parseInt(map['ageInMonths']),
      ownerUserName: JsonParsers.parseString(map['ownerUserName']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CreatePashudhanRequest.fromJson(String source) =>
      CreatePashudhanRequest.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CreatePashudhanRequest(category: $category, name: $name, breed: $breed, lactationNumber: $lactationNumber, milkYield: $milkYield, weight: $weight, heightInCms: $heightInCms, numCalves: $numCalves, earTagNumber: $earTagNumber, ageRecordedAt: $ageRecordedAt, ageInMonths: $ageInMonths, ownerUserName: $ownerUserName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreatePashudhanRequest &&
        other.category == category &&
        other.name == name &&
        other.breed == breed &&
        other.lactationNumber == lactationNumber &&
        other.milkYield == milkYield &&
        other.weight == weight &&
        other.heightInCms == heightInCms &&
        other.numCalves == numCalves &&
        other.earTagNumber == earTagNumber &&
        other.ageRecordedAt == ageRecordedAt &&
        other.ageInMonths == ageInMonths &&
        other.ownerUserName == ownerUserName;
  }

  @override
  int get hashCode {
    return category.hashCode ^
        name.hashCode ^
        breed.hashCode ^
        lactationNumber.hashCode ^
        milkYield.hashCode ^
        weight.hashCode ^
        heightInCms.hashCode ^
        numCalves.hashCode ^
        earTagNumber.hashCode ^
        ageRecordedAt.hashCode ^
        ageInMonths.hashCode ^
        ownerUserName.hashCode;
  }
}

class UpdatePashudhanRequest {
  final String category;
  final String name;
  final String breed;
  final String? gender;
  final int lactationNumber;
  final double milkYield;
  final double weight;
  final double heightInCms;
  final int numCalves;
  final int ageInMonths;
  final String ownerUserName;

  UpdatePashudhanRequest({
    required this.category,
    required this.name,
    required this.breed,
    this.gender,
    required this.lactationNumber,
    required this.milkYield,
    required this.weight,
    required this.heightInCms,
    required this.numCalves,
    required this.ageInMonths,
    required this.ownerUserName,
  });

  UpdatePashudhanRequest copyWith({
    String? category,
    String? name,
    String? breed,
    String? gender,
    int? lactationNumber,
    double? milkYield,
    double? weight,
    double? heightInCms,
    int? numCalves,
    int? ageInMonths,
    String? ownerUserName,
  }) {
    return UpdatePashudhanRequest(
      category: category ?? this.category,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      lactationNumber: lactationNumber ?? this.lactationNumber,
      milkYield: milkYield ?? this.milkYield,
      weight: weight ?? this.weight,
      heightInCms: heightInCms ?? this.heightInCms,
      numCalves: numCalves ?? this.numCalves,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      ownerUserName: ownerUserName ?? this.ownerUserName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'name': name,
      'breed': breed,
      'gender': gender,
      'lactationNumber': lactationNumber,
      'milkYield': milkYield,
      'weight': weight,
      'heightInCms': heightInCms,
      'numCalves': numCalves,
      'ageInMonths': ageInMonths,
      'ownerUserName': ownerUserName,
    };
  }

  factory UpdatePashudhanRequest.fromMap(Map<String, dynamic> map) {
    return UpdatePashudhanRequest(
      category: JsonParsers.parseString(map['category']),
      name: JsonParsers.parseString(map['name']),
      breed: JsonParsers.parseString(map['breed']),
      gender: map['gender']?.toString(),
      lactationNumber: JsonParsers.parseInt(map['lactationNumber']),
      milkYield: JsonParsers.parseDouble(map['milkYield']),
      weight: JsonParsers.parseDouble(map['weight']),
      heightInCms: JsonParsers.parseDouble(map['heightInCms']),
      numCalves: JsonParsers.parseInt(map['numCalves']),
      ageInMonths: JsonParsers.parseInt(map['ageInMonths']),
      ownerUserName: JsonParsers.parseString(map['ownerUserName']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdatePashudhanRequest.fromJson(String source) =>
      UpdatePashudhanRequest.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UpdatePashudhanRequest(category: $category, name: $name, breed: $breed, lactationNumber: $lactationNumber, milkYield: $milkYield, weight: $weight, heightInCms: $heightInCms, numCalves: $numCalves, ageInMonths: $ageInMonths, ownerUserName: $ownerUserName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpdatePashudhanRequest &&
        other.category == category &&
        other.name == name &&
        other.breed == breed &&
        other.lactationNumber == lactationNumber &&
        other.milkYield == milkYield &&
        other.weight == weight &&
        other.heightInCms == heightInCms &&
        other.numCalves == numCalves &&
        other.ageInMonths == ageInMonths &&
        other.ownerUserName == ownerUserName;
  }

  @override
  int get hashCode {
    return category.hashCode ^
        name.hashCode ^
        breed.hashCode ^
        lactationNumber.hashCode ^
        milkYield.hashCode ^
        weight.hashCode ^
        heightInCms.hashCode ^
        numCalves.hashCode ^
        ageInMonths.hashCode ^
        ownerUserName.hashCode;
  }
}

class PashudhanAggregationResponseDto {
  final String type;
  final int count;
  final Map<String, dynamic>? breedwiseDist;

  PashudhanAggregationResponseDto({
    required this.type,
    required this.count,
    this.breedwiseDist,
  });

  factory PashudhanAggregationResponseDto.fromMap(Map<String, dynamic> map) {
    return PashudhanAggregationResponseDto(
      type: JsonParsers.parseString(map['type']),
      count: JsonParsers.parseInt(map['count']),
      breedwiseDist: map['breedwiseDist'],
    );
  }
}

class MuzzleRegisterResponse {
  final String? pointId;
  final String? cattleId;
  final double? qualityScore;
  final String? modelVersion;
  final bool accepted;
  final String? rejectReason;

  MuzzleRegisterResponse({
    this.pointId,
    this.cattleId,
    this.qualityScore,
    this.modelVersion,
    required this.accepted,
    this.rejectReason,
  });

  factory MuzzleRegisterResponse.fromMap(Map<String, dynamic> map) {
    return MuzzleRegisterResponse(
      pointId: map['point_id']?.toString(),
      cattleId: map['cattle_id']?.toString(),
      qualityScore: map['quality_score'] is num ? (map['quality_score'] as num).toDouble() : (map['quality_score'] != null ? double.tryParse(map['quality_score'].toString()) : null),
      modelVersion: map['model_version']?.toString(),
      accepted: map['accepted'] == true,
      rejectReason: map['reject_reason']?.toString(),
    );
  }
}

class MuzzleIdentifyAlternative {
  final String cattleId;
  final double score;

  MuzzleIdentifyAlternative({
    required this.cattleId,
    required this.score,
  });

  factory MuzzleIdentifyAlternative.fromMap(Map<String, dynamic> map) {
    return MuzzleIdentifyAlternative(
      cattleId: JsonParsers.parseString(map['cattle_id']),
      score: JsonParsers.parseDouble(map['score']),
    );
  }
}

class MuzzleIdentifyMatch {
  final String cattleId;
  final double score;
  final int supportingHits;
  final Pashudhan? pashudhan;

  MuzzleIdentifyMatch({
    required this.cattleId,
    required this.score,
    required this.supportingHits,
    this.pashudhan,
  });

  factory MuzzleIdentifyMatch.fromMap(Map<String, dynamic> map) {
    return MuzzleIdentifyMatch(
      cattleId: JsonParsers.parseString(map['cattle_id']),
      score: JsonParsers.parseDouble(map['score']),
      supportingHits: JsonParsers.parseInt(map['supporting_hits']),
      pashudhan: map['pashudhan'] != null
          ? Pashudhan.fromMap(map['pashudhan'])
          : null,
    );
  }
}

class MuzzleIdentifyResponse {
  final MuzzleIdentifyMatch? match;
  final List<MuzzleIdentifyAlternative> alternatives;
  final String? modelVersion;
  final Map<String, int>? timingMs;

  MuzzleIdentifyResponse({
    this.match,
    required this.alternatives,
    this.modelVersion,
    this.timingMs,
  });

  factory MuzzleIdentifyResponse.fromMap(Map<String, dynamic> map) {
    var altsList = map['alternatives'] as List?;
    var alts = <MuzzleIdentifyAlternative>[];
    if (altsList != null) {
      alts = altsList.map((e) => MuzzleIdentifyAlternative.fromMap(e)).toList();
    }

    Map<String, int>? timings;
    if (map['timing_ms'] != null) {
      timings = Map<String, int>.from(map['timing_ms']);
    }

    return MuzzleIdentifyResponse(
      match: map['match'] != null
          ? MuzzleIdentifyMatch.fromMap(map['match'])
          : null,
      alternatives: alts,
      modelVersion: map['model_version']?.toString(),
      timingMs: timings,
    );
  }
}
