import 'package:flutter/material.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/widgets/common_layout.dart';

class ApprovalPendingView extends StatelessWidget {
  const ApprovalPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Approval Pending',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account is currently under review. You will be notified once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              ElevatedButton(
                onPressed: () async {
                  await locator<AuthRepository>().logout();
                  locator<NavigationService>()
                      .clearStackAndShow(Routes.loginView);
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
