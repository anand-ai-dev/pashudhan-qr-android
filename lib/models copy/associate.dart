class Associate {
  final int id;
  final String userName;
  final String idNo;
  final int associatePartnerId;
  final bool approved;
  final String fullName;

  final String? associateType;

  Associate({
    required this.id,
    required this.userName,
    required this.idNo,
    required this.associatePartnerId,
    required this.approved,
    required this.fullName,
    this.associateType,
  });

  factory Associate.fromJson(Map<String, dynamic> json) {
    return Associate(
      id: json['id']?.toInt() ?? 0,
      userName: json['userName'] ?? '',
      idNo: json['idNo'] ?? '',
      associatePartnerId: json['associatePartnerId']?.toInt() ?? 0,
      approved: json['approved'] ?? false,
      fullName: json['fullName'] ?? '',
      associateType: json['associateType'],
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
    };
  }
}
