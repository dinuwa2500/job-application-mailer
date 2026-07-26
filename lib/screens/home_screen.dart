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
  final TextEditingController _companyNameController = TextEditingController();

  List<String> _recentRecipients = [];

  String? _pdfPath;
  String? _pdfName;
  bool _isDefaultPdf = false;

  String _selectedTone = 'standard';
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
    final recentList = await StorageService.getRecentRecipients();
    final lastCompany = await StorageService.getLastCompanyName();
    final lastTone = await StorageService.getLastTone();
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
      _recentRecipients = recentList;
      if (lastCompany != null) {
        _companyNameController.text = lastCompany;
      }
      if (lastTone != null) {
        _selectedTone = lastTone;
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
    return EmailTemplate.generateSubject(
      roleTitle: _effectiveRole,
      companyName: _companyNameController.text.trim(),
      applicantName: _profile.name,
    );
  }

  String get _currentBody {
    return EmailTemplate.generateBody(
      role: _effectiveRole,
      profile: _profile,
      companyName: _companyNameController.text.trim(),
      tone: _selectedTone,
      customBodyTemplate: _customBodyText,
    );
  }

  bool get _isValidRecipientEmail {
    final text = _recipientEmailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(text);
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
    if (recipient.isNotEmpty) {
      await StorageService.saveLastRecipientEmail(recipient);
      final updatedRecipients = await StorageService.getRecentRecipients();
      setState(() {
        _recentRecipients = updatedRecipients;
      });
    }

    final result = await EmailService.sendEmail(
      recipientEmail: recipient,
      subject: _currentSubject,
      body: _currentBody,
      attachmentPath: _pdfPath,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(result.message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: result.success ? const Color(0xFF6366F1) : Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleSendGmailWeb() async {
    final recipient = _recipientEmailController.text.trim();
    if (recipient.isNotEmpty) {
      await StorageService.saveLastRecipientEmail(recipient);
      final updatedRecipients = await StorageService.getRecentRecipients();
      setState(() {
        _recentRecipients = updatedRecipients;
      });
    }

    final result = await EmailService.sendViaGmailWeb(
      recipientEmail: recipient,
      subject: _currentSubject,
      body: _currentBody,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.success ? Icons.open_in_browser_rounded : Icons.info_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(result.message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: result.success ? const Color(0xFF6366F1) : Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAttachment = _pdfPath != null && _pdfPath!.isNotEmpty;

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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Job Application Mailer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sender Profile Settings',
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
                        color: Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _openProfileSettings,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
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
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        _profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _profile.senderEmail.isNotEmpty
                                ? 'From: ${_profile.senderEmail}'
                                : 'Tap to add your default sender email',
                            style: TextStyle(
                              fontSize: 12,
                              color: _profile.senderEmail.isNotEmpty
                                  ? theme.colorScheme.onSurfaceVariant
                                  : Colors.orange,
                              fontWeight: _profile.senderEmail.isNotEmpty
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

            const SizedBox(height: 16),

            // Recipient HR Email & Company Name Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
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
                          Icons.alternate_email_rounded,
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
                              'Target Company & Recipient HR',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Enter HR email and optional company name',
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

                  // Target HR Email Field with Format Validation Badge
                  TextFormField(
                    controller: _recipientEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Recipient HR Email Address',
                      hintText: 'e.g. careers@company.com or hr@tech.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                      suffixIcon: _recipientEmailController.text.isNotEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isValidRecipientEmail)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF10B981),
                                      size: 18,
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _recipientEmailController.clear();
                                    setState(() {});
                                  },
                                ),
                              ],
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

                  // Recent Recipient Email Chips
                  if (_recentRecipients.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          Text(
                            'Recent:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          ..._recentRecipients.map((email) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () {
                                  _recipientEmailController.text = email;
                                  setState(() {});
                                  StorageService.saveLastRecipientEmail(email);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.history_rounded,
                                        size: 12,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Target Company Name Field (Optional)
                  TextFormField(
                    controller: _companyNameController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Company Name (Optional)',
                      hintText: 'e.g. WSO2, 99x, Virtusa...',
                      prefixIcon: const Icon(Icons.business_rounded, size: 20),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {});
                      StorageService.saveLastCompanyName(val);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 16),

            // Role Selector Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.18),
                ),
              ),
              child: RoleSelectorWidget(
                selectedRole: _selectedRole,
                customRoleText: _customRoleText,
                onRoleChanged: _onRoleChanged,
                onCustomRoleChanged: _onCustomRoleChanged,
              ),
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 16),

            // PDF Attachment Card
            PdfAttachmentCard(
              pdfPath: _pdfPath,
              pdfName: _pdfName,
              isDefaultPdf: _isDefaultPdf,
              onPdfSelected: _onPdfSelected,
              onPdfRemoved: _onPdfRemoved,
              onToggleDefault: _onToggleDefaultPdf,
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 16),

            // Email Preview Card
            EmailPreviewCard(
              subject: _currentSubject,
              body: _currentBody,
              selectedTone: _selectedTone,
              onToneChanged: (tone) {
                setState(() {
                  _selectedTone = tone;
                });
                StorageService.saveLastTone(tone);
              },
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

            const SizedBox(height: 110), // Spacing for bottom floating bar
          ],
        ),
      ),

      // Floating Action Bottom Bar
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Attachment status bar indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      hasAttachment ? Icons.task_alt_rounded : Icons.info_outline_rounded,
                      size: 14,
                      color: hasAttachment ? const Color(0xFF10B981) : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasAttachment
                          ? 'Resume attached: ${_pdfName ?? "CV.pdf"}'
                          : 'No PDF attached. Mail app will launch with text only.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: hasAttachment ? const Color(0xFF10B981) : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  // Copy email text button
                  IconButton.outlined(
                    tooltip: 'Copy Subject & Body',
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      EmailService.copyToClipboard(
                        subject: _currentSubject,
                        body: _currentBody,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Subject & Body copied to clipboard!'),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Open Gmail Web Button
                  IconButton.outlined(
                    tooltip: 'Open Gmail Web',
                    icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _handleSendGmailWeb,
                  ),
                  const SizedBox(width: 8),

                  // Send Email Primary Action Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _handleSendEmail,
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: const Text(
                          'Send via Mail App',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
