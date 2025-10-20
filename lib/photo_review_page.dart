import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:skin_guardian/skin_condition_result_page.dart';

class PhotoPreviewPage extends StatefulWidget {
  final File? image;

  const PhotoPreviewPage({super.key, this.image});

  @override
  createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  bool _isUploading = false;

  Future<void> _uploadImageToFirestore() async {
    if (widget.image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Generate a unique file name based on timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image to Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child('skin_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(widget.image!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save metadata to Firestore and get document reference
      DocumentReference docRef = await FirebaseFirestore.instance.collection('skin_images').add({
        'url': downloadUrl,
        'uploaded_at': Timestamp.now(),
        'file_name': fileName,
      });

      // Notify user of success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );

      // Navigate to results page with correct document ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkinConditionResultsPage(
            imageUrl: downloadUrl,
            documentId: docRef.id, // ✅ Correct document ID passed
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        title: const Text(
          'Photo Preview',
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
        automaticallyImplyLeading: false, // removes the back arrow
      ),
      body: SafeArea(
        child: Container(
          color: Colors.blueGrey.shade900,
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.image != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        widget.image!,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                  children: [
                    ElevatedButton(
                      onPressed: _uploadImageToFirestore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                        elevation: 10,
                      ),
                      child: const Text(
                        'Upload & Save Image',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                        elevation: 10,
                      ),
                      child: const Text(
                        'Retake Image',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
