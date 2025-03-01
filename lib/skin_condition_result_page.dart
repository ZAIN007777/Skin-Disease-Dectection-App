import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkinConditionResultsPage extends StatelessWidget {
  final String imageUrl;
  const SkinConditionResultsPage({super.key, required this.imageUrl, required String documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Condition Results'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display the image
              Image.network(imageUrl, width: 300, height: 300, fit: BoxFit.cover),
              const SizedBox(height: 20),

              // Display analysis results
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('skin_conditions')
                    .doc(imageUrl) // Use image URL or another identifier as doc ID
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  var data = snapshot.data!;
                  return Column(
                    children: [
                      Text(
                        'Condition Detected: ${data['condition_detected']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Confidence Score: ${data['confidence_score']}%',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Recommendations based on analysis
                      const Text(
                        'Recommendations:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data['recommendations'] ?? 'No recommendations available.',
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // Action buttons
              ElevatedButton(
                onPressed: () {
                  // Add navigation to another scan or save/share results functionality
                  Navigator.pop(context); // Navigate back
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                child: const Text('Go Back to Scan Another Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
