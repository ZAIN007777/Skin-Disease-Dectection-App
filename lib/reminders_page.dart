import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class Reminder {
  String title;
  DateTime dateTime;

  Reminder({required this.title, required this.dateTime});

  // Convert a Reminder to a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  // Convert a Map to a Reminder
  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      title: map['title'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  List<Reminder> _reminders = [];
  late Timer _reminderExpiryTimer;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Ensure time zone is initialized
    _initializeNotifications();
    _loadReminders();
    _startReminderExpiryTimer(); // Start the timer to check for expired reminders
  }

  // Request permission for notifications
  Future<void> _requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.notification.isGranted) {
      print("Notification permission granted.");
    }
  }

  void _initializeNotifications() {
    const InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap);
  }

  Future<void> _loadReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? remindersString = prefs.getString('reminders');

    if (remindersString != null) {
      List<dynamic> remindersJson = json.decode(remindersString);
      setState(() {
        _reminders = remindersJson
            .map((jsonItem) => Reminder.fromMap(jsonItem))
            .toList();
      });
      _removeExpiredReminders(); // Remove expired reminders when loading them
      _scheduleNotifications(); // Schedule notifications for active reminders
    }
  }

  Future<void> _saveReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String remindersString = json.encode(
      _reminders.map((reminder) => reminder.toMap()).toList(),
    );
    prefs.setString('reminders', remindersString);
  }

  Future<void> _showNotification(Reminder reminder) async {
    await _requestPermission(); // Request notification permission first

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // Convert the reminder's DateTime to the correct timezone
    tz.TZDateTime scheduledTime =
    tz.TZDateTime.from(reminder.dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      reminder.title,
      'Time to check your skin!',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _onNotificationTap(NotificationResponse notificationResponse) {
    // Handle notification tap, remove the reminder after it's tapped
    String? payload = notificationResponse.payload;
    if (payload != null) {
      setState(() {
        _reminders.removeWhere((reminder) => reminder.title == payload);
      });
      _saveReminders(); // Save the updated reminder list
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _addReminder() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reminder title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final DateTime reminderDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final reminder = Reminder(
      title: _titleController.text,
      dateTime: reminderDateTime,
    );

    setState(() {
      _reminders.add(reminder);
    });

    _saveReminders(); // Save reminders to SharedPreferences
    _scheduleNotifications(); // Schedule notifications for active reminders
    _titleController.clear();
    FocusScope.of(context).unfocus();
  }

  void _removeExpiredReminders() {
    final now = DateTime.now();
    _reminders.removeWhere((reminder) => reminder.dateTime.isBefore(now));
    _saveReminders(); // Save updated reminders list after removing expired ones
  }

  void _scheduleNotifications() {
    for (Reminder reminder in _reminders) {
      if (reminder.dateTime.isAfter(DateTime.now())) {
        _showNotification(reminder); // Schedule the notification if the reminder is active
      }
    }
  }

  void _startReminderExpiryTimer() {
    // Check every minute if there are any expired reminders
    _reminderExpiryTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _removeExpiredReminders();
      _scheduleNotifications(); // Reschedule notifications for active reminders
    });
  }

  @override
  void dispose() {
    _reminderExpiryTimer.cancel(); // Stop the timer when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        title: const Text(
          'Set Reminder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey.shade800,
        elevation: 4,
        shadowColor: Colors.black45,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reminder Title Input
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Reminder Title',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Date and Time Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateTimeButton(
                    label: DateFormat.yMMMd().format(_selectedDate),
                    icon: Icons.calendar_today,
                    onPressed: () => _selectDate(context),
                  ),
                  _buildDateTimeButton(
                    label: _selectedTime.format(context),
                    icon: Icons.access_time,
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Add Reminder Button
              _buildWideButton(
                label: 'Set Reminder',
                icon: Icons.alarm_add,
                onPressed: _addReminder,
              ),
              const SizedBox(height: 20),

              // Reminder List Section
              Expanded(
                child: _reminders.isEmpty
                    ? const Center(
                  child: Text(
                    'No reminders set',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return Card(
                      color: Colors.blueGrey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.notifications,
                            color: Colors.white),
                        title: Text(
                          reminder.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd()
                              .add_jm()
                              .format(reminder.dateTime),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for creating DateTime selection buttons
  Widget _buildDateTimeButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade700,
        minimumSize: const Size(130, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Helper for creating wide action buttons
  Widget _buildWideButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade700,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ReminderPage(),
  ));
}
