// lib/widgets/summary/summary_controls_widget.dart
import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/typography.dart';

enum SummaryPeriod { daily, weekly, monthly }

class SummaryControlsWidget extends StatelessWidget {
  final SummaryPeriod currentPeriod;
  final Function(SummaryPeriod) onPeriodChanged;
  final VoidCallback onExport;
  final bool isExporting;

  const SummaryControlsWidget({
    super.key,
    required this.currentPeriod,
    required this.onPeriodChanged,
    required this.onExport,
    this.isExporting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Period Switcher
          Expanded(
            child: _buildPeriodSwitcher(),
          ),
          
          const SizedBox(width: 16),
          
          // Export Button (Icon Only)
          _buildExportIconButton(),
        ],
      ),
    );
  }

  Widget _buildPeriodSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: SummaryPeriod.values.map((period) {
          final isSelected = period == currentPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getPeriodIcon(period),
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getPeriodLabel(period),
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExportIconButton() {
    return Container(
      width: 48, // Fixed square size
      height: 48, // Fixed square size
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isExporting ? null : onExport,
          child: Center(
            child: isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.file_download_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getPeriodIcon(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return Icons.today;
      case SummaryPeriod.weekly:
        return Icons.view_week;
      case SummaryPeriod.monthly:
        return Icons.calendar_month;
    }
  }

  String _getPeriodLabel(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return 'Daily';
      case SummaryPeriod.weekly:
        return 'Weekly';
      case SummaryPeriod.monthly:
        return 'Monthly';
    }
  }
}