import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class DesktopService with TrayListener, WindowListener {
  static final DesktopService _instance = DesktopService._internal();
  factory DesktopService() => _instance;
  DesktopService._internal();

  bool _isInitialized = false;

  Future<String> _resolveTrayIconPath() async {
    try {
      // 1. Check relative to executable (standard in release / install / debug build)
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final bundledPath = '$exeDir\\data\\flutter_assets\\images\\app_icon.ico';
      if (await File(bundledPath).exists()) {
        return bundledPath;
      }

      // 2. Check workspace relative path
      const localPath = 'windows\\runner\\resources\\app_icon.ico';
      if (await File(localPath).exists()) {
        return File(localPath).absolute.path;
      }

      // 3. Fallback: extract from Flutter asset bundle to temp directory
      final byteData = await rootBundle.load('images/app_icon.ico');
      final tempFile = File('${Directory.systemTemp.path}\\mawaqit_tray_icon.ico');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile.path;
    } catch (e) {
      debugPrint('Error resolving tray icon path: $e');
      return 'windows\\runner\\resources\\app_icon.ico';
    }
  }

  Future<void> init() async {
    if (kIsWeb || !Platform.isWindows || _isInitialized) {
      return;
    }
    _isInitialized = true;

    try {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        size: Size(420, 840),
        minimumSize: Size(420, 840),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'Mawaqit Al-Quds',
      );

      windowManager.addListener(this);

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setPreventClose(true);
        await windowManager.setAspectRatio(420 / 840);
        await windowManager.setMaximizable(false);
      });

      trayManager.addListener(this);
      final iconPath = await _resolveTrayIconPath();
      await trayManager.setIcon(iconPath);
      await trayManager.setToolTip('Mawaqit Al-Quds - مواقيت بيت المقدس');

      final menu = Menu(
        items: [
          MenuItem(
            key: 'show_window',
            label: 'Show Mawaqit / عرض التطبيق',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'exit_app',
            label: 'Exit / خروج',
          ),
        ],
      );
      await trayManager.setContextMenu(menu);
    } catch (e) {
      debugPrint('DesktopService init error: $e');
    }
  }

  @override
  void onWindowClose() async {
    try {
      final isPreventClose = await windowManager.isPreventClose();
      if (isPreventClose) {
        await windowManager.hide();
      }
    } catch (_) {}
  }

  @override
  void onTrayIconMouseDown() async {
    try {
      final isVisible = await windowManager.isVisible();
      if (isVisible) {
        await windowManager.hide();
      } else {
        await windowManager.show();
        await windowManager.focus();
      }
    } catch (_) {}
  }

  @override
  void onTrayIconRightMouseDown() async {
    try {
      await trayManager.popUpContextMenu();
    } catch (_) {}
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == 'exit_app') {
      trayManager.removeListener(this);
      windowManager.removeListener(this);
      await windowManager.destroy();
    }
  }
}
