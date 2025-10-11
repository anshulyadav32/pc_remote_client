import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class WindowControlPanel extends StatelessWidget {
  final WebSocketService wsService;

  const WindowControlPanel({Key? key, required this.wsService}) : super(key: key);

  void _sendCommand(Map<String, dynamic> command) {
    wsService.sendCommand(command);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Window Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.window, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Window Controls',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildButton(
                        context,
                        'Alt+Tab',
                        Icons.alt_route,
                        () => _sendCommand({'type': 'alt_tab'}),
                      ),
                      _buildButton(
                        context,
                        'Minimize',
                        Icons.minimize,
                        () => _sendCommand({'type': 'minimize_window'}),
                      ),
                      _buildButton(
                        context,
                        'Maximize',
                        Icons.crop_square,
                        () => _sendCommand({'type': 'maximize_window'}),
                      ),
                      _buildButton(
                        context,
                        'Fullscreen',
                        Icons.fullscreen,
                        () => _sendCommand({'type': 'toggle_fullscreen'}),
                      ),
                      _buildButton(
                        context,
                        'Close Window',
                        Icons.close,
                        () => _sendCommand({'type': 'close_window'}),
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
    [Color? backgroundColor]
  ) {
    return SizedBox(
      width: 160,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
