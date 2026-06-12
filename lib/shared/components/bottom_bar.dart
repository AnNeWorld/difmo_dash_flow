import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dashflow/features/dashboard/pages/homepage.dart';
import 'package:dashflow/features/activities/pages/activity.dart';
import 'package:dashflow/features/profile/pages/profile.dart';

class BottomBarWidget extends StatefulWidget {
  const BottomBarWidget({super.key});

  @override
  State<BottomBarWidget> createState() => _BottomBarWidgetState();
}

class _BottomBarWidgetState extends State<BottomBarWidget> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const DashboardPage(),
    ActivityPage(),
    const ProfilePage(),
  ];

  void onNavTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> _onBackPressed() async {
    // If not on Home tab → navigate back to Home tab
    if (selectedIndex != 0) {
      setState(() {
        selectedIndex = 0;
      });
      return;
    }

    // On Home tab → show exit confirmation dialog
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon bubble
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF36617E).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.logout,
                  color: Color(0xFF36617E),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Exit App?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Are you sure you want to exit\nthe application?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Action buttons
              Row(
                children: [
                  // Try Again (stay)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF36617E),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          color: Color(0xFF36617E),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Exit App (leave)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36617E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Exit App',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if ((shouldExit ?? false) && mounted) {
      SystemNavigator.pop(); // Properly exits the Android app
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: selectedIndex, children: screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: const Color(0xFF36617E),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: onNavTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home),
              activeIcon: Icon(Iconsax.home5),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.clock),
              activeIcon: Icon(Iconsax.clock5),
              label: 'Activity',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Iconsax.folder_2),
            //   activeIcon: Icon(Iconsax.folder_25),
            //   label: 'Projects',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.profile_circle),
              activeIcon: Icon(Iconsax.profile_circle5),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
