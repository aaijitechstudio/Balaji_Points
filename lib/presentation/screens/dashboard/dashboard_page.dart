import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/mixins/double_tap_exit_mixin.dart';
import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../wallet/wallet_page.dart';
import '../profile/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with DoubleTapExitMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(), // Points summary + offers
    WalletPage(), // Earn Balaji Points via tasks // Redeem points for rewards// Points transactions list
    ProfilePage(
      showBottomNav: false,
    ), // Edit info, logout - no bottom nav since DashboardPage has it
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Check for dialogs first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }

          // Handle double-tap exit
          await handleDoubleTapExit();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF001F3F), // Navy blue background
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: DesignToken.secondary, // Active tab color
          unselectedItemColor: DesignToken.white, // Inactive tab color
          backgroundColor: DesignToken.primary, // Navy blue background
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.monetization_on_outlined),
              label: l10n.earn,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
