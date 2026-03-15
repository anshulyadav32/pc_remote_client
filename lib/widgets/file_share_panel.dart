import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/websocket_service.dart';

class FileSharePanel extends StatefulWidget {
  final WebSocketService wsService;

  const FileSharePanel({super.key, required this.wsService});

  @override
  State<FileSharePanel> createState() => _FileSharePanelState();
}

class _FileSharePanelState extends State<FileSharePanel> {
  bool _isUploading = false;

  Future<void> _pickAndSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);

      if (result != null) {
        setState(() => _isUploading = true);

        final picked = result.files.single;
        final fileName = picked.name;
        final bytes = picked.bytes;
        if (bytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unable to read file bytes')),
            );
          }
          return;
        }
        
        widget.wsService.sendCommand({
          'type': 'file',
          'action': 'send',
          'data': {
            'name': fileName,
            'bytes': base64Encode(bytes),
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('📤 Sending $fileName...')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Send Files to PC',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select any file from your phone to instantly send it to your computer\'s Downloads folder.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (_isUploading)
              const CircularProgressIndicator()
            else
              FilledButton.icon(
                onPressed: _pickAndSendFile,
                icon: const Icon(Icons.add),
                label: const Text('Select File'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
