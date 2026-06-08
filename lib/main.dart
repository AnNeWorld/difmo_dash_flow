import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:dashflow/features/auth/pages/login_screen.dart';
import 'package:dashflow/company/pages/dashboard_page.dart' as company_dashboard;
import 'package:dashflow/company/pages/admin_shell.dart';
import 'package:dashflow/shared/components/bottom_bar.dart';

import 'package:dashflow/company/services/api_service.dart' as company_api;

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;

  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;

    try {
      await mapsImplementation.initializeWithRenderer(
        AndroidMapRenderer.latest,
      );
    } catch (e) {
      debugPrint("Renderer initialization failed: $e");
    }
  }

  await company_api.ApiService().init();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token') ?? prefs.getString('token');
  final userStr = prefs.getString('user');
  
  Widget initialScreen = const LoginScreen();
  
  if (token != null && token.isNotEmpty) {
    bool isAdmin = false;
    if (userStr != null) {
      try {
        final user = jsonDecode(userStr);
        final roleField = user['role'];
        if (roleField != null && roleField.toString().toLowerCase() == 'admin') {
          isAdmin = true;
        } else if (user['roles'] != null) {
          final rolesRaw = user['roles'];
          if (rolesRaw is List) {
            for (final r in rolesRaw) {
              if (r is Map && r['name'] != null && r['name'].toString().toLowerCase() == 'admin') {
                isAdmin = true;
                break;
              } else if (r is String && r.toLowerCase() == 'admin') {
                isAdmin = true;
                break;
              }
            }
          } else if (rolesRaw is String && rolesRaw.toLowerCase() == 'admin') {
            isAdmin = true;
          }
        }
      } catch (_) {}
    }
    if (isAdmin) {
      initialScreen = const AdminShell();
    } else {
      initialScreen = const BottomBarWidget();
    }
  }

  runApp(ProviderScope(child: MyApp(initialScreen: initialScreen)));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     navigatorKey: navigatorKey,
     debugShowCheckedModeBanner: false,
     title: 'Dashflow',

     theme: ThemeData(
       useMaterial3: true,

       colorScheme: ColorScheme.fromSeed(
         seedColor: const Color(0xFF36617E),
         secondary: Colors.white,
         surface: Colors.grey.shade50,
       ),

       scaffoldBackgroundColor: Colors.grey.shade50,

       textTheme: GoogleFonts.poppinsTextTheme(),

       appBarTheme: const AppBarTheme(
         backgroundColor: Color(0xFF36617E),
         foregroundColor: Colors.white,
         centerTitle: true,
         elevation: 0,
       ),

       elevatedButtonTheme: ElevatedButtonThemeData(
         style: ElevatedButton.styleFrom(
           backgroundColor: const Color(0xFF36617E),
           foregroundColor: Colors.white,
           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
           ),
         ),
       ),

       cardTheme: CardThemeData(
         color: Colors.white,
         elevation: 2,
         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(16),
         ),
       ),

       inputDecorationTheme: InputDecorationTheme(
         filled: true,
         fillColor: Colors.white,

         contentPadding: const EdgeInsets.symmetric(
           horizontal: 16,
           vertical: 16,
         ),

         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.grey.shade300),
         ),

         enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.grey.shade300),
         ),

         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: Color(0xFF36617E), width: 2),
         ),
       ),
     ),

     home: initialScreen,

     routes: {
       '/login':     (context) => const LoginScreen(),
       '/dashboard': (context) => const company_dashboard.DashboardPage(),
       '/home':      (context) => const BottomBarWidget(),
     },
   );
  }
}