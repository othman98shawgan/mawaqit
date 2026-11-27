For all Git, branching, and release operations, strictly follow the rules in ./GIT_WORKFLOW.md.

Always showcase and align on the complete scope, architecture, and edge cases of any feature or fix before writing any code, especially for big features.

When preparing a Pull Request reminder, always format the PR Description inside a fenced markdown code block (```markdown ... ```) so it can be easily copied with one click into GitHub.

## Terminal & Background Commands (Windows)
- On Windows, Flutter/Dart CLI tools (`flutter analyze`, `flutter test`, `flutter gen-l10n`, etc.) hang silently with empty background logs when run inside the restricted terminal sandbox (`BypassSandbox: false`).
- Always run those background/CLI verification commands as **standalone single commands** (do not chain multiple commands with `;` or `&&`) using **`BypassSandbox: true`** so output streams live and the command completes cleanly.
- If you run `flutter analyze` and `flutter test`, invoke them as two separate `run_command` calls (`BypassSandbox: true`), not combined in one shell string.

## Tasks
- [x] feat: add Windows support with notifications and scheduling
- [x] fix: resolve Android release notifications and add dev indicator to app name
- [x] fix: enforce single instance on Windows desktop and restore window on launch
- [x] feat: add prayer alarms with custom audio, snooze, and battery guide
- [x] fix: refresh today date and prayers when app resumes or midnight passes
- [x] fix: snooze prayer alarms with volume and power buttons
- [x] feat: add iOS support with notifications, reminders, and scheduling
- [x] feat: replace navigation drawer with 5-tab bottom navigation bar
- [x] feat: add in-app GPS Qibla finder with compass and distance to Makkah
- [x] feat: refactor prayer alarm dialog into modal bottom sheet
- [x] chore: migrate UI components and themes to Material 3 conventions
- [x] feat: implement Al-Ma'thurat page with morning/evening adhkar, hadith modal, and haptic feedback
- [x] fix: prevent app from showing over lock screen unless prayer alarm is ringing
- [x] chore: remove Our Apps/Contact/Share from More section and expand test suite
- [ ] chore: restore Our Apps, Contact Us, and Share in More section
- [ ] fix: update UI colors for visibility and consistency
- [x] feat: add vibrate toggle icon in Al-Ma'thurat page to control haptic feedback
- [x] fix: optimize app startup by caching prayer JSON and removing duplicate audio assets
- [x] feat: add swipe navigation between days in Calendar view using PageController
