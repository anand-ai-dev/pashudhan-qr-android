import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/models/vaccination_model.dart';
import 'package:pashudhan_qr/screens/home/customer_home/livestock_farmer/vaccination_customer_viewmodel.dart';
import 'package:pashudhan_qr/screens/reports/vaccination_detail_screen.dart'; // We will create this

class VaccinationCustomerScreen extends StackedView<VaccinationCustomerViewModel> {
  const VaccinationCustomerScreen({super.key});

  static const Color bgYellow = Color.fromARGB(255, 243, 209, 51);
  static const Color btnGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF5A391D);
  static const Color iconYellow = Color(0xFFEACA25);

  @override
  Widget builder(BuildContext context, VaccinationCustomerViewModel viewModel, Widget? child) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgYellow,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/pattern_bg.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.10,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Title
              Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: darkBrown,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: btnGreen, width: 3.5),
                ),
                child: const Center(
                  child: Text(
                    'VACCINATION RECORDS',
                    style: TextStyle(
                      color: iconYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content Area
              Expanded(
                child: _buildContent(context, viewModel),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, VaccinationCustomerViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator(color: darkBrown));
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: darkBrown, size: 60),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: darkBrown, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: darkBrown),
              onPressed: viewModel.initialize,
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (viewModel.vaccinations.isEmpty) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.vaccinations.length,
      itemBuilder: (context, index) {
        final record = viewModel.vaccinations[index];
        return _buildVaccinationCard(context, record, viewModel);
      },
    );
  }

  Widget _buildVaccinationCard(BuildContext context, Vaccination record, VaccinationCustomerViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VaccinationDetailScreen(uuid: record.uuid),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: btnGreen,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: darkBrown, width: 2.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Vaccine: ${record.vaccineName ?? 'Unknown'}',
                    style: const TextStyle(color: darkBrown, fontSize: 16, fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(record.vaccinationDate),
                  style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final pashudhan = viewModel.pashudhanMap[record.animalUuid];
                final animalName = '${pashudhan?.name ?? "Unknown"} (${pashudhan?.displayGender ?? "NA"})';
                final animalId = pashudhan?.earTagNumber?.isNotEmpty == true 
                    ? pashudhan!.earTagNumber 
                    : (pashudhan?.uuid ?? 'N/A');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animal: $animalName (${record.animalType ?? "Unknown"})',
                      style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $animalId',
                      style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }
            ),
            if (record.administratorName != null) ...[
              const SizedBox(height: 4),
              Text(
                'By: ${record.administratorName}',
                style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
            if (record.frontPhoto != null || record.backPhoto != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (record.frontPhoto != null && record.frontPhoto!.isNotEmpty)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${viewModel.baseUrl}/v1/vaccinations/photos/${record.frontPhoto}',
                          headers: {'Authorization': 'Bearer ${viewModel.token}'},
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(height: 120, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  if (record.frontPhoto != null && record.frontPhoto!.isNotEmpty && record.backPhoto != null && record.backPhoto!.isNotEmpty)
                    const SizedBox(width: 8),
                  if (record.backPhoto != null && record.backPhoto!.isNotEmpty)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${viewModel.baseUrl}/v1/vaccinations/photos/${record.backPhoto}',
                          headers: {'Authorization': 'Bearer ${viewModel.token}'},
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(height: 120, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime date;
      final milliseconds = int.tryParse(isoDate);
      if (milliseconds != null) {
        date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      } else {
        date = DateTime.parse(isoDate);
      }
      final year = date.year;
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  VaccinationCustomerViewModel viewModelBuilder(BuildContext context) => VaccinationCustomerViewModel();

  @override
  void onViewModelReady(VaccinationCustomerViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
