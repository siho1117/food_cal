import 'package:flutter/material.dart';
import '../config/design_system/theme.dart';
import '../widgets/progress/progress_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // This will rebuild the ProgressWidgets
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: const ProgressWidgets(),
          ),
        ),
      ),
    );
  }
}