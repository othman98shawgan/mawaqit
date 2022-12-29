import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../resources/colors.dart';
import '../services/store_manager.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // Full screen width and height
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;

    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;

    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) => Center(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: SettingsList(
            lightTheme: const SettingsThemeData(settingsListBackground: backgroudColor),
            sections: [
              SettingsSection(
                title: const Text('General'),
                tiles: [
                  SettingsTile.switchTile(
                    title: const Text('Dark Mode'),
                    leading: const Icon(Icons.dark_mode_outlined),
                    initialValue: theme.getTheme() == theme.darkTheme,
                    onToggle: (value) {
                      if (value) {
                        theme.setDarkMode();
                      } else {
                        theme.setLightMode();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
