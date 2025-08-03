import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../landing/landing_screen.dart';
import '../home/requester_home_screen.dart';
import '../home/runner_home_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _checkExistingRole();
  }

  Future<void> _checkExistingRole() async {
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        print('Checking existing role for user: ${authService.currentUser!.uid}');
        final userRole = await firestoreService.getUserRole(authService.currentUser!.uid);
        print('Existing role found: $userRole');
        
        if (userRole == 'requester') {
          print('User has requester role, navigating to RequesterHomeScreen');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RequesterHomeScreen(),
              ),
            );
          }
        } else if (userRole == 'runner') {
          print('User has runner role, navigating to RunnerHomeScreen');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RunnerHomeScreen(),
              ),
            );
          }
        } else {
          print('No existing role found, staying on role selection screen');
        }
      }
    } catch (e) {
      print('Error checking existing role: $e');
      // Don't navigate away, let user stay on role selection screen
    }
  }

  Future<void> _selectRole(String role) async {
    if (_isLoading) return;

    setState(() {
      _selectedRole = role;
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      // Save user role to Firestore
      await firestoreService.updateUserRole(
        authService.currentUser!.uid,
        role,
      );

      if (mounted) {
        // Navigate to appropriate home screen
        if (role == 'requester') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RequesterHomeScreen(),
            ),
          );
        } else if (role == 'runner') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RunnerHomeScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save role: $e'),
            backgroundColor: const Color(0xFFFF566B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Logout button for testing
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final authService = context.read<AuthService>();
                        await authService.signOut();
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LandingScreen(),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logout failed: $e'),
                              backgroundColor: const Color(0xFFFF566B),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout, color: Color(0xFF5ABDA7)),
                    label: Text(
                      'Logout (Test)',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF5ABDA7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Welcome Message
              Text(
                'Welcome to NowRunner!',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tell us how you\'ll be using the app',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF1A1A1A).withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Role Selection Cards
              Expanded(
                child: Column(
                  children: [
                    // Requester Card
                    _buildRoleCard(
                      title: 'I\'m a Requester',
                      subtitle: 'I need help with tasks and errands',
                      icon: Icons.shopping_cart_outlined,
                      color: const Color(0xFF5ABDA7),
                      isSelected: _selectedRole == 'requester',
                      onTap: () => _selectRole('requester'),
                    ),
                    const SizedBox(height: 20),
                    
                    // Runner Card
                    _buildRoleCard(
                      title: 'I\'m a Runner',
                      subtitle: 'I can help with tasks and errands',
                      icon: Icons.directions_run,
                      color: const Color(0xFFFF566B),
                      isSelected: _selectedRole == 'runner',
                      onTap: () => _selectRole('runner'),
                    ),
                  ],
                ),
              ),

              // Loading Indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5ABDA7)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF1A1A1A).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
} 