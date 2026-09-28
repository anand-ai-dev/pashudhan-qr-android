import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/models/breeding_model.dart';
import 'package:pashudhan_qr/screens/home/customer_home/pet_owner/breeding_details_customer_pet_viewmodel.dart';
import 'package:pashudhan_qr/screens/reports/breeding_detail_screen.dart';

class BreedingDetailsCustomerPet extends StackedView<BreedingDetailsCustomerPetViewModel> {
  const BreedingDetailsCustomerPet({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(BuildContext context, BreedingDetailsCustomerPetViewModel viewModel, Widget? child) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryGreen,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: primaryGreen,
            image: DecorationImage(
              image: AssetImage('assets/pattern_bg.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.15,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Title
              Container(
                height: 65,
                decoration: BoxDecoration(
                  color: darkBrown,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 3.5),
                ),
                child: const Center(
                  child: Text(
                    'BREEDING RECORDS',
                    style: TextStyle(
                      color: buttonYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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

  Widget _buildContent(BuildContext context, BreedingDetailsCustomerPetViewModel viewModel) {
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

    if (viewModel.breedingReports.isEmpty) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.breedingReports.length,
      itemBuilder: (context, index) {
        final record = viewModel.breedingReports[index];
        return _buildBreedingCard(context, record, viewModel);
      },
    );
  }

  Widget _buildBreedingCard(BuildContext context, BreedingReport record, BreedingDetailsCustomerPetViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BreedingDetailScreen(uuid: record.uuid),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    'Type: ${record.inseminationType ?? 'Unknown'}',
                    style: const TextStyle(color: darkBrown, fontSize: 16, fontWeight: FontWeight.w900),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(record.dateOfInsemination),
                  style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Bull Breed: ${record.bullBreed ?? 'N/A'}',
              style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (record.administratorName != null) ...[
              const SizedBox(height: 4),
              Text(
                'By: ${record.administratorName}',
                style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
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
  BreedingDetailsCustomerPetViewModel viewModelBuilder(BuildContext context) => BreedingDetailsCustomerPetViewModel();

  @override
  void onViewModelReady(BreedingDetailsCustomerPetViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
