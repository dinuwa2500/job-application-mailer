import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmailPreviewCard extends StatefulWidget {
  final String subject;
  final String body;
  final ValueChanged<String> onBodyChanged;
  final VoidCallback onResetTemplate;

  const EmailPreviewCard({
    super.key,
    required this.subject,
    required this.body,
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
      const SnackBar(
        content: Text('Subject line copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyBody(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.body));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email body copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Email Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: _isEditing ? 'Done Editing' : 'Edit Email Text',
                  icon: Icon(
                    _isEditing ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                    color: _isEditing ? Colors.green : theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
                IconButton(
                  tooltip: 'Reset Template',
                  icon: const Icon(Icons.refresh_rounded),
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
                // Subject Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
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
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.subject,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _copySubject(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Body Box
                if (_isEditing)
                  TextFormField(
                    controller: _bodyController,
                    maxLines: 12,
                    onChanged: (newVal) {
                      widget.onBodyChanged(newVal);
                    },
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.body.split(RegExp(r'\s+')).length} words • ${_isEditing ? "Editing Mode" : "Tap edit icon to tweak text"}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _copyBody(context),
                      icon: const Icon(Icons.copy_all_rounded, size: 16),
                      label: const Text('Copy Body Text'),
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
}
