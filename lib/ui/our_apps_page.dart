import 'package:alfajr/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import '../services/theme_service.dart';

class OurAppsPage extends StatefulWidget {
  const OurAppsPage({super.key});

  @override
  State<OurAppsPage> createState() => _OurAppsPageState();
}

class _OurAppsPageState extends State<OurAppsPage> {
  var data = ourAppsList;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.ourAppsString),
        ),
        body: Container(
          child: _buildList(data),
        ),
      ),
    );
  }

  Widget _buildList(List<AppModel> data) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 16),
      itemCount: data.length,
      itemBuilder: (context, i) {
        return Column(
          children: [
            _buildRow((data[i])),
            const Divider(
              thickness: 1,
            )
          ],
        );
      },
    );
  }

  Widget _buildRow(AppModel app) {
    var themeMode = Provider.of<ThemeNotifier>(context, listen: false).themeMode;
    var descriptionColor = themeMode == ThemeMode.dark ? Colors.grey.shade400 : Colors.grey.shade700;

    return ListTile(
      onTap: () {
        _launchURL(app.appUrl);
      },
      contentPadding: const EdgeInsets.only(left: 16.0, right: 4.0),
      leading: Image(image: NetworkImage(app.imageUrl)),
      title: Text(app.name),
      subtitle: Text(
        app.description,
        style: TextStyle(color: descriptionColor),
      ),
      trailing: IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: () {
            _launchURL(app.appUrl);
          }),
    );
  }


  _launchURL(String urlString) async {
    Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

List<AppModel> ourAppsList = [
  AppModel(
    'Easy Count',
    'http://play.google.com/store/apps/details?id=com.othman.dhikrcounter',
    'Simple Counter for Tasbeeh and Regular Counting',
    'http://lh3.googleusercontent.com/gOiUulPSyIDr438fc37sRtM-h-Whi_bO6NxYmEciYq8CqSIPy2_uYmAWKdomkr_z_is',
  )
];
