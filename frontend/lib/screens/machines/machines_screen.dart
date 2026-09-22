import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/machine_card.dart';

/// Machines Screen displaying factory machine inventory with combined search, status filtering, and sorting.
class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  String _selectedFilter = 'All';
  String _selectedZone = 'All Zones';
  String _sortBy = 'Name';
  String _searchQuery = '';
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  // Sample Static Machine Dataset
  final List<Map<String, String>> _allMachines = const [
    {
      'id': '1',
      'name': 'Hydraulic Press 500T',
      'code': 'PRESS-500T-04',
      'location': 'Zone A - Stamping Line',
      'status': 'Breakdown',
      'lastInspected': '25 mins ago',
      'model': 'StamperPro 500',
      'serialNumber': 'SN-99812-A',
      'assignedTech': 'Mukthar',
    },
    {
      'id': '2',
      'name': 'CNC Lathe Machine #02',
      'code': 'CNC-LTH-02',
      'location': 'Zone B - Machining Cell',
      'status': 'Running',
      'lastInspected': '2 hours ago',
      'model': 'LatheMatic 3000',
      'serialNumber': 'SN-44310-B',
      'assignedTech': 'Abhinav',
    },
    {
      'id': '3',
      'name': 'Automated Conveyor Belt #05',
      'code': 'CNV-BELT-05',
      'location': 'Zone C - Packaging Line',
      'status': 'Maintenance',
      'lastInspected': 'Yesterday',
      'model': 'ConveyX Ultra',
      'serialNumber': 'SN-11204-C',
      'assignedTech': 'Steve',
    },
    {
      'id': '4',
      'name': 'Robotic Welding Arm Alpha',
      'code': 'ROB-WLD-01',
      'location': 'Zone A - Welding Bay',
      'status': 'Running',
      'lastInspected': '3 hours ago',
      'model': 'WeldBot 900',
      'serialNumber': 'SN-77291-A',
      'assignedTech': 'Mukthar',
    },
    {
      'id': '5',
      'name': 'Injection Molding Unit #03',
      'code': 'INJ-MLD-03',
      'location': 'Zone D - Plastics Sector',
      'status': 'Idle',
      'lastInspected': '3 days ago',
      'model': 'MoldMaster Pro',
      'serialNumber': 'SN-55612-D',
      'assignedTech': 'Abhinav',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshMachines() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _resetSearchAndFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedFilter = 'All';
      _selectedZone = 'All Zones';
      _sortBy = 'Name';
    });
  }

  bool get _hasActiveFilters =>
      _selectedFilter != 'All' ||
      _selectedZone != 'All Zones' ||
      _searchQuery.isNotEmpty ||
      _sortBy != 'Name';

  List<Map<String, String>> get _filteredMachines {
    final list = _allMachines.where((m) {
      final matchesStatus = _selectedFilter == 'All' ||
          m['status']!.toLowerCase() == _selectedFilter.toLowerCase();
      final matchesZone = _selectedZone == 'All Zones' ||
          m['location']!.toLowerCase().contains(_selectedZone.toLowerCase().replaceAll('zone ', ''));
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          m['name']!.toLowerCase().contains(query) ||
          m['code']!.toLowerCase().contains(query) ||
          m['location']!.toLowerCase().contains(query) ||
          (m['assignedTech']?.toLowerCase().contains(query) ?? false);
      return matchesStatus && matchesZone && matchesSearch;
    }).toList();

    if (_sortBy == 'Status') {
      list.sort((a, b) => a['status']!.compareTo(b['status']!));
    } else if (_sortBy == 'Location') {
      list.sort((a, b) => a['location']!.compareTo(b['location']!));
    } else {
      list.sort((a, b) => a['name']!.compareTo(b['name']!));
    }

    return list;
  }

  void _openFilterBottomSheet() {
    String tempFilter = _selectedFilter;
    String tempZone = _selectedZone;
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
                    // Handle Bar
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

                    // Title & Reset Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter & Sort Machines',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempFilter = 'All';
                              tempZone = 'All Zones';
                              tempSort = 'Name';
                            });
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppTheme.borderLight),
                    const SizedBox(height: 8),

                    // Status Filter Section
                    const Text(
                      'Operational Status',
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
                      children: ['All', 'Running', 'Maintenance', 'Breakdown', 'Idle'].map((status) {
                        final isSelected = tempFilter == status;
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
                              setModalState(() => tempFilter = status);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Plant Zone Section
                    const Text(
                      'Plant Zone',
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
                      children: ['All Zones', 'Zone A', 'Zone B', 'Zone C', 'Zone D'].map((zone) {
                        final isSelected = tempZone == zone;
                        return ChoiceChip(
                          label: Text(zone),
                          selected: isSelected,
                          selectedColor: AppTheme.secondaryBlue,
                          backgroundColor: AppTheme.backgroundLight,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppTheme.secondaryBlue : AppTheme.borderLight,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => tempZone = zone);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Sort By Section
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
                      children: ['Name', 'Status', 'Location'].map((sort) {
                        final isSelected = tempSort == sort;
                        return ChoiceChip(
                          label: Text('By $sort'),
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

                    // Apply Button
                    CustomButton(
                      text: 'Apply Filters',
                      onPressed: () {
                        setState(() {
                          _selectedFilter = tempFilter;
                          _selectedZone = tempZone;
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

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredMachines;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Factory Machines'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 22),
                tooltip: 'Filter & Sort',
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
                  hintText: 'Search machine name, ID, or zone...',
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
                children: ['All', 'Running', 'Maintenance', 'Breakdown', 'Idle'].map((filter) {
                  final isSelected = _selectedFilter == filter;
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
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Active Filter & Count Bar
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${filteredList.length} of ${_allMachines.length} machines',
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
            const SizedBox(height: 4),

            // Machine Cards List View / Loading / Empty State
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshMachines,
                      color: AppTheme.primaryBlue,
                      child: filteredList.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                              itemCount: filteredList.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                return MachineCard(
                                  id: item['id']!,
                                  name: item['name']!,
                                  code: item['code']!,
                                  location: item['location']!,
                                  status: item['status']!,
                                  lastInspected: item['lastInspected'],
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.machineDetails,
                                      arguments: item,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(32.0),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withAlpha(12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No Machines Found',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _searchQuery.isNotEmpty
              ? 'No machines matched "$_searchQuery". Try checking the name, code, or active status filter.'
              : 'No machines match the selected status "$_selectedFilter".',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
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
    );
  }
}
