import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WebSocketService {
  WebSocket? _socket;
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();

  String? _lastServerUrl;
  String? _lastToken;
  bool _isConnected = false;

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  Future<bool> connect(String serverUrl, String token) async {
    try {
      // Disconnect if already connected
      if (_isConnected) {
        await disconnect();
      }

      // Parse server URL and construct WebSocket URL
      final uri = Uri.parse(serverUrl.startsWith('http') ? serverUrl : 'http://$serverUrl');
      final wsUrl = 'ws://${uri.host}:${uri.port}/ws?token=$token';

      _socket = await WebSocket.connect(wsUrl);
      _isConnected = true;
      _lastServerUrl = serverUrl;
      _lastToken = token;

      _connectionController.add(true);

      // Listen for messages
      _socket!.listen(
        (data) {
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(message);
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnection();
        },
      );

      return true;
    } catch (e) {
      print('Connection error: $e');
      _handleDisconnection();
      return false;
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _socket = null;
    _connectionController.add(false);
  }

  Future<void> disconnect() async {
    if (_socket != null) {
      await _socket!.close();
      _socket = null;
    }
    _handleDisconnection();
  }

  void sendCommand(Map<String, dynamic> command) {
    if (_socket != null && _isConnected) {
      try {
        _socket!.add(jsonEncode(command));
      } catch (e) {
        print('Error sending command: $e');
      }
    } else {
      print('Not connected to server');
    }
  }

  Future<void> reconnect() async {
    if (_lastServerUrl != null && _lastToken != null) {
      await connect(_lastServerUrl!, _lastToken!);
    }
  }

  void dispose() {
    disconnect();
    _connectionController.close();
    _messageController.close();
  }
}
