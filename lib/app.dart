// filepath: lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'presentation/widgets/loading_overlay.dart';
import 'package:google_fonts/google_fonts.dart';

class BalajiPointsApp extends ConsumerWidget {
  const BalajiPointsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider); // Correctly fetch the router
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Balaji Points',
      theme: appTheme, //
      routerConfig: router, // Use the fetched router
      builder: (context, child) =>
          Stack(children: [if (child != null) child, const LoadingOverlay()]),
    );
  }
}
