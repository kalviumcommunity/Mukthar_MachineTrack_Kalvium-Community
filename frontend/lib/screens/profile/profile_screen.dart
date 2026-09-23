import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

/// Profile & Settings Screen for worker account management.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to end your active shift session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusBreakdown,
                minimumSize: const Size(80, 36),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (user?.email?.split('@').first ?? 'Mukthar');
    final subtitle = user?.email ?? 'Frontend Lead • Kalvium Community';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Worker Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // User Information Card Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBlue.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Shift #1 • Plant Floor A',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Team Allocation Info (Frontend, Backend, Database)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MachineTrack Project Team',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTeamRow('Mukthar', 'Frontend / Flutter UI', true),
                    const Divider(height: 16, color: AppTheme.borderLight),
                    _buildTeamRow('Abhinav', 'Backend / Firebase Auth', false),
                    const Divider(height: 16, color: AppTheme.borderLight),
                    _buildTeamRow('Steve', 'Database / Firestore', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account & Preferences Menu
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _buildTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Shift Alerts & Notifications',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    _buildTile(
                      icon: Icons.shield_outlined,
                      title: 'Security & Permissions',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    _buildTile(
                      icon: Icons.help_outline_rounded,
                      title: 'MachineTrack Support',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    _buildTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      subtitle: 'v1.0.0 (Build 2026.09)',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              CustomButton(
                text: 'End Shift / Logout',
                isOutlined: true,
                backgroundColor: AppTheme.statusBreakdown,
                textColor: AppTheme.statusBreakdown,
                icon: Icons.logout_rounded,
                onPressed: () => _handleLogout(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(String name, String role, bool isCurrentUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                color: isCurrentUser ? AppTheme.primaryBlue : AppTheme.textPrimary,
              ),
            ),
            if (isCurrentUser)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        Text(
          role,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            )
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
      onTap: onTap,
    );
  }
}
