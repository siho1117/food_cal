import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/weight_entry.dart';
import '../settings/weight_entry_dialog.dart';

class CurrentWeightWidget extends StatefulWidget {
  final double? initialWeight;
  final bool isMetric;
  final Function(double, bool) onWeightUpdated;

  const CurrentWeightWidget({
    Key? key,
    this.initialWeight,
    required this.isMetric,
    required this.onWeightUpdated,
  }) : super(key: key);

  @override
  State<CurrentWeightWidget> createState() => _CurrentWeightWidgetState();
}

class _CurrentWeightWidgetState extends State<CurrentWeightWidget> {
  final UserRepository _repository = UserRepository();
  bool _isLoading = true;
  double? _currentWeight;
  bool _isMetric = true;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.isMetric;
    _loadLatestWeight();
  }

  /// Load the latest weight entry from the repository
  Future<void> _loadLatestWeight() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final latestEntry = await _repository.getLatestWeightEntry();
      
      if (mounted) {
        setState(() {
          if (latestEntry != null) {
            _currentWeight = latestEntry.weight;
            _lastUpdated = latestEntry.timestamp;
          } else {
            _currentWeight = widget.initialWeight;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading weight: $e');
      if (mounted) {
        setState(() {
          _currentWeight = widget.initialWeight;
          _isLoading = false;
        });
      }
    }
  }

  /// Format the date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Format as date
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Show the weight entry dialog
  void _showWeightEntryDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => WeightEntryDialog(
        initialWeight: _currentWeight,
        isMetric: _isMetric,
        onWeightSaved: (weight, isMetric) async {
          // Create new weight entry with current timestamp
          final entry = WeightEntry.create(weight: weight);
          
          // Save the weight entry
          await _repository.addWeightEntry(entry);
          
          // Update state
          setState(() {
            _currentWeight = weight;
            _isMetric = isMetric;
            _lastUpdated = DateTime.now();
          });
          
          // Notify parent component
          widget.onWeightUpdated(weight, isMetric);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Weight',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontSize: Dimensions.getTextSize(
                    context, 
                    size: TextSize.medium
                  ),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: _showWeightEntryDialog,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey[600],
              ),
            ],
          ),
          
          SizedBox(height: Dimensions.s),
          
          // Weight value or loading indicator
          _isLoading
              ? const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _currentWeight == null
                  ? Center(
                      child: Text(
                        'No weight data',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _currentWeight!.toStringAsFixed(1),
                          style: AppTextStyles.getNumericStyle().copyWith(
                            fontSize: 34, // Using direct value instead of WidgetUIStandards
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        SizedBox(width: Dimensions.xxs),
                        Text(
                          _isMetric ? 'kg' : 'lbs',
                          style: AppTextStyles.getNumericStyle().copyWith(
                            fontSize: 16, // Using direct value instead of WidgetUIStandards
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryBlue.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    
          // Last updated date - Only show if there's an update timestamp
          if (_lastUpdated != null) ...[
            SizedBox(height: Dimensions.xxs),
            Text(
              'Last updated: ${_formatDate(_lastUpdated!)}',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 13, // Using direct value instead of WidgetUIStandards
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}