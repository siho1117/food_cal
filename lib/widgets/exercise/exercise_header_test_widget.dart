import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/widgets/master_widget.dart';
import '../../config/components/state_builder.dart';

/// A test widget for experimenting with the simplified header designs
class ExerciseHeaderTestWidget extends StatefulWidget {
  const ExerciseHeaderTestWidget({Key? key}) : super(key: key);

  @override
  State<ExerciseHeaderTestWidget> createState() => _ExerciseHeaderTestWidgetState();
}

class _ExerciseHeaderTestWidgetState extends State<ExerciseHeaderTestWidget> {
  // Test parameters
  int _widgetTypeIndex = 0;
  int _colorIndex = 0;
  bool _showInfoButton = true;
  
  // Widget types to test
  final List<String> _widgetTypes = [
    'Standard',
    'Data Widget',
    'Metric Widget',
    'Progress Widget',
  ];
  
  // Colors to test (starting with black)
  final List<Color> _colors = [
    Colors.black,
    AppTheme.primaryBlue,
    AppTheme.accentColor,
    AppTheme.goldAccent,
    AppTheme.coralAccent,
  ];
  
  // Get current color
  Color get _currentColor => _colors[_colorIndex];
  
  // Toggle widget type
  void _nextWidgetType() {
    setState(() {
      _widgetTypeIndex = (_widgetTypeIndex + 1) % _widgetTypes.length;
    });
  }
  
  // Toggle color
  void _nextColor() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _colors.length;
    });
  }
  
  // Toggle info button visibility
  void _toggleInfoButton() {
    setState(() {
      _showInfoButton = !_showInfoButton;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The test widget using the modified master_widget
        _buildTestWidget(),
        
        // Controls
        _buildControls(),
      ],
    );
  }
  
  // Build the appropriate test widget based on selected type
  Widget _buildTestWidget() {
    switch (_widgetTypeIndex) {
      case 1:
        return MasterWidget.dataWidget(
          title: 'Exercise Data',
          icon: Icons.fitness_center,
          textColor: _currentColor,
          iconColor: _currentColor,
          showInfoButton: _showInfoButton,
          onInfoTap: _showInfoButton ? _showInfoDialog : null,
          child: _buildSampleContent(),
        );
      case 2:
        return MasterWidget.metricWidget(
          title: 'Exercise Metric',
          icon: Icons.local_fire_department,
          textColor: _currentColor,
          iconColor: _currentColor,
          showInfoButton: _showInfoButton,
          onInfoTap: _showInfoButton ? _showInfoDialog : null,
          valueWidget: Center(
            child: Column(
              children: [
                Text(
                  '350',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _currentColor,
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
          textColor: _currentColor,
          iconColor: _currentColor,
          progress: 0.65,
          progressText: '65% complete',
          progressColor: _currentColor,
          showInfoButton: _showInfoButton,
          onInfoTap: _showInfoButton ? _showInfoDialog : null,
          child: _buildSampleContent(height: 80),
        );
      case 0:
      default:
        return MasterWidget(
          title: 'Exercise Header Test',
          icon: Icons.speed,
          textColor: _currentColor,
          iconColor: _currentColor,
          showInfoButton: _showInfoButton,
          onInfoTap: _showInfoButton ? _showInfoDialog : null,
          child: _buildSampleContent(),
        );
    }
  }
  
  // Build sample content
  Widget _buildSampleContent({double height = 120}) {
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
                    color: _currentColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simplified Header Design',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _currentColor,
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
            message: 'The simplified header features black text by default, consistent height with/without info button, no animations, and cleaner structure.',
            icon: Icons.lightbulb_outline,
            color: _currentColor,
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
              _buildControlButton(
                label: 'Widget: ${_widgetTypes[_widgetTypeIndex]}',
                onPressed: _nextWidgetType,
                color: Colors.black,
              ),
              _buildControlButton(
                label: 'Color',
                onPressed: _nextColor,
                color: _currentColor,
              ),
              _buildControlButton(
                label: 'Info: ${_showInfoButton ? 'On' : 'Off'}',
                onPressed: _toggleInfoButton,
                color: Colors.teal,
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