import 'package:pashudhan_qr/core/json_parsers.dart';

class Associate {
  final int id;
  final String userName;
  final String idNo;
  final int associatePartnerId;
  final bool approved;
  final String fullName;

  final String? associateType;
  final String? partnerType;

  Associate({
    required this.id,
    required this.userName,
    required this.idNo,
    required this.associatePartnerId,
    required this.approved,
    required this.fullName,
    this.associateType,
    this.partnerType,
  });

  factory Associate.fromJson(Map<String, dynamic> json) {
    return Associate(
      id: JsonParsers.parseInt(json['id']),
      userName: JsonParsers.parseString(json['userName']),
      idNo: JsonParsers.parseString(json['idNo']),
      associatePartnerId: JsonParsers.parseInt(json['associatePartnerId']),
      approved: JsonParsers.parseBool(json['approved']),
      fullName: JsonParsers.parseString(json['fullName']),
      associateType: JsonParsers.parseString(json['associateType']),
      partnerType: json['partnerType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'idNo': idNo,
      'associatePartnerId': associatePartnerId,
      'approved': approved,
      'fullName': fullName,
      'associateType': associateType,
      'partnerType': partnerType,
    };
  }
}
