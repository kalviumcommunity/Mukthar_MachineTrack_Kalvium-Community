import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';

/// Screen displaying the complete breakdown and audit trail of a specific machine inspection.
class InspectionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? inspectionData;

  const InspectionDetailsScreen({super.key, this.inspectionData});

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'passed':
      case 'good':
      case 'operational':
        return AppTheme.statusRunning;
      case 'needs repair':
      case 'warning':
      case 'maintenance':
        return AppTheme.statusMaintenance;
      case 'critical':
      case 'failed':
        return AppTheme.statusBreakdown;
      default:
        return AppTheme.statusIdle;
    }
  }

  IconData _getConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'passed':
      case 'good':
      case 'operational':
        return Icons.check_circle_rounded;
      case 'needs repair':
      case 'warning':
      case 'maintenance':
        return Icons.build_circle_rounded;
      case 'critical':
      case 'failed':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = inspectionData ?? {};
    final id = data['id'] ?? 'INS-2026-0982';
    final machineName = data['machineName'] ?? 'Hydraulic Press 500T';
    final machineCode = data['machineCode'] ?? 'PRESS-500T-04';
    final machineLocation = data['machineLocation'] ?? 'Zone A - Heavy Stamping';
    final date = data['date'] ?? data['timestamp'] ?? '22 Sep 2026';
    final time = data['time'] ?? '10:30 AM';
    final condition = data['condition'] ?? data['status'] ?? 'Passed';
    final notes = data['notes'] ?? data['description'] ?? 'Regular shift inspection verified in order.';
    final inspector = data['inspector'] ?? data['reportedBy'] ?? 'Mukthar (Lead Tech)';
    final shift = data['shift'] ?? 'Shift #1 • Plant Floor A';

    final Map<String, bool> checklist = data['checklist'] is Map
        ? Map<String, bool>.from(data['checklist'] as Map)
        : {
            'Power & electrical systems operational': true,
            'Fluid, hydraulic & lubricant levels adequate': true,
            'Safety guards & emergency stops functional': true,
            'No abnormal vibration or mechanical noise': true,
            'Operating temperature within normal range': true,
            'Sensors, gauges & calibration verified': true,
          };

    final conditionColor = _getConditionColor(condition);
    final conditionIcon = _getConditionIcon(condition);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Inspection Details'),
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
                  content: Text('Exporting report for $id'),
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
              // Header Card with ID and Status
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            id,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: conditionColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: conditionColor.withAlpha(80)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(conditionIcon, size: 14, color: conditionColor),
                              const SizedBox(width: 4),
                              Text(
                                condition,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: conditionColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      machineName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
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

              // Inspection Meta Details
              const Text(
                'Audit Metadata',
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
                    _buildMetaRow(Icons.event_note_rounded, 'Date & Time', '$date at $time'),
                    const Divider(height: 18, color: AppTheme.borderLight),
                    _buildMetaRow(Icons.person_outline_rounded, 'Inspector', inspector),
                    const Divider(height: 18, color: AppTheme.borderLight),
                    _buildMetaRow(Icons.access_time_rounded, 'Shift Session', shift),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Checklist Items Verification
              const Text(
                'Checklist Verification',
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
                  children: checklist.entries.map((entry) {
                    final isPassed = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isPassed ? AppTheme.statusRunning : AppTheme.statusBreakdown,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPassed
                                  ? AppTheme.statusRunning.withAlpha(15)
                                  : AppTheme.statusBreakdown.withAlpha(15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPassed ? 'PASSED' : 'FLAGGED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isPassed ? AppTheme.statusRunning : AppTheme.statusBreakdown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Inspector Notes
              const Text(
                'Inspector Notes & Observations',
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
                  notes,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Back / Return Button
              CustomButton(
                text: 'Return to Dashboard',
                icon: Icons.dashboard_rounded,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.main,
                    (route) => false,
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

  Widget _buildMetaRow(IconData icon, String label, String value) {
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
