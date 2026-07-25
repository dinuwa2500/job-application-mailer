import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/email_template.dart';
import '../models/user_profile.dart';
import '../services/email_service.dart';
import '../services/storage_service.dart';
import '../widgets/email_preview_card.dart';
import '../widgets/pdf_attachment_card.dart';
import '../widgets/profile_settings_modal.dart';
import '../widgets/role_selector_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile _profile = UserProfile.defaultProfile();
  String _selectedRole = PredefinedRoles.internSoftwareEngineer;
  String _customRoleText = '';
  final TextEditingController _recipientEmailController = TextEditingController();

  String? _pdfPath;
  String? _pdfName;
  bool _isDefaultPdf = false;

  String? _customBodyText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final loadedProfile = await StorageService.getProfile();
    final lastRole = await StorageService.getLastChosenRole();
    final lastCustomRole = await StorageService.getLastCustomRole();
    final lastRecipient = await StorageService.getLastRecipientEmail();
    final customTemplate = await StorageService.getCustomTemplate();

    setState(() {
      _profile = loadedProfile;
      if (lastRole != null && PredefinedRoles.allRoles.contains(lastRole)) {
        _selectedRole = lastRole;
      }
      if (lastCustomRole != null) {
        _customRoleText = lastCustomRole;
      }
      if (lastRecipient != null) {
        _recipientEmailController.text = lastRecipient;
      }
      if (customTemplate != null) {
        _customBodyText = customTemplate;
      }

      // Check default PDF path from saved profile
      if (loadedProfile.defaultPdfPath != null && loadedProfile.defaultPdfPath!.isNotEmpty) {
        _pdfPath = loadedProfile.defaultPdfPath;
        _pdfName = loadedProfile.defaultPdfName ?? 'Saved_CV.pdf';
        _isDefaultPdf = true;
      }

      _isLoading = false;
    });
  }

  String get _effectiveRole {
    if (_selectedRole == PredefinedRoles.other) {
      return _customRoleText.trim().isEmpty ? 'intern software engineer' : _customRoleText.trim();
    }
    return _selectedRole;
  }

  String get _currentSubject {
    return EmailTemplate.generateSubject(_effectiveRole);
  }

  String get _currentBody {
    return EmailTemplate.generateBody(
      role: _effectiveRole,
      profile: _profile,
      customBodyTemplate: _customBodyText,
    );
  }

  void _onRoleChanged(String newRole) {
    setState(() {
      _selectedRole = newRole;
    });
    StorageService.saveLastChosenRole(newRole);
  }

  void _onCustomRoleChanged(String customRole) {
    setState(() {
      _customRoleText = customRole;
    });
    StorageService.saveLastCustomRole(customRole);
  }

  void _onPdfSelected(String path, String name) {
    setState(() {
      _pdfPath = path;
      _pdfName = name;
    });
  }

  void _onPdfRemoved() {
    setState(() {
      _pdfPath = null;
      _pdfName = null;
      _isDefaultPdf = false;
    });
  }

  void _onToggleDefaultPdf(bool isDefault) async {
    setState(() {
      _isDefaultPdf = isDefault;
    });

    if (isDefault && _pdfPath != null) {
      final updatedProfile = _profile.copyWith(
        defaultPdfPath: _pdfPath,
        defaultPdfName: _pdfName,
      );
      setState(() {
        _profile = updatedProfile;
      });
      await StorageService.saveProfile(updatedProfile);
    } else if (!isDefault) {
      final updatedProfile = UserProfile(
        name: _profile.name,
        phone: _profile.phone,
        senderEmail: _profile.senderEmail,
        degree: _profile.degree,
        skills: _profile.skills,
        defaultPdfPath: null,
        defaultPdfName: null,
      );
      setState(() {
        _profile = updatedProfile;
      });
      await StorageService.saveProfile(updatedProfile);
    }
  }

  void _openProfileSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileSettingsModal(
        currentProfile: _profile,
        onSave: (updatedProfile) async {
          setState(() {
            _profile = updatedProfile;
          });
          await StorageService.saveProfile(updatedProfile);
        },
      ),
    );
  }

  Future<void> _handleSendEmail() async {
    final recipient = _recipientEmailController.text.trim();
    StorageService.saveLastRecipientEmail(recipient);

    final result = await EmailService.sendEmail(
      recipientEmail: recipient,
      subject: _currentSubject,
      body: _currentBody,
      attachmentPath: _pdfPath,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.indigo : Colors.orangeAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleSendGmailWeb() async {
    final recipient = _recipientEmailController.text.trim();
    StorageService.saveLastRecipientEmail(recipient);

    final result = await EmailService.sendViaGmailWeb(
      recipientEmail: recipient,
      subject: _currentSubject,
      body: _currentBody,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.indigo : Colors.orangeAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Job Application Mailer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sender Settings',
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded),
                if (_profile.senderEmail.isEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _openProfileSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender Profile Status Banner
            InkWell(
              onTap: _openProfileSettings,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        _profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _profile.senderEmail.isNotEmpty
                                ? 'Sender: ${_profile.senderEmail}'
                                : 'Tap to save default sender email address',
                            style: TextStyle(
                              fontSize: 12,
                              color: _profile.senderEmail.isNotEmpty
                                  ? theme.colorScheme.onSurfaceVariant
                                  : Colors.orangeAccent,
                              fontWeight: _profile.senderEmail.isNotEmpty
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

            const SizedBox(height: 18),

            // Recipient HR Email Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.alternate_email_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Target Recipient (Company HR Email)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _recipientEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'e.g. careers@company.com or hr@tech.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      suffixIcon: _recipientEmailController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _recipientEmailController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {});
                      StorageService.saveLastRecipientEmail(val);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 18),

            // Role Selector Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: RoleSelectorWidget(
                selectedRole: _selectedRole,
                customRoleText: _customRoleText,
                onRoleChanged: _onRoleChanged,
                onCustomRoleChanged: _onCustomRoleChanged,
              ),
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 18),

            // PDF Attachment Card
            PdfAttachmentCard(
              pdfPath: _pdfPath,
              pdfName: _pdfName,
              isDefaultPdf: _isDefaultPdf,
              onPdfSelected: _onPdfSelected,
              onPdfRemoved: _onPdfRemoved,
              onToggleDefault: _onToggleDefaultPdf,
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 18),

            // Email Preview Card
            EmailPreviewCard(
              subject: _currentSubject,
              body: _currentBody,
              onBodyChanged: (newBody) {
                setState(() {
                  _customBodyText = newBody;
                });
                StorageService.saveCustomTemplate(newBody);
              },
              onResetTemplate: () {
                setState(() {
                  _customBodyText = null;
                });
                StorageService.clearCustomTemplate();
              },
            ).animate().fadeIn(duration: 700.ms),

            const SizedBox(height: 100), // Spacing for bottom bar
          ],
        ),
      ),

      // Floating Action Bottom Bar
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Copy full email text button
              IconButton.outlined(
                tooltip: 'Copy Email Text',
                icon: const Icon(Icons.copy_rounded),
                onPressed: () {
                  EmailService.copyToClipboard(
                    subject: _currentSubject,
                    body: _currentBody,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subject and Body copied to clipboard!'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              // Open Gmail Web Composer Button
              IconButton.outlined(
                tooltip: 'Open Gmail Web',
                icon: const Icon(Icons.open_in_browser_rounded),
                onPressed: _handleSendGmailWeb,
              ),
              const SizedBox(width: 8),

              // Send Email Action Button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _handleSendEmail,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text(
                      'Send via Mail App',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
