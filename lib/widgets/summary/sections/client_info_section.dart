// lib/widgets/summary/sections/client_info_section.dart
import 'package:flutter/material.dart';
import '../../../data/models/user_profile.dart';
import '../../../utils/shared/summary_data_calculator.dart';
import 'base_section_widget.dart';

/// Client Information Section - User profile details
class ClientInfoSection extends StatelessWidget {
  final UserProfile? profile;

  const ClientInfoSection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return BaseSectionWidget(
      icon: Icons.person,
      title: 'CLIENT INFORMATION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: 'Name', value: profile?.name ?? 'Not set'),
          InfoRow(
            label: 'Age',
            value: profile?.age != null ? '${profile!.age} years old' : 'Not set',
          ),
          InfoRow(label: 'Gender', value: profile?.gender ?? 'Not set'),
          if (profile?.birthDate != null)
            InfoRow(
              label: 'Date of Birth',
              value: SummaryDataCalculator.formatDate(profile!.birthDate!),
            ),
        ],
      ),
    );
  }
}
