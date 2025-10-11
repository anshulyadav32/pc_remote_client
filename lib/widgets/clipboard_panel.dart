import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/websocket_service.dart';

class ClipboardPanel extends StatefulWidget {
  final WebSocketService wsService;

  const ClipboardPanel({Key? key, required this.wsService}) : super(key: key);

  @override
  State<ClipboardPanel> createState() => _ClipboardPanelState();
}

class _ClipboardPanelState extends State<ClipboardPanel> {
  final _clipboardController = TextEditingController();
  final _remoteClipboardController = TextEditingController();
  bool _autoClipboardEnabled = false;

  @override
  void initState() {
    super.initState();

    // Listen for clipboard messages from server
    widget.wsService.messageStream.listen((message) {
      if (message['type'] == 'clipboard_content') {
        setState(() {
          _remoteClipboardController.text = message['content'] ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _clipboardController.dispose();
    _remoteClipboardController.dispose();
    super.dispose();
  }

  void _setRemoteClipboard() {
    if (_clipboardController.text.isNotEmpty) {
      widget.wsService.sendCommand({
        'type': 'set_clipboard',
        'text': _clipboardController.text,
      });
      _showMessage('Clipboard set on remote computer!');
    }
  }

  void _getRemoteClipboard() {
    widget.wsService.sendCommand({'type': 'get_clipboard'});
    _showMessage('Requesting remote clipboard...');
  }

  void _copyToLocal() {
    if (_remoteClipboardController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _remoteClipboardController.text));
      _showMessage('Copied to local clipboard!');
    }
  }

  void _toggleAutoClipboard() {
    setState(() {
      _autoClipboardEnabled = !_autoClipboardEnabled;
    });

    if (_autoClipboardEnabled) {
      widget.wsService.sendCommand({'type': 'enable_auto_clipboard'});
      _showMessage('Auto clipboard enabled');
    } else {
      widget.wsService.sendCommand({'type': 'disable_auto_clipboard'});
      _showMessage('Auto clipboard disabled');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Clipboard Sync',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Auto Clipboard Toggle
          Card(
            color: _autoClipboardEnabled ? Colors.green[50] : null,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        _autoClipboardEnabled ? Icons.sync : Icons.sync_disabled,
                        color: _autoClipboardEnabled ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Auto Clipboard Sync',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _autoClipboardEnabled
                        ? 'Remote clipboard changes will sync automatically'
                        : 'Enable to automatically receive clipboard updates',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _toggleAutoClipboard,
                    icon: Icon(_autoClipboardEnabled ? Icons.sync_disabled : Icons.sync),
                    label: Text(_autoClipboardEnabled ? 'Disable Auto Sync' : 'Enable Auto Sync'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _autoClipboardEnabled ? Colors.orange : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Remote Clipboard Content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.computer, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Remote Computer Clipboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _remoteClipboardController,
                    maxLines: 5,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Remote clipboard content will appear here...',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _getRemoteClipboard,
                          icon: const Icon(Icons.download),
                          label: const Text('Get Remote Clipboard'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyToLocal,
                          icon: const Icon(Icons.content_copy),
                          label: const Text('Copy to Local'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Set Remote Clipboard
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.upload, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Set Remote Clipboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _clipboardController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Enter text to copy to remote computer...',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _setRemoteClipboard,
                    icon: const Icon(Icons.upload),
                    label: const Text('Set Remote Clipboard'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
