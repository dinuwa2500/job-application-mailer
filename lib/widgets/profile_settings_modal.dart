import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileSettingsModal extends StatefulWidget {
  final UserProfile currentProfile;
  final ValueChanged<UserProfile> onSave;

  const ProfileSettingsModal({
    super.key,
    required this.currentProfile,
    required this.onSave,
  });

  @override
  State<ProfileSettingsModal> createState() => _ProfileSettingsModalState();
}

class _ProfileSettingsModalState extends State<ProfileSettingsModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _degreeController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentProfile.name);
    _phoneController = TextEditingController(text: widget.currentProfile.phone);
    _emailController = TextEditingController(text: widget.currentProfile.senderEmail);
    _degreeController = TextEditingController(text: widget.currentProfile.degree);
    _skillsController = TextEditingController(text: widget.currentProfile.skills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _degreeController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.currentProfile.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        senderEmail: _emailController.text.trim(),
        degree: _degreeController.text.trim(),
        skills: _skillsController.text.trim(),
      );
      widget.onSave(updated);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Profile & Sender settings saved!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_pin_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sender & Profile Settings',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Auto-fills your details in generated application emails',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Default Sender Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Your Email Address (Sender)',
                  hintText: 'e.g. yourname@gmail.com',
                  prefixIcon: Icon(
                    Icons.mark_email_read_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your full name' : null,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Lakviru Perera',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter contact phone number' : null,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. 0704224786',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Degree Field
              TextFormField(
                controller: _degreeController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter degree or education details' : null,
                decoration: InputDecoration(
                  labelText: 'Degree / Education Title',
                  hintText: 'e.g. BSc (Hons) in Information Technology...',
                  prefixIcon: Icon(
                    Icons.school_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Skills Field
              TextFormField(
                controller: _skillsController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter key technical skills' : null,
                decoration: InputDecoration(
                  labelText: 'Key Skills & Stack',
                  hintText: 'e.g. React, Node.js, Flutter, Java, Python...',
                  prefixIcon: Icon(
                    Icons.code_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Save Profile & Defaults',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
