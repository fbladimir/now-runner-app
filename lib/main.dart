import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/auth_service.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'NowRunner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
        ),
        home: const AuthWrapper(),
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
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (authService.currentUser != null) {
          print('User is logged in, showing HomeScreen...');
          return const HomeScreen();
        }
        
        print('User is not logged in, showing LoginScreen...');
        return const LoginScreen();
      },
    );
  }
}
