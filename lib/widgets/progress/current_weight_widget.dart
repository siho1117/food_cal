import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
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
      
      // Get current entry
      _currentEntry = entries.isNotEmpty ? entries.first : null;
      
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
      // Use the standard edit button helper
      trailing: MasterWidget.createEditButton(
        onPressed: _showWeightEntryDialog,
        color: textColor,
      ),
      // Empty state is also tappable to add first weight
      isEmpty: _currentEntry == null,
      child: _currentEntry == null 
          ? InkWell(
              onTap: _showWeightEntryDialog,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monitor_weight_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to record your weight',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : InkWell(
              onTap: _showWeightEntryDialog, // Allow tapping anywhere on the widget
              child: Padding(
                // Reduced vertical padding to 8px
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Weight value with unit
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          // Current weight value - same size as BMI
                          Text(
                            _getFormattedWeight(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          
                          // Units - smaller size
                          Text(
                            _isMetric ? ' kg' : ' lbs',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      
                      // Last updated text - small and subtle
                      const SizedBox(height: 4),
                      Text(
                        _getLastUpdatedText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  // Format the weight value based on metric/imperial
  String _getFormattedWeight() {
    if (_currentEntry == null) return '0.0';
    
    // Display either current weight (metric) or converted to imperial
    final double displayWeight = _isMetric ? 
      _currentEntry!.weight : 
      _currentEntry!.weight * 2.20462;
    
    return displayWeight.toStringAsFixed(1);
  }
  
  // Format the last updated text
  String _getLastUpdatedText() {
    if (_currentEntry == null) return '';
    
    final now = DateTime.now();
    final entryDate = _currentEntry!.timestamp;
    final difference = now.difference(entryDate);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${entryDate.day}/${entryDate.month}/${entryDate.year}';
    }
  }
}