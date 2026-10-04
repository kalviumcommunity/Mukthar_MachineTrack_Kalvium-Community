import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_button.dart';

/// Profile & Settings Screen for worker account management.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  StreamSubscription<List<UserProfile>>? _usersSub;
  List<UserProfile> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _usersSub = _userService.getUsersStream().listen((users) {
      if (mounted) setState(() => _teamMembers = users);
    });
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }

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
                          fontWeight: FontWeight.w800,
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
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.statusRunning.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.statusRunning),
                          SizedBox(width: 6),
                          Text(
                            'Shift Active • Plant Floor A',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.statusRunning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Operational Shift Info Card
              Container(
                width: double.infinity,
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
                      'Shift Assignments & Station',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.access_time_rounded, 'Shift Schedule', 'Shift #1 (08:00 - 16:00)'),
                    const Divider(height: 16, color: AppTheme.borderLight),
                    _buildInfoRow(Icons.location_on_outlined, 'Primary Assigned Zone', 'Zone A - Stamping & Bay'),
                    const Divider(height: 16, color: AppTheme.borderLight),
                    _buildInfoRow(Icons.engineering_outlined, 'Role Designation', 'Senior Maintenance Tech'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Community Team Credits
              Container(
                width: double.infinity,
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
                    if (_teamMembers.isNotEmpty)
                      ..._teamMembers.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final member = entry.value;
                        final isMe = member.uid == user?.uid || member.email == user?.email;
                        final roleTitle = member.isAdmin ? 'Admin' : 'Technician';
                        return Column(
                          children: [
                            if (idx > 0) const Divider(height: 16, color: AppTheme.borderLight),
                            _buildTeamRow(member.name, roleTitle, isMe),
                          ],
                        );
                      })
                    else ...[
                      _buildTeamRow('Mukthar', 'Frontend / Flutter UI', true),
                      const Divider(height: 16, color: AppTheme.borderLight),
                      _buildTeamRow('Abhinav', 'Backend / Firebase Auth', false),
                      const Divider(height: 16, color: AppTheme.borderLight),
                      _buildTeamRow('Steve', 'Database / Firestore', false),
                    ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
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
      leading: Icon(icon, color: AppTheme.primaryBlue, size: 22),
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
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
