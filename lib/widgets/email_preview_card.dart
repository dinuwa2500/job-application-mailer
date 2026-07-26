import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmailPreviewCard extends StatefulWidget {
  final String subject;
  final String body;
  final String selectedTone;
  final ValueChanged<String> onToneChanged;
  final ValueChanged<String> onBodyChanged;
  final VoidCallback onResetTemplate;

  const EmailPreviewCard({
    super.key,
    required this.subject,
    required this.body,
    required this.selectedTone,
    required this.onToneChanged,
    required this.onBodyChanged,
    required this.onResetTemplate,
  });

  @override
  State<EmailPreviewCard> createState() => _EmailPreviewCardState();
}

class _EmailPreviewCardState extends State<EmailPreviewCard> {
  bool _isEditing = false;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: widget.body);
  }

  @override
  void didUpdateWidget(covariant EmailPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.body != widget.body) {
      _bodyController.text = widget.body;
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _copySubject(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.subject));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Subject line copied to clipboard!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6366F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyBody(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.body));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Email body text copied to clipboard!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6366F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wordCount = widget.body.trim().isEmpty ? 0 : widget.body.trim().split(RegExp(r'\s+')).length;
    final charCount = widget.body.length;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_read_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Email Preview & Tone',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: _isEditing ? 'Done Editing' : 'Edit Email Body',
                  icon: Icon(
                    _isEditing ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                    color: _isEditing ? const Color(0xFF10B981) : theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
                IconButton(
                  tooltip: 'Reset Template to Default',
                  icon: const Icon(Icons.restart_alt_rounded),
                  color: theme.colorScheme.onSurfaceVariant,
                  onPressed: () {
                    widget.onResetTemplate();
                    setState(() {
                      _isEditing = false;
                    });
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Tone Selector Bar
                Row(
                  children: [
                    Text(
                      'Tone:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildToneChip('standard', 'Standard', Icons.article_outlined),
                            const SizedBox(width: 6),
                            _buildToneChip('formal', 'Formal', Icons.gavel_rounded),
                            const SizedBox(width: 6),
                            _buildToneChip('concise', 'Direct & Short', Icons.bolt_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Subject Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Subject: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.subject,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _copySubject(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Body Box
                if (_isEditing)
                  TextFormField(
                    controller: _bodyController,
                    maxLines: 12,
                    onChanged: (newVal) {
                      widget.onBodyChanged(newVal);
                    },
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.55,
                      fontSize: 13.5,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      hintText: 'Type or edit custom email body...',
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: SelectableText(
                      widget.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: 13.5,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Word / Char count & Action Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$wordCount words • $charCount chars',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _copyBody(context),
                      icon: const Icon(Icons.copy_all_rounded, size: 16),
                      label: const Text('Copy Body'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToneChip(String value, String label, IconData icon) {
    final isSelected = widget.selectedTone.toLowerCase() == value.toLowerCase();
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => widget.onToneChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
