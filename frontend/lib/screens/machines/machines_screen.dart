import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/machine_card.dart';

/// Machines Screen displaying factory machine inventory with status filtering.
class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
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

  List<Map<String, String>> get _filteredMachines {
    return _allMachines.where((m) {
      final matchesFilter = _selectedFilter == 'All' ||
          m['status']!.toLowerCase() == _selectedFilter.toLowerCase();
      final matchesSearch = m['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m['code']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m['location']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredMachines;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Factory Machines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter settings sheet')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            const SizedBox(height: 8),

            // Machine Cards List View
            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textMuted.withAlpha(120),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Machines Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your filter selection or search query.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
