import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/websocket_service.dart';

class MouseControlPanel extends StatefulWidget {
  final WebSocketService wsService;

  const MouseControlPanel({Key? key, required this.wsService}) : super(key: key);

  @override
  State<MouseControlPanel> createState() => _MouseControlPanelState();
}

class _MouseControlPanelState extends State<MouseControlPanel> {
  Offset? _lastPanPosition;
  double _sensitivity = 1.5;

  void _sendCommand(Map<String, dynamic> command) {
    widget.wsService.sendCommand(command);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mouse Control',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Sensitivity Control
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sensitivity: ${_sensitivity.toStringAsFixed(1)}x',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _sensitivity,
                    min: 0.5,
                    max: 5.0,
                    divisions: 18,
                    label: _sensitivity.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _sensitivity = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Trackpad
          Card(
            elevation: 4,
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surfaceVariant,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: GestureDetector(
                onPanStart: (details) {
                  _lastPanPosition = details.localPosition;
                },
                onPanUpdate: (details) {
                  if (_lastPanPosition != null) {
                    final dx = (details.localPosition.dx - _lastPanPosition!.dx) * _sensitivity;
                    final dy = (details.localPosition.dy - _lastPanPosition!.dy) * _sensitivity;

                    _sendCommand({
                      'type': 'move',
                      'dx': dx.round(),
                      'dy': dy.round(),
                    });

                    _lastPanPosition = details.localPosition;
                  }
                },
                onPanEnd: (details) {
                  _lastPanPosition = null;
                },
                child: Listener(
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      final scrollDelta = pointerSignal.scrollDelta.dy;
                      _sendCommand({
                        'type': 'wheel',
                        'delta': scrollDelta.round(),
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Move your mouse here to control',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Drag to move • Scroll to wheel',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mouse Buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _sendCommand({'type': 'click', 'button': 'left'}),
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Left Click'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _sendCommand({'type': 'click', 'button': 'right'}),
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Right Click'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _sendCommand({
                    'type': 'click',
                    'button': 'left',
                    'kind': 'double'
                  }),
                  icon: const Icon(Icons.double_arrow),
                  label: const Text('Double Click'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
