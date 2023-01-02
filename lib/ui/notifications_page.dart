import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../resources/colors.dart';
import '../services/prayer_methods.dart';
import '../services/theme_service.dart';
import 'widgets/reminder_dialog.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    // Full screen width and height
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;

    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<String>>(
          future: getScheduledPrayers(),
          builder: (buildContext, snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: _buildList(snapshot.data ?? []),
              );
            } else {
              // Return loading screen while reading preferences
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget _buildList(List<String> notifications) {
    var notificationsDateTime = notifications.map((n) => getDateFromId(n)).toList();
    notificationsDateTime.sort();
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, i) {
        return Column(
          children: [
            _buildRow((notificationsDateTime[i])),
            const Divider(
              thickness: 1,
            )
          ],
        );
      },
    );
  }

  Widget _buildRow(DateTime notification) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 1.0, right: 1.0),
      leading: Text(DateFormat('EEE').format(notification)),
      title: Text(notification.toString().substring(0, 19)),
    );
  }
}
