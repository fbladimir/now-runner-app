import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../home/runner_home_screen.dart';

class RunnerOnboardingScreen extends StatefulWidget {
  const RunnerOnboardingScreen({super.key});

  @override
  State<RunnerOnboardingScreen> createState() => _RunnerOnboardingScreenState();
}

class _RunnerOnboardingScreenState extends State<RunnerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = false;

  final List<String> _availabilityOptions = ['Weekdays', 'Weekends', 'Evenings', 'Anytime'];
  final Set<String> _selectedAvailability = {};

  @override
  void dispose() {
    _nameController.dispose();
    _zipCodeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _toggleAvailability(String option) {
    setState(() {
      if (_selectedAvailability.contains(option)) {
        _selectedAvailability.remove(option);
      } else {
        _selectedAvailability.add(option);
      }
    });
  }

  Future<void> _saveRunnerInfo() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms & conditions'),
          backgroundColor: Color(0xFFFF566B),
        ),
      );
      return;
    }
    if (_selectedAvailability.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one availability option'),
          backgroundColor: Color(0xFFFF566B),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      // Save runner info to Firestore
      await firestoreService.updateRunnerInfo(
        userId: authService.currentUser!.uid,
        name: _nameController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        availability: _selectedAvailability.toList(),
        bio: _bioController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RunnerHomeScreen(),
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
                  'Get Started as a Runner',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help others and earn money',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            helperText: 'Area where you can accept jobs',
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

                        // Availability Section
                        Text(
                          'Availability',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availabilityOptions.map((option) {
                            final isSelected = _selectedAvailability.contains(option);
                            return GestureDetector(
                              onTap: () => _toggleAvailability(option),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF5ABDA7) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF5ABDA7) : const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: Text(
                                  option,
                                  style: GoogleFonts.inter(
                                    color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Bio Field
                        TextFormField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Short Bio (Optional)',
                            prefixIcon: Icon(Icons.edit_outlined),
                            helperText: 'Tell requesters about yourself',
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Terms & Conditions
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF5ABDA7),
                            ),
                            Expanded(
                              child: Text(
                                'I agree to NowRunner\'s terms & conditions',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveRunnerInfo,
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
                            'Get Started',
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