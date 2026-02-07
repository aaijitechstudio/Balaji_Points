import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/mixins/double_tap_exit_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> with DoubleTapExitMixin {
  final List<Widget> _pages = const [
    HomePage(),
    WalletPage(),
    ProfilePage(showBottomNav: false),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }
          await handleDoubleTapExit();
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final selectedIndex = state is DashboardTab ? state.selectedIndex : 0;
          
          return Scaffold(
            backgroundColor: const Color(0xFF001F3F),
            body: _pages[selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                context.read<DashboardBloc>().add(TabChanged(index));
              },
              selectedItemColor: DesignToken.secondary,
              unselectedItemColor: DesignToken.white,
              backgroundColor: DesignToken.primary,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home, semanticLabel: 'Home'),
                  label: l10n.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.monetization_on_outlined, semanticLabel: 'Earn points'),
                  label: l10n.earn,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline, semanticLabel: 'User profile'),
                  label: l10n.profile,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
