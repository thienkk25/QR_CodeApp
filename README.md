# QR Scanner Pro

A modern QR code & Barcode scanner app built with Flutter.

## Version

**Version 0.1.0:**
Support Flash(on/off), Gallery, Camera (front, selfie).

**Version 1.0.0:**
1. Improved performance and stability.
2. Enhanced camera support (front/rear switching optimized).
3. Flash toggle improved.
4. Added image picker from gallery.
5. Added Scan History feature to view previous scanned results.
6. Added Auto-open link option for scanned URLs.

**Version 1.1.0:**
Add pinch-to-zoom feature for camera using two fingers and optimize performance.

**Version 1.2.0:**
Improved performance and stability. Added code QR, ISBN, Aztec, ... and save image.

**Version 1.3.0:**
Complete UI/UX redesign — modern dark theme with premium glassmorphism effects:
1. **New Design System**: Deep dark background (`#08080F`), purple-blue gradient accent (`#7C5CFC` → `#3D8EF1`), centralized `AppTheme`, `AppColors`, `AppTextStyles`.
2. **Glassmorphism**: `BackdropFilter` blur on AppBar, BottomBar, settings drawer — creates a premium frosted glass feel.
3. **Animated Scan Window**: Responsive scan frame with gradient glow corners, pulse animation, animated scan line (purple→cyan gradient with glow).
4. **Custom Result Bottom Sheet**: Replaces stock `AlertDialog` — slide-up sheet with domain chip, animated copy feedback, URL open button.
5. **History Screen**: Card-based items with swipe-to-delete (`Dismissible`), item count badge, confirm-before-clear dialog, URL quick-open button, empty state illustration.
6. **Create QR Screen**: Animated barcode preview (fade+slide on input), barcode card with purple glow, full-width gradient save button, empty state placeholder.
7. **Help Screen**: Card-based layout with colored icon badges, section titles with gradient accent bar, gradient hero banner, premium footer.
8. **Settings Drawer**: Fully redesigned slide-in panel with icon badges, categorized settings, app version footer.
9. **Haptic Feedback**: `HapticFeedback.mediumImpact()` on successful scans.
10. **Responsive**: Scan window size adapts to screen width (`clamp(200, 300)`). Tested on Android, iOS, Web, Desktop.
11. **Page Transitions**: Custom `SlideTransition + FadeTransition` on navigation.

12. MIT © by ThienNguyen
