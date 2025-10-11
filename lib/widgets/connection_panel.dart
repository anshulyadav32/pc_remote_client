import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/websocket_service.dart';

class ConnectionPanel extends StatefulWidget {
  final WebSocketService wsService;

  const ConnectionPanel({Key? key, required this.wsService}) : super(key: key);

  @override
  State<ConnectionPanel> createState() => _ConnectionPanelState();
}

class _ConnectionPanelState extends State<ConnectionPanel> {
  final _serverController = TextEditingController(text: '192.168.1.100:8765');
  final _tokenController = TextEditingController(text: 'CHANGE_ME_1234');
  bool _isConnecting = false;

  @override
  void dispose() {
    _serverController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_serverController.text.isEmpty || _tokenController.text.isEmpty) {
      _showMessage('Please enter server address and token', isError: true);
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    final success = await widget.wsService.connect(
      _serverController.text,
      _tokenController.text,
    );

    setState(() {
      _isConnecting = false;
    });

    if (success) {
      _showMessage('Connected successfully!');
    } else {
      _showMessage('Failed to connect. Check server address and token.', isError: true);
    }
  }

  void _disconnect() {
    widget.wsService.disconnect();
    _showMessage('Disconnected');
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.wsService.connectionStream,
      initialData: false,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    isConnected ? Icons.router : Icons.router_outlined,
                    size: 100,
                    color: isConnected ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isConnected ? 'Connected to Remote Server' : 'Not Connected',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connection Settings',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _serverController,
                            enabled: !isConnected,
                            decoration: const InputDecoration(
                              labelText: 'Server Address',
                              hintText: '192.168.1.100:8765',
                              prefixIcon: Icon(Icons.computer),
                              border: OutlineInputBorder(),
                              helperText: 'Enter IP address and port',
                            ),
                            keyboardType: TextInputType.url,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _tokenController,
                            enabled: !isConnected,
                            decoration: const InputDecoration(
                              labelText: 'Authentication Token',
                              hintText: 'CHANGE_ME_1234',
                              prefixIcon: Icon(Icons.vpn_key),
                              border: OutlineInputBorder(),
                              helperText: 'Enter the server token',
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 24),
                          if (isConnected)
                            FilledButton.icon(
                              onPressed: _disconnect,
                              icon: const Icon(Icons.close),
                              label: const Text('Disconnect'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            )
                          else
                            FilledButton.icon(
                              onPressed: _isConnecting ? null : _connect,
                              icon: _isConnecting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.wifi),
                              label: Text(_isConnecting ? 'Connecting...' : 'Connect'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'How to Connect',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('1. Start the Remote Mouse Server on your target computer'),
                          const SizedBox(height: 8),
                          const Text('2. Note the IP address and port shown in the server'),
                          const SizedBox(height: 8),
                          const Text('3. Copy the authentication token from the server'),
                          const SizedBox(height: 8),
                          const Text('4. Enter the details above and click Connect'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
