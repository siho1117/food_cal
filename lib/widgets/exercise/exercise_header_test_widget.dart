import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/widgets/master_widget.dart';
import '../../config/components/state_builder.dart';

/// A test widget for experimenting with the standardized header designs
class ExerciseHeaderTestWidget extends StatefulWidget {
  const ExerciseHeaderTestWidget({Key? key}) : super(key: key);

  @override
  State<ExerciseHeaderTestWidget> createState() => _ExerciseHeaderTestWidgetState();
}

class _ExerciseHeaderTestWidgetState extends State<ExerciseHeaderTestWidget> {
  // Test parameters
  int _widgetTypeIndex = 0;
  bool _showButton = true;
  bool _showErrorState = false;
  bool _showEmptyState = false;
  
  // Widget types to test
  final List<String> _widgetTypes = [
    'Standard',
    'Data Widget',
    'Metric Widget',
    'Progress Widget',
  ];
  
  // Button types to test
  final List<String> _buttonTypes = [
    'Edit Button',
    'Info Button',
    'No Button',
  ];
  
  int _buttonTypeIndex = 0;
  
  // Fixed color for title and icons
  final Color _titleColor = AppTheme.textDark;
  
  // Get current accent color
  Color _getCurrentAccentColor() {
    switch (_accentColorIndex) {
      case 0: return AppTheme.primaryBlue;
      case 1: return AppTheme.accentColor;
      case 2: return AppTheme.goldAccent;
      case 3: return AppTheme.coralAccent;
      default: return AppTheme.primaryBlue;
    }
  }
  
  // Accent color index
  int _accentColorIndex = 0;
  
  // Toggle widget type
  void _nextWidgetType() {
    setState(() {
      _widgetTypeIndex = (_widgetTypeIndex + 1) % _widgetTypes.length;
    });
  }
  
  // Toggle button type
  void _nextButtonType() {
    setState(() {
      _buttonTypeIndex = (_buttonTypeIndex + 1) % _buttonTypes.length;
    });
  }
  
  // Toggle accent color
  void _nextAccentColor() {
    setState(() {
      _accentColorIndex = (_accentColorIndex + 1) % 4;
    });
  }
  
  // Toggle error state
  void _toggleErrorState() {
    setState(() {
      _showErrorState = !_showErrorState;
      if (_showErrorState) {
        _showEmptyState = false;
      }
    });
  }
  
  // Toggle empty state
  void _toggleEmptyState() {
    setState(() {
      _showEmptyState = !_showEmptyState;
      if (_showEmptyState) {
        _showErrorState = false;
      }
    });
  }
  
  // Show info dialog when info button is tapped
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Information'),
        content: const Text(
          'This is a sample information dialog that would appear when the user taps the info button. '
          'It provides additional context about the widget\'s purpose or data.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
  
  // Get the appropriate button for the current button type
  Widget? _getButtonForType() {
    switch (_buttonTypeIndex) {
      case 0: // Edit Button
        return MasterWidget.createEditButton(
          onPressed: () => print('Edit button pressed'),
          color: _titleColor,
        );
      case 1: // Info Button
        return MasterWidget.createInfoButton(
          onPressed: _showInfoDialog,
          color: _titleColor,
        );
      case 2: // No Button
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The test widget using the standardized master_widget
        _buildTestWidget(),
        
        // Controls
        _buildControls(),
      ],
    );
  }
  
  // Build the appropriate test widget based on selected type
  Widget _buildTestWidget() {
    final Color accentColor = _getCurrentAccentColor();
    final Widget? trailingButton = _getButtonForType();
    
    // Handle error and empty states
    if (_showErrorState) {
      return MasterWidget(
        title: 'Exercise Header Test',
        icon: Icons.fitness_center,
        textColor: _titleColor,
        iconColor: _titleColor,
        trailing: trailingButton,
        hasError: true,
        errorMessage: 'This is a test error message to see how error states look with the new standardized header design.',
        onRetry: () {
          setState(() {
            _showErrorState = false;
          });
        },
        child: const SizedBox(),
      );
    }
    
    if (_showEmptyState) {
      return MasterWidget(
        title: 'Exercise Header Test',
        icon: Icons.fitness_center,
        textColor: _titleColor,
        iconColor: _titleColor,
        trailing: trailingButton,
        isEmpty: true,
        emptyMessage: 'No exercise data available. This message shows how empty states look with the standardized header design.',
        emptyIcon: Icons.directions_run,
        child: const SizedBox(),
      );
    }
    
    // Different widget types
    switch (_widgetTypeIndex) {
      case 1:
        return MasterWidget.dataWidget(
          title: 'Exercise Data',
          icon: Icons.fitness_center,
          textColor: _titleColor,
          iconColor: _titleColor,
          trailing: trailingButton,
          child: _buildSampleContent(accentColor),
        );
      case 2:
        return MasterWidget.metricWidget(
          title: 'Exercise Metric',
          icon: Icons.local_fire_department,
          textColor: _titleColor,
          iconColor: _titleColor,
          trailing: trailingButton,
          valueWidget: Center(
            child: Column(
              children: [
                Text(
                  '350',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                Text(
                  'calories',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      case 3:
        return MasterWidget.progressWidget(
          title: 'Exercise Progress',
          icon: Icons.directions_run,
          textColor: _titleColor,
          iconColor: _titleColor,
          progress: 0.65,
          progressText: '65% complete',
          progressColor: accentColor,
          trailing: trailingButton,
          child: _buildSampleContent(accentColor, height: 80),
        );
      case 0:
      default:
        return MasterWidget(
          title: 'Exercise Header Test',
          icon: Icons.speed,
          textColor: _titleColor,
          iconColor: _titleColor,
          trailing: trailingButton,
          child: _buildSampleContent(accentColor),
        );
    }
  }
  
  // Build sample content
  Widget _buildSampleContent(Color accentColor, {double height = 120}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: height,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _widgetTypeIndex == 2 
                        ? Icons.local_fire_department
                        : (_widgetTypeIndex == 3 
                            ? Icons.directions_run 
                            : Icons.fitness_center),
                    size: 32,
                    color: accentColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Standardized Header Design',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    'Testing with ${_widgetTypes[_widgetTypeIndex]} type',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Add a message explaining header changes
          StateBuilder.infoMessage(
            title: 'Header Design Updates',
            message: 'The standardized header maintains consistent height and spacing with/without button, ensuring uniform appearance across all widgets.',
            icon: Icons.lightbulb_outline,
            color: accentColor,
          ),
          
          // Add message about button types
          if (_buttonTypeIndex < 2)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: 16,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Using standardized ${_buttonTypes[_buttonTypeIndex]} that matches the header text color.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
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
  
  // Build control buttons
  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Header Design Controls',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Widget type control
              _buildControlButton(
                label: 'Widget: ${_widgetTypes[_widgetTypeIndex]}',
                onPressed: _nextWidgetType,
                color: AppTheme.textDark,
              ),
              
              // Button type control
              _buildControlButton(
                label: 'Button: ${_buttonTypes[_buttonTypeIndex]}',
                onPressed: _nextButtonType,
                color: AppTheme.primaryBlue,
              ),
              
              // Accent color control
              _buildControlButton(
                label: 'Accent Color',
                onPressed: _nextAccentColor,
                color: _getCurrentAccentColor(),
              ),
              
              // State controls
              _buildControlButton(
                label: 'Error State',
                onPressed: _toggleErrorState,
                color: Colors.red,
              ),
              
              _buildControlButton(
                label: 'Empty State',
                onPressed: _toggleEmptyState,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Build a control button
  Widget _buildControlButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
}