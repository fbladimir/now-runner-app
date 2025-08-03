import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../home/requester_home_screen.dart';

class RequesterOnboardingScreen extends StatefulWidget {
  const RequesterOnboardingScreen({super.key});

  @override
  State<RequesterOnboardingScreen> createState() => _RequesterOnboardingScreenState();
}

class _RequesterOnboardingScreenState extends State<RequesterOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _zipCodeController = TextEditingController();
  String _selectedContactMethod = 'Text';
  bool _isLoading = false;

  final List<String> _contactMethods = ['Text', 'Call', 'In-App Only'];

  @override
  void dispose() {
    _nameController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveRequesterInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      // Save requester info to Firestore
      await firestoreService.updateRequesterInfo(
        userId: authService.currentUser!.uid,
        name: _nameController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        contactMethod: _selectedContactMethod,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RequesterHomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save info: $e'),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 20),
                Text(
                  'Tell us about yourself',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us connect you with the right runners',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF1A1A1A).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // ZIP Code Field
                        TextFormField(
                          controller: _zipCodeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ZIP Code',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            helperText: 'Location where you typically need help',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your ZIP code';
                            }
                            if (value.length != 5) {
                              return 'Please enter a valid 5-digit ZIP code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Contact Method Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedContactMethod,
                          decoration: const InputDecoration(
                            labelText: 'Preferred Contact Method',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          items: _contactMethods.map((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedContactMethod = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveRequesterInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5ABDA7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Continue',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 