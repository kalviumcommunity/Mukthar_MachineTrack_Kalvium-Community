import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';

/// Comprehensive details screen for viewing factory activity records (Breakdowns, Maintenance, and Inspections).
class RecordDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? recordData;

  const RecordDetailsScreen({super.key, this.recordData});

  bool get isBreakdown =>
      (recordData?['recordType'] ?? 'Breakdown').toString().toLowerCase() == 'breakdown';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
      case 'resolved':
      case 'good':
        return AppTheme.statusRunning;
      case 'needs repair':
      case 'warning':
      case 'in progress':
      case 'maintenance':
        return AppTheme.statusMaintenance;
      case 'critical':
      case 'failed':
      case 'unresolved':
      case 'breakdown':
        return AppTheme.statusBreakdown;
      default:
        return AppTheme.statusIdle;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
      case 'resolved':
      case 'good':
        return Icons.check_circle_rounded;
      case 'needs repair':
      case 'warning':
      case 'in progress':
      case 'maintenance':
        return Icons.build_circle_rounded;
      case 'critical':
      case 'failed':
      case 'unresolved':
      case 'breakdown':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = recordData ?? {};
    final id = data['id'] ?? 'REC-2026-101';
    final title = data['title'] ?? 'Hydraulic Fluid Pressure Drop';
    final machineName = data['machineName'] ?? 'Hydraulic Press 500T';
    final machineCode = data['machineCode'] ?? 'PRESS-500T-04';
    final machineLocation = data['machineLocation'] ?? 'Zone A - Heavy Stamping';
    final recordType = data['recordType'] ?? (isBreakdown ? 'Breakdown' : 'Inspection');
    final status = data['status'] ?? 'Critical';
    final timestamp = data['timestamp'] ?? '10:45 AM Today';
    final description = data['description'] ??
        'Fluid line leak detected near main cylinder valve during morning shift operation. Immediate maintenance required to prevent pressure seal rupture.';
    final reportedBy = data['reportedBy'] ?? 'Mukthar (Lead Tech)';
    final shift = data['shift'] ?? 'Shift #1 • Plant Floor A';
    final priority = data['priority'] ?? (status.toLowerCase() == 'critical' ? 'High / Urgent' : 'Medium');
    final affectedComponent = data['component'] ?? 'Hydraulic Valve & Pressure Seal';

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final typeColor = isBreakdown ? AppTheme.statusBreakdown : AppTheme.secondaryBlue;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('$recordType Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exporting report for $id...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: typeColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                recordType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: typeColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              id,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withAlpha(80)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.precision_manufacturing_rounded,
                          size: 16,
                          color: AppTheme.secondaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          machineName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$machineCode • $machineLocation',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Incident / Audit Metadata
              const Text(
                'Log Specifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _buildSpecRow(Icons.schedule_rounded, 'Logged Timestamp', timestamp),
                    const Divider(height: 18, color: AppTheme.borderLight),
                    _buildSpecRow(Icons.person_outline_rounded, 'Reported By', reportedBy),
                    const Divider(height: 18, color: AppTheme.borderLight),
                    _buildSpecRow(Icons.access_time_rounded, 'Active Shift', shift),
                    const Divider(height: 18, color: AppTheme.borderLight),
                    _buildSpecRow(Icons.flag_outlined, 'Priority Level', priority),
                    if (isBreakdown) ...[
                      const Divider(height: 18, color: AppTheme.borderLight),
                      _buildSpecRow(Icons.build_outlined, 'Affected Subsystem', affectedComponent),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description & Remarks
              const Text(
                'Incident Details & Observations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Recommended Remediation Actions
              const Text(
                'Remediation Protocol',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _buildActionItem(
                      step: '1',
                      title: isBreakdown ? 'Isolate Equipment Power' : 'Verify Calibration Certificate',
                      desc: isBreakdown
                          ? 'Tag out hydraulic valve breaker on substation box B-4.'
                          : 'Ensure measurement gauges are stamped for current quarter.',
                      isDone: true,
                    ),
                    const Divider(height: 16, color: AppTheme.borderLight),
                    _buildActionItem(
                      step: '2',
                      title: isBreakdown ? 'Replace Pressure Seals' : 'Conduct Fluid Leak Check',
                      desc: isBreakdown
                          ? 'Obtain OEM seal kit #SK-449 from plant storage zone 2.'
                          : 'Inspect all joints and fittings under steady operating load.',
                      isDone: !isBreakdown,
                    ),
                    const Divider(height: 16, color: AppTheme.borderLight),
                    _buildActionItem(
                      step: '3',
                      title: isBreakdown ? 'Post-Repair Pressure Verification' : 'Log Shift Verification Sign-Off',
                      desc: isBreakdown
                          ? 'Run cycle pressure test at 350 bar for 10 minutes.'
                          : 'Submit checklist signature to lead supervisor.',
                      isDone: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Primary Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: isBreakdown ? 'Update Status' : 'Log New Inspection',
                      icon: isBreakdown ? Icons.published_with_changes_rounded : Icons.add_task_rounded,
                      onPressed: () {
                        if (isBreakdown) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Status update logged to shift records!'),
                              backgroundColor: AppTheme.statusRunning,
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, AppRoutes.newInspection);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Return to Records',
                isOutlined: true,
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required String step,
    required String title,
    required String desc,
    required bool isDone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? AppTheme.statusRunning : AppTheme.primaryBlue.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Text(
                    step,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDone ? AppTheme.textPrimary : AppTheme.textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
