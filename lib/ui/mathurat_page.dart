import 'dart:convert';

import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/models/mathurat.dart';
import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/services/haptic_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/store_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MathuratPage extends StatefulWidget {
  const MathuratPage({super.key});

  @override
  State<MathuratPage> createState() => _MathuratPageState();
}

class _MathuratPageState extends State<MathuratPage> with SingleTickerProviderStateMixin {
  static const String _vibratePrefKey = 'MathuratVibrate';

  late final TabController _tabController;
  List<MathuratModel> _allItems = [];
  List<MathuratModel> _morningItems = [];
  List<MathuratModel> _eveningItems = [];
  int _morningTotal = 0;
  int _eveningTotal = 0;
  bool _isLoading = true;
  bool _vibrateEnabled = true;

  @override
  void initState() {
    super.initState();
    final initialIndex = DateTime.now().hour >= 15 ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadVibratePref();
    _loadData();
  }

  Future<void> _loadVibratePref() async {
    final stored = await StorageManager.readData(_vibratePrefKey);
    if (!mounted) return;
    if (stored is bool) {
      setState(() {
        _vibrateEnabled = stored;
      });
    }
  }

  void _toggleVibrate() {
    final next = !_vibrateEnabled;
    setState(() {
      _vibrateEnabled = next;
    });
    StorageManager.saveData(_vibratePrefKey, next);
    if (next) {
      HapticService.tap();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final response = await rootBundle.loadString('lib/data/mathurat.json');
    final data = json.decode(response) as List<dynamic>;
    final parsed = data.map((x) => MathuratModel.fromJson(x as Map<String, dynamic>)).toList();

    final morning = parsed.where((e) => e.period == 'morning' || e.period == 'both').toList();
    final evening = parsed.where((e) => e.period == 'evening' || e.period == 'both').toList();

    if (!mounted) return;
    setState(() {
      _allItems = parsed;
      _morningItems = List.of(morning);
      _eveningItems = List.of(evening);
      _morningTotal = morning.length;
      _eveningTotal = evening.length;
      _isLoading = false;
    });
  }

  void _removeCompleted(String period, String id) {
    setState(() {
      if (period == 'morning') {
        _morningItems.removeWhere((item) => item.id == id);
      } else {
        _eveningItems.removeWhere((item) => item.id == id);
      }
    });
  }

  void _resetActiveTab() {
    setState(() {
      if (_tabController.index == 0) {
        _morningItems = _allItems.where((e) => e.period == 'morning' || e.period == 'both').toList();
        _morningTotal = _morningItems.length;
      } else {
        _eveningItems = _allItems.where((e) => e.period == 'evening' || e.period == 'both').toList();
        _eveningTotal = _eveningItems.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleNotifier>(context);
    final textDirection = localeProvider.getTextDirection(localeProvider.locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? darkThemeSwatch : color3;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.mathuratTitle,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(
              icon: _VibrateToggleIcon(enabled: _vibrateEnabled),
              tooltip: _vibrateEnabled ? l10n.mathuratVibrateOn : l10n.mathuratVibrateOff,
              onPressed: _toggleVibrate,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.mathuratReset,
              onPressed: _isLoading ? null : _resetActiveTab,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: const Icon(Icons.light_mode_outlined),
                text: l10n.mathuratMorning,
              ),
              Tab(
                icon: const Icon(Icons.nightlight_round),
                text: l10n.mathuratEvening,
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTabBody(
                    period: 'morning',
                    items: _morningItems,
                    total: _morningTotal,
                    accentColor: accentColor,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                  _buildTabBody(
                    period: 'evening',
                    items: _eveningItems,
                    total: _eveningTotal,
                    accentColor: accentColor,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTabBody({
    required String period,
    required List<MathuratModel> items,
    required int total,
    required Color accentColor,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final completed = total - items.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: isDark ? Colors.white12 : Colors.black12,
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: accentColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.mathuratCompletedTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.mathuratCompletedSubtitle,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.tonalIcon(
                          onPressed: _resetActiveTab,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.mathuratReset),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return MathuratCard(
                      key: ValueKey('${period}_${item.id}'),
                      item: item,
                      isEvening: period == 'evening',
                      isEnglish: Localizations.localeOf(context).languageCode == 'en',
                      isDark: isDark,
                      accentColor: accentColor,
                      vibrateEnabled: _vibrateEnabled,
                      remainingLabel: (count) => l10n.mathuratRemainingCount(count),
                      onCompleted: () => _removeCompleted(period, item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class MathuratCard extends StatefulWidget {
  const MathuratCard({
    super.key,
    required this.item,
    required this.isEvening,
    required this.isEnglish,
    required this.isDark,
    required this.accentColor,
    required this.vibrateEnabled,
    required this.remainingLabel,
    required this.onCompleted,
  });

  final MathuratModel item;
  final bool isEvening;
  final bool isEnglish;
  final bool isDark;
  final Color accentColor;
  final bool vibrateEnabled;
  final String Function(int count) remainingLabel;
  final VoidCallback onCompleted;

  @override
  State<MathuratCard> createState() => _MathuratCardState();
}

class _MathuratCardState extends State<MathuratCard> with SingleTickerProviderStateMixin {
  late int _count;
  late final AnimationController _removeController;
  late final Animation<double> _sizeAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _count = widget.item.count;
    _removeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 1.0,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _removeController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _removeController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _removeController.dispose();
    super.dispose();
  }

  void _decrement() {
    if (_count <= 0) return;
    setState(() {
      _count--;
    });
    if (_count == 0) {
      if (widget.vibrateEnabled) {
        HapticService.complete();
      }
      _removeController.reverse().then((_) {
        if (mounted) {
          widget.onCompleted();
        }
      });
    } else if (widget.vibrateEnabled) {
      HapticService.tap();
    }
  }

  void _showHadithSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleNotifier>(context, listen: false);
    final textDirection = localeProvider.getTextDirection(localeProvider.locale);
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final subTextColor = widget.isDark ? Colors.white70 : Colors.black54;
    final hasHadith = widget.item.hadith != null && widget.item.hadith!.trim().isNotEmpty;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: widget.isDark ? appBarColor : color1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: textDirection,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: widget.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      hasHadith ? widget.item.hadith! : l10n.mathuratNoHadith,
                      style: hasHadith
                          ? GoogleFonts.amiri(
                              fontSize: 16,
                              height: 1.75,
                              color: textColor,
                            )
                          : TextStyle(
                              fontSize: 16,
                              height: 1.7,
                              color: subTextColor,
                            ),
                      textDirection: hasHadith ? TextDirection.rtl : textDirection,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      final arabicText = widget.item.textFor(isEvening: widget.isEvening);
                      final englishText = widget.isEnglish ? widget.item.englishFor(isEvening: widget.isEvening) : null;
                      final body = englishText != null ? '$arabicText\n\n$englishText' : arabicText;
                      final shareText = hasHadith ? '$body\n\n${widget.item.hadith!}' : body;
                      Share.share(shareText);
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l10n.mathuratShareReward),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cardBg = widget.isDark ? appBarColor : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final subTextColor = widget.isDark ? Colors.white70 : Colors.black54;
    final actionIconColor = widget.isDark ? Colors.white70 : Colors.black54;
    final arabicText = widget.item.textFor(isEvening: widget.isEvening);
    final englishText = widget.isEnglish ? widget.item.englishFor(isEvening: widget.isEvening) : null;

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            color: cardBg,
            elevation: widget.isDark ? 1 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _decrement,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      arabicText,
                      style: GoogleFonts.notoNaskhArabic(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        height: 2.0,
                        color: textColor,
                      ),
                      locale: const Locale('ar', 'AE'),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    if (englishText != null && englishText.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        englishText,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: subTextColor,
                        ),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info_outline, color: actionIconColor),
                          tooltip: l10n.mathuratHadithTitle,
                          onPressed: () => _showHadithSheet(context),
                        ),
                        FilledButton.tonal(
                          onPressed: _decrement,
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.accentColor.withValues(alpha: 0.16),
                            foregroundColor: widget.isDark ? Colors.tealAccent.shade100 : color4,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          ),
                          child: Text(
                            widget.remainingLabel(_count),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.share_outlined, color: actionIconColor),
                          tooltip: l10n.mathuratShareTooltip,
                          onPressed: () {
                            final shareText = englishText != null && englishText.isNotEmpty
                                ? '$arabicText\n\n$englishText'
                                : arabicText;
                            Share.share(shareText);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VibrateToggleIcon extends StatelessWidget {
  const _VibrateToggleIcon({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return const Icon(Icons.vibration);
    }
    final iconColor = IconTheme.of(context).color ?? Colors.white;
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.65,
            child: Icon(Icons.vibration, color: iconColor),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _DiagonalSlashPainter(color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalSlashPainter extends CustomPainter {
  const _DiagonalSlashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.16),
      Offset(size.width * 0.84, size.height * 0.84),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DiagonalSlashPainter oldDelegate) => oldDelegate.color != color;
}
