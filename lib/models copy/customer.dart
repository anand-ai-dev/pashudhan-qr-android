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
      id: json['id']?.toInt() ?? 0,
      userName: json['userName'] ?? '',
      fatherName: json['fatherName'],
      name: json['name'] ?? '',
      address: json['address'],
      pincode: json['pincode']?.toInt(),
      aadharNumber: json['aadharNumber'],
      profilePic: json['profilePic'],
      gender: json['gender'],
      caste: json['caste'],
      deviceId: json['deviceId'],
      aadharVerified: json['aadharVerified'] ?? false,
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
