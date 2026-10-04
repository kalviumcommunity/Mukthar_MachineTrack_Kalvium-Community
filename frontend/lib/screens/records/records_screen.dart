import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/breakdown.dart';
import '../../models/inspection.dart';
import '../../services/breakdown_service.dart';
import '../../services/inspection_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/record_card.dart';

/// Records Screen displaying historical machine inspection checklists & breakdown logs with search and multi-criteria filtering.
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'All'; // 'All', 'Passed', 'Needs Repair', 'Critical'
  String _sortBy = 'Newest';
  bool _isLoading = false;

  final InspectionService _inspectionService = InspectionService();
  final BreakdownService _breakdownService = BreakdownService();
  StreamSubscription<List<Inspection>>? _inspectionsSub;
  StreamSubscription<List<Breakdown>>? _breakdownsSub;

  List<Inspection> _latestInspections = [];
  List<Breakdown> _latestBreakdowns = [];

  // Static Fallback Records Dataset
  static const List<Map<String, dynamic>> _allStaticRecords = [
    {
      'id': 'INS-2026-0812',
      'title': 'Shift Start Checklist Passed',
      'machineName': 'CNC Lathe Machine #02',
      'machineCode': 'CNC-LTH-02',
      'machineLocation': 'Zone B - Machining Cell',
      'recordType': 'Inspection',
      'status': 'Passed',
      'timestamp': '08:30 AM Today',
      'description':
          'Coolant levels checked, safety guards aligned, emergency stop verified.',
      'reportedBy': 'Abhinav',
      'shift': 'Shift #1 • Plant Floor A',
    },
    {
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
      'reportedBy': 'Mukthar',
      'shift': 'Shift #1 • Plant Floor A',
      'priority': 'Critical / Urgent',
      'component': 'Main Hydraulic Pump & Valve',
    },
    {
      'id': 'INS-2026-0810',
      'title': 'Weekly Safety System Verification',
      'machineName': 'Robotic Welding Arm Alpha',
      'machineCode': 'ROB-WLD-01',
      'machineLocation': 'Zone A - Welding Bay',
      'recordType': 'Inspection',
      'status': 'Passed',
      'timestamp': '15 Sep 2026',
      'description':
          'Laser curtains, interlock switches, and manual override tested without issues.',
      'reportedBy': 'Mukthar',
      'shift': 'Shift #1 • Plant Floor A',
    },
    {
      'id': 'rec-103',
      'title': 'Conveyor Roller Misalignment',
      'machineName': 'Automated Conveyor Belt #05',
      'machineCode': 'CNV-BELT-05',
      'machineLocation': 'Zone C - Packaging Line',
      'recordType': 'Breakdown',
      'status': 'Needs Repair',
      'timestamp': 'Yesterday, 4:15 PM',
      'description':
          'Belt tension loose on section 3 resulting in package jams. Scheduled for maintenance.',
      'reportedBy': 'Steve',
      'shift': 'Shift #2 • Plant Floor C',
      'priority': 'Medium',
      'component': 'Conveyor Drive Belt #03',
    },
    {
      'id': 'rec-105',
      'title': 'Heater Nozzle Clogged',
      'machineName': 'Injection Molding Unit #03',
      'machineCode': 'INJ-MLD-03',
      'machineLocation': 'Zone D - Plastics Sector',
      'recordType': 'Breakdown',
      'status': 'Needs Repair',
      'timestamp': '14 Sep 2026',
      'description':
          'Temperature sensor warning triggered due to partial polymer buildup in nozzle.',
      'reportedBy': 'Abhinav',
      'shift': 'Shift #2 • Plant Floor D',
      'priority': 'Medium',
      'component': 'Thermal Nozzle Unit',
    },
    {
      'id': 'INS-2026-0799',
      'title': 'Pre-Shift Safety Walkthrough',
      'machineName': 'Hydraulic Press 500T',
      'machineCode': 'PRESS-500T-04',
      'machineLocation': 'Zone A - Stamping Line',
      'recordType': 'Inspection',
      'status': 'Passed',
      'timestamp': '12 Sep 2026',
      'description':
          'Ram alignment verified, pressure relief valve operational, safety curtain active.',
      'reportedBy': 'Mukthar',
      'shift': 'Shift #1 • Plant Floor A',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _subscribeToRecords();
  }

  void _subscribeToRecords() {
    _inspectionsSub = _inspectionService.getInspectionsStream().listen((inspections) {
      if (mounted) {
        setState(() {
          _latestInspections = inspections;
        });
      }
    });

    _breakdownsSub = _breakdownService.getBreakdownsStream().listen((breakdowns) {
      if (mounted) {
        setState(() {
          _latestBreakdowns = breakdowns;
        });
      }
    });
  }

  List<Map<String, dynamic>> get _currentRecords {
    if (_latestInspections.isNotEmpty || _latestBreakdowns.isNotEmpty) {
      final combined = <Map<String, dynamic>>[
        ..._latestInspections.map((i) => i.toMapForRecord()),
        ..._latestBreakdowns.map((b) => b.toMapForRecord()),
      ];
      // Sort newest first
      combined.sort((a, b) {
        final dateA = a['rawDate'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b['rawDate'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
      return combined;
    }
    return _allStaticRecords;
  }

  @override
  void dispose() {
    _inspectionsSub?.cancel();
    _breakdownsSub?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshRecords() async {
    setState(() => _isLoading = true);
    try {
      final inspections = await _inspectionService.getInspections();
      final breakdowns = await _breakdownService.getBreakdowns();
      if (mounted) {
        setState(() {
          _latestInspections = inspections;
          _latestBreakdowns = breakdowns;
        });
      }
    } catch (_) {
      // Quiet fallback
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _resetSearchAndFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatusFilter = 'All';
      _sortBy = 'Newest';
    });
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedStatusFilter != 'All' ||
      _sortBy != 'Newest';

  List<Map<String, dynamic>> _getFilteredRecords(int tabIndex) {
    final list = _currentRecords.where((r) {
      // 1. Tab Type Filter
      bool matchesType = true;
      final type = (r['recordType'] ?? '').toString();
      if (tabIndex == 1) {
        matchesType = type == 'Inspection';
      } else if (tabIndex == 2) {
        matchesType = type == 'Breakdown';
      }

      // 2. Status / Severity Filter
      bool matchesStatus = true;
      if (_selectedStatusFilter != 'All') {
        matchesStatus =
            (r['status'] ?? '').toString().toLowerCase() == _selectedStatusFilter.toLowerCase();
      }

      // 3. Search Query (Machine name, ID, title, description, reporter)
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        matchesSearch = (r['title'] ?? '').toString().toLowerCase().contains(q) ||
            (r['machineName'] ?? '').toString().toLowerCase().contains(q) ||
            (r['machineCode']?.toString().toLowerCase().contains(q) ?? false) ||
            (r['id'] ?? '').toString().toLowerCase().contains(q) ||
            (r['description'] ?? '').toString().toLowerCase().contains(q) ||
            (r['reportedBy'] ?? '').toString().toLowerCase().contains(q);
      }

      return matchesType && matchesStatus && matchesSearch;
    }).toList();

    return list;
  }

  void _openFilterBottomSheet() {
    String tempStatus = _selectedStatusFilter;
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Records',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempStatus = 'All';
                              tempSort = 'Newest';
                            });
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(
                              color: AppTheme.statusBreakdown,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppTheme.borderLight),
                    const SizedBox(height: 8),

                    // Status / Severity Filter
                    const Text(
                      'Record Status / Severity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Passed', 'Needs Repair', 'Critical', 'Warning'].map((status) {
                        final isSelected = tempStatus == status;
                        return ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryBlue,
                          backgroundColor: AppTheme.backgroundLight,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => tempStatus = status);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Sort Order
                    const Text(
                      'Sort Order',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Newest', 'Oldest'].map((sort) {
                        final isSelected = tempSort == sort;
                        return ChoiceChip(
                          label: Text(sort),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryBlue,
                          backgroundColor: AppTheme.backgroundLight,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => tempSort = sort);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Apply Filters',
                      onPressed: () {
                        setState(() {
                          _selectedStatusFilter = tempStatus;
                          _sortBy = tempSort;
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleRecordTap(Map<String, dynamic> record, int index) {
    Navigator.pushNamed(
      context,
      AppRoutes.recordDetails,
      arguments: record,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Activity Logs & Audits'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 22),
                tooltip: 'Filter Records',
                onPressed: _openFilterBottomSheet,
              ),
              if (_hasActiveFilters)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppTheme.surfaceWhite,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryBlue,
              indicatorWeight: 3,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'All Logs'),
                Tab(text: 'Inspections'),
                Tab(text: 'Breakdowns'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search title, machine, reporter or ID...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: ['All', 'Passed', 'Needs Repair', 'Critical', 'Warning'].map((filter) {
                  final isSelected = _selectedStatusFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
                      selectedColor: AppTheme.primaryBlue,
                      backgroundColor: AppTheme.surfaceWhite,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedStatusFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Active Filters Banner
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtered results for "${_tabController.index == 0 ? 'All' : _tabController.index == 1 ? 'Inspections' : 'Breakdowns'}"',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: _resetSearchAndFilters,
                      child: const Text(
                        'Reset Filters',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // TabBarView Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRecordList(0),
                  _buildRecordList(1),
                  _buildRecordList(2),
                ],
              ),
            ),
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
      return RefreshIndicator(
        onRefresh: _refreshRecords,
        color: AppTheme.primaryBlue,
        child: ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withAlpha(12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 52,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Activity Records Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No records matching "$_searchQuery" found in this category.'
                  : _selectedStatusFilter != 'All'
                      ? 'No records with status "$_selectedStatusFilter" found in this tab.'
                      : 'No inspection or breakdown logs recorded yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (_hasActiveFilters)
              Center(
                child: SizedBox(
                  width: 200,
                  child: CustomButton(
                    text: 'Reset Filters & Search',
                    isOutlined: true,
                    icon: Icons.refresh_rounded,
                    onPressed: _resetSearchAndFilters,
                  ),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: records.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = records[index];
          return RecordCard(
            title: (item['title'] ?? '').toString(),
            machineName: (item['machineName'] ?? '').toString(),
            recordType: (item['recordType'] ?? '').toString(),
            status: (item['status'] ?? '').toString(),
            timestamp: (item['timestamp'] ?? '').toString(),
            description: (item['description'] ?? '').toString(),
            reportedBy: (item['reportedBy'] ?? '').toString(),
            onTap: () => _handleRecordTap(item, index),
          );
        },
      ),
    );
  }
}
