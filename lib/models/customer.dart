import 'package:pashudhan_qr/core/json_parsers.dart';

class Customer {
  final int id;
  final String userName;
  final String? fatherName;
  final String name;
  final String? address;
  final int? pincode;
  final String? aadharNumber;
  final String? profilePic;
  final String? gender;
  final String? caste;
  final String? deviceId;
  final bool aadharVerified;

  Customer({
    required this.id,
    required this.userName,
    this.fatherName,
    required this.name,
    this.address,
    this.pincode,
    this.aadharNumber,
    this.profilePic,
    this.gender,
    this.caste,
    this.deviceId,
    required this.aadharVerified,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: JsonParsers.parseInt(json['id']),
      userName: JsonParsers.parseString(json['userName']),
      fatherName: JsonParsers.parseString(json['fatherName']),
      name: JsonParsers.parseString(json['name'] ?? json['fullName']),
      address: JsonParsers.parseString(json['address']),
      pincode: JsonParsers.parseInt(json['pincode'] ?? json['pinCode']),
      aadharNumber: JsonParsers.parseString(json['aadharNumber']),
      profilePic: json['profilePic'],
      gender: JsonParsers.parseString(json['gender']),
      caste: JsonParsers.parseString(json['caste']),
      deviceId: JsonParsers.parseString(json['deviceId']),
      aadharVerified: JsonParsers.parseBool(json['aadharVerified']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'fatherName': fatherName,
      'name': name,
      'address': address,
      'pincode': pincode,
      'aadharNumber': aadharNumber,
      'profilePic': profilePic,
      'gender': gender,
      'caste': caste,
      'deviceId': deviceId,
      'aadharVerified': aadharVerified,
    };
  }
}
