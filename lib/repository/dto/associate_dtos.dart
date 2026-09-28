import 'package:pashudhan_qr/core/json_parsers.dart';

class AssociatePartnerResponse {
  final int id;
  final String name;

  AssociatePartnerResponse({
    required this.id,
    required this.name,
  });

  factory AssociatePartnerResponse.fromMap(Map<String, dynamic> map) {
    return AssociatePartnerResponse(
      id: JsonParsers.parseInt(map['id']),
      name: JsonParsers.parseString(map['partnerName'] ?? map['name']),
    );
  }
}

class AssociatePartnerRequest {
  final String userName;
  final String partnerName;
  final String partnerType;
  final String registrationNo;
  final String state;
  final String district;
  final String area;
  final String gstNumber;
  final String drugLicenseNumber;
  final String? password;

  AssociatePartnerRequest({
    required this.userName,
    required this.partnerName,
    required this.partnerType,
    required this.registrationNo,
    required this.state,
    required this.district,
    required this.area,
    required this.gstNumber,
    required this.drugLicenseNumber,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'partnerName': partnerName,
      'partnerType': partnerType,
      'registrationNo': registrationNo,
      'state': state,
      'district': district,
      'area': area,
      'gstNumber': gstNumber,
      'drugLicenseNumber': drugLicenseNumber,
      if (password != null) 'password': password,
    };
  }
}

class CreateAssociateRequest {
  final String userName;
  final String fullName;
  final int partnerId;
  final String idNo;

  CreateAssociateRequest({
    required this.userName,
    required this.fullName,
    required this.partnerId,
    required this.idNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'fullName': fullName,
      'associatePartnerId': partnerId,
      'idNo': idNo,
    };
  }
}

class AssociateRequest {
  final String userName;
  final String fullName;
  final String idNo;

  AssociateRequest({
    required this.userName,
    required this.fullName,
    required this.idNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'fullName': fullName,
      'idNo': idNo,
    };
  }
}

class RequestAssociateViewDto {
  final int requestId;
  final String comments;
  final String status;
  final String requestCreatedAt;
  final int associateId;
  final String userName;
  final String? profilePic;
  final int associatePartnerId;
  final String idNo;
  final String fullName;
  final bool approved;
  final String lifecycleState;
  final String associateCreatedAt;
  final String? associateType;

  RequestAssociateViewDto({
    required this.requestId,
    required this.comments,
    required this.status,
    required this.requestCreatedAt,
    required this.associateId,
    required this.userName,
    this.profilePic,
    required this.associatePartnerId,
    required this.idNo,
    required this.fullName,
    required this.approved,
    required this.lifecycleState,
    required this.associateCreatedAt,
    this.associateType,
  });

  factory RequestAssociateViewDto.fromMap(Map<String, dynamic> map) {
    return RequestAssociateViewDto(
      requestId: JsonParsers.parseInt(map['requestId']),
      comments: JsonParsers.parseString(map['comments']),
      status: JsonParsers.parseString(map['status']),
      requestCreatedAt: JsonParsers.parseString(map['requestCreatedAt']),
      associateId: JsonParsers.parseInt(map['associateId']),
      userName: JsonParsers.parseString(map['userName']),
      profilePic: map['profilePic'],
      associatePartnerId: JsonParsers.parseInt(map['associatePartnerId']),
      idNo: JsonParsers.parseString(map['idNo']),
      fullName: JsonParsers.parseString(map['fullName']),
      approved: JsonParsers.parseBool(map['approved']),
      lifecycleState: JsonParsers.parseString(map['lifecycleState']),
      associateCreatedAt: JsonParsers.parseString(map['associateCreatedAt']),
      associateType: map['associateType'],
    );
  }
}
