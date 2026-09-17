import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Reusable card component for displaying machine inspection and breakdown records.
class RecordCard extends StatelessWidget {
  final String title;
  final String machineName;
  final String recordType; // 'Inspection' or 'Breakdown'
  final String status; // 'Passed', 'Needs Repair', 'Critical', 'Pending'
  final String timestamp;
  final String description;
  final String reportedBy;
  final VoidCallback? onTap;

  const RecordCard({
    super.key,
    required this.title,
    required this.machineName,
    required this.recordType,
    required this.status,
    required this.timestamp,
    required this.description,
    required this.reportedBy,
    this.onTap,
  });

  bool get isBreakdown => recordType.toLowerCase() == 'breakdown';

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'passed':
      case 'resolved':
      case 'good':
        return AppTheme.statusRunning;
      case 'needs repair':
      case 'warning':
      case 'in progress':
        return AppTheme.statusMaintenance;
      case 'critical':
      case 'failed':
      case 'unresolved':
        return AppTheme.statusBreakdown;
      default:
        return AppTheme.statusIdle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final typeBgColor = isBreakdown
        ? AppTheme.statusBreakdown.withAlpha(15)
        : AppTheme.secondaryBlue.withAlpha(15);
    final typeIconColor = isBreakdown ? AppTheme.statusBreakdown : AppTheme.secondaryBlue;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Type Icon, Title, Type Chip & Status Chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: typeBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isBreakdown ? Icons.report_problem_rounded : Icons.fact_check_rounded,
                      color: typeIconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: typeBgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                recordType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: typeIconColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              timestamp,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Machine name & details
              Row(
                children: [
                  const Icon(
                    Icons.precision_manufacturing_rounded,
                    size: 15,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    machineName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Short description preview
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.borderLight),
              const SizedBox(height: 10),
              // Reporter footer
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 15,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Logged by $reportedBy',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
