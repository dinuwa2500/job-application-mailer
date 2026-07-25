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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAttachment
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAttachment
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: hasAttachment ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasAttachment
                          ? Colors.redAccent.withValues(alpha: 0.15)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: hasAttachment ? Colors.redAccent : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Attach CV / Resume (PDF)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (!hasAttachment)
                ElevatedButton.icon(
                  onPressed: () => _pickPdf(context),
                  icon: const Icon(Icons.attach_file_rounded, size: 18),
                  label: const Text('Attach PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
            ],
          ),
          if (hasAttachment) ...[
            const SizedBox(height: 14),
            Row(
              children: [
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
            const Divider(height: 20),
            InkWell(
              onTap: () => onToggleDefault(!isDefaultPdf),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: isDefaultPdf,
                      onChanged: (val) {
                        if (val != null) onToggleDefault(val);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save as default CV for future emails',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
