import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';
import '../../data/models/weight_data.dart';
import 'package:intl/intl.dart';

class WeightHistoryGraphWidget extends StatelessWidget {
  final List<WeightData> weightHistory;
  final bool isMetric;

  const WeightHistoryGraphWidget({
    Key? key,
    required this.weightHistory,
    required this.isMetric,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort the weight history by date (newest first)
    final sortedEntries = List<WeightData>.from(weightHistory)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
    // Only show the most recent entries (e.g., last 10)
    final recentEntries = sortedEntries.take(10).toList().reversed.toList();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.s),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimensions.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.insert_chart_outlined_rounded,
                  size: Dimensions.m,
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(width: Dimensions.xs),
                Text(
                  'Weight History',
                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                    fontSize: Dimensions.getTextSize(context, size: TextSize.medium),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: Dimensions.m),
            
            if (recentEntries.isEmpty)
              // Empty state
              Center(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.m),
                  child: Text(
                    'No weight entries yet.\nAdd your first weight to see your progress.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.getBodyStyle().copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              // Simple graph representation
              SizedBox(
                height: 200,
                child: _buildSimpleGraph(context, recentEntries),
              ),
          ],
        ),
      ),
    );
  }
  
  // Build a simple graph visualization
  Widget _buildSimpleGraph(BuildContext context, List<WeightData> entries) {
    if (entries.isEmpty) return Container();
    
    // Find min and max for y-axis scaling
    double minWeight = entries.first.weight;
    double maxWeight = entries.first.weight;
    
    for (final entry in entries) {
      minWeight = minWeight < entry.weight ? minWeight : entry.weight;
      maxWeight = maxWeight > entry.weight ? maxWeight : entry.weight;
    }
    
    // Add a little padding to the min/max
    final padding = (maxWeight - minWeight) * 0.1;
    minWeight = minWeight - padding;
    maxWeight = maxWeight + padding;
    
    // If min and max are the same (only one entry), add some range
    if (minWeight == maxWeight) {
      minWeight = minWeight * 0.95;
      maxWeight = maxWeight * 1.05;
    }
    
    return Column(
      children: [
        // Main graph area
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: SimpleGraphPainter(
              entries: entries,
              minWeight: minWeight,
              maxWeight: maxWeight,
              isMetric: isMetric,
            ),
          ),
        ),
        
        SizedBox(height: Dimensions.xs),
        
        // X-axis labels (dates)
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollPhysics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final dateFormat = entries.length > 5 ? 'MM/dd' : 'MM/dd/yy';
              return Container(
                width: MediaQuery.of(context).size.width / (entries.length + 1),
                alignment: Alignment.center,
                child: Text(
                  DateFormat(dateFormat).format(entries[index].timestamp),
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}

// Simple custom painter for the graph
class SimpleGraphPainter extends CustomPainter {
  final List<WeightData> entries;
  final double minWeight;
  final double maxWeight;
  final bool isMetric;
  
  SimpleGraphPainter({
    required this.entries,
    required this.minWeight,
    required this.maxWeight,
    required this.isMetric,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    
    final paint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final dotPaint = Paint()
      ..color = AppTheme.primaryBlue
      ..style = PaintingStyle.fill;
    
    final dotStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final path = Path();
    
    for (int i = 0; i < entries.length; i++) {
      // Calculate position
      final x = i * size.width / (entries.length - 1);
      final normalizedY = (entries[i].weight - minWeight) / (maxWeight - minWeight);
      final y = size.height - (normalizedY * size.height);
      
      // Move to first point, then line to others
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Draw point at each entry
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, dotStrokePaint);
    }
    
    // Draw the connecting line
    canvas.drawPath(path, paint);
    
    // Draw y-axis labels (weight)
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    );
    final textSpacerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    // Draw at most 5 labels on the y-axis
    int numLabels = 5;
    for (int i = 0; i < numLabels; i++) {
      final labelWeight = minWeight + (maxWeight - minWeight) * i / (numLabels - 1);
      final displayWeight = isMetric ? labelWeight : labelWeight * 2.20462;
      final y = size.height - (i / (numLabels - 1) * size.height);
      
      // Add background for text
      final rect = Rect.fromLTWH(0, y - 10, 40, 20);
      canvas.drawRect(rect, textSpacerPaint);
      
      // Draw weight label
      final textSpan = TextSpan(
        text: displayWeight.toStringAsFixed(1),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 5));
    }
  }
  
  @override
  bool shouldRepaint(covariant SimpleGraphPainter oldDelegate) {
    return entries != oldDelegate.entries ||
           minWeight != oldDelegate.minWeight ||
           maxWeight != oldDelegate.maxWeight ||
           isMetric != oldDelegate.isMetric;
  }
}