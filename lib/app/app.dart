import 'package:pashudhan_qr/repository/admin_repository.dart';
import 'package:pashudhan_qr/repository/associate_partner_repository.dart';
import 'package:pashudhan_qr/repository/associate_repository.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/repository/deworming_repository.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart';
import 'package:pashudhan_qr/repository/breeding_repository.dart';
import 'package:pashudhan_qr/screens/login/login_view.dart';
import 'package:pashudhan_qr/screens/login/otp_verify_view.dart';
import 'package:pashudhan_qr/screens/login/role_selection_view.dart';
import 'package:pashudhan_qr/screens/registration/registration_view.dart';
import 'package:pashudhan_qr/screens/registration/photo_upload_view.dart';
import 'package:pashudhan_qr/screens/login/approval_pending_view.dart';
import 'package:pashudhan_qr/screens/login/splash_view.dart';
import 'package:pashudhan_qr/screens/home/customer_home/livestock_farmer/livestock_farmer_home.dart';
import 'package:pashudhan_qr/screens/home/customer_home/pet_owner/home_customer_pet.dart';
import 'package:pashudhan_qr/screens/home/associate_home/livestock_farmer_associate/home_livestock_associate.dart';
import 'package:pashudhan_qr/screens/home/associate_home/petowner_associate/home_petowner_associate.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:stacked/stacked_annotations.dart';

@StackedApp(
  logger: StackedLogger(),
  routes: [
    MaterialRoute(page: SplashView, initial: true),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: OtpVerifyView),
    MaterialRoute(page: RoleSelectionView),
    MaterialRoute(page: RegistrationView),
    MaterialRoute(page: ApprovalPendingView),
    MaterialRoute(page: LivestockFarmerHome),
    MaterialRoute(page: HomeCustomerPet),
    MaterialRoute(page: HomeLivestockAssociate),
    MaterialRoute(page: HomePetOwnerAssociate),
    MaterialRoute(page: PhotoUploadView),
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: ApiClientService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: AuthRepository),
    LazySingleton(classType: AdminRepository),
    LazySingleton(classType: PashudhanRepository),
    LazySingleton(classType: PetRepository),
    LazySingleton(classType: UserRepository),
    LazySingleton(classType: AssociateRepository),
    LazySingleton(classType: AssociatePartnerRepository),
    LazySingleton(classType: VaccinationRepository),
    LazySingleton(classType: DewormingRepository),
    LazySingleton(classType: BreedingRepository),
  ],
)
class App {}
