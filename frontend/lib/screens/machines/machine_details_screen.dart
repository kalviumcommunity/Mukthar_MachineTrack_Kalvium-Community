import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/record_card.dart';

/// Machine Details Screen displaying comprehensive machine specs & recent activity.
class MachineDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? machineData;

  const MachineDetailsScreen({super.key, this.machineData});

  @override
  Widget build(BuildContext context) {
    final name = machineData?['name'] ?? 'Hydraulic Press 500T';
    final code = machineData?['code'] ?? 'PRESS-500T-04';
    final location = machineData?['location'] ?? 'Zone A - Heavy Stamping';
    final status = machineData?['status'] ?? 'Breakdown';
    final model = machineData?['model'] ?? 'StamperPro 500';
    final serialNumber = machineData?['serialNumber'] ?? 'SN-99812-A';
    final assignedTech = machineData?['assignedTech'] ?? 'Mukthar';

    Color statusColor;
    switch (status.toString().toLowerCase()) {
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
                    _buildSpecRow('Installation Date', '12 Jan 2024'),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Log inspection trigger for this machine'),
                          ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report breakdown trigger for this machine'),
                            backgroundColor: AppTheme.statusBreakdown,
                          ),
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
