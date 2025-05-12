import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class Reminder {
  String id;
  String title;
  DateTime dateTime;

  Reminder({required this.id, required this.title, required this.dateTime});

  // Convert a Reminder to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include the ID in the map
      'title': title,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  // Convert a Map to a Reminder
  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'], // Retrieve the ID from the map
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
    _initializeTimeZones();
    _initializeNotifications();
    _loadReminders();
    _requestPermission();
    _setupNotificationChannel();
    _startReminderExpiryTimer(); // Start the timer to check for expired reminders
  }

  void _initializeTimeZones() {
    tz.initializeTimeZones();
    // Try to get the local timezone instead of hardcoding it
    try {
      tz.setLocalLocation(tz.local);
    } catch (e) {
      // Fallback to a specific timezone if local detection fails
      tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
      debugPrint("Fallback to 'Asia/Karachi' timezone: $e");
    }
  }

  // Request permission for notifications
  Future<void> _requestPermission() async {
    // Check current status
    var status = await Permission.notification.status;

    if (status.isDenied) {
      // Request permission
      status = await Permission.notification.request();
      if (status.isGranted) {
        debugPrint("✅ Notification permission granted.");
      } else {
        debugPrint("❌ Notification permission denied.");
      }
    } else if (status.isPermanentlyDenied) {
      // The user has previously denied the permission and instructed the OS to not ask again.
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Notification Permission Required'),
          content: const Text(
              'Please enable notifications for this app in your device settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else if (status.isGranted) {
      debugPrint("✅ Notification permission already granted.");
    }
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings);

    try {
      final bool? initialized = await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      if (initialized == true) {
        debugPrint("✅ Notifications initialized successfully.");
      } else {
        debugPrint("❌ Notification initialization failed.");
      }
    } catch (e) {
      debugPrint("❌ Notification initialization error: $e");
    }
  }

  Future<void> _loadReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? remindersString = prefs.getString('reminders');

    if (remindersString != null) {
      try {
        List<dynamic> remindersJson = json.decode(remindersString);
        setState(() {
          _reminders = remindersJson
              .map((jsonItem) => Reminder.fromMap(jsonItem))
              .toList();
        });
        _removeExpiredReminders(); // Remove expired reminders when loading them
        _scheduleNotifications(); // Schedule notifications for active reminders
      } catch (e) {
        debugPrint("❌ Error loading reminders: $e");
      }
    }
  }

  Future<void> _saveReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String remindersString = json.encode(
      _reminders.map((reminder) => reminder.toMap()).toList(),
    );
    prefs.setString('reminders', remindersString);
  }

  Future<void> _checkPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    debugPrint("📢 Pending Notifications: ${pendingNotifications.length}");
    for (var notification in pendingNotifications) {
      debugPrint("🆔 ID: ${notification.id}, Title: ${notification.title}");
    }
  }

  Future<void> _showNotification(Reminder reminder) async {
    // If the date is in the past, don't schedule
    if (reminder.dateTime.isBefore(DateTime.now())) {
      debugPrint("⏭️ Skipping past notification for: ${reminder.title}");
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    // Convert to the correct time zone
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(reminder.dateTime, tz.local);

    debugPrint("📅 Scheduling notification at: ${scheduledTime.toString()}");
    debugPrint("🆔 Notification ID: ${reminder.id.hashCode}");
    debugPrint("🔔 Reminder Title: ${reminder.title}");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        reminder.id.hashCode,
        reminder.title,
        '⏰ Reminder Time: ${DateFormat.jm().format(reminder.dateTime)}',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );

      debugPrint("✅ Notification successfully scheduled!");
    } catch (e) {
      debugPrint("❌ Notification scheduling failed: $e");
    }
  }

  // FIXED: This function was incorrectly implemented
  void _scheduleNotifications() {
    // Cancel previous notifications to prevent duplicates
    flutterLocalNotificationsPlugin.cancelAll().then((_) {
      debugPrint("🗑️ Cleared all previous notifications!");

      // Schedule new notifications only for future reminders
      for (Reminder reminder in _reminders) {
        if (reminder.dateTime.isAfter(DateTime.now())) {
          _showNotification(reminder);
          debugPrint("Scheduling notification for: ${reminder.title} at ${reminder.dateTime}");
        } else {
          debugPrint("Skipping expired reminder: ${reminder.title}");
        }
      }

      // Check which notifications are actually scheduled
      _checkPendingNotifications();
    });
  }

  void _onNotificationTap(NotificationResponse notificationResponse) {
    // Handle notification tap, remove the reminder after it's tapped
    String? payload = notificationResponse.payload;
    if (payload != null) {
      setState(() {
        _reminders.removeWhere((reminder) => reminder.id == payload);
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

    // Don't allow setting reminders in the past
    if (reminderDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot set reminder for past time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    const uuid = Uuid();
    final reminder = Reminder(
      id: uuid.v4(), // Generate a unique ID
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

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${DateFormat.yMMMd().add_jm().format(reminderDateTime)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeExpiredReminders() {
    final now = DateTime.now();
    final previousCount = _reminders.length;

    setState(() {
      _reminders.removeWhere((reminder) => reminder.dateTime.isBefore(now));
    });

    final removedCount = previousCount - _reminders.length;
    if (removedCount > 0) {
      debugPrint("Removed $removedCount expired reminders");
      _saveReminders(); // Save updated reminders list after removing expired ones
    }
  }

  void _startReminderExpiryTimer() {
    // Check every minute if there are any expired reminders
    _reminderExpiryTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _removeExpiredReminders();
      // No need to reschedule here - it will create too many notifications
    });
  }

  void _setupNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Channel for reminder notifications',
      importance: Importance.high,
    );

    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      debugPrint("✅ Notification channel created successfully.");
    } catch (e) {
      debugPrint("❌ Error creating notification channel: $e");
    }
  }

  @override
  void dispose() {
    _reminderExpiryTimer.cancel(); // Stop the timer when the page is disposed
    _titleController.dispose(); // Dispose the text controller
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
        actions: [
          // Add a manual refresh button for debugging
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _scheduleNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications refreshed')),
              );
            },
          ),
        ],
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _reminders.removeAt(index);
                            });
                            _saveReminders();
                            _scheduleNotifications();
                          },
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
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: ReminderPage(),
  ));
}
