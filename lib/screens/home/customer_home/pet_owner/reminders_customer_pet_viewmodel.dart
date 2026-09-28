import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/repository/vaccination_repository.dart';
import 'package:pashudhan_qr/repository/deworming_repository.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/repository/breeding_repository.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
class ReminderItem {
  final String title;
  final String petName;
  final DateTime dueDate;
  final String type; 

  ReminderItem({
    required this.title, 
    required this.petName, 
    required this.dueDate, 
    required this.type
  });

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }
}


class RemindersCustomerPetViewModel extends BaseViewModel {
  final _vaccinationRepo = locator<VaccinationRepository>();
  final _dewormingRepo = locator<DewormingRepository>();
  final _petRepo = locator<PetRepository>();
  final _breedingRepo = locator<BreedingRepository>();
  final _pashudhanRepo = locator<PashudhanRepository>();

  List<ReminderItem> reminders = [];
  Map<String, String> animalNames = {};

  void initialize() {
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    setBusy(true);
    try {
      final pets = await _petRepo.getPets();
      for (var pet in pets) {
        animalNames[pet.uuid] = pet.name ?? pet.petName ?? 'Unknown Pet';
      }
      
      // Only load pets for pet reminders

      final vaccinations = await _vaccinationRepo.getVaccinations();
      final dewormings = await _dewormingRepo.getDewormings();

      final List<ReminderItem> allItems = [];

      DateTime? parseDateSafe(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return null;
        try {
          if (int.tryParse(dateStr) != null) {
            return DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));
          }
          return DateTime.parse(dateStr);
        } catch (_) {
          return null;
        }
      }

      for (var v in vaccinations) {
        if (v.animalType != 'PET') continue;
        final due = parseDateSafe(v.nextDueDate);
        if (due != null && due.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
          allItems.add(ReminderItem(
            title: v.vaccineName ?? 'Vaccination',
            petName: animalNames[v.animalUuid] ?? 'Unknown Pet',
            dueDate: due,
            type: 'Vaccination',
          ));
        }
      }

      for (var d in dewormings) {
        final due = parseDateSafe(d.nextDueDate);
        if (due != null && due.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
          allItems.add(ReminderItem(
            title: d.medicineName ?? 'Deworming',
            petName: animalNames[d.petUuid] ?? 'Unknown Pet',
            dueDate: due,
            type: 'Deworming',
          ));
        }
      }

      final breedings = await _breedingRepo.getBreedingReports();
      for (var b in breedings) {
        if (!animalNames.containsKey(b.pashudhanUuid)) continue;
        final due = parseDateSafe(b.dateOfCalving);
        if (due != null && due.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
          allItems.add(ReminderItem(
            title: 'Expected Whelping',
            petName: animalNames[b.pashudhanUuid] ?? 'Unknown Pet',
            dueDate: due,
            type: 'Breeding',
          ));
        }
      }

      allItems.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      reminders = allItems;

    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching reminders: $e');
    } finally {
      setBusy(false);
    }
  }
}
