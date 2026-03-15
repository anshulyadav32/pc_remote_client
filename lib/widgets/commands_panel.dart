import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class CommandsPanel extends StatelessWidget {
  final WebSocketService wsService;

  const CommandsPanel({super.key, required this.wsService});

  void _runCommand(String action, String label) {
    wsService.sendCommand({
      'type': 'command',
      'action': action,
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> commands = [
      {'label': 'Lock PC', 'action': 'lock', 'icon': Icons.lock, 'color': Colors.orange},
      {'label': 'Sleep', 'action': 'sleep', 'icon': Icons.bedtime, 'color': Colors.blue},
      {'label': 'Restart', 'action': 'restart', 'icon': Icons.restart_alt, 'color': Colors.redAccent},
      {'label': 'Shutdown', 'action': 'shutdown', 'icon': Icons.power_settings_new, 'color': Colors.red},
      {'label': 'Volume Up', 'action': 'volume_up', 'icon': Icons.volume_up, 'color': Colors.green},
      {'label': 'Volume Down', 'action': 'volume_down', 'icon': Icons.volume_down, 'color': Colors.green},
      {'label': 'Mute', 'action': 'mute', 'icon': Icons.volume_off, 'color': Colors.grey},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Commands',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: commands.length,
              itemBuilder: (context, index) {
                final cmd = commands[index];
                return InkWell(
                  onTap: () => _runCommand(cmd['action'], cmd['label']),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cmd['color'].withOpacity(0.1),
                      border: Border.all(color: cmd['color'].withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cmd['icon'], color: cmd['color'], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          cmd['label'],
                          style: TextStyle(color: cmd['color'], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
