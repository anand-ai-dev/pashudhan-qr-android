import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'reminders_customer_pet_viewmodel.dart';
import 'package:intl/intl.dart';

class RemindersCustomerPetScreen extends StackedView<RemindersCustomerPetViewModel> {
  const RemindersCustomerPetScreen({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(BuildContext context, RemindersCustomerPetViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBrown, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pattern_bg.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.15,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // TITLE
            Container(
              width: double.infinity,
              height: 65,
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryYellow, width: 3.5),
              ),
              child: const Center(
                child: Text(
                  'UPCOMING REMINDERS',
                  style: TextStyle(
                    color: buttonYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: viewModel.isBusy
                  ? const Center(child: CircularProgressIndicator(color: darkBrown))
                  : viewModel.reminders.isEmpty
                      ? const Center(
                          child: Text(
                            'No upcoming reminders!',
                            style: TextStyle(
                              color: darkBrown,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: viewModel.reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = viewModel.reminders[index];
                            return _buildReminderCard(reminder);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderItem reminder) {
    final bool isDueSoon = reminder.daysLeft <= 3;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: darkBrown, width: 2.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: reminder.type == 'Vaccination' ? primaryGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              reminder.type == 'Vaccination' ? Icons.vaccines : Icons.medication,
              color: darkBrown,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reminder.type}: ${reminder.title}',
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Pet: ${reminder.petName}',
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: ${DateFormat('dd MMM yyyy').format(reminder.dueDate)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                '${reminder.daysLeft}',
                style: TextStyle(
                  color: isDueSoon ? Colors.red : darkBrown,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Days left',
                style: TextStyle(
                  color: isDueSoon ? Colors.red : darkBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  RemindersCustomerPetViewModel viewModelBuilder(BuildContext context) => RemindersCustomerPetViewModel();

  @override
  void onViewModelReady(RemindersCustomerPetViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
