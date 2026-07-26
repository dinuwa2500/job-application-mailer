import 'package:flutter/material.dart';
import '../models/email_template.dart';

class RoleSelectorWidget extends StatelessWidget {
  final String selectedRole;
  final String customRoleText;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onCustomRoleChanged;

  const RoleSelectorWidget({
    super.key,
    required this.selectedRole,
    required this.customRoleText,
    required this.onRoleChanged,
    required this.onCustomRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustom = selectedRole == PredefinedRoles.other;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.work_history_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Application Role',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Select position to auto-customize subject & body',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Quick Role Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildRoleChip(
                context: context,
                label: 'Software Eng',
                value: PredefinedRoles.internSoftwareEngineer,
                icon: Icons.code_rounded,
              ),
              const SizedBox(width: 8),
              _buildRoleChip(
                context: context,
                label: 'Frontend Dev',
                value: PredefinedRoles.internFrontendDeveloper,
                icon: Icons.devices_rounded,
              ),
              const SizedBox(width: 8),
              _buildRoleChip(
                context: context,
                label: 'Full Stack',
                value: PredefinedRoles.internFullStackDeveloper,
                icon: Icons.layers_rounded,
              ),
              const SizedBox(width: 8),
              _buildRoleChip(
                context: context,
                label: 'Backend Dev',
                value: PredefinedRoles.internBackendDeveloper,
                icon: Icons.dns_rounded,
              ),
              const SizedBox(width: 8),
              _buildRoleChip(
                context: context,
                label: 'QA Eng',
                value: PredefinedRoles.internQaEngineer,
                icon: Icons.bug_report_rounded,
              ),
              const SizedBox(width: 8),
              _buildRoleChip(
                context: context,
                label: 'Custom...',
                value: PredefinedRoles.other,
                icon: Icons.edit_note_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Dropdown menu container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.18),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: PredefinedRoles.allRoles.contains(selectedRole)
                  ? selectedRole
                  : PredefinedRoles.other,
              isExpanded: true,
              icon: Icon(
                Icons.unfold_more_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              dropdownColor: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              items: PredefinedRoles.allRoles.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Row(
                    children: [
                      Icon(
                        role == PredefinedRoles.other
                            ? Icons.edit_note_rounded
                            : Icons.badge_outlined,
                        size: 18,
                        color: role == selectedRole
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: role == selectedRole
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: role == selectedRole
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onRoleChanged(newValue);
                }
              },
            ),
          ),
        ),

        // Custom role text field if "Other" is selected
        if (isCustom) ...[
          const SizedBox(height: 14),
          TextFormField(
            initialValue: customRoleText,
            onChanged: onCustomRoleChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Custom Position Title',
              hintText: 'e.g. Mobile Developer Intern, Data Analyst...',
              prefixIcon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRoleChip({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = selectedRole == value;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        selected: isSelected,
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
        ),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        onSelected: (_) => onRoleChanged(value),
      ),
    );
  }
}
