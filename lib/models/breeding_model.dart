class BreedingReport {
  final String uuid;
  final String? pashudhanUuid;
  final String? dateOfInsemination;
  final String? inseminationType;
  final String? bullBreed;
  final String? strawNo;
  final String? numberOfCalves;
  final String? dateOfCalving;
  final String? administratorName;
  final String? associatePartnerName;
  final String? createdAt;
  final String? updatedAt;

  BreedingReport({
    required this.uuid,
    this.pashudhanUuid,
    this.dateOfInsemination,
    this.inseminationType,
    this.bullBreed,
    this.strawNo,
    this.numberOfCalves,
    this.dateOfCalving,
    this.administratorName,
    this.associatePartnerName,
    this.createdAt,
    this.updatedAt,
  });

  factory BreedingReport.fromJson(Map<String, dynamic> json) {
    return BreedingReport(
      uuid: json['uuid']?.toString() ?? '',
      pashudhanUuid: json['pashudhanUuid']?.toString(),
      dateOfInsemination: json['dateOfInsemination']?.toString(),
      inseminationType: json['inseminationType']?.toString(),
      bullBreed: json['bullBreed']?.toString(),
      strawNo: json['strawNo']?.toString(),
      numberOfCalves: json['numberOfCalves']?.toString(),
      dateOfCalving: json['dateOfCalving']?.toString(),
      administratorName: json['administratorName']?.toString(),
      associatePartnerName: json['associatePartnerName']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}
