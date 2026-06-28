import 'package:flutter/material.dart';
import '../services/notifications_service.dart';

class TestNotificationsPage extends StatelessWidget {
  const TestNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Use these buttons to test the different types of notifications that the app will send.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              NotificationsService.showNotifications(
                id: 1,
                title: 'Adhan: Fajr',
                body: 'It is time for Fajr prayer in Al-Quds.',
                payload: 'prayer_fajr',
              );
            },
            child: const Text('Test Prayer Adhan (Immediate)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              NotificationsService.scheduleNotifications(
                id: 2,
                channelId: 'prayer_channel',
                title: 'Adhan: Dhuhr (Scheduled)',
                body: 'It is time for Dhuhr prayer. (Triggered after 3s)',
                payload: 'prayer_dhuhr',
                sheduledDate: DateTime.now().add(const Duration(seconds: 3)),
              );
            },
            child: const Text('Test Prayer Adhan (Scheduled 3s)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              NotificationsService.showNotifications(
                id: 3,
                title: 'Mathurat Reminder',
                body: 'Have you read your Morning Mathurat today?',
                payload: 'mathurat',
              );
            },
            child: const Text('Test Mathurat Reminder'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              NotificationsService.showNotifications(
                id: 4,
                title: 'Dhikr Target Reached',
                body: 'MashaAllah, you have reached your Dhikr target!',
                payload: 'dhikr',
              );
            },
            child: const Text('Test Dhikr Target Reached'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              NotificationsService.showNotifications(
                id: 5,
                title: 'Missed Prayer Reminder',
                body: 'You have a missed Asr prayer to make up.',
                payload: 'missed_prayer',
              );
            },
            child: const Text('Test Missed Prayer Reminder'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Background Scheduling Test:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final now = DateTime.now();
              
              // Schedule 1: 10 seconds from now
              NotificationsService.scheduleNotifications(
                id: 101,
                channelId: 'test_channel_1',
                title: 'Test 1/3 (10s)',
                body: 'This is the first background test notification.',
                payload: 'bg_test_1',
                sheduledDate: now.add(const Duration(seconds: 10)),
              );

              // Schedule 2: 30 seconds from now
              NotificationsService.scheduleNotifications(
                id: 102,
                channelId: 'test_channel_2',
                title: 'Test 2/3 (30s)',
                body: 'This is the second background test notification.',
                payload: 'bg_test_2',
                sheduledDate: now.add(const Duration(seconds: 30)),
              );

              // Schedule 3: 60 seconds from now
              NotificationsService.scheduleNotifications(
                id: 103,
                channelId: 'test_channel_3',
                title: 'Test 3/3 (1m)',
                body: 'This is the final background test notification.',
                payload: 'bg_test_3',
                sheduledDate: now.add(const Duration(seconds: 60)),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scheduled 3 notifications (10s, 30s, 60s). You can now lock your phone!'),
                  duration: Duration(seconds: 5),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Schedule Multiple (10s, 30s, 1m)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
