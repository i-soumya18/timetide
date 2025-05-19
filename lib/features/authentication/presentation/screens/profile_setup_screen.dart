import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/avatar_picker.dart';
import '../../providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  File? _avatarFile;
  final List<String> _goals = ['Productivity', 'Health', 'Study', 'Personal', 'Errands'];
  final List<String> _selectedGoals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user?.name != null) {
      _nameController.text = user!.name!;
    }
    if (user?.preferences != null) {
      _selectedGoals.addAll(user!.preferences);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8ECAE6), Color(0xFF219EBC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Complete Your Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                AvatarPicker(
                  avatarUrl: authProvider.user?.avatar,
                  avatarFile: _avatarFile,
                  onPickImage: _pickImage,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    hintText: 'Name',
                    hintStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Your Goals',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ..._goals.map((goal) {
                  return CheckboxListTile(
                    title: Text(goal, style: const TextStyle(color: Colors.white)),
                    value: _selectedGoals.contains(goal),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedGoals.add(goal);
                        } else {
                          _selectedGoals.remove(goal);
                        }
                      });
                    },
                    checkColor: const Color(0xFF219EBC),
                    activeColor: const Color(0xFFFFB703),
                  );
                }),
                const SizedBox(height: 24),
                if (authProvider.errorMessage != null)
                  Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 16),
                AuthButton(
                  text: 'Save Profile',
                  isLoading: _isLoading,
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await authProvider.updateUserProfile(
                      name: _nameController.text.trim(),
                      avatar: _avatarFile,
                      preferences: _selectedGoals,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    if (authProvider.user != null && !authProvider.needsProfileSetup) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
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