import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';

/// Screen for creating and recording a new machine safety and maintenance inspection.
class NewInspectionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialMachine;

  const NewInspectionScreen({super.key, this.initialMachine});

  @override
  State<NewInspectionScreen> createState() => _NewInspectionScreenState();
}

class _NewInspectionScreenState extends State<NewInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();

  // Sample fleet list
  final List<Map<String, String>> _machineOptions = const [
    {
      'id': '1',
      'name': 'Hydraulic Press 500T',
      'code': 'PRESS-500T-04',
      'location': 'Zone A - Heavy Stamping',
      'status': 'Breakdown',
      'model': 'StamperPro 500',
    },
    {
      'id': '2',
      'name': 'CNC Lathe Machine #02',
      'code': 'CNC-LTH-02',
      'location': 'Zone B - Machining Cell',
      'status': 'Running',
      'model': 'LatheMatic 3000',
    },
    {
      'id': '3',
      'name': 'Automated Conveyor Belt #05',
      'code': 'CNV-BELT-05',
      'location': 'Zone C - Packaging Line',
      'status': 'Maintenance',
      'model': 'ConveyX Ultra',
    },
    {
      'id': '4',
      'name': 'Robotic Welding Arm Alpha',
      'code': 'ROB-WLD-01',
      'location': 'Zone A - Welding Bay',
      'status': 'Running',
      'model': 'WeldBot 900',
    },
    {
      'id': '5',
      'name': 'Injection Molding Unit #03',
      'code': 'INJ-MLD-03',
      'location': 'Zone D - Plastics Sector',
      'status': 'Idle',
      'model': 'MoldMaster Pro',
    },
  ];

  Map<String, String>? _selectedMachine;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCondition = 'Passed'; // 'Passed', 'Needs Repair', 'Critical'
  bool _isSubmitting = false;

  // Inspection Checklist Items
  final Map<String, bool> _checklist = {
    'Power & electrical systems operational': true,
    'Fluid, hydraulic & lubricant levels adequate': true,
    'Safety guards & emergency stops functional': true,
    'No abnormal vibration or mechanical noise': true,
    'Operating temperature within normal range': true,
    'Sensors, gauges & calibration verified': true,
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialMachine != null) {
      final initialId = widget.initialMachine!['id']?.toString();
      final initialName = widget.initialMachine!['name']?.toString();
      final match = _machineOptions.firstWhere(
        (m) => m['id'] == initialId || m['name'] == initialName,
        orElse: () => {
          'id': widget.initialMachine!['id']?.toString() ?? '1',
          'name': widget.initialMachine!['name']?.toString() ?? 'Selected Machine',
          'code': widget.initialMachine!['code']?.toString() ?? 'M-001',
          'location': widget.initialMachine!['location']?.toString() ?? 'Plant Floor',
          'status': widget.initialMachine!['status']?.toString() ?? 'Running',
          'model': widget.initialMachine!['model']?.toString() ?? 'Standard Model',
        },
      );
      _selectedMachine = match;
    } else {
      _selectedMachine = _machineOptions.first;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleAllChecklist(bool value) {
    setState(() {
      for (final key in _checklist.keys) {
        _checklist[key] = value;
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMachine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a machine to inspect'),
          backgroundColor: AppTheme.statusBreakdown,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate network submission delay
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // Format formatted date and time
    final formattedDate =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    final formattedTime = _selectedTime.format(context);
    final inspectionId = 'INS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final inspectionPayload = {
      'id': inspectionId,
      'machineId': _selectedMachine!['id'],
      'machineName': _selectedMachine!['name'],
      'machineCode': _selectedMachine!['code'],
      'machineLocation': _selectedMachine!['location'],
      'date': formattedDate,
      'time': formattedTime,
      'condition': _selectedCondition,
      'checklist': Map<String, bool>.from(_checklist),
      'notes': _notesController.text.trim().isEmpty
          ? 'Regular shift inspection verified in order.'
          : _notesController.text.trim(),
      'inspector': 'Mukthar (Lead Tech)',
      'shift': 'Shift #1 (08:00 - 16:00)',
      'createdTimestamp': 'Just now',
    };

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.inspectionSuccess,
      arguments: inspectionPayload,
    );
  }

  @override
  Widget build(BuildContext context) {
    final passedChecksCount = _checklist.values.where((v) => v).length;
    final totalChecksCount = _checklist.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('New Machine Inspection'),
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
                // Machine Selector Section
                _buildSectionLabel('Target Machine', Icons.precision_manufacturing_rounded),
                const SizedBox(height: 8),
                _buildMachineSelector(),
                const SizedBox(height: 20),

                // Date & Time Selection Cards
                _buildSectionLabel('Inspection Schedule', Icons.calendar_today_rounded),
                const SizedBox(height: 8),
                _buildDateTimePickers(),
                const SizedBox(height: 20),

                // Checklist Section
                _buildChecklistHeader(passedChecksCount, totalChecksCount),
                const SizedBox(height: 8),
                _buildChecklistCard(),
                const SizedBox(height: 20),

                // Machine Condition / Operational Status
                _buildSectionLabel('Overall Machine Condition', Icons.health_and_safety_rounded),
                const SizedBox(height: 8),
                _buildConditionSelector(),
                const SizedBox(height: 20),

                // Notes & Observations
                _buildSectionLabel('Inspector Notes & Remarks', Icons.edit_note_rounded),
                const SizedBox(height: 8),
                _buildNotesField(),
                const SizedBox(height: 24),

                // Submit Button
                CustomButton(
                  text: 'Submit Inspection Report',
                  icon: Icons.check_circle_outline_rounded,
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
                      color: AppTheme.primaryBlue.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 18,
                      color: AppTheme.primaryBlue,
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

  Widget _buildDateTimePickers() {
    final formattedDate =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    final formattedTime = _selectedTime.format(context);

    return Row(
      children: [
        // Date Picker Field
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded, size: 20, color: AppTheme.primaryBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
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
        // Time Picker Field
        Expanded(
          child: InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 20, color: AppTheme.primaryBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
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

  Widget _buildChecklistHeader(int passedCount, int totalCount) {
    final allChecked = passedCount == totalCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionLabel('Safety & Inspection Checklist', Icons.checklist_rounded),
        TextButton(
          onPressed: () => _toggleAllChecklist(!allChecked),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            allChecked ? 'Uncheck All' : 'Check All ($passedCount/$totalCount)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: _checklist.keys.map((key) {
          final isChecked = _checklist[key] ?? false;
          return Column(
            children: [
              CheckboxListTile(
                value: isChecked,
                activeColor: AppTheme.statusRunning,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                title: Text(
                  key,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isChecked ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppTheme.statusRunning.withAlpha(20)
                        : AppTheme.borderLight.withAlpha(80),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isChecked ? Icons.check_rounded : Icons.horizontal_rule_rounded,
                    size: 14,
                    color: isChecked ? AppTheme.statusRunning : AppTheme.textMuted,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _checklist[key] = val ?? false;
                  });
                },
              ),
              if (key != _checklist.keys.last)
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.borderLight),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConditionSelector() {
    final options = [
      {
        'title': 'Passed',
        'subtitle': 'Fully Operational',
        'color': AppTheme.statusRunning,
        'icon': Icons.check_circle_rounded,
      },
      {
        'title': 'Needs Repair',
        'subtitle': 'Maintenance Required',
        'color': AppTheme.statusMaintenance,
        'icon': Icons.build_circle_rounded,
      },
      {
        'title': 'Critical',
        'subtitle': 'Immediate Halt',
        'color': AppTheme.statusBreakdown,
        'icon': Icons.warning_rounded,
      },
    ];

    return Row(
      children: options.map((opt) {
        final title = opt['title'] as String;
        final subtitle = opt['subtitle'] as String;
        final color = opt['color'] as Color;
        final icon = opt['icon'] as IconData;
        final isSelected = _selectedCondition == title;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: opt != options.last ? 8.0 : 0.0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedCondition = title),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(25) : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? color : AppTheme.textMuted,
                      size: 22,
                    ),
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
                        fontWeight: FontWeight.w500,
                        color: isSelected ? color : AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: _selectedCondition == 'Passed'
                  ? 'Add any additional inspector comments, oil readings, or shift handoff notes (optional)...'
                  : 'Describe identified faults, abnormal sounds, or required replacement components (required)...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            validator: (value) {
              if (_selectedCondition != 'Passed' &&
                  (value == null || value.trim().length < 5)) {
                return 'Please provide detailed notes for condition $_selectedCondition';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textMuted),
                  SizedBox(width: 4),
                  Text(
                    'Inspector: Mukthar (Shift #1)',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              Text(
                'Plant Floor A',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted.withAlpha(200),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
