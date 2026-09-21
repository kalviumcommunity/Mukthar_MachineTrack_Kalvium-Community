import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';

/// Screen displayed immediately following a successfully submitted machine inspection.
class InspectionSuccessScreen extends StatelessWidget {
  final Map<String, dynamic>? inspectionData;

  const InspectionSuccessScreen({super.key, this.inspectionData});

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
    final date = data['date'] ?? '22/09/2026';
    final time = data['time'] ?? '12:30 PM';
    final condition = data['condition'] ?? 'Passed';
    final inspector = data['inspector'] ?? 'Mukthar (Lead Tech)';
    final shift = data['shift'] ?? 'Shift #1 (Plant Floor A)';

    final checklist = data['checklist'] as Map<String, bool>? ?? {};
    final passedCount = checklist.values.where((v) => v).length;
    final totalCount = checklist.isNotEmpty ? checklist.length : 6;

    final conditionColor = _getConditionColor(condition);
    final conditionIcon = _getConditionIcon(condition);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Success Badge Animation / Circle
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.statusRunning.withAlpha(25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.statusRunning.withAlpha(80),
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: AppTheme.statusRunning,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Success Title & Subtitle
                const Text(
                  'Inspection Logged Successfully!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Record ID: $id has been added to active shift logs.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Machine Info Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.precision_manufacturing_rounded,
                              color: AppTheme.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  machineName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$machineCode • $machineLocation',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w500,
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

                      // Key Summary Metrics
                      _buildSummaryRow(
                        label: 'Overall Condition',
                        valueWidget: Container(
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
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        label: 'Checklist Verification',
                        value: '$passedCount / $totalCount Passed',
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        label: 'Inspection Timestamp',
                        value: '$date at $time',
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        label: 'Logged By Inspector',
                        value: inspector,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        label: 'Shift Session',
                        value: shift,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Primary CTA: View Details
                CustomButton(
                  text: 'View Inspection Details',
                  icon: Icons.receipt_long_rounded,
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.inspectionDetails,
                      arguments: data,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Secondary CTA: Return to Main Dashboard
                CustomButton(
                  text: 'Back to Dashboard',
                  isOutlined: true,
                  icon: Icons.home_rounded,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.main,
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Tertiary: Log Another Inspection
                TextButton.icon(
                  icon: const Icon(Icons.add_task_rounded, size: 18, color: AppTheme.secondaryBlue),
                  label: const Text(
                    'Log Another Inspection',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondaryBlue,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.newInspection,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (valueWidget != null)
          valueWidget
        else
          Text(
            value ?? '',
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
