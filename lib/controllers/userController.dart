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

  // Placeholder for other user-related methods if needed
}
