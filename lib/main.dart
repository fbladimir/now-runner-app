import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'views/splash/splash_screen.dart';
import 'views/landing/landing_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/role_selection_screen.dart';
import 'views/home/requester_home_screen.dart';
import 'views/home/runner_home_screen.dart';

void main() async {
  print('Starting app initialization...');
  WidgetsFlutterBinding.ensureInitialized();
  print('Flutter binding initialized');
  
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    print('Continuing without Firebase...');
  }
  
  print('Running NowRunnerApp...');
  runApp(const NowRunnerApp());
}

class NowRunnerApp extends StatelessWidget {
  const NowRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building NowRunnerApp...');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'NowRunner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5ABDA7),
            brightness: Brightness.light,
            background: const Color(0xFFF4F5F7),
            surface: const Color(0xFFF4F5F7),
            primary: const Color(0xFF5ABDA7),
            secondary: const Color(0xFFFF566B),
            error: const Color(0xFFFF566B),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: const Color(0xFF1A1A1A),
            onSurface: const Color(0xFF1A1A1A),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF1A1A1A),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5ABDA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5ABDA7), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF566B)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
        ),
        home: const SplashScreen(
          child: AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building AuthWrapper...');
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        print('AuthWrapper - isLoading: ${authService.isLoading}, currentUser: ${authService.currentUser}');
        
        if (authService.isLoading) {
          print('Showing loading indicator...');
          return const Scaffold(
            backgroundColor: Color(0xFFF4F5F7),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5ABDA7)),
              ),
            ),
          );
        }
        
        if (authService.currentUser != null) {
          print('User is logged in, checking role...');
          return FutureBuilder(
            future: _getUserRole(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFFF4F5F7),
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5ABDA7)),
                    ),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                print('Error fetching user role: ${snapshot.error}');
                return const RoleSelectionScreen();
              }
              
              final userRole = snapshot.data as String?;
              print('User role: $userRole');
              
              if (userRole == null) {
                // No role found, show role selection
                return const RoleSelectionScreen();
              } else if (userRole == 'requester') {
                return const RequesterHomeScreen();
              } else if (userRole == 'runner') {
                return const RunnerHomeScreen();
              } else {
                // Invalid role, show role selection
                return const RoleSelectionScreen();
              }
            },
          );
        }
        
        print('User is not logged in, showing LandingScreen...');
        return const LandingScreen();
      },
    );
  }

  Future<String?> _getUserRole(BuildContext context) async {
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        return await firestoreService.getUserRole(authService.currentUser!.uid);
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }
}
