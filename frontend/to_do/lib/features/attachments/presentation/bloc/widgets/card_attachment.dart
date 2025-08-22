import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:to_do/features/attachments/domain/entity/attachment_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class CardAttachment extends StatelessWidget {
  final AttachmentEntity attachment;
  const CardAttachment(this.attachment, {super.key});

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      case 'zip':
      case 'rar':
        return Icons.archive_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Colors.red.shade600;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Colors.purple.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade700;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade700;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade700;
      case 'txt':
        return Colors.grey.shade600;
      case 'zip':
      case 'rar':
        return Colors.amber.shade700;
      default:
        return Colors.blueGrey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileColor = _getFileColor(attachment.fileName);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        //color: theme.cardColor,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: open or preview attachment
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // File icon with background
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: fileColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileIcon(attachment.fileName),
                    size: 28,
                    color: fileColor,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        attachment.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Uploaded ${_formatDate(attachment.uploadAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                    
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 5),
                
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.download_rounded,
                          color: theme.primaryColor,
                        ),
                        iconSize: 20,
                        onPressed: () {
                          // TODO: download file
                          downloadAndOpenPdf(attachment.fileUrl, attachment.fileName, context); 
                        },
                        tooltip: 'Download',
                        splashRadius: 20,
                      ),
                    ),
                    
                  
                    
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.hintColor,
                      ),
                      iconSize: 20,
                      splashRadius: 20,
                      offset: const Offset(0, 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share_rounded, size: 18, color: theme.hintColor),
                              const SizedBox(width: 12),
                              const Text('Share'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18, color: theme.hintColor),
                              const SizedBox(width: 12),
                              const Text('Rename'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, size: 18, color: Colors.red.shade600),
                              const SizedBox(width: 12),
                              Text('Delete', style: TextStyle(color: Colors.red.shade600)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'share':
                            // TODO: share attachment
                            break;
                          case 'rename':
                            // TODO: rename attachment
                            break;
                          case 'delete':
                            // TODO: delete attachment
                            break;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> downloadAndOpenPdf(String url, String fileName, BuildContext context) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải file...')),
      );

      // Get the application documents directory
      final dir = await getApplicationDocumentsDirectory();
      // Use a unique file name based on the original file name
      final filePath = '${dir.path}/$fileName';

      // Download the file
      await Dio().download(url, filePath);

      print('PDF downloaded to $filePath');

      // Open the file
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở $fileName: ${result.message}'),
            action: SnackBarAction(
              label: 'Cài ứng dụng PDF',
              onPressed: () async {
                final playStoreUri = Uri.parse('market://details?id=com.adobe.reader');
                if (await canLaunchUrl(playStoreUri)) {
                  await launchUrl(playStoreUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không thể mở Play Store')),
                  );
                }
              },
            ),
          ),
        );
        print('Failed to open $filePath: ${result.message}');
      } else {
        print('Successfully opened $filePath');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải/mở $fileName: $e')),
      );
      print('Error downloading/opening $url: $e');
    }
  }
}

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
