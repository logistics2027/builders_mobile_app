import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:avg_mart/screens/login_screen.dart';
import 'package:avg_mart/state/app_state.dart';
import 'package:avg_mart/theme/app_color.dart';
import 'package:avg_mart/widgets/avg_mart_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  bool _notificationsEnabled = false;
  final Map<Permission, PermissionStatus> _statuses = {};

  List<_PermissionItem> get _permissionItems {
    final isIOS = !kIsWeb && Platform.isIOS;
    return [
      const _PermissionItem(
        permission: Permission.camera,
        title: "Camera",
        subtitle: "Used to capture photos for product reviews",
        icon: Icons.camera_alt_outlined,
      ),
      const _PermissionItem(
        permission: Permission.location,
        title: "Location",
        subtitle: "Used to set delivery address and find nearby stores",
        icon: Icons.location_on_outlined,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When the user backgrounds the app to flip a switch in system
  /// Settings and comes back, re-check everything so the UI stays in
  /// sync with the real OS-level state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatuses();
    }
  }

  Future<void> _refreshStatuses() async {
    final notifStatus = await Permission.notification.status;
    final Map<Permission, PermissionStatus> statuses = {};
    for (final item in _permissionItems) {
      statuses[item.permission] = await item.permission.status;
    }
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = notifStatus.isGranted;
      _statuses
        ..clear()
        ..addAll(statuses);
    });
  }

  Future<void> _handleNotificationToggle(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (!mounted) return;
      if (status.isGranted) {
        setState(() => _notificationsEnabled = true);
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog(
          "Notifications",
          "Notifications are turned off in system settings. "
              "Enable them from Settings to continue.",
        );
      } else {
        setState(() => _notificationsEnabled = false);
      }
    } else {
      // Can't revoke an already-granted permission from inside the app.
      _showSettingsDialog(
        "Notifications",
        "To turn off notifications, disable them from your device Settings.",
      );
    }
  }

  Future<void> _handlePermissionAction(_PermissionItem item) async {
    final current = _statuses[item.permission] ?? PermissionStatus.denied;

    if (current.isGranted) {
      // Already enabled — only the system Settings screen can disable it.
      _showSettingsDialog(
        item.title,
        "To disable ${item.title} access, turn it off from your device Settings.",
      );
      return;
    }

    if (current.isPermanentlyDenied || current.isRestricted) {
      _showSettingsDialog(
        item.title,
        "${item.title} access was denied. Enable it from Settings to use this feature.",
      );
      return;
    }

    final result = await item.permission.request();
    if (!mounted) return;
    setState(() => _statuses[item.permission] = result);

    if (result.isPermanentlyDenied) {
      _showSettingsDialog(
        item.title,
        "${item.title} access was denied. Enable it from Settings to use this feature.",
      );
    }
  }

  void _showSettingsDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account?\n\n'
          'All your personal profile data, addresses, and order history will be deleted immediately. '
          'This action is irreversible.',
          style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF4A5568)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    try {
      final appState = AppStateProvider.of(context);
      await appState.deleteAccount();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your account and personal data have been permanently deleted.',
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete account. Please try again or contact support at support@avgmart.com: $e',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AvgMartAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // _sectionLabel("NOTIFICATIONS"),
          // const SizedBox(height: 8),
          // _buildCard(
          //   child: SwitchListTile(
          //     contentPadding: EdgeInsets.zero,
          //     value: _notificationsEnabled,
          //     onChanged: _handleNotificationToggle,
          //     activeColor: AppColors.primary,
          //     title: const Text(
          //       "Push Notifications",
          //       style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          //     ),
          //     subtitle: Text(
          //       _notificationsEnabled
          //           ? "You'll receive updates and alerts"
          //           : "Turned off",
          //       style: const TextStyle(fontSize: 12, color: Color(0xFFA3ACB9)),
          //     ),
          //     secondary: Icon(
          //       _notificationsEnabled
          //           ? Icons.notifications_active_outlined
          //           : Icons.notifications_off_outlined,
          //       color: AppColors.primary,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 24),
          _sectionLabel("PERMISSIONS"),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: [
                for (int i = 0; i < _permissionItems.length; i++) ...[
                  _buildPermissionTile(_permissionItems[i]),
                  if (i != _permissionItems.length - 1)
                    const Divider(height: 1, color: Color(0xFFF1F3F5)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Enabled permissions can only be turned off from your device Settings app.",
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          _sectionLabel("ACCOUNT MANAGEMENT"),
          const SizedBox(height: 8),
          _buildCard(
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                  ),
                ),
                title: const Text(
                  "Delete Account",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                subtitle: const Text(
                  "Permanently delete your profile and personal data",
                  style: TextStyle(fontSize: 12, color: Color(0xFFA3ACB9)),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFA3ACB9),
                ),
                onTap: _showDeleteAccountDialog,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Color(0xFFA3ACB9),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F3F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  Widget _buildPermissionTile(_PermissionItem item) {
    final status = _statuses[item.permission] ?? PermissionStatus.denied;
    final isEnabled = status.isGranted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF001B44),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA3ACB9),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isEnabled
                            ? const Color(0xFF0A9B4B)
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEnabled ? "Enabled" : "Disabled",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? const Color(0xFF0A9B4B)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _handlePermissionAction(item),
            style: OutlinedButton.styleFrom(
              foregroundColor: isEnabled
                  ? Colors.grey.shade700
                  : AppColors.primary,
              side: BorderSide(
                color: isEnabled ? Colors.grey.shade300 : AppColors.primary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isEnabled ? "Manage" : "Enable",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem {
  final Permission permission;
  final String title;
  final String subtitle;
  final IconData icon;

  const _PermissionItem({
    required this.permission,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
