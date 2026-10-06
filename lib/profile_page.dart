import 'package:flutter/material.dart';

import 'authentication/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  String _userEmail = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  // Fetch current user email from AuthService
  void _loadUserEmail() {
    final email = _authService.getCurrentUserEmail();
    if (email != null && email.isNotEmpty) {
      setState(() {
        _userEmail = email;
      });
    }
  }

  // Handle Logout Action
  void _handleLogout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;

      // Navigate back to login screen or clear stack (adjust route as needed)
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Logout option on the top right
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section with current user info
            Text(
              'Hi, $_userEmail',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // Additional profile options can go here
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Address'),
              subtitle: Text(_userEmail),
            ),
          ],
        ),
      ),
    );
  }
}