import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;

class RedeemPage extends StatelessWidget {
  const RedeemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignToken.navyBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Work",
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 22,
                  color: DesignToken.black87,
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Add Work Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: DesignToken.redShade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DesignToken.secondary.withValues(alpha: 0.3),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_task_rounded,
                      size: 40,
                      color: DesignToken.redShade700,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add New Work",
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "Submit photos or job details to earn points",
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: 13,
                              color: DesignToken.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignToken.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Add"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Recent Work Entries",
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),

              // 🔹 Work List
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: DesignToken.secondary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.work,
                            color: DesignToken.secondary,
                          ),
                        ),
                        title: Text(
                          "Wooden Door Installation",
                          style: AppTextStyles.nunitoBold,
                        ),
                        subtitle: Text(
                          "Earned 150 Points",
                          style: AppTextStyles.nunitoRegular,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
