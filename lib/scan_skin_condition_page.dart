import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skin_guardian/photo_review_page.dart';

class ScanSkinConditionPage extends StatefulWidget {
  const ScanSkinConditionPage({super.key});

  @override
  createState() => _ScanSkinConditionPageState();
}

class _ScanSkinConditionPageState extends State<ScanSkinConditionPage> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      _takePhoto();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required to take a photo.')),
      );
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPreviewPage(image: _image),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        title: const Text(
          'Scan Skin Condition',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade800,
        elevation: 4,
        shadowColor: Colors.black45,
        iconTheme: const IconThemeData(color: Colors.white), // White back button
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Follow these tips for the best results:",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Instruction Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade800,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: _buildInstructionList(),
              ),
            ),

            const Spacer(),

            // Continue Button
            Center(
              child: ElevatedButton(
                onPressed: _requestCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade600, // Updated color to match Set Reminder button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.5),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInstructionList() {
    List<Map<String, dynamic>> instructions = [
      {"icon": Icons.lightbulb, "text": "Ensure good lighting."},
      {"icon": Icons.center_focus_strong, "text": "Focus on the area of concern."},
      {"icon": Icons.image, "text": "Hold the camera steady."},
      {"icon": Icons.fullscreen, "text": "Capture the full affected area."},
      {"icon": Icons.flash_off, "text": "Avoid using flash."},
      {"icon": Icons.panorama, "text": "Take multiple shots for accuracy."},
      {"icon": Icons.content_cut, "text": "Make sure no obstructions like clothing are in the way."},
    ];

    return instructions
        .map((item) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Icon(item["icon"], color: Colors.tealAccent, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item["text"],
              style: const TextStyle(fontSize: 22, color: Colors.white70),
            ),
          ),
        ],
      ),
    ))
        .toList();
  }
}
