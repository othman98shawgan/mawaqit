import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/prayer_methods.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
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
