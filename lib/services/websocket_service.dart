import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();

  String? _lastServerUrl;
  String? _lastToken;
  bool _isConnected = false;

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  Uri _parseServerUri(String serverUrl) {
    final uri = Uri.parse(serverUrl.startsWith('http') ? serverUrl : 'http://$serverUrl');
    if (uri.host.isEmpty) {
      throw FormatException('Invalid server url: $serverUrl');
    }
    return uri;
  }

  Future<bool> connect(String serverUrl, String token) async {
    try {
      // Disconnect if already connected
      if (_isConnected) {
        await disconnect();
      }

      // Parse server URL and construct WebSocket URL
      final uri = _parseServerUri(serverUrl);
      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final wsUri = Uri(
        scheme: wsScheme,
        host: uri.host,
        port: uri.port,
        path: '/ws',
        queryParameters: {'token': token},
      );

      _channel = WebSocketChannel.connect(wsUri);
      _isConnected = true;
      _lastServerUrl = serverUrl;
      _lastToken = token;

      _connectionController.add(true);

      // Listen for messages
      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data.toString()) as Map<String, dynamic>;
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
    _channel = null;
    _connectionController.add(false);
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;

    final channel = _channel;
    _channel = null;
    channel?.sink.close(status.normalClosure);

    _handleDisconnection();
  }

  void sendCommand(Map<String, dynamic> command) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(command));
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
