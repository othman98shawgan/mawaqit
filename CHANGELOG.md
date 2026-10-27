# Changelog

## [1.0.9] - 2026-10-26

### Added
- Windows desktop platform support with system tray integration, window aspect-ratio locking, and local notifications.
- Developer indicator prefix `[DEV]` for debug builds in application name, title, and drawer.
- ProGuard rules and resource keep configuration (`keep.xml`) for `flutter_local_notifications`.

### Fixed
- Resolved Android release notification delivery and background crashes on scheduled alarms.
- Fixed startup splash screen hang by handling timezone lookups with timeout fallbacks and non-blocking prayer scheduling.
- Fixed race condition where notification toggle status was read asynchronously after prayer scheduling began.

### Changed
- Refactored user-facing strings across notifications, settings, and dialogs into Arabic and English localization (`l10n`).
- Standardized Android notification channels with high priority and importance.
