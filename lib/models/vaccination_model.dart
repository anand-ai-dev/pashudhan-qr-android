class Vaccination {
  final String uuid;
  final String? animalUuid;
  final String? animalType;
  final String? vaccineName;
  final String? vaccinationDate;
  final String? nextDueDate;
  final String? notes;
  final String? frontPhoto;
  final String? backPhoto;
  final String? administratorName;
  final String? associatePartnerName;
  final String? createdAt;
  final String? updatedAt;

  Vaccination({
    required this.uuid,
    this.animalUuid,
    this.animalType,
    this.vaccineName,
    this.vaccinationDate,
    this.nextDueDate,
    this.notes,
    this.frontPhoto,
    this.backPhoto,
    this.administratorName,
    this.associatePartnerName,
    this.createdAt,
    this.updatedAt,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      uuid: json['uuid']?.toString() ?? '',
      animalUuid: json['animalUuid']?.toString(),
      animalType: json['animalType']?.toString(),
      vaccineName: json['vaccineName']?.toString(),
      vaccinationDate: json['vaccinationDate']?.toString(),
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
