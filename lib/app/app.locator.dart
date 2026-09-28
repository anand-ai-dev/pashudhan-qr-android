// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../repository/admin_repository.dart';
import '../repository/associate_partner_repository.dart';
import '../repository/associate_repository.dart';
import '../repository/auth_repository.dart';
import '../repository/breeding_repository.dart';
import '../repository/deworming_repository.dart';
import '../repository/pashudhan_repository.dart';
import '../repository/pet_repository.dart';
import '../repository/user_repository.dart';
import '../repository/vaccination_repository.dart';
import '../services/api_client_service.dart';
import '../services/storage_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator(
    {String? environment, EnvironmentFilter? environmentFilter}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => ApiClientService());
  locator.registerLazySingleton(() => StorageService());
  locator.registerLazySingleton(() => AuthRepository());
  locator.registerLazySingleton(() => AdminRepository());
  locator.registerLazySingleton(() => PashudhanRepository());
  locator.registerLazySingleton(() => PetRepository());
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => AssociateRepository());
  locator.registerLazySingleton(() => AssociatePartnerRepository());
  locator.registerLazySingleton(() => VaccinationRepository());
  locator.registerLazySingleton(() => DewormingRepository());
  locator.registerLazySingleton(() => BreedingRepository());
}
