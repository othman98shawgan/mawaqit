import 'package:alfajr/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import 'package:intl/intl.dart';
import '../services/notifications_service.dart';
import '../services/prayer_methods.dart';
import '../services/daylight_time_service.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _canScheduleExact = true;
  List<PendingNotificationRequest> _pendingRequests = [];
  List<String> _cachedScheduledPrayers = [];
  bool _isLoadingPending = false;
  int _selectedDelaySeconds = 5;

  final List<int> _delayOptions = [5, 10, 30, 60];

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _loadPendingNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_titleController.text.isEmpty) {
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      _titleController.text = isArabic ? 'تجربة أذان الفجر' : 'Test Fajr Azan';
      _bodyController.text = isArabic ? 'حان الآن موعد صلاة الفجر' : 'It is now time for Fajr prayer';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    final canExact = await NotificationsService.canScheduleExactNotifications();
    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _canScheduleExact = canExact;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    if (mounted) {
      setState(() {
        _permissionStatus = status;
      });
      _showSnackBar(
        status.isGranted ? 'Permission granted!' : 'Permission denied ($status)',
      );
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    await NotificationsService.requestExactAlarmsPermission();
    if (mounted) {
      await _checkPermission();
    }
  }

  DateTime? _extractScheduledDate(PendingNotificationRequest req) {
    if (req.payload != null && req.payload!.isNotEmpty) {
      final parts = req.payload!.split('|');
      for (final part in parts.reversed) {
        final parsed = DateTime.tryParse(part);
        if (parsed != null) return parsed;
      }
    }

    if (req.id == 888000 || req.payload == 'dst_transition') {
      try {
        final now = DateTime.now();
        final autumnEnd = DaylightSavingNotifier.dstEndDate(now.year);
        final autumnEve = DateTime(autumnEnd.year, autumnEnd.month, autumnEnd.day - 1, 20, 0);
        final springStart = DaylightSavingNotifier.dstStartDate(now.year);
        final springEve = DateTime(springStart.year, springStart.month, springStart.day - 1, 20, 0);

        if (now.difference(autumnEve).abs() < const Duration(days: 10)) {
          return autumnEve;
        }
        if (now.difference(springEve).abs() < const Duration(days: 10)) {
          return springEve;
        }
        return DaylightSavingNotifier.getNextDstTransitionEve(now).notificationTime;
      } catch (_) {}
    }

    final idSuffix = req.id.toString().padLeft(6, '0');
    for (final prayerId in _cachedScheduledPrayers) {
      if (prayerId.endsWith(idSuffix)) {
        try {
          return getDateFromId(prayerId);
        } catch (_) {}
      }
    }

    if (req.id >= 10000 && req.id <= 312459) {
      final s = req.id.toString().padLeft(6, '0');
      final day = int.tryParse(s.substring(0, 2));
      final hour = int.tryParse(s.substring(2, 4));
      final min = int.tryParse(s.substring(4, 6));

      if (day != null && hour != null && min != null &&
          day >= 1 && day <= 31 &&
          hour >= 0 && hour <= 24 &&
          min >= 0 && min <= 59) {
        final now = DateTime.now();
        int year = now.year;
        int month = now.month;

        if (day < now.day && (now.day - day) > 7) {
          month++;
          if (month > 12) {
            month = 1;
            year++;
          }
        } else if (day > now.day && (day - now.day) > 20) {
          month--;
          if (month < 1) {
            month = 12;
            year--;
          }
        }

        if (hour == 24) {
          return DateTime(year, month, day + 1, 0, min);
        }
        return DateTime(year, month, day, hour, min);
      }
    }

    return null;
  }

  String _formatScheduledDate(DateTime? date, bool isArabic) {
    if (date == null) return isArabic ? 'تاريخ غير محدد' : 'Date not specified';
    final locale = isArabic ? 'ar' : 'en';
    final dayName = DateFormat('EEEE', locale).format(date);
    final dateStr = DateFormat('d MMMM yyyy', locale).format(date);
    return '$dayName، $dateStr';
  }

  String _formatScheduledHour(DateTime? date, bool isArabic) {
    if (date == null) return '--:--';
    final locale = isArabic ? 'ar' : 'en';
    return DateFormat('hh:mm a', locale).format(date);
  }

  String _formatRelativeTime(DateTime? date, bool isArabic) {
    if (date == null) return isArabic ? 'غير محدد' : 'Not specified';
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return isArabic ? 'حان وقته' : 'Due now';
    } else if (difference.inDays > 0) {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      return isArabic
          ? (hours > 0 ? 'بعد $days يوم و $hours س' : 'بعد $days يوم')
          : (hours > 0 ? 'in ${days}d ${hours}h' : 'in ${days}d');
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      final mins = difference.inMinutes % 60;
      return isArabic
          ? (mins > 0 ? 'بعد $hours س و $mins د' : 'بعد $hours س')
          : (mins > 0 ? 'in ${hours}h ${mins}m' : 'in ${hours}h');
    } else {
      final mins = difference.inMinutes;
      final secs = difference.inSeconds % 60;
      return isArabic
          ? (mins > 0 ? 'بعد $mins دقيقة' : 'بعد $secs ثانية')
          : (mins > 0 ? 'in ${mins}m' : 'in ${secs}s');
    }
  }

  int _comparePendingRequests(PendingNotificationRequest a, PendingNotificationRequest b) {
    final timeA = _extractScheduledDate(a);
    final timeB = _extractScheduledDate(b);

    if (timeA != null && timeB != null) {
      final diff = timeA.compareTo(timeB);
      if (diff != 0) return diff;
    } else if (timeA != null) {
      return -1;
    } else if (timeB != null) {
      return 1;
    }

    // Tie-breaker: reminder before prayer
    final titleA = a.title ?? '';
    final titleB = b.title ?? '';
    final aIsReminder = titleA.contains('بعد') || titleA.toLowerCase().contains('reminder') || titleA.contains('دقائق');
    final bIsReminder = titleB.contains('بعد') || titleB.toLowerCase().contains('reminder') || titleB.contains('دقائق');
    if (aIsReminder && !bIsReminder) return -1;
    if (!aIsReminder && bIsReminder) return 1;

    return a.id.compareTo(b.id);
  }

  Future<void> _loadPendingNotifications() async {
    setState(() {
      _isLoadingPending = true;
    });
    try {
      final rawList = await NotificationsService.getPendingNotificationRequests();
      final prayers = await getScheduledPrayers();
      final list = List<PendingNotificationRequest>.from(rawList);

      _cachedScheduledPrayers = prayers;
      list.sort(_comparePendingRequests);

      if (mounted) {
        setState(() {
          _pendingRequests = list;
          _isLoadingPending = false;
        });
      }
    } catch (e, stack) {
      debugPrint('Error loading pending notifications: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoadingPending = false;
        });
      }
    }
  }

  Future<void> _sendInstantNotification() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final title = _titleController.text.trim().isEmpty
        ? (isArabic ? 'إشعار تجريبي' : 'Test Notification')
        : _titleController.text.trim();
    final body = _bodyController.text.trim().isEmpty
        ? (isArabic ? 'هذا إشعار تجريبي للتأكد من وصول التنبيهات' : 'This is a test notification')
        : _bodyController.text.trim();

    final testId = DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000;

    await NotificationsService.showNotifications(
      id: testId,
      title: title,
      body: body,
      payload: 'test_instant_$testId',
    );

    if (mounted) {
      _showSnackBar(isArabic ? 'تم إرسال الإشعار الفوري' : 'Instant notification sent');
      _loadPendingNotifications();
    }
  }

  Future<void> _scheduleNotification() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final title = _titleController.text.trim().isEmpty
        ? (isArabic ? 'إشعار تجريبي مجدول' : 'Scheduled Test Notification')
        : _titleController.text.trim();
    final body = _bodyController.text.trim().isEmpty
        ? (isArabic ? 'هذا إشعار تجريبي مجدول للتأكد من التنبيهات' : 'This is a scheduled test notification')
        : _bodyController.text.trim();

    final scheduledDate = DateTime.now().add(Duration(seconds: _selectedDelaySeconds));
    final testId = (DateTime.now().millisecondsSinceEpoch ~/ 1000 % 90000) + 10000;

    await NotificationsService.scheduleNotifications(
      id: testId,
      channelId: testId.toString(),
      title: title,
      body: body,
      payload: 'test_scheduled_$testId',
      sheduledDate: scheduledDate,
    );

    if (mounted) {
      _showSnackBar(
        isArabic
            ? 'تم جدولة الإشعار بعد $_selectedDelaySeconds ثوانٍ'
            : 'Notification scheduled in $_selectedDelaySeconds seconds',
      );
      // Wait a short moment then refresh the pending list
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _loadPendingNotifications();
      });
    }
  }

  Future<void> _cancelNotification(int id) async {
    await NotificationsService.cancelNotification(id);
    if (mounted) {
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      _showSnackBar(isArabic ? 'تم إلغاء الإشعار ($id)' : 'Cancelled notification ($id)');
      _loadPendingNotifications();
    }
  }

  Future<void> _cancelAllNotifications() async {
    await NotificationsService.cancelAll();
    if (mounted) {
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      _showSnackBar(isArabic ? 'تم إلغاء جميع الإشعارات' : 'All notifications cancelled');
      _loadPendingNotifications();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'اختبار الإشعارات' : 'Notification Testing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: () {
              _checkPermission();
              _loadPendingNotifications();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildPermissionCard(isArabic),
          const SizedBox(height: 16),
          _buildTriggerCard(isArabic),
          const SizedBox(height: 16),
          _buildPendingListCard(isArabic),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(bool isArabic) {
    Color badgeColor;
    String statusText;

    if (_permissionStatus.isGranted) {
      badgeColor = Colors.green;
      statusText = isArabic ? 'مفعل ومسموح' : 'Granted';
    } else if (_permissionStatus.isPermanentlyDenied) {
      badgeColor = Colors.red;
      statusText = isArabic ? 'مرفوض بشكل دائم' : 'Permanently Denied';
    } else {
      badgeColor = Colors.orange;
      statusText = isArabic ? 'غير مسموح' : 'Denied';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _permissionStatus.isGranted ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: badgeColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'حالة إذن الإشعارات' : 'Notification Permission',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'يتطلب نظام أندرويد و iOS الإذن لعرض التنبيهات والأذان عند حلول وقت الصلاة.'
                  : 'Android and iOS require explicit permission to display prayer and reminder alerts.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!_permissionStatus.isGranted)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.security, size: 18),
                      label: Text(isArabic ? 'طلب الإذن' : 'Request Permission'),
                      onPressed: _requestPermission,
                    ),
                  ),
                if (!_permissionStatus.isGranted) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings, size: 18),
                    label: Text(isArabic ? 'إعدادات النظام' : 'App Settings'),
                    onPressed: () {
                      AppSettings.openAppSettings(type: AppSettingsType.notification);
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  _canScheduleExact ? Icons.alarm_on : Icons.alarm_off,
                  color: _canScheduleExact ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArabic ? 'إذن التنبيهات الدقيقة (Exact Alarms)' : 'Exact Alarms Permission',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (_canScheduleExact ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _canScheduleExact ? Colors.green : Colors.orange),
                  ),
                  child: Text(
                    _canScheduleExact
                        ? (isArabic ? 'مفعل ومسموح' : 'Granted')
                        : (isArabic ? 'غير مسموح' : 'Restricted'),
                    style: TextStyle(
                      color: _canScheduleExact ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'يتطلب نظام أندرويد 12 فأحدث إذناً خاصاً لجدولة الأذان والتنبيهات في وقتها بالدقيقة والثانية.'
                  : 'Android 12+ requires special permission to trigger prayer alarms at exact scheduled times.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (!_canScheduleExact) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.alarm, size: 18),
                  label: Text(isArabic ? 'طلب إذن التنبيهات الدقيقة' : 'Request Exact Alarm Permission'),
                  onPressed: _requestExactAlarmPermission,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerCard(bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'إرسال إشعار تجريبي' : 'Send Test Notification',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: isArabic ? 'عنوان الإشعار' : 'Notification Title',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: isArabic ? 'نص الإشعار' : 'Notification Body',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isArabic ? 'جدولة الإشعار بعد:' : 'Schedule Delay:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _delayOptions.map((seconds) {
                final isSelected = _selectedDelaySeconds == seconds;
                return ChoiceChip(
                  label: Text(
                    isArabic ? (seconds >= 60 ? 'دقيقة' : '$seconds ثوانٍ') : (seconds >= 60 ? '1 min' : '${seconds}s'),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDelaySeconds = seconds;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.flash_on, size: 18),
                    label: Text(isArabic ? 'إرسال فوري' : 'Send Instant'),
                    onPressed: _sendInstantNotification,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(isArabic ? 'جدولة' : 'Schedule'),
                    onPressed: _scheduleNotification,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingListCard(bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'الإشعارات المجدولة النشطة' : 'Active Pending Notifications',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_pendingRequests.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'قائمة التنبيهات المسجلة حالياً لدى نظام التشغيل في انتظار وقت التفعيل.'
                  : 'Notifications currently registered in the OS waiting to be triggered.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const Divider(height: 20),
            if (_isLoadingPending)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_pendingRequests.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        isArabic ? 'لا توجد إشعارات مجدولة حالياً' : 'No pending notifications',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              Builder(
                builder: (context) {
                  final sortedList = List<PendingNotificationRequest>.from(_pendingRequests)
                    ..sort(_comparePendingRequests);
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedList.length,
                    separatorBuilder: (context, index) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final req = sortedList[index];
                  final scheduledDate = _extractScheduledDate(req);
                  final isDue = scheduledDate != null && scheduledDate.isBefore(DateTime.now());

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              child: Text(
                                '${req.id}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req.title ?? (isArabic ? 'بدون عنوان' : 'Untitled'),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  if (req.body != null && req.body!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        req.body!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                              tooltip: isArabic ? 'حذف' : 'Cancel',
                              onPressed: () => _cancelNotification(req.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDue
                                ? Colors.orange.withValues(alpha: 0.08)
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDue
                                  ? Colors.orange.withValues(alpha: 0.3)
                                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: isDue ? Colors.deepOrange : Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatScheduledDate(scheduledDate, isArabic),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 15,
                                    color: isDue ? Colors.deepOrange : Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatScheduledHour(scheduledDate, isArabic),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDue ? Colors.deepOrange : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDue
                                          ? Colors.orange.withValues(alpha: 0.2)
                                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _formatRelativeTime(scheduledDate, isArabic),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDue ? Colors.deepOrange : Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
                },
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                icon: const Icon(Icons.clear_all, size: 18),
                label: Text(isArabic ? 'إلغاء مسح جميع الإشعارات' : 'Cancel All Notifications'),
                onPressed: _pendingRequests.isEmpty ? null : _cancelAllNotifications,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
