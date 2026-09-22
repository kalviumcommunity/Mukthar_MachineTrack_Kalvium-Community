import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/machine_card.dart';
import '../../widgets/record_card.dart';

/// Home Screen displaying worker shift overview, machine quick metrics, and recent activity.
class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker Greeting Header
              _buildHeader(context),
              const SizedBox(height: 20),

              // Machine Operational Summary Cards
              _buildMetricsSummary(),
              const SizedBox(height: 24),

              // Quick Action Shortcuts
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Priority Machine Focus
              _buildSectionHeader(
                title: 'High Priority Machines',
                onSeeAll: () => onNavigateToTab?.call(1),
              ),
              const SizedBox(height: 12),
              MachineCard(
                id: 'M-104',
                name: 'Hydraulic Press 500T',
                code: 'PRESS-500T-04',
                location: 'Zone A - Heavy Stamping',
                status: 'Breakdown',
                lastInspected: '25 mins ago',
                onTap: () {
                  onNavigateToTab?.call(1);
                },
              ),
              const SizedBox(height: 24),

              // Recent Inspections & Breakdowns Activity
              _buildSectionHeader(
                title: 'Recent Activity Logs',
                onSeeAll: () => onNavigateToTab?.call(2),
              ),
              const SizedBox(height: 12),
              RecordCard(
                title: 'Hydraulic Fluid Pressure Drop',
                machineName: 'Hydraulic Press 500T',
                recordType: 'Breakdown',
                status: 'Critical',
                timestamp: '10:45 AM Today',
                description:
                    'Fluid line leak detected near main cylinder valve during morning shift operation.',
                reportedBy: 'Mukthar (Me)',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.recordDetails,
                    arguments: {
                      'id': 'rec-101',
                      'title': 'Hydraulic Fluid Pressure Drop',
                      'machineName': 'Hydraulic Press 500T',
                      'machineCode': 'PRESS-500T-04',
                      'machineLocation': 'Zone A - Stamping Line',
                      'recordType': 'Breakdown',
                      'status': 'Critical',
                      'timestamp': '10:45 AM Today',
                      'description':
                          'Fluid line leak detected near main cylinder valve during morning shift operation.',
                      'reportedBy': 'Mukthar (Lead Tech)',
                      'shift': 'Shift #1 • Plant Floor A',
                      'priority': 'Critical / Line Halt',
                      'component': 'Main Hydraulic Pump & Valve',
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              RecordCard(
                title: 'Routine Shift-Start Checklist',
                machineName: 'CNC Lathe Machine #02',
                recordType: 'Inspection',
                status: 'Passed',
                timestamp: '08:30 AM Today',
                description:
                    'Coolant levels checked, safety guards aligned, emergency stop verified.',
                reportedBy: 'Abhinav',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.inspectionDetails,
                    arguments: {
                      'id': 'INS-2026-0812',
                      'machineName': 'CNC Lathe Machine #02',
                      'machineCode': 'CNC-LTH-02',
                      'machineLocation': 'Zone B - Machining Cell',
                      'date': '22 Sep 2026',
                      'time': '08:30 AM',
                      'condition': 'Passed',
                      'notes': 'Coolant levels checked, safety guards aligned, emergency stop verified.',
                      'reportedBy': 'Abhinav (Operator)',
                      'shift': 'Shift #1',
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryBlue.withAlpha(25),
          child: const Text(
            'M',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello, Mukthar 👋',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.statusRunning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Shift #1 • Plant Floor A',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: AppTheme.textPrimary,
            ),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications functionality coming in Sprint 3'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricsSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            label: 'Running',
            value: '18',
            color: AppTheme.statusRunning,
            icon: Icons.play_circle_fill_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricItem(
            label: 'Maintenance',
            value: '3',
            color: AppTheme.statusMaintenance,
            icon: Icons.build_circle_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricItem(
            label: 'Breakdown',
            value: '1',
            color: AppTheme.statusBreakdown,
            icon: Icons.warning_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.newInspection);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_task_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Inspection',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Shift checklist',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.reportBreakdown);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.statusBreakdown.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.statusBreakdown.withAlpha(60)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppTheme.statusBreakdown, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Breakdown Alert',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.statusBreakdown,
                          ),
                        ),
                        Text(
                          'Report fault',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}
