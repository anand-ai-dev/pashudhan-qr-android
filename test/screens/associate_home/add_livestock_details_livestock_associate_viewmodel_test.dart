import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/dto/pashudhan_dtos.dart';
import 'package:pashudhan_qr/screens/home/associate_home/livestock_farmer_associate/add_livestock_details_livestock_associate_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../helpers/test_helpers.dart';

class MockBuildContext extends Mock implements BuildContext {}

// Minimal Pashudhan to satisfy createPashudhan return value
Pashudhan _fakePashudhan() => Pashudhan(
      uuid: 'uuid-1',
      category: 'COW',
      name: 'Gauri',
      breed: 'Holstein',
      lactationNumber: 2,
      milkYield: 10.0,
      weight: 400.0,
      heightInCms: 140.0,
      numCalves: 0,
      earTagNumber: 'EAR001',
      ageInMonths: 24,
      ageRecordedAt: '2024-01-01',
      ownerId: 1,
      visuals: [],
    );

DioException _dioErr(int status) => DioException(
      requestOptions: RequestOptions(path: '/v1/pashudhan'),
      response: Response(
        requestOptions: RequestOptions(path: '/v1/pashudhan'),
        statusCode: status,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  setUpAll(registerFallbackValues);

  late MockNavigationService mockNav;
  late MockDialogService mockDialog;
  late MockPashudhanRepository mockRepo;
  late AddLivestockDetailsLivestockAssociateViewModel viewModel;

  void fillValid({
    String mobile = '9876543210',
    String name = 'Gauri',
    String breed = 'Holstein',
    String age = '24',
    String weight = '400.0',
    String earTag = 'EAR001',
    String lactation = '2',
  }) {
    viewModel.lfMobileController.text = mobile;
    viewModel.livestockNameController.text = name;
    viewModel.breedController.text = breed;
    viewModel.ageController.text = age;
    viewModel.weightController.text = weight;
    viewModel.idNoController.text = earTag;
    viewModel.lactationNoController.text = lactation;
    // Simulate user clicking "CONTINUE >" to confirm owner details
    viewModel.continueWithOwner(MockBuildContext());
  }

  setUp(() {
    locator.allowReassignment = true;
    mockNav = getAndRegisterNavigationService();
    mockDialog = getAndRegisterDialogService();
    mockRepo = getAndRegisterPashudhanRepository();
    viewModel = AddLivestockDetailsLivestockAssociateViewModel();
  });

  tearDown(() => locator.reset());

  // ── setLivestockType ────────────────────────────────────────────────

  group('setLivestockType', () {
    test('defaults to COW', () {
      expect(viewModel.selectedLivestockType, 'COW');
    });

    test('updates selectedLivestockType', () {
      viewModel.setLivestockType('BUFFALO');
      expect(viewModel.selectedLivestockType, 'BUFFALO');
    });
  });

  // ── submit — validation ─────────────────────────────────────────────

  group('submit — validation', () {
    test('empty mobile shows error dialog', () async {
      viewModel.lfMobileController.text = '';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });

    test('mobile shorter than 10 digits shows error', () async {
      viewModel.lfMobileController.text = '98765';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });

    test('non-numeric mobile shows error', () async {
      viewModel.lfMobileController.text = 'abcdefghij';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });

    test('empty name shows error', () async {
      viewModel.lfMobileController.text = '9876543210';
      viewModel.livestockNameController.text = '';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });

    test('empty breed shows error', () async {
      viewModel.lfMobileController.text = '9876543210';
      viewModel.livestockNameController.text = 'Gauri';
      viewModel.breedController.text = '';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });

    test('non-integer age shows error', () async {
      viewModel.lfMobileController.text = '9876543210';
      viewModel.livestockNameController.text = 'Gauri';
      viewModel.breedController.text = 'Holstein';
      viewModel.ageController.text = 'abc';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });

    test('empty age shows error', () async {
      viewModel.lfMobileController.text = '9876543210';
      viewModel.livestockNameController.text = 'Gauri';
      viewModel.breedController.text = 'Holstein';
      viewModel.ageController.text = '';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });

    test('non-numeric weight shows error', () async {
      viewModel.lfMobileController.text = '9876543210';
      viewModel.livestockNameController.text = 'Gauri';
      viewModel.breedController.text = 'Holstein';
      viewModel.ageController.text = '24';
      viewModel.weightController.text = 'heavy';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });

    test('empty ear tag shows error', () async {
      viewModel.lfMobileController.text = '9876543210';
      viewModel.livestockNameController.text = 'Gauri';
      viewModel.breedController.text = 'Holstein';
      viewModel.ageController.text = '24';
      viewModel.weightController.text = '400';
      viewModel.idNoController.text = '';
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      verifyNever(() => mockRepo.createPashudhan(any()));
    });
  });

  // ── submit — success path ───────────────────────────────────────────

  group('submit — success', () {
    setUp(() {
      when(() => mockRepo.createPashudhan(any()))
          .thenAnswer((_) async => _fakePashudhan());
    });

    test('calls createPashudhan with ownerUserName set to mobile number', () async {
      fillValid();
      await viewModel.submit();

      final captured = verify(() => mockRepo.createPashudhan(captureAny()))
          .captured
          .single as CreatePashudhanRequest;
      expect(captured.ownerUserName, '9876543210');
    });

    test('maps controller values into request correctly', () async {
      fillValid(
        mobile: '9000000001',
        name: 'Kali',
        breed: 'Murrah',
        age: '36',
        weight: '500.5',
        earTag: 'EAR999',
        lactation: '3',
      );
      viewModel.setLivestockType('BUFFALO');
      await viewModel.submit();

      final captured = verify(() => mockRepo.createPashudhan(captureAny()))
          .captured
          .single as CreatePashudhanRequest;
      expect(captured.category, 'BUFFALO');
      expect(captured.name, 'Kali');
      expect(captured.breed, 'Murrah');
      expect(captured.ageInMonths, 36);
      expect(captured.weight, 500.5);
      expect(captured.earTagNumber, 'EAR999');
      expect(captured.lactationNumber, 3);
    });

    test('shows success dialog on API success', () async {
      fillValid();
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
    });

    test('navigates to LivestockMemberDetails after success', () async {
      fillValid();
      await viewModel.submit();

      verify(() => mockNav.navigateToView(any())).called(1);
    });

    test('isBusy is false after successful submit', () async {
      fillValid();
      await viewModel.submit();

      expect(viewModel.isBusy, isFalse);
    });
  });

  // ── submit — DioException 400 ───────────────────────────────────────

  group('submit — DioException 400 (owner not registered)', () {
    setUp(() {
      when(() => mockRepo.createPashudhan(any())).thenThrow(_dioErr(400));
    });

    test('shows confirmation dialog asking to register farmer', () async {
      when(() => mockDialog.showConfirmationDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
            confirmationTitle: any(named: 'confirmationTitle'),
            cancelTitle: any(named: 'cancelTitle'),
          )).thenAnswer((_) async => DialogResponse(confirmed: false));

      fillValid();
      await viewModel.submit();

      verify(() => mockDialog.showConfirmationDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
            confirmationTitle: any(named: 'confirmationTitle'),
            cancelTitle: any(named: 'cancelTitle'),
          )).called(1);
    });

    test('navigates to LivestockMemberDetails when confirmed', () async {
      when(() => mockDialog.showConfirmationDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
            confirmationTitle: any(named: 'confirmationTitle'),
            cancelTitle: any(named: 'cancelTitle'),
          )).thenAnswer((_) async => DialogResponse(confirmed: true));

      fillValid();
      await viewModel.submit();

      verify(() => mockNav.navigateToView(any())).called(1);
    });

    test('does not navigate when user cancels registration', () async {
      when(() => mockDialog.showConfirmationDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
            confirmationTitle: any(named: 'confirmationTitle'),
            cancelTitle: any(named: 'cancelTitle'),
          )).thenAnswer((_) async => DialogResponse(confirmed: false));

      fillValid();
      await viewModel.submit();

      verifyNever(() => mockNav.navigateToView(any()));
    });

    test('isBusy is false after 400 error', () async {
      when(() => mockDialog.showConfirmationDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
            confirmationTitle: any(named: 'confirmationTitle'),
            cancelTitle: any(named: 'cancelTitle'),
          )).thenAnswer((_) async => null);

      fillValid();
      await viewModel.submit();

      expect(viewModel.isBusy, isFalse);
    });
  });

  // ── submit — other DioException statuses ───────────────────────────

  group('submit — other DioException statuses', () {
    for (final status in [401, 403, 409, 500, 503]) {
      test('shows error dialog on $status', () async {
        when(() => mockRepo.createPashudhan(any())).thenThrow(_dioErr(status));
        fillValid();
        await viewModel.submit();

        verify(() => mockDialog.showDialog(
              title: any(named: 'title'),
              description: any(named: 'description'),
            )).called(1);
        expect(viewModel.isBusy, isFalse);
      });
    }
  });

  // ── submit — generic exception ─────────────────────────────────────

  group('submit — generic exception', () {
    test('shows generic error dialog', () async {
      when(() => mockRepo.createPashudhan(any()))
          .thenThrow(Exception('network timeout'));

      fillValid();
      await viewModel.submit();

      verify(() => mockDialog.showDialog(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).called(1);
      expect(viewModel.isBusy, isFalse);
    });
  });
}
