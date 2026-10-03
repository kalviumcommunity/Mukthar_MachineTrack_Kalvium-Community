import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/machine.dart';
import '../../services/machine_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/record_card.dart';

/// Machine Details Screen displaying comprehensive machine specs & recent activity backed by Firestore.
class MachineDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? machineData;
  final String? machineId;
  final MachineService? machineService;

  const MachineDetailsScreen({
    super.key,
    this.machineData,
    this.machineId,
    this.machineService,
  });

  @override
  State<MachineDetailsScreen> createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen> {
  late final MachineService _machineService;
  StreamSubscription<Machine?>? _machineSubscription;
  Machine? _liveMachine;
  bool _isLoading = false;

  String get _machineId =>
      widget.machineId ??
      widget.machineData?['id']?.toString() ??
      '';

  @override
  void initState() {
    super.initState();
    _machineService = widget.machineService ?? MachineService();
    if (widget.machineData != null) {
      _liveMachine = Machine.fromMap(widget.machineData!, id: _machineId);
    }
    _subscribeToMachine();
  }

  void _subscribeToMachine() {
    if (_machineId.isEmpty || !_machineService.isAvailable) return;

    if (_liveMachine == null) {
      setState(() => _isLoading = true);
    }

    _machineSubscription = _machineService.getMachineStream(_machineId).listen(
      (machine) {
        if (mounted) {
          setState(() {
            if (machine != null) {
              _liveMachine = machine;
            }
            _isLoading = false;
          });
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _machineSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _liveMachine == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('Machine Specifications'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    final machine = _liveMachine;
    final name = (machine != null && machine.name.isNotEmpty)
        ? machine.name
        : (widget.machineData?['name']?.toString() ?? 'Hydraulic Press 500T');
    final code = (machine != null && machine.code.isNotEmpty)
        ? machine.code
        : (widget.machineData?['code']?.toString() ?? 'PRESS-500T-04');
    final location = (machine != null && machine.location.isNotEmpty)
        ? machine.location
        : (widget.machineData?['location']?.toString() ?? 'Zone A - Heavy Stamping');
    final status = (machine != null && machine.status.isNotEmpty)
        ? machine.status
        : (widget.machineData?['status']?.toString() ?? 'Breakdown');
    final model = (machine?.model != null && machine!.model!.isNotEmpty)
        ? machine.model!
        : (widget.machineData?['model']?.toString() ?? 'StamperPro 500');
    final serialNumber = (machine?.serialNumber != null && machine!.serialNumber!.isNotEmpty)
        ? machine.serialNumber!
        : (widget.machineData?['serialNumber']?.toString() ?? 'SN-99812-A');
    final assignedTech = (machine?.assignedTech != null && machine!.assignedTech!.isNotEmpty)
        ? machine.assignedTech!
        : (widget.machineData?['assignedTech']?.toString() ?? 'Mukthar');
    final installationDate = (machine?.installationDate != null && machine!.installationDate!.isNotEmpty)
        ? machine.installationDate!
        : (widget.machineData?['installationDate']?.toString() ?? '12 Jan 2024');

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'running':
      case 'active':
        statusColor = AppTheme.statusRunning;
        break;
      case 'maintenance':
        statusColor = AppTheme.statusMaintenance;
        break;
      case 'breakdown':
        statusColor = AppTheme.statusBreakdown;
        break;
      default:
        statusColor = AppTheme.statusIdle;
    }

    final currentArgs = machine?.toRouteMap() ??
        widget.machineData ??
        {
          'id': _machineId.isNotEmpty ? _machineId : '1',
          'name': name,
          'code': code,
          'location': location,
          'status': status,
          'model': model,
          'serialNumber': serialNumber,
          'assignedTech': assignedTech,
          'installationDate': installationDate,
        };

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Machine Specifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withAlpha(15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.precision_manufacturing_rounded,
                            color: AppTheme.primaryBlue,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ID: $code',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withAlpha(80)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Technical Specifications Section
              const Text(
                'Technical Details',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _buildSpecRow('Model Designation', model),
                    const Divider(height: 20, color: AppTheme.borderLight),
                    _buildSpecRow('Serial Number', serialNumber),
                    const Divider(height: 20, color: AppTheme.borderLight),
                    _buildSpecRow('Assigned Lead Tech', assignedTech),
                    const Divider(height: 20, color: AppTheme.borderLight),
                    _buildSpecRow('Installation Date', installationDate),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Log Inspection',
                      icon: Icons.add_task_rounded,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.newInspection,
                          arguments: currentArgs,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Report Fault',
                      icon: Icons.warning_amber_rounded,
                      backgroundColor: AppTheme.statusBreakdown,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.reportBreakdown,
                          arguments: currentArgs,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Logs for this Machine
              const Text(
                'Machine History',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              RecordCard(
                title: 'Hydraulic Pressure Failure',
                machineName: name,
                recordType: 'Breakdown',
                status: 'Critical',
                timestamp: '10:45 AM Today',
                description:
                    'Fluid line pressure drop recorded. Main pump valve requires seal replacement.',
                reportedBy: 'Mukthar',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.recordDetails,
                    arguments: {
                      'id': 'REC-2026-101',
                      'title': 'Hydraulic Pressure Failure',
                      'machineName': name,
                      'machineCode': code,
                      'machineLocation': location,
                      'recordType': 'Breakdown',
                      'status': 'Critical',
                      'timestamp': '10:45 AM Today',
                      'description':
                          'Fluid line pressure drop recorded. Main pump valve requires seal replacement.',
                      'reportedBy': 'Mukthar (Lead Tech)',
                      'shift': 'Shift #1 • Plant Floor A',
                      'priority': 'Critical / Urgent',
                      'component': 'Main Hydraulic Pump Valve',
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              RecordCard(
                title: 'Weekly Preventive Maintenance',
                machineName: name,
                recordType: 'Inspection',
                status: 'Passed',
                timestamp: '3 Days Ago',
                description: 'Full hydraulic check, oil topped up, filter cleaned.',
                reportedBy: 'Steve',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.inspectionDetails,
                    arguments: {
                      'id': 'INS-2026-0811',
                      'machineName': name,
                      'machineCode': code,
                      'machineLocation': location,
                      'date': '19 Sep 2026',
                      'time': '09:15 AM',
                      'condition': 'Passed',
                      'notes': 'Full hydraulic check, oil topped up, filter cleaned.',
                      'reportedBy': 'Steve (Maintenance Tech)',
                      'shift': 'Shift #2',
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

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
