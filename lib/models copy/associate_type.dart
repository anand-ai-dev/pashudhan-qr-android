const String kAssociateType = 'associate_type';

enum AssociateType {
  petOwner,
  livestockFarmer,
}

String mapToStorage(AssociateType type) {
  switch (type) {
    case AssociateType.petOwner:
      return 'PET_OWNER';
    case AssociateType.livestockFarmer:
      return 'LIVESTOCK_FARMER';
  }
}

AssociateType? mapFromStorage(String? value) {
  switch (value) {
    case 'PET_OWNER':
      return AssociateType.petOwner;
    case 'LIVESTOCK_FARMER':
      return AssociateType.livestockFarmer;
    default:
      return null;
  }
}
