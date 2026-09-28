import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:pashudhan_qr/repository/dto/otp_dtos.dart';
import 'package:pashudhan_qr/repository/dto/pashudhan_dtos.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:stacked_services/stacked_services.dart';

class MockNavigationService extends Mock implements NavigationService {}

class MockDialogService extends Mock implements DialogService {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockStorageService extends Mock implements StorageService {}

class MockPashudhanRepository extends Mock implements PashudhanRepository {}

MockNavigationService getAndRegisterNavigationService() {
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);

  // Stub navigateTo with all named params wildcarded
  when(() => service.navigateTo(
        any(),
        arguments: any(named: 'arguments'),
        id: any(named: 'id'),
        preventDuplicates: any(named: 'preventDuplicates'),
        parameters: any(named: 'parameters'),
        transition: any(named: 'transition'),
      )).thenAnswer((_) async => null);

  // Stub clearStackAndShow with all named params wildcarded
  when(() => service.clearStackAndShow(
        any(),
        arguments: any(named: 'arguments'),
        id: any(named: 'id'),
        parameters: any(named: 'parameters'),
      )).thenAnswer((_) async => null);

  // Stub navigateToView with all named params wildcarded
  when(() => service.navigateToView(
        any(),
        arguments: any(named: 'arguments'),
        id: any(named: 'id'),
        opaque: any(named: 'opaque'),
        curve: any(named: 'curve'),
        duration: any(named: 'duration'),
        fullscreenDialog: any(named: 'fullscreenDialog'),
        popGesture: any(named: 'popGesture'),
        preventDuplicates: any(named: 'preventDuplicates'),
        transition: any(named: 'transition'),
        transitionStyle: any(named: 'transitionStyle'),
      )).thenAnswer((_) async => null);

  return service;
}

MockDialogService getAndRegisterDialogService() {
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);

  when(() => service.showDialog(
        title: any(named: 'title'),
        description: any(named: 'description'),
        dialogPlatform: any(named: 'dialogPlatform'),
        buttonTitle: any(named: 'buttonTitle'),
        cancelTitle: any(named: 'cancelTitle'),
        barrierDismissible: any(named: 'barrierDismissible'),
      )).thenAnswer((_) async => null);

  when(() => service.showConfirmationDialog(
        title: any(named: 'title'),
        description: any(named: 'description'),
        confirmationTitle: any(named: 'confirmationTitle'),
        cancelTitle: any(named: 'cancelTitle'),
        dialogPlatform: any(named: 'dialogPlatform'),
        barrierDismissible: any(named: 'barrierDismissible'),
        cancelTitleColor: any(named: 'cancelTitleColor'),
        confirmationTitleColor: any(named: 'confirmationTitleColor'),
        routeSettings: any(named: 'routeSettings'),
      )).thenAnswer((_) async => null);

  return service;
}

MockAuthRepository getAndRegisterAuthRepository() {
  final service = MockAuthRepository();
  locator.registerSingleton<AuthRepository>(service);
  return service;
}

MockStorageService getAndRegisterStorageService() {
  final service = MockStorageService();
  locator.registerSingleton<StorageService>(service);
  return service;
}

MockPashudhanRepository getAndRegisterPashudhanRepository() {
  final service = MockPashudhanRepository();
  locator.registerSingleton<PashudhanRepository>(service);
  return service;
}

void registerFallbackValues() {
  registerFallbackValue(Uri());
  registerFallbackValue(VerifyOtpRequest(otpId: 0, otp: 0, userName: ''));
  registerFallbackValue(CreatePashudhanRequest(
    category: '',
    name: '',
    breed: '',
    lactationNumber: 0,
    milkYield: 0,
    weight: 0,
    heightInCms: 0,
    numCalves: 0,
    earTagNumber: '',
    ageRecordedAt: '',
    ageInMonths: 0,
    ownerUserName: '',
  ));
  registerFallbackValue(const SizedBox());
  registerFallbackValue(const RouteSettings());
}
