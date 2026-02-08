import 'package:flutter/material.dart';
import 'package:balaji_points/config/theme.dart';
import 'package:balaji_points/core/theme/design_token.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Transaction Page", style: AppTextStyles.nunitoBold.copyWith(fontSize: DesignToken.fontSize2XL)),
    );
  }
}
