import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/models/deworming_model.dart';
import 'deworming_details_customer_pet_viewmodel.dart';

class DewormingDetailsCustomerPet extends StackedView<DewormingDetailsCustomerPetViewModel> {
  const DewormingDetailsCustomerPet({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(
    BuildContext context,
    DewormingDetailsCustomerPetViewModel viewModel,
    Widget? child,
  ) {
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
                    'DEWORMING RECORDS',
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

  Widget _buildContent(BuildContext context, DewormingDetailsCustomerPetViewModel viewModel) {
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

    if (viewModel.dewormingRecords.isEmpty) {
      return const Center(
        child: Text(
          'No deworming records found',
          style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.dewormingRecords.length,
      itemBuilder: (context, index) {
        final record = viewModel.dewormingRecords[index];
        return _buildDewormingCard(context, record, viewModel);
      },
    );
  }

  Widget _buildDewormingCard(BuildContext context, Deworming record, DewormingDetailsCustomerPetViewModel viewModel) {
    final pet = viewModel.petMap[record.petUuid];
    final petName = '${pet?.name ?? pet?.petName ?? 'Unknown'} (${pet?.displayGender ?? 'NA'})';
    final petId = (pet?.petIdNumber?.isNotEmpty == true) ? pet!.petIdNumber : (pet?.uuid ?? 'N/A');
    final petImage = (pet?.visuals.isNotEmpty == true) ? '${viewModel.baseUrl}/v1/pets/${pet!.uuid}/visuals/${pet.visuals.first}' : null;

    return Container(
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
          // Pet info row
          if (pet != null) ...[
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: darkBrown, width: 2),
                  ),
                  child: ClipOval(
                    child: petImage != null
                        ? Image.network(
                            petImage,
                            headers: {'Authorization': 'Bearer ${viewModel.token}'},
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.pets, color: darkBrown, size: 30),
                          )
                        : const Icon(Icons.pets, color: darkBrown, size: 30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        petName,
                        style: const TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'ID: $petId',
                        style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Owner: ${viewModel.ownerName}',
                        style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: darkBrown, thickness: 1),
            ),
          ],
          // Deworming details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Medicine: ${record.medicineName ?? 'Unknown'}',
                  style: const TextStyle(color: darkBrown, fontSize: 16, fontWeight: FontWeight.w900),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatDate(record.dewormingDate),
                style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (record.nextDueDate != null && record.nextDueDate!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Next Due: ${_formatDate(record.nextDueDate)}',
              style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
          if (record.administratorName != null) ...[
            const SizedBox(height: 4),
            Text(
              'By: ${record.administratorName}',
              style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
          if (record.associatePartnerName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Partner: ${record.associatePartnerName}',
              style: const TextStyle(color: darkBrown, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
          // Front and Back Photos
          if (record.frontPhoto != null || record.backPhoto != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (record.frontPhoto != null && record.frontPhoto!.isNotEmpty)
                  Expanded(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${viewModel.baseUrl}/v1/pet-deworming/photos/${record.frontPhoto}',
                            headers: {'Authorization': 'Bearer ${viewModel.token}'},
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(height: 120, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Front', style: TextStyle(color: darkBrown, fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                if (record.frontPhoto != null && record.frontPhoto!.isNotEmpty && record.backPhoto != null && record.backPhoto!.isNotEmpty)
                  const SizedBox(width: 8),
                if (record.backPhoto != null && record.backPhoto!.isNotEmpty)
                  Expanded(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${viewModel.baseUrl}/v1/pet-deworming/photos/${record.backPhoto}',
                            headers: {'Authorization': 'Bearer ${viewModel.token}'},
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(height: 120, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Back', style: TextStyle(color: darkBrown, fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
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
      return isoDate ?? '';
    }
  }

  @override
  DewormingDetailsCustomerPetViewModel viewModelBuilder(BuildContext context) =>
      DewormingDetailsCustomerPetViewModel();

  @override
  void onViewModelReady(DewormingDetailsCustomerPetViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
