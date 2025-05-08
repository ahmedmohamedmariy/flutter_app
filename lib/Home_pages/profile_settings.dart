import 'package:flutter/material.dart';
import 'package:precure/theme/gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../controllers/userController.dart'; // Corrected Import UserController
import '../models/users.dart'; // Corrected Import User model

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final UserController _userController = UserController();
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController(); // Removed
  final TextEditingController _emergencyNumberController =
      TextEditingController();
  String? _profileImagePath; // This might be a URL from backend or local path

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _userController.getUserProfile();
      if (response['success'] == true) {
        final user = response['user'] as users;
        setState(() {
          _nameController.text = user.name;
          // _emailController.text = user.email; // Removed
          _emergencyNumberController.text = user.emergencyPhone;
          // Assuming profileImage from backend is a URL.
          // If it's a local path that FileImage can use, this is fine.
          // If it's a network URL, CircleAvatar's backgroundImage should use NetworkImage.
          _profileImagePath = user.profileImage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load profile.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final emergencyPhone = _emergencyNumberController.text.trim();

      // Call the updateProfile method from UserController
      final response = await _userController.updateProfile(
        name: name,
        emergencyPhone: emergencyPhone,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Profile updated successfully')),
        );

        // Also update local storage for immediate UI updates if needed
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserName', name);
        await prefs.setString('currentEmergencyNumber', emergencyPhone);
        if (_profileImagePath != null) {
          await prefs.setString('profileImagePath', _profileImagePath!);
        }

        // Return to previous screen with updated data
        Navigator.pop(context, {
          'name': name,
          'emergencyNumber': emergencyPhone,
          'profileImagePath': _profileImagePath,
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while updating profile')),
      );
    }
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path; // تحديث مسار الصورة
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile Settings'),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $_errorMessage',
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                  ))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _updateProfileImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.scaffoldBackgroundColor,
                              child: CircleAvatar(
                                radius: 48,
                                // Adjust based on whether _profileImagePath is a local file or network URL
                                backgroundImage: _profileImagePath != null
                                    ? (_profileImagePath!.startsWith('http')
                                            ? NetworkImage(_profileImagePath!)
                                            : FileImage(
                                                File(_profileImagePath!)))
                                        as ImageProvider
                                    : const AssetImage(
                                        'images/Sample_User_Icon.png'),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: theme.cardColor,
                                    child: Icon(Icons.camera_alt,
                                        size: 18, color: theme.iconTheme.color),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person,
                                color: theme.iconTheme.color),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                            labelStyle: TextStyle(
                                color: theme.textTheme.bodyMedium?.color),
                          ),
                          style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                        // const SizedBox(height: 20), // Removed Email TextField and SizedBox
                        // TextField(
                        //   // Added Email TextField
                        //   controller: _emailController, // This line would cause error as _emailController is removed
                        //   decoration: InputDecoration(
                        //     labelText: 'Email',
                        //     prefixIcon:
                        //         Icon(Icons.email, color: theme.iconTheme.color),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(30),
                        //     ),
                        //     filled: true,
                        //     fillColor: theme.cardColor,
                        //     labelStyle: TextStyle(
                        //         color: theme.textTheme.bodyMedium?.color),
                        //   ),
                        //   style: TextStyle(
                        //       color: theme.textTheme.bodyMedium?.color),
                        //   readOnly:
                        //       true, // Email usually not editable here, or handle update separately
                        // ),
                        const SizedBox(height: 20), // This SizedBox might be desired or can be removed too. Keeping for now.
                        TextField(
                          controller: _emergencyNumberController,
                          decoration: InputDecoration(
                            labelText: 'Emergency Number',
                            prefixIcon:
                                Icon(Icons.phone, color: theme.iconTheme.color),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                            labelStyle: TextStyle(
                                color: theme.textTheme.bodyMedium?.color),
                          ),
                          style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _saveUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    ); // Closes GradientBackground
  } // Closes build method
} // Closes class
