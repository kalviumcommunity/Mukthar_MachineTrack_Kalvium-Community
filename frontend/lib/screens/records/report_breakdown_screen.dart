import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';

/// Screen for reporting and logging machine breakdown incidents and emergency maintenance requests.
class ReportBreakdownScreen extends StatefulWidget {
  final Map<String, dynamic>? initialMachine;

  const ReportBreakdownScreen({super.key, this.initialMachine});

  @override
  State<ReportBreakdownScreen> createState() => _ReportBreakdownScreenState();
}

class _ReportBreakdownScreenState extends State<ReportBreakdownScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, String>> _machineOptions = const [
    {
      'id': '1',
      'name': 'Hydraulic Press 500T',
      'code': 'PRESS-500T-04',
      'location': 'Zone A - Stamping Line',
      'status': 'Breakdown',
    },
    {
      'id': '2',
      'name': 'CNC Lathe Machine #02',
      'code': 'CNC-LTH-02',
      'location': 'Zone B - Machining Cell',
      'status': 'Running',
    },
    {
      'id': '3',
      'name': 'Automated Conveyor Belt #05',
      'code': 'CNV-BELT-05',
      'location': 'Zone C - Packaging Line',
      'status': 'Maintenance',
    },
    {
      'id': '4',
      'name': 'Robotic Welding Arm Alpha',
      'code': 'ROB-WLD-01',
      'location': 'Zone A - Welding Bay',
      'status': 'Running',
    },
    {
      'id': '5',
      'name': 'Injection Molding Unit #03',
      'code': 'INJ-MLD-03',
      'location': 'Zone D - Plastics Sector',
      'status': 'Idle',
    },
  ];

  Map<String, String>? _selectedMachine;
  String _selectedSeverity = 'Critical'; // 'Critical', 'Needs Repair', 'Warning'
  String _selectedCategory = 'Hydraulics';
  bool _safetyStopTriggered = true;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Hydraulics',
    'Electrical',
    'Mechanical / Bearings',
    'Pneumatics',
    'Thermal / Cooling',
    'Sensors / Safety Guard',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialMachine != null) {
      final id = widget.initialMachine!['id']?.toString();
      final name = widget.initialMachine!['name']?.toString();
      _selectedMachine = _machineOptions.firstWhere(
        (m) => m['id'] == id || m['name'] == name,
        orElse: () => {
          'id': widget.initialMachine!['id']?.toString() ?? '1',
          'name': widget.initialMachine!['name']?.toString() ?? 'Selected Machine',
          'code': widget.initialMachine!['code']?.toString() ?? 'M-001',
          'location': widget.initialMachine!['location']?.toString() ?? 'Plant Floor',
          'status': widget.initialMachine!['status']?.toString() ?? 'Breakdown',
        },
      );
    } else {
      _selectedMachine = _machineOptions.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final recordId = 'BRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final payload = {
      'id': recordId,
      'title': _titleController.text.trim().isEmpty
          ? '$_selectedCategory Failure Incident'
          : _titleController.text.trim(),
      'machineName': _selectedMachine!['name'],
      'machineCode': _selectedMachine!['code'],
      'machineLocation': _selectedMachine!['location'],
      'recordType': 'Breakdown',
      'status': _selectedSeverity,
      'timestamp': 'Just now',
      'description': _descriptionController.text.trim(),
      'reportedBy': 'Mukthar (Lead Tech)',
      'shift': 'Shift #1 • Plant Floor A',
      'priority': _selectedSeverity == 'Critical' ? 'Urgent / Line Halt' : 'High Priority',
      'component': '$_selectedCategory Subsystem',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Breakdown incident $recordId logged! Alert dispatched to maintenance team.'),
        backgroundColor: AppTheme.statusBreakdown,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.recordDetails,
      arguments: payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Report Machine Fault'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Machine Selector
                _buildSectionLabel('Affected Machine', Icons.precision_manufacturing_rounded),
                const SizedBox(height: 8),
                _buildMachineSelector(),
                const SizedBox(height: 20),

                // Severity Level
                _buildSectionLabel('Fault Severity & Urgency', Icons.warning_amber_rounded),
                const SizedBox(height: 8),
                _buildSeveritySelector(),
                const SizedBox(height: 20),

                // Category Chips
                _buildSectionLabel('Affected Subsystem', Icons.category_rounded),
                const SizedBox(height: 8),
                _buildCategorySelector(),
                const SizedBox(height: 20),

                // Incident Title & Description
                _buildSectionLabel('Incident Summary', Icons.edit_note_rounded),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Short Fault Headline',
                          hintText: 'e.g. Hydraulic Line Pressure Drop / Motor Overheat',
                          prefixIcon: Icon(Icons.title_rounded, size: 20, color: AppTheme.textMuted),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a short headline for the fault';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Detailed Failure Observations',
                          hintText: 'Describe symptoms, unusual sounds, smoke, or error codes displayed on machine panel...',
                          alignLabelWithHint: true,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().length < 8) {
                            return 'Please provide a clear description of the issue (at least 8 characters)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Safety Interlock Check
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.statusBreakdown.withAlpha(12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.statusBreakdown.withAlpha(40)),
                  ),
                  child: CheckboxListTile(
                    value: _safetyStopTriggered,
                    activeColor: AppTheme.statusBreakdown,
                    title: const Text(
                      'Emergency Stop / Safety Interlock Triggered',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.statusBreakdown,
                      ),
                    ),
                    subtitle: const Text(
                      'Machine isolated to avoid secondary tool or operator damage',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    onChanged: (val) {
                      setState(() => _safetyStopTriggered = val ?? true);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                CustomButton(
                  text: 'Submit Breakdown Report',
                  icon: Icons.emergency_rounded,
                  backgroundColor: AppTheme.statusBreakdown,
                  isLoading: _isSubmitting,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMachineSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, String>>(
          value: _selectedMachine,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryBlue),
          items: _machineOptions.map((machine) {
            return DropdownMenuItem<Map<String, String>>(
              value: machine,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.statusBreakdown.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing_rounded,
                      size: 18,
                      color: AppTheme.statusBreakdown,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          machine['name']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${machine['code']} • ${machine['location']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedMachine = val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSeveritySelector() {
    final severities = [
      {
        'title': 'Critical',
        'subtitle': 'Line Stopped',
        'color': AppTheme.statusBreakdown,
        'icon': Icons.report_problem_rounded,
      },
      {
        'title': 'Needs Repair',
        'subtitle': 'Degraded Mode',
        'color': AppTheme.statusMaintenance,
        'icon': Icons.warning_rounded,
      },
      {
        'title': 'Warning',
        'subtitle': 'Precautionary',
        'color': AppTheme.tealAccent,
        'icon': Icons.info_outline_rounded,
      },
    ];

    return Row(
      children: severities.map((item) {
        final title = item['title'] as String;
        final subtitle = item['subtitle'] as String;
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;
        final isSelected = _selectedSeverity == title;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: item != severities.last ? 8.0 : 0.0),
            child: InkWell(
              onTap: () => setState(() => _selectedSeverity = title),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(20) : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon, color: isSelected ? color : AppTheme.textMuted, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: isSelected ? color : AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return ChoiceChip(
          label: Text(cat),
          selected: isSelected,
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
          selectedColor: AppTheme.primaryBlue,
          backgroundColor: AppTheme.surfaceWhite,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
          ),
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedCategory = cat);
            }
          },
        );
      }).toList(),
    );
  }
}
