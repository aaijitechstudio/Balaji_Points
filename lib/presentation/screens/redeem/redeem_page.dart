import 'package:flutter/material.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/config/theme.dart' hide AppColors;

class RedeemPage extends StatelessWidget {
  const RedeemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F), // Navy blue background
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
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink.shade100),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_task_rounded,
                      size: 40,
                      color: Colors.pink.shade700,
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
                        backgroundColor: Colors.pinkAccent,
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
                            color: Colors.pink.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.work, color: Colors.pink),
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
