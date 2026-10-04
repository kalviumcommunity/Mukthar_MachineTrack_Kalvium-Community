import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/breakdown.dart';
import '../../models/inspection.dart';
import '../../models/machine.dart';
import '../../services/auth_service.dart';
import '../../services/breakdown_service.dart';
import '../../services/inspection_service.dart';
import '../../services/machine_service.dart';
import '../../widgets/machine_card.dart';
import '../../widgets/record_card.dart';

/// Home Screen displaying worker shift overview, machine quick metrics, and recent activity.
class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MachineService _machineService = MachineService();
  final BreakdownService _breakdownService = BreakdownService();
  final InspectionService _inspectionService = InspectionService();

  StreamSubscription<List<Machine>>? _machinesSub;
  StreamSubscription<List<Breakdown>>? _breakdownsSub;
  StreamSubscription<List<Inspection>>? _inspectionsSub;

  List<Machine> _machines = [];
  List<Breakdown> _breakdowns = [];
  List<Inspection> _inspections = [];

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _machinesSub = _machineService.getMachinesStream().listen((machines) {
      if (mounted) setState(() => _machines = machines);
    });
    _breakdownsSub = _breakdownService.getBreakdownsStream().listen((breakdowns) {
      if (mounted) setState(() => _breakdowns = breakdowns);
    });
    _inspectionsSub = _inspectionService.getInspectionsStream().listen((inspections) {
      if (mounted) setState(() => _inspections = inspections);
    });
  }

  @override
  void dispose() {
    _machinesSub?.cancel();
    _breakdownsSub?.cancel();
    _inspectionsSub?.cancel();
    super.dispose();
  }

  int get _runningCount =>
      _machines.isNotEmpty ? _machines.where((m) => m.status == 'Running').length : 18;
  int get _maintenanceCount =>
      _machines.isNotEmpty ? _machines.where((m) => m.status == 'Maintenance').length : 3;
  int get _breakdownCount =>
      _machines.isNotEmpty ? _machines.where((m) => m.status == 'Breakdown').length : 1;

  Machine? get _priorityMachine {
    if (_machines.isNotEmpty) {
      final breakdownMachine = _machines.where((m) => m.status == 'Breakdown').firstOrNull;
      if (breakdownMachine != null) return breakdownMachine;
      final maintenanceMachine = _machines.where((m) => m.status == 'Maintenance').firstOrNull;
      if (maintenanceMachine != null) return maintenanceMachine;
      return _machines.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final priority = _priorityMachine;

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
                onSeeAll: () => widget.onNavigateToTab?.call(1),
              ),
              const SizedBox(height: 12),
              if (priority != null)
                MachineCard(
                  id: priority.id,
                  name: priority.name,
                  code: priority.code,
                  location: priority.location,
                  status: priority.status,
                  lastInspected: priority.displayLastInspected,
                  onTap: () {
                    widget.onNavigateToTab?.call(1);
                  },
                )
              else
                MachineCard(
                  id: 'M-104',
                  name: 'Hydraulic Press 500T',
                  code: 'PRESS-500T-04',
                  location: 'Zone A - Heavy Stamping',
                  status: 'Breakdown',
                  lastInspected: '25 mins ago',
                  onTap: () {
                    widget.onNavigateToTab?.call(1);
                  },
                ),
              const SizedBox(height: 24),

              // Recent Inspections & Breakdowns Activity
              _buildSectionHeader(
                title: 'Recent Activity Logs',
                onSeeAll: () => widget.onNavigateToTab?.call(2),
              ),
              const SizedBox(height: 12),
              _buildRecentActivityLogs(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityLogs(BuildContext context) {
    if (_breakdowns.isNotEmpty || _inspections.isNotEmpty) {
      final logs = <Map<String, dynamic>>[
        ..._breakdowns.map((b) => b.toMapForRecord()),
        ..._inspections.map((i) => i.toMapForRecord()),
      ];
      logs.sort((a, b) {
        final dateA = a['rawDate'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b['rawDate'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      return Column(
        children: logs.take(2).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: RecordCard(
              title: item['title']?.toString() ?? '',
              machineName: item['machineName']?.toString() ?? '',
              recordType: item['recordType']?.toString() ?? '',
              status: item['status']?.toString() ?? '',
              timestamp: item['timestamp']?.toString() ?? '',
              description: item['description']?.toString() ?? '',
              reportedBy: item['reportedBy']?.toString() ?? '',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.recordDetails,
                  arguments: item,
                );
              },
            ),
          );
        }).toList(),
      );
    }

    // Static fallback activity logs
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = AuthService().currentUser;
    final displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (user?.email?.split('@').first ?? 'Mukthar');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryBlue.withAlpha(25),
          child: Text(
            initial,
            style: const TextStyle(
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
              Text(
                'Hello, $displayName 👋',
                style: const TextStyle(
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
            value: '$_runningCount',
            color: AppTheme.statusRunning,
            icon: Icons.play_circle_fill_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricItem(
            label: 'Maintenance',
            value: '$_maintenanceCount',
            color: AppTheme.statusMaintenance,
            icon: Icons.build_circle_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricItem(
            label: 'Breakdown',
            value: '$_breakdownCount',
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
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
          child: _buildActionCard(
            context: context,
            title: 'New Inspection',
            subtitle: 'Conduct daily audit',
            icon: Icons.playlist_add_check_circle_rounded,
            color: AppTheme.primaryBlue,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.newInspection);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context: context,
            title: 'Report Fault',
            subtitle: 'Log machine issue',
            icon: Icons.report_problem_rounded,
            color: AppTheme.statusBreakdown,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.reportBreakdown);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withAlpha(12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}
