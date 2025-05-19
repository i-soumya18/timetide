import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication//providers/auth_provider.dart';
import '../widgets/avatar_picker.dart';
import 'package:timetide/core/colors.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedGoals = [];
  String? _selectedAvatarUrl;
  final List<String> _availableGoals = [
    'Productivity',
    'Health',
    'Learning',
    'Relaxation',
  ];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _nameController.text = user.name;
      if (user.preferences.isNotEmpty) {
        _selectedGoals.addAll(user.preferences);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set Up Your Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AvatarPicker(
                  imageUrl: authProvider.user?.avatarUrl,
                  onImageSelected: (url) {
                    // Handle avatar selection
                    _selectedAvatarUrl = url;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Your Goals',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Wrap(
                  spacing: 8,
                  children: _availableGoals
                      .map((goal) => ChoiceChip(
                            label: Text(goal),
                            selected: _selectedGoals.contains(goal),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedGoals.add(goal);
                                } else {
                                  _selectedGoals.remove(goal);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await authProvider.updateUserProfile(
                        name: _nameController.text.trim(),
                        preferences: _selectedGoals,
                      );
                      if (authProvider.user != null) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Save Profile',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
