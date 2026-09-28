class ProfilePicUploadRequest {
  final String filePath;
  ProfilePicUploadRequest({required this.filePath});
}

class CreateCustomerRequest {
  final String userName; // phone number (required)
  final String fullName; // required
  final String fatherName;
  final String address;
  final int pinCode;
  final String deviceId;
  final String gender;
  final String caste;
  final String aadharNumber;
  final double? latitude;
  final double? longitude;

  CreateCustomerRequest({
    required this.userName,
    required this.fullName,
    this.fatherName = 'NA',
    this.address = 'NA',
    this.pinCode = 100000,
    this.deviceId = 'NA',
    this.gender = 'NA',
    this.caste = 'NA',
    this.aadharNumber = '',
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'fullName': fullName,
      'fatherName': fatherName,
      'address': address,
      'pinCode': pinCode,
      'deviceId': deviceId,
      'gender': gender,
      'caste': caste,
      'aadharNumber': aadharNumber,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

class CustomerRegistrationStatus {
  final String userName;
  final bool registered;
  final int? customerId;
  final bool approved;

  CustomerRegistrationStatus({
    required this.userName,
    required this.registered,
    this.customerId,
    required this.approved,
  });

  factory CustomerRegistrationStatus.fromMap(Map<String, dynamic> map) {
    return CustomerRegistrationStatus(
      userName: map['userName']?.toString() ?? '',
      registered: map['registered'] == true,
      customerId: map['customerId'] is int
          ? map['customerId'] as int
          : int.tryParse(map['customerId']?.toString() ?? ''),
      approved: map['approved'] == true,
    );
  }
}
