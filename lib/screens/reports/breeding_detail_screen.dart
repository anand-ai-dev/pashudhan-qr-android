import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/screens/reports/breeding_detail_viewmodel.dart';

class BreedingDetailScreen extends StackedView<BreedingDetailViewModel> {
  final String uuid;
  
  const BreedingDetailScreen({super.key, required this.uuid});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(BuildContext context, BreedingDetailViewModel viewModel, Widget? child) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryYellow,
        appBar: AppBar(
          backgroundColor: darkBrown,
          iconTheme: const IconThemeData(color: primaryYellow),
          title: const Text('BREEDING DETAILS', style: TextStyle(color: primaryYellow, fontWeight: FontWeight.bold)),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/pattern_bg.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.15,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BreedingDetailViewModel viewModel) {
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
              onPressed: () => viewModel.initialize(uuid),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (viewModel.breedingReport == null) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    final record = viewModel.breedingReport!;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Insemination Type', record.inseminationType),
            const Divider(color: darkBrown, thickness: 1.5),
            _buildDetailRow('Insemination Date', _formatDate(record.dateOfInsemination)),
            const Divider(color: darkBrown, thickness: 1.5),
            _buildDetailRow('Bull Breed', record.bullBreed),
            const Divider(color: darkBrown, thickness: 1.5),
            _buildDetailRow('Straw No', record.strawNo),
            const Divider(color: darkBrown, thickness: 1.5),
            _buildDetailRow('Calves', record.numberOfCalves),
            const Divider(color: darkBrown, thickness: 1.5),
            _buildDetailRow('Calving Date', _formatDate(record.dateOfCalving)),
            const Divider(color: darkBrown, thickness: 1.5),
            _buildDetailRow('Administrator', record.administratorName),
            const Divider(color: darkBrown, thickness: 1.5),
            _buildDetailRow('Partner', record.associatePartnerName),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: darkBrown, fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value?.isNotEmpty == true ? value! : 'N/A',
              style: const TextStyle(color: darkBrown, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
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
  BreedingDetailViewModel viewModelBuilder(BuildContext context) => BreedingDetailViewModel();

  @override
  void onViewModelReady(BreedingDetailViewModel viewModel) {
    viewModel.initialize(uuid);
    super.onViewModelReady(viewModel);
  }
}
