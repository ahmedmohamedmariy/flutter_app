import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../api_config.dart';
import '../models/users.dart'; // Assuming your User model is here
import 'package:flutter/material.dart';
import '../Home_pages/HomePage.dart';

class UserController {
  final String _baseUrl = ApiConfig.baseUrl;

  // Register User
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword, // Added confirmPassword
    required String emergencyPhone,
  }) async {
    // Optional: Add client-side validation here to check if password == confirmPassword
    // if (password != confirmPassword) {
    //   return {'success': false, 'message': 'Passwords do not match'};
    // }

    final url = Uri.parse('$_baseUrl/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword':
              confirmPassword, // Added confirmPassword to request body
          'emergencyPhone': emergencyPhone,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 && responseData['success'] == true) {
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        final data = responseData['data'];
        final token = data['token'];
        final userData = data['user'];

        await prefs.setString('token', token);
        await prefs.setString(
            'userData', jsonEncode(userData)); // Store user data as JSON string

        print(
            'Token and user data saved successfully!'); // Optional: Log success

        // Get the current context.  This is a bit of a hack since you don't have direct access to context here.
        // You might need to pass the context from the SignUp page to the register function.
        // For now, we'll assume that the SignUp page is still in the navigation stack.
        // Navigator.pushReplacement(
        //   context as BuildContext, // Cast to BuildContext
        //   MaterialPageRoute(builder: (context) => HomePage()),
        // );

        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed'
        };
      }
    } catch (error) {
      print('Registration error: $error');
      return {
        'success': false,
        'message': 'An error occurred during registration.'
      };
    }
  }

  // Login User
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        final data = responseData['data'];
        final token = data['token'];
        final userData = data['user'];

        await prefs.setString('token', token);
        await prefs.setString(
            'userData', jsonEncode(userData)); // Store user data as JSON string

        print(
            'Token and user data saved successfully on login!'); // Optional: Log success

        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'] // Contains user info and token
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed'
        };
      }
    } catch (error) {
      print('Login error: $error');
      return {'success': false, 'message': 'An error occurred during login.'};
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final url = Uri.parse('$_baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Forgot password request failed'
        };
      }
    } catch (error) {
      print('Forgot password error: $error');
      return {'success': false, 'message': 'An error occurred.'};
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Password reset failed'
        };
      }
    } catch (error) {
      print('Reset password error: $error');
      return {
        'success': false,
        'message': 'An error occurred during password reset.'
      };
    }
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token not found. User not logged in.'
      };
    }

    final url = Uri.parse('$_baseUrl/change-password');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to change password'
        };
      }
    } catch (error) {
      print('Change password error: $error');
      return {
        'success': false,
        'message': 'An error occurred while changing password.'
      };
    }
  }

  // Update User Profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String emergencyPhone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token not found. User not logged in.'
      };
    }

    final url = Uri.parse('$_baseUrl/profile');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'emergencyPhone': emergencyPhone,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Update the stored user data
        final userData = responseData['data'];
        await prefs.setString('userData', jsonEncode(userData));

        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'data': userData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile'
        };
      }
    } catch (error) {
      print('Update profile error: $error');
      return {
        'success': false,
        'message': 'An error occurred while updating profile.'
      };
    }
  }

  // Logout User
  Future<Map<String, dynamic>> logout() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Clear token and user data from SharedPreferences
      await prefs.remove('token');
      await prefs.remove('userData');
      await prefs.setBool('isLoggedIn', false);

      // You could also call a logout endpoint on the server if needed
      // final url = Uri.parse('$_baseUrl/logout');
      // final token = prefs.getString('token');
      // if (token != null) {
      //   await http.post(
      //     url,
      //     headers: {
      //       'Content-Type': 'application/json',
      //       'Authorization': 'Bearer $token',
      //     },
      //   );
      // }

      return {'success': true, 'message': 'Logged out successfully'};
    } catch (error) {
      print('Logout error: $error');
      return {'success': false, 'message': 'An error occurred during logout.'};
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {
        'success': false,
        'message': 'Token not found. User not logged in.'
      };
    }

    final url = Uri.parse('$_baseUrl/profile');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        final userDataFromServer = responseData['data'];
        // The backend sends '_id', our model expects 'id'.
        // The backend also sends 'id' directly now based on the provided backend code.
        // Let's ensure we handle both cases or prioritize 'id' if present.
        final Map<String, dynamic> userJson = {
          'id': userDataFromServer['id'] ??
              userDataFromServer['_id'] ??
              '', // Handle both _id and id
          'name': userDataFromServer['name'] ?? '',
          'email': userDataFromServer['email'] ?? '',
          'emergencyPhone': userDataFromServer['emergencyPhone'] ?? '',
          'profileImage': userDataFromServer['profileImage'],
          // 'password' is not sent by this endpoint, User.fromJson will use default ''
        };
        final user = users.fromJson(userJson);
        return {'success': true, 'user': user};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch user profile'
        };
      }
    } catch (error) {
      print('Get user profile error: $error');
      return {
        'success': false,
        'message': 'An error occurred while fetching user profile.'
      };
    }
  }
}
