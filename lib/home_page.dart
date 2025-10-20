import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skin_guardian/reminders_page.dart';
import 'login_page.dart';
import 'scan_skin_condition_page.dart';
import 'user_panel_page.dart';
//import 'insights_chatbot_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _dailyReminders = [
    "Take a moment to care for your skin today!",
    "Healthy skin is a reflection of overall wellness.",
    "Don't forget to moisturize daily for glowing skin.",
    "Protect your skin from the sun to prevent damage.",
    "Drink plenty of water to keep your skin hydrated.",
    "Exfoliate regularly for smoother, healthier skin.",
  ];

  String _currentReminder = "Loading reminder..."; // Default text

  @override
  void initState() {
    super.initState();
    _setRandomReminder();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setRandomReminder() {
    final random = DateTime.now().millisecondsSinceEpoch % _dailyReminders.length;
    setState(() {
      _currentReminder = _dailyReminders[random];
    });
  }

  void logUserOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App bar with logout icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: logUserOut,
                      ),
                    ],
                  ),
                  const SizedBox(height: 45), // Increased top spacing

                  // Welcome message
                  const Text(
                    'Welcome to SkinGuardian',
                    style: TextStyle(
                      fontSize: 32, // Increased font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your Personal Skin Health Assistant',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),

                  // Grid layout for buttons
                  GridView.count(
                    shrinkWrap: true, // Allow the grid to take only the space it needs
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    padding: const EdgeInsets.all(10),
                    childAspectRatio: 1.2,
                    children: [
                      _buildDashboardCard(
                        label: 'Recovery Progress',
                        icon: Icons.bar_chart,
                        onPressed: () {},
                        color: Colors.blue.shade600,
                      ),
                      _buildDashboardCard(
                        label: 'Skin Insights',
                        icon: Icons.lightbulb,
                        onPressed: () {
                        },
                        color: Colors.orange.shade600,
                      ),
                      _buildDashboardCard(
                        label: 'Set Reminders',
                        icon: Icons.alarm,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReminderPage()),
                          );
                        },
                        color: Colors.purple.shade600,
                      ),
                      _buildDashboardCard(
                        label: 'User Panel',
                        icon: Icons.account_circle,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserPanelPage()),
                          );
                        },
                        color: Colors.indigo.shade600,
                      ),
                    ],
                  ),

                  // Scan Skin Condition button
                  const SizedBox(height: 10),
                  _buildWideButton(
                    label: 'Scan Skin Condition',
                    icon: Icons.camera_alt,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ScanSkinConditionPage()),
                      );
                    },
                    color: Colors.teal.shade600,
                  ),

                  // Spacer to push the reminder section to the bottom
                  const Spacer(),

                  // Daily Reminder Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentReminder,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Card widget for building the dashboard cards with icons and text
  Widget _buildDashboardCard({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wide button for "Scan Skin Condition"
  Widget _buildWideButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity, // Full width
      height: 110, // Increased height for a bigger button
      child: Card(
        elevation: 10, // More shadow for visibility
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Softer edges
        ),
        color: color,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 45, // Bigger icon size
                  color: Colors.white,
                ),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 25, // Bigger text
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
