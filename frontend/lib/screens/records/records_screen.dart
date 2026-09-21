import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/record_card.dart';

/// Records Screen displaying historical machine inspection checklists & breakdown logs.
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final List<Map<String, String>> _allRecords = const [
    {
      'id': 'INS-2026-0812',
      'title': 'Shift Start Checklist Passed',
      'machineName': 'CNC Lathe Machine #02',
      'recordType': 'Inspection',
      'status': 'Passed',
      'timestamp': '08:30 AM Today',
      'description':
          'Coolant levels checked, safety guards aligned, emergency stop verified.',
      'reportedBy': 'Abhinav',
    },
    {
      'id': 'rec-101',
      'title': 'Hydraulic Fluid Pressure Drop',
      'machineName': 'Hydraulic Press 500T',
      'recordType': 'Breakdown',
      'status': 'Critical',
      'timestamp': '10:45 AM Today',
      'description':
          'Fluid line leak detected near main cylinder valve during morning shift operation.',
      'reportedBy': 'Mukthar',
    },
    {
      'id': 'INS-2026-0810',
      'title': 'Weekly Safety System Verification',
      'machineName': 'Robotic Welding Arm Alpha',
      'recordType': 'Inspection',
      'status': 'Passed',
      'timestamp': '15 Sep 2026',
      'description':
          'Laser curtains, interlock switches, and manual override tested without issues.',
      'reportedBy': 'Mukthar',
    },
    {
      'id': 'rec-103',
      'title': 'Conveyor Roller Misalignment',
      'machineName': 'Automated Conveyor Belt #05',
      'recordType': 'Breakdown',
      'status': 'Needs Repair',
      'timestamp': 'Yesterday, 4:15 PM',
      'description':
          'Belt tension loose on section 3 resulting in package jams. Scheduled for maintenance.',
      'reportedBy': 'Steve',
    },
    {
      'id': 'rec-105',
      'title': 'Heater Nozzle Clogged',
      'machineName': 'Injection Molding Unit #03',
      'recordType': 'Breakdown',
      'status': 'Needs Repair',
      'timestamp': '14 Sep 2026',
      'description':
          'Temperature sensor warning triggered due to partial polymer buildup in nozzle.',
      'reportedBy': 'Abhinav',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshRecords() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, String>> _getFilteredRecords(int tabIndex) {
    if (tabIndex == 1) {
      return _allRecords.where((r) => r['recordType'] == 'Inspection').toList();
    } else if (tabIndex == 2) {
      return _allRecords.where((r) => r['recordType'] == 'Breakdown').toList();
    }
    return _allRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Activity Records'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'All Records'),
            Tab(text: 'Inspections'),
            Tab(text: 'Breakdowns'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded, size: 20),
        label: const Text('Log Inspection', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.newInspection);
        },
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRecordList(0),
            _buildRecordList(1),
            _buildRecordList(2),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordList(int tabIndex) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }

    final records = _getFilteredRecords(tabIndex);

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: AppTheme.textMuted.withAlpha(120),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Records Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No logs available in this category.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshRecords,
      color: AppTheme.primaryBlue,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: records.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = records[index];
          return RecordCard(
            title: item['title']!,
            machineName: item['machineName']!,
            recordType: item['recordType']!,
            status: item['status']!,
            timestamp: item['timestamp']!,
            description: item['description']!,
            reportedBy: item['reportedBy']!,
            onTap: () {
              if (item['recordType'] == 'Inspection') {
                Navigator.pushNamed(
                  context,
                  AppRoutes.inspectionDetails,
                  arguments: {
                    'id': item['id'] ?? 'INS-2026-0812',
                    'machineName': item['machineName'],
                    'machineCode': 'M-00${index + 1}',
                    'machineLocation': 'Plant Floor A',
                    'date': item['timestamp'],
                    'time': '08:30 AM',
                    'condition': item['status'],
                    'notes': item['description'],
                    'reportedBy': '${item['reportedBy']} (Inspector)',
                    'shift': 'Shift #1',
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Breakdown incident log: ${item['title']}'),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
