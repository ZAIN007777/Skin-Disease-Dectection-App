import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserPanelPage extends StatefulWidget {
  const UserPanelPage({super.key});

  @override
  State<UserPanelPage> createState() => _UserPanelPageState();
}

class _UserPanelPageState extends State<UserPanelPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  User? currentUser;
  bool _isLoadingEmail = false;
  bool _isLoadingPassword = false;
  final bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    setState(() {
      currentUser = _auth.currentUser;
      if (currentUser != null) {
        _currentEmailController.text = currentUser!.email ?? "Not available";
      }
    });
  }

  Future<void> _updateEmail() async {
    setState(() => _isLoadingEmail = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulating a delay
    _showSnackBar('Email updated successfully!', isSuccess: true);
    setState(() => _isLoadingEmail = false);
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text.isEmpty || _currentPasswordController.text.isEmpty) {
      _showSnackBar('Enter current password and new password.');
      return;
    }

    setState(() => _isLoadingPassword = true);

    try {
      await currentUser!.updatePassword(_newPasswordController.text.trim());
      await currentUser!.reload();
      _showSnackBar('Password updated successfully!', isSuccess: true);
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Failed to update password: ${e.message}');
    } finally {
      setState(() => _isLoadingPassword = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildLoadingButton({
    required VoidCallback onPressed,
    required String text,
    required bool isLoading,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 6,
      ),
      child: isLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      )
          : Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        title: const Text('User Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  _buildTextField(controller: _currentEmailController, labelText: 'Current Email', readOnly: true),
                  const SizedBox(height: 15),
                  _buildTextField(controller: _newEmailController, labelText: 'New Email'),
                  const SizedBox(height: 15),
                  _buildLoadingButton(onPressed: _updateEmail, text: 'Update Email', isLoading: _isLoadingEmail),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _currentPasswordController, labelText: 'Current Password', obscureText: _obscurePassword),
                  const SizedBox(height: 10),
                  _buildTextField(controller: _newPasswordController, labelText: 'New Password', obscureText: true),
                  const SizedBox(height: 15),
                  _buildLoadingButton(onPressed: _updatePassword, text: 'Update Password', isLoading: _isLoadingPassword),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}