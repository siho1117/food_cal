import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/widgets/master_widget.dart';
import '../../data/models/weight_entry.dart';
import '../../data/repositories/user_repository.dart';
import '../../widgets/settings/weight_entry_dialog.dart';

class CurrentWeightWidget extends StatefulWidget {
  final Function() onWeightUpdated;

  const CurrentWeightWidget({
    Key? key,
    required this.onWeightUpdated,
  }) : super(key: key);

  @override
  State<CurrentWeightWidget> createState() => _CurrentWeightWidgetState();
}

class _CurrentWeightWidgetState extends State<CurrentWeightWidget> {
  final UserRepository _userRepository = UserRepository();
  
  bool _isLoading = true;
  bool _isMetric = true;
  WeightEntry? _currentEntry;
  WeightEntry? _previousEntry;
  bool _hasWeightToday = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Load user profile for unit preference
      final userProfile = await _userRepository.getUserProfile();
      
      // Get weight entries
      final entries = await _userRepository.getWeightEntries();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Check if today already has an entry
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      _hasWeightToday = entries.any((entry) => 
        entry.timestamp.year == todayDate.year && 
        entry.timestamp.month == todayDate.month && 
        entry.timestamp.day == todayDate.day
      );
      
      // Get current and previous entries
      _currentEntry = entries.isNotEmpty ? entries.first : null;
      _previousEntry = entries.length > 1 ? entries[1] : null;
      
      if (mounted) {
        setState(() {
          _isMetric = userProfile?.isMetric ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading weight data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showWeightEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => WeightEntryDialog(
        initialWeight: _currentEntry?.weight,
        isMetric: _isMetric,
        onWeightSaved: (weight, isMetric) async {
          // Create entry for today
          final entry = WeightEntry.create(weight: weight);
          await _userRepository.addWeightEntry(entry);
          
          // Refresh data
          await _loadData();
          
          // Notify parent
          widget.onWeightUpdated();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use standard text color
    final textColor = AppTheme.textDark;
    
    // Use MasterWidget with standardized header and edit button
    return MasterWidget(
      title: 'Current Weight',
      icon: Icons.monitor_weight_rounded,
      textColor: textColor,
      iconColor: textColor,
      isLoading: _isLoading,
      // Use the standard edit button helper with matching color
      trailing: MasterWidget.createEditButton(
        onPressed: _showWeightEntryDialog,
        color: textColor,
      ),
      child: _currentEntry == null 
          ? _buildEmptyState() 
          : _buildWeightContent(),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      height: 65, // Fixed height to ensure consistency
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No weight data recorded',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the pencil icon to record your weight',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeightContent() {
    // Display either current weight (metric) or converted to imperial
    final double displayWeight = _isMetric ? 
      _currentEntry!.weight : 
      _currentEntry!.weight * 2.20462;
    
    // Calculate weight change
    final bool hasChange = _previousEntry != null;
    final double weightDiff = hasChange ? 
      _currentEntry!.weight - _previousEntry!.weight : 0;
    
    // Format the weight change
    final String changePrefix = weightDiff > 0 ? '+' : '';
    final String changeText = hasChange ? 
      '$changePrefix${weightDiff.toStringAsFixed(1)} ${_isMetric ? 'kg' : 'lbs'}' : '';
    
    // Color for change
    final Color changeColor = weightDiff > 0 ? 
      Colors.orange : (weightDiff < 0 ? Colors.green : Colors.grey);
    
    return Container(
      height: 65, // Fixed height to match empty state
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Weight display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current weight value
              Text(
                '${displayWeight.toStringAsFixed(1)} ${_isMetric ? 'kg' : 'lbs'}',
                style: AppTextStyles.getNumericStyle().copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              
              // Last recorded date
              Text(
                _getLastUpdatedText(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          // Weight change indicator (if exists)
          if (hasChange)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    weightDiff > 0 ? Icons.arrow_upward : 
                      (weightDiff < 0 ? Icons.arrow_downward : Icons.remove),
                    color: changeColor,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    changeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // Simple format for last updated text
  String _getLastUpdatedText() {
    if (_currentEntry == null) return '';
    
    final now = DateTime.now();
    final entryDate = _currentEntry!.timestamp;
    final difference = now.difference(entryDate);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${entryDate.day}/${entryDate.month}/${entryDate.year}';
    }
  }
}