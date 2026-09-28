class Deworming {
  final String uuid;
  final String? petUuid;
  final String? medicineName;
  final String? dewormingDate;
  final String? nextDueDate;
  final String? notes;
  final String? frontPhoto;
  final String? backPhoto;
  final String? administratorName;
  final String? associatePartnerName;
  final String? createdAt;
  final String? updatedAt;

  Deworming({
    required this.uuid,
    this.petUuid,
    this.medicineName,
    this.dewormingDate,
    this.nextDueDate,
    this.notes,
    this.frontPhoto,
    this.backPhoto,
    this.administratorName,
    this.associatePartnerName,
    this.createdAt,
    this.updatedAt,
  });

  factory Deworming.fromJson(Map<String, dynamic> json) {
    return Deworming(
      uuid: json['uuid']?.toString() ?? '',
      petUuid: json['petUuid']?.toString(),
      medicineName: json['medicineName']?.toString(),
      dewormingDate: json['dewormingDate']?.toString(),
      nextDueDate: json['nextDueDate']?.toString(),
      notes: json['notes']?.toString(),
      frontPhoto: json['frontPhoto']?.toString(),
      backPhoto: json['backPhoto']?.toString(),
      administratorName: json['administratorName']?.toString(),
      associatePartnerName: json['associatePartnerName']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}
