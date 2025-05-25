// lib/widgets/camera/meal_type_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../providers/camera_provider.dart';

class MealTypeSelectorWidget extends StatelessWidget {
  final bool showAsFloating;
  
  const MealTypeSelectorWidget({
    Key? key,
    this.showAsFloating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        if (showAsFloating) {
          return _buildFloatingSelector(context, cameraProvider);
        } else {
          return _buildInlineSelector(context, cameraProvider);
        }
      },
    );
  }

  Widget _buildFloatingSelector(BuildContext context, CameraProvider cameraProvider) {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _getMealTypeIcon(cameraProvider.selectedMealType),
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Meal Type: ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: cameraProvider.selectedMealType,
                  isExpanded: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      cameraProvider.setMealType(newValue);
                    }
                  },
                  items: cameraProvider.mealTypes.map((String mealType) {
                    return DropdownMenuItem<String>(
                      value: mealType,
                      child: Row(
                        children: [
                          Icon(
                            _getMealTypeIcon(mealType),
                            size: 16,
                            color: _getMealTypeColor(mealType),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cameraProvider.getFormattedMealType(mealType),
                            style: TextStyle(
                              color: _getMealTypeColor(mealType),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineSelector(BuildContext context, CameraProvider cameraProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.restaurant,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Meal Type:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: cameraProvider.selectedMealType,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.primaryBlue,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    cameraProvider.setMealType(newValue);
                  }
                },
                items: cameraProvider.mealTypes.map((String mealType) {
                  return DropdownMenuItem<String>(
                    value: mealType,
                    child: Row(
                      children: [
                        Icon(
                          _getMealTypeIcon(mealType),
                          size: 18,
                          color: _getMealTypeColor(mealType),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cameraProvider.getFormattedMealType(mealType),
                          style: TextStyle(
                            color: _getMealTypeColor(mealType),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.bakery_dining;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.indigo;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}