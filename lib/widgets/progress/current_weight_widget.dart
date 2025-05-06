import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
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
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.02),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monitor_weight_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current Weight',
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.primaryBlue.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: _loadData,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Weight display
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current weight
                      Text(
                        _currentEntry != null 
                            ? _currentEntry!.formattedWeight(_isMetric)
                            : 'No data',
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      
                      // Weight change
                      if (_currentEntry != null && _previousEntry != null)
                        _buildWeightChangeIndicator()
                    ],
                  ),
                ),
                
                // Add weight button
                ElevatedButton.icon(
                  icon: Icon(
                    _hasWeightToday ? Icons.edit : Icons.add,
                    size: 16,
                  ),
                  label: Text(_hasWeightToday ? 'Update' : 'Add Weight'),
                  onPressed: _showWeightEntryDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, 
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeightChangeIndicator() {
    if (_currentEntry == null || _previousEntry == null) return const SizedBox.shrink();
    
    final weightDiff = _currentEntry!.weight - _previousEntry!.weight;
    final absWeightDiff = weightDiff.abs();
    
    // Format the difference value based on units
    final diffText = _isMetric
        ? '${absWeightDiff.toStringAsFixed(1)} kg'
        : '${(absWeightDiff * 2.20462).toStringAsFixed(1)} lbs';
        
    // Determine direction and color
    final isGain = weightDiff > 0;
    final isLoss = weightDiff < 0;
    final noChange = weightDiff == 0;
    
    Color indicatorColor;
    IconData indicatorIcon;
    String indicatorText;
    
    if (isGain) {
      indicatorColor = Colors.orange;
      indicatorIcon = Icons.arrow_upward;
      indicatorText = '$diffText since last entry';
    } else if (isLoss) {
      indicatorColor = Colors.green;
      indicatorIcon = Icons.arrow_downward;
      indicatorText = '$diffText since last entry';
    } else {
      indicatorColor = Colors.grey;
      indicatorIcon = Icons.remove;
      indicatorText = 'No change since last entry';
    }
    
    // Build the indicator
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            indicatorIcon,
            color: indicatorColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            indicatorText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: indicatorColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}