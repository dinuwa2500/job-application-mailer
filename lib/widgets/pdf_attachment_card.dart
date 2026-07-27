import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PdfAttachmentCard extends StatelessWidget {
  final String? pdfPath;
  final String? pdfName;
  final bool isDefaultPdf;
  final Function(String path, String name) onPdfSelected;
  final VoidCallback onPdfRemoved;
  final ValueChanged<bool> onToggleDefault;

  const PdfAttachmentCard({
    super.key,
    required this.pdfPath,
    required this.pdfName,
    required this.isDefaultPdf,
    required this.onPdfSelected,
    required this.onPdfRemoved,
    required this.onToggleDefault,
  });

  Future<void> _pickPdf(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        onPdfSelected(platformFile.path!, platformFile.name);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick PDF file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _getFileSizeString(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
    } catch (_) {}
    return 'PDF Document';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAttachment = pdfPath != null && pdfPath!.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAttachment
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.22)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAttachment
              ? theme.colorScheme.primary.withValues(alpha: 0.45)
              : theme.colorScheme.outline.withValues(alpha: 0.18),
          width: hasAttachment ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (hasAttachment)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasAttachment
                      ? Colors.redAccent.withValues(alpha: 0.12)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: hasAttachment ? Colors.redAccent : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Resume / CV (PDF)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: hasAttachment
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hasAttachment ? 'Attached' : 'Missing',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: hasAttachment ? const Color(0xFF10B981) : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasAttachment ? 'Ready to send' : 'Attach your latest resume',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!hasAttachment) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _pickPdf(context),
                  icon: const Icon(Icons.attach_file_rounded, size: 16),
                  label: const Text(
                    'Attach PDF',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ],
          ),
          if (hasAttachment) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_rounded,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pdfName ?? 'Attached_CV.pdf',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getFileSizeString(pdfPath!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Change PDF',
                    icon: const Icon(Icons.swap_horiz_rounded),
                    color: theme.colorScheme.primary,
                    onPressed: () => _pickPdf(context),
                  ),
                  IconButton(
                    tooltip: 'Remove Attachment',
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: Colors.redAccent,
                    onPressed: onPdfRemoved,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => onToggleDefault(!isDefaultPdf),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: isDefaultPdf,
                        onChanged: (val) {
                          if (val != null) onToggleDefault(val);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Save as default CV for all future applications',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
