// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i13;
import 'package:flutter/material.dart';
import 'package:pashudhan_qr/models/role.dart' as _i14;
import 'package:pashudhan_qr/screens/home/associate_home/livestock_farmer_associate/home_livestock_associate.dart'
    as _i10;
import 'package:pashudhan_qr/screens/home/associate_home/petowner_associate/home_petowner_associate.dart'
    as _i11;
import 'package:pashudhan_qr/screens/home/customer_home/livestock_farmer/livestock_farmer_home.dart'
    as _i8;
import 'package:pashudhan_qr/screens/home/customer_home/pet_owner/home_customer_pet.dart'
    as _i9;
import 'package:pashudhan_qr/screens/login/approval_pending_view.dart' as _i7;
import 'package:pashudhan_qr/screens/login/login_view.dart' as _i3;
import 'package:pashudhan_qr/screens/login/otp_verify_view.dart' as _i4;
import 'package:pashudhan_qr/screens/login/role_selection_view.dart' as _i5;
import 'package:pashudhan_qr/screens/login/splash_view.dart' as _i2;
import 'package:pashudhan_qr/screens/registration/photo_upload_view.dart'
    as _i12;
import 'package:pashudhan_qr/screens/registration/registration_view.dart'
    as _i6;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i15;

class Routes {
  static const splashView = '/';

  static const loginView = '/login-view';

  static const otpVerifyView = '/otp-verify-view';

  static const roleSelectionView = '/role-selection-view';

  static const registrationView = '/registration-view';

  static const approvalPendingView = '/approval-pending-view';

  static const livestockFarmerHome = '/livestock-farmer-home';

  static const homeCustomerPet = '/home-customer-pet';

  static const homeLivestockAssociate = '/home-livestock-associate';

  static const homePetOwnerAssociate = '/home-pet-owner-associate';

  static const photoUploadView = '/photo-upload-view';

  static const all = <String>{
    splashView,
    loginView,
    otpVerifyView,
    roleSelectionView,
    registrationView,
    approvalPendingView,
    livestockFarmerHome,
    homeCustomerPet,
    homeLivestockAssociate,
    homePetOwnerAssociate,
    photoUploadView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.splashView,
      page: _i2.SplashView,
    ),
    _i1.RouteDef(
      Routes.loginView,
      page: _i3.LoginView,
    ),
    _i1.RouteDef(
      Routes.otpVerifyView,
      page: _i4.OtpVerifyView,
    ),
    _i1.RouteDef(
      Routes.roleSelectionView,
      page: _i5.RoleSelectionView,
    ),
    _i1.RouteDef(
      Routes.registrationView,
      page: _i6.RegistrationView,
    ),
    _i1.RouteDef(
      Routes.approvalPendingView,
      page: _i7.ApprovalPendingView,
    ),
    _i1.RouteDef(
      Routes.livestockFarmerHome,
      page: _i8.LivestockFarmerHome,
    ),
    _i1.RouteDef(
      Routes.homeCustomerPet,
      page: _i9.HomeCustomerPet,
    ),
    _i1.RouteDef(
      Routes.homeLivestockAssociate,
      page: _i10.HomeLivestockAssociate,
    ),
    _i1.RouteDef(
      Routes.homePetOwnerAssociate,
      page: _i11.HomePetOwnerAssociate,
    ),
    _i1.RouteDef(
      Routes.photoUploadView,
      page: _i12.PhotoUploadView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.SplashView: (data) {
      final args = data.getArgs<SplashViewArguments>(
        orElse: () => const SplashViewArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i2.SplashView(key: args.key, skipDelay: args.skipDelay),
        settings: data,
      );
    },
    _i3.LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => const LoginViewArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.LoginView(key: args.key),
        settings: data,
      );
    },
    _i4.OtpVerifyView: (data) {
      final args = data.getArgs<OtpVerifyViewArguments>(nullOk: false);
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.OtpVerifyView(
            key: args.key, phoneNumber: args.phoneNumber, otpId: args.otpId),
        settings: data,
      );
    },
    _i5.RoleSelectionView: (data) {
      final args = data.getArgs<RoleSelectionViewArguments>(
        orElse: () => const RoleSelectionViewArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.RoleSelectionView(key: args.key),
        settings: data,
      );
    },
    _i6.RegistrationView: (data) {
      final args = data.getArgs<RegistrationViewArguments>(nullOk: false);
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i6.RegistrationView(key: args.key, type: args.type),
        settings: data,
      );
    },
    _i7.ApprovalPendingView: (data) {
      final args = data.getArgs<ApprovalPendingViewArguments>(
        orElse: () => const ApprovalPendingViewArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.ApprovalPendingView(key: args.key),
        settings: data,
      );
    },
    _i8.LivestockFarmerHome: (data) {
      final args = data.getArgs<LivestockFarmerHomeArguments>(
        orElse: () => const LivestockFarmerHomeArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.LivestockFarmerHome(key: args.key),
        settings: data,
      );
    },
    _i9.HomeCustomerPet: (data) {
      final args = data.getArgs<HomeCustomerPetArguments>(
        orElse: () => const HomeCustomerPetArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i9.HomeCustomerPet(key: args.key),
        settings: data,
      );
    },
    _i10.HomeLivestockAssociate: (data) {
      final args = data.getArgs<HomeLivestockAssociateArguments>(
        orElse: () => const HomeLivestockAssociateArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i10.HomeLivestockAssociate(key: args.key),
        settings: data,
      );
    },
    _i11.HomePetOwnerAssociate: (data) {
      final args = data.getArgs<HomePetOwnerAssociateArguments>(
        orElse: () => const HomePetOwnerAssociateArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i11.HomePetOwnerAssociate(key: args.key),
        settings: data,
      );
    },
    _i12.PhotoUploadView: (data) {
      final args = data.getArgs<PhotoUploadViewArguments>(nullOk: false);
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => _i12.PhotoUploadView(
            key: args.key, uuid: args.uuid, isPet: args.isPet),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class SplashViewArguments {
  const SplashViewArguments({
    this.key,
    this.skipDelay = false,
  });

  final _i13.Key? key;

  final bool skipDelay;

  @override
  String toString() {
    return '{"key": "$key", "skipDelay": "$skipDelay"}';
  }

  @override
  bool operator ==(covariant SplashViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.skipDelay == skipDelay;
  }

  @override
  int get hashCode {
    return key.hashCode ^ skipDelay.hashCode;
  }
}

class LoginViewArguments {
  const LoginViewArguments({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class OtpVerifyViewArguments {
  const OtpVerifyViewArguments({
    this.key,
    required this.phoneNumber,
    required this.otpId,
  });

  final _i13.Key? key;

  final String phoneNumber;

  final int otpId;

  @override
  String toString() {
    return '{"key": "$key", "phoneNumber": "$phoneNumber", "otpId": "$otpId"}';
  }

  @override
  bool operator ==(covariant OtpVerifyViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.phoneNumber == phoneNumber &&
        other.otpId == otpId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ phoneNumber.hashCode ^ otpId.hashCode;
  }
}

class RoleSelectionViewArguments {
  const RoleSelectionViewArguments({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant RoleSelectionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class RegistrationViewArguments {
  const RegistrationViewArguments({
    this.key,
    required this.type,
  });

  final _i13.Key? key;

  final _i14.UserRole type;

  @override
  String toString() {
    return '{"key": "$key", "type": "$type"}';
  }

  @override
  bool operator ==(covariant RegistrationViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.type == type;
  }

  @override
  int get hashCode {
    return key.hashCode ^ type.hashCode;
  }
}

class ApprovalPendingViewArguments {
  const ApprovalPendingViewArguments({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ApprovalPendingViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LivestockFarmerHomeArguments {
  const LivestockFarmerHomeArguments({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LivestockFarmerHomeArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class HomeCustomerPetArguments {
  const HomeCustomerPetArguments({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant HomeCustomerPetArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class HomeLivestockAssociateArguments {
  const HomeLivestockAssociateArguments({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant HomeLivestockAssociateArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class HomePetOwnerAssociateArguments {
  const HomePetOwnerAssociateArguments({this.key});

  final _i13.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant HomePetOwnerAssociateArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class PhotoUploadViewArguments {
  const PhotoUploadViewArguments({
    this.key,
    required this.uuid,
    this.isPet,
  });

  final _i13.Key? key;

  final String uuid;

  final bool? isPet;

  @override
  String toString() {
    return '{"key": "$key", "uuid": "$uuid", "isPet": "$isPet"}';
  }

  @override
  bool operator ==(covariant PhotoUploadViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.uuid == uuid && other.isPet == isPet;
  }

  @override
  int get hashCode {
    return key.hashCode ^ uuid.hashCode ^ isPet.hashCode;
  }
}

extension NavigatorStateExtension on _i15.NavigationService {
  Future<dynamic> navigateToSplashView({
    _i13.Key? key,
    bool skipDelay = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.splashView,
        arguments: SplashViewArguments(key: key, skipDelay: skipDelay),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOtpVerifyView({
    _i13.Key? key,
    required String phoneNumber,
    required int otpId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.otpVerifyView,
        arguments: OtpVerifyViewArguments(
            key: key, phoneNumber: phoneNumber, otpId: otpId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRoleSelectionView({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.roleSelectionView,
        arguments: RoleSelectionViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToRegistrationView({
    _i13.Key? key,
    required _i14.UserRole type,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.registrationView,
        arguments: RegistrationViewArguments(key: key, type: type),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToApprovalPendingView({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.approvalPendingView,
        arguments: ApprovalPendingViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLivestockFarmerHome({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.livestockFarmerHome,
        arguments: LivestockFarmerHomeArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeCustomerPet({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.homeCustomerPet,
        arguments: HomeCustomerPetArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeLivestockAssociate({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.homeLivestockAssociate,
        arguments: HomeLivestockAssociateArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomePetOwnerAssociate({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.homePetOwnerAssociate,
        arguments: HomePetOwnerAssociateArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPhotoUploadView({
    _i13.Key? key,
    required String uuid,
    bool? isPet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.photoUploadView,
        arguments: PhotoUploadViewArguments(key: key, uuid: uuid, isPet: isPet),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSplashView({
    _i13.Key? key,
    bool skipDelay = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.splashView,
        arguments: SplashViewArguments(key: key, skipDelay: skipDelay),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOtpVerifyView({
    _i13.Key? key,
    required String phoneNumber,
    required int otpId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.otpVerifyView,
        arguments: OtpVerifyViewArguments(
            key: key, phoneNumber: phoneNumber, otpId: otpId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRoleSelectionView({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.roleSelectionView,
        arguments: RoleSelectionViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithRegistrationView({
    _i13.Key? key,
    required _i14.UserRole type,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.registrationView,
        arguments: RegistrationViewArguments(key: key, type: type),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithApprovalPendingView({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.approvalPendingView,
        arguments: ApprovalPendingViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLivestockFarmerHome({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.livestockFarmerHome,
        arguments: LivestockFarmerHomeArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeCustomerPet({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.homeCustomerPet,
        arguments: HomeCustomerPetArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeLivestockAssociate({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.homeLivestockAssociate,
        arguments: HomeLivestockAssociateArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomePetOwnerAssociate({
    _i13.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.homePetOwnerAssociate,
        arguments: HomePetOwnerAssociateArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPhotoUploadView({
    _i13.Key? key,
    required String uuid,
    bool? isPet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.photoUploadView,
        arguments: PhotoUploadViewArguments(key: key, uuid: uuid, isPet: isPet),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
