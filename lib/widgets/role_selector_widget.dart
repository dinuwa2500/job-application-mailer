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
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.work_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Select Target Role',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Dropdown menu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: PredefinedRoles.allRoles.contains(selectedRole)
                  ? selectedRole
                  : PredefinedRoles.other,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.primary,
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

        // Quick Selector Chips
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRoleChip(
                context: context,
                label: 'Software Engineer',
                value: PredefinedRoles.internSoftwareEngineer,
              ),
              const SizedBox(width: 8),
              _buildRoleChip(
                context: context,
                label: 'Frontend Dev',
                value: PredefinedRoles.internFrontendDeveloper,
              ),
              const SizedBox(width: 8),
              _buildRoleChip(
                context: context,
                label: 'Full Stack Dev',
                value: PredefinedRoles.internFullStackDeveloper,
              ),
              const SizedBox(width: 8),
              _buildRoleChip(
                context: context,
                label: 'Custom...',
                value: PredefinedRoles.other,
              ),
            ],
          ),
        ),

        // Custom role text field if "Other" is selected
        if (isCustom) ...[
          const SizedBox(height: 14),
          TextFormField(
            initialValue: customRoleText,
            onChanged: onCustomRoleChanged,
            decoration: InputDecoration(
              labelText: 'Enter Custom Position Title',
              hintText: 'e.g. intern QA engineer, Mobile Developer...',
              prefixIcon: const Icon(Icons.edit_outlined),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
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
  }) {
    final isSelected = selectedRole == value;
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurfaceVariant,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      checkmarkColor: theme.colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      onSelected: (_) => onRoleChanged(value),
    );
  }
}
