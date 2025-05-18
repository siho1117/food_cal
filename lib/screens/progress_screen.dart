import 'package:flutter/material.dart';
import '../config/design_system/theme.dart';
import '../data/repositories/user_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final UserRepository _userRepository = UserRepository();
  
  // Simple state
  bool _isLoading = true;
  double? _bmiValue;
  String _bmiClassification = "Not set";
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load data
      final profile = await _userRepository.getUserProfile();
      final weight = await _userRepository.getLatestWeightEntry();
      
      if (profile?.height != null && weight != null) {
        _bmiValue = _calculateBMI(weight.weight, profile!.height!);
        _bmiClassification = _getBMIClassification(_bmiValue!);
      }
      
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  double _calculateBMI(double weight, double height) {
    // BMI formula: weight (kg) / (height (m) * height (m))
    // Height is stored in cm, so convert to meters
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
  
  String _getBMIClassification(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ProgressScreenContent(
              onWeightUpdated: _loadData,
              bmiValue: _bmiValue,
              bmiClassification: _bmiClassification,
            ),
    );
  }
}

class ProgressScreenContent extends StatelessWidget {
  final VoidCallback onWeightUpdated;
  final double? bmiValue;
  final String bmiClassification;
  
  const ProgressScreenContent({
    Key? key,
    required this.onWeightUpdated,
    required this.bmiValue,
    required this.bmiClassification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'HEALTH METRICS',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Row 1: Current Weight and BMI
            Row(
              children: [
                // Current Weight Widget - Simple method implementation
                Expanded(
                  child: CurrentWeightWidget(
                    onWeightUpdated: onWeightUpdated,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // BMI Widget
                Expanded(
                  child: _buildBMIWidget(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Method defined as widget
  Widget CurrentWeightWidget({required VoidCallback onWeightUpdated}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Weight',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder(
            future: UserRepository().getLatestWeightEntry(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              
              final weightEntry = snapshot.data;
              if (weightEntry == null) {
                return Center(
                  child: Text(
                    'No weight data',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    weightEntry.weight.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue.withOpacity(0.8),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Simple BMI Widget method
  Widget _buildBMIWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'BMI',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            bmiValue?.toStringAsFixed(1) ?? '--',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _getBMIColor(),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getBMIColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bmiClassification,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getBMIColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getBMIColor() {
    if (bmiValue == null) return Colors.grey;
    if (bmiValue! < 18.5) return Colors.blue;
    if (bmiValue! < 25.0) return Colors.green;
    if (bmiValue! < 30.0) return Colors.orange;
    return Colors.red;
  }
}