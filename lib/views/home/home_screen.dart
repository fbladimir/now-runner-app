import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../auth/role_selection_screen.dart';
import '../requester/requester_screen.dart';
import '../runner/runner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        final user = await firestoreService.getUser(authService.currentUser!.uid);
        if (mounted) {
          setState(() {
            _currentUser = user;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F5F7),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5ABDA7)),
          ),
        ),
      );
    }

    // If user hasn't selected a role yet, show role selection
    if (_currentUser?.role == null) {
      return const RoleSelectionScreen();
    }

    // Route to appropriate screen based on role
    if (_currentUser!.role == 'requester') {
      return const RequesterScreen();
    } else if (_currentUser!.role == 'runner') {
      return const RunnerScreen();
    }

    // Fallback to role selection if role is invalid
    return const RoleSelectionScreen();
  }
} 