import 'package:balaji_points/config/theme.dart';
import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../wallet/wallet_page.dart';
import '../profile/profile_page.dart';
import '../redeem/redeem_page.dart'; // Add this import for RedeemPage
import '../transaction/transaction_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(), // Points summary + offers
    WalletPage(), // Earn Balaji Points via tasks // Redeem points for rewards// Points transactions list
    ProfilePage(), // Edit info, logout
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F), // Navy blue background
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.secondary, // Active tab color
        unselectedItemColor: Colors.white, // Inactive tab color
        backgroundColor: AppColors.primary, // Navy blue background
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            label: "Earn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
