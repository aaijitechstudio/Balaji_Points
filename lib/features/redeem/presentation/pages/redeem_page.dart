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
          padding: DesignToken.paddingAllLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Work",
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: DesignToken.fontSize2XL,
                  color: DesignToken.black87,
                ),
              ),
              SizedBox(height: DesignToken.heightLG),

              // 🔹 Add Work Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: DesignToken.borderRadiusLG,
                  border: Border.all(color: Colors.pink.shade100),
                ),
                padding: DesignToken.paddingAllXL,
                child: Row(
                  children: [
                    Icon(
                      Icons.add_task_rounded,
                      size: 40,
                      color: Colors.pink.shade700,
                      semanticLabel: 'Add new work task',
                    ),
                    SizedBox(width: DesignToken.widthLG),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add New Work",
                            style: AppTextStyles.nunitoBold.copyWith(
                              fontSize: DesignToken.fontSizeXL,
                            ),
                          ),
                          Text(
                            "Submit photos or job details to earn points",
                            style: AppTextStyles.nunitoRegular.copyWith(
                              fontSize: DesignToken.fontSizeMD,
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
                          borderRadius: DesignToken.borderRadiusSM,
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Add"),
                    ),
                  ],
                ),
              ),

              SizedBox(height: DesignToken.height3XL),
              Text(
                "Recent Work Entries",
                style: AppTextStyles.nunitoBold.copyWith(fontSize: DesignToken.fontSizeXL),
              ),
              SizedBox(height: DesignToken.heightSM),

              // 🔹 Work List
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: DesignToken.borderRadiusLG,
                      ),
                      margin: const EdgeInsets.only(bottom: DesignToken.paddingMD),
                      child: ListTile(
                        leading: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            borderRadius: DesignToken.borderRadiusMD,
                          ),
                          child: const Icon(Icons.work, color: Colors.pink, semanticLabel: 'Work entry'),
                        ),
                        title: Text(
                          "Wooden Door Installation",
                          style: AppTextStyles.nunitoBold,
                        ),
                        subtitle: Text(
                          "Earned 150 Points",
                          style: AppTextStyles.nunitoRegular,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, semanticLabel: 'View details'),
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
