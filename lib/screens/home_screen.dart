import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:battery_plus/battery_plus.dart';
import '../services/websocket_service.dart';
import '../widgets/connection_panel.dart';
import '../widgets/mouse_control_panel.dart';
import '../widgets/media_control_panel.dart';
import '../widgets/browser_control_panel.dart';
import '../widgets/window_control_panel.dart';
import '../widgets/text_input_panel.dart';
import '../widgets/clipboard_panel.dart';
import '../widgets/file_share_panel.dart';
import '../widgets/commands_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final WebSocketService _wsService = WebSocketService();
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Battery _battery = Battery();
  Timer? _batteryTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _initMessageListener();
    if (!kIsWeb) {
      _startBatterySync();
      if (Platform.isAndroid) {
        _initNotificationListener();
      }
    }
  }

  void _startBatterySync() {
    _batteryTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_wsService.isConnected) {
        try {
          final level = await _battery.batteryLevel;
          _wsService.sendCommand({
            'type': 'battery',
            'action': 'sync',
            'data': {
              'level': level,
            }
          });
        } catch (e) {
          print('Battery sync error: $e');
        }
      }
    });
  }

  void _initNotificationListener() async {
    try {
      final bool status = await NotificationListenerService.isPermissionGranted();
      if (!status) {
        await NotificationListenerService.requestPermission();
      }

      NotificationListenerService.notificationsStream.listen((event) {
        if (event.packageName != "com.remote.pc_remote_client") {
          _wsService.sendCommand({
            'type': 'notification',
            'action': 'sync',
            'data': {
              'title': event.title ?? 'No Title',
              'content': event.content ?? 'No Content',
              'package': event.packageName,
            }
          });
        }
      });
    } catch (e) {
      print('Notification listener error: $e');
    }
  }

  void _initMessageListener() {
    _wsService.messageStream.listen((message) async {
      if (message['type'] == 'find_device' || (message['type'] == 'input' && message['action'] == 'ring')) {
        _showRingDialog();
      } else if (message['type'] == 'file' && message['action'] == 'receive') {
        _receiveFile(message['data']);
      }
    });
  }

  void _receiveFile(Map<String, dynamic> data) async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File receive is not supported on web')),
      );
      return;
    }

    try {
      final fileName = data['name'];
      final bytes = base64Decode(data['bytes']);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📁 File received: $fileName'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    } catch (e) {
      print('Error receiving file: $e');
    }
  }

  void _showRingDialog() async {
    if (!kIsWeb) {
      try {
        await _audioPlayer.play(AssetSource('ring.mp3'));
      } catch (e) {
        print('Error playing ring sound: $e');
      }
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🔔 PC is Ringing!'),
        content: const Text('Your computer is trying to find this device.'),
        actions: [
          FilledButton(
            onPressed: () {
              _audioPlayer.stop();
              Navigator.pop(context);
            },
            child: const Text('Stop Ringing'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    _audioPlayer.dispose();
    _wsService.disconnect();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCRemote'),
        elevation: 2,
        actions: [
          StreamBuilder<bool>(
            stream: _wsService.connectionStream,
            initialData: false,
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.settings_remote), text: 'Connect'),
            Tab(icon: Icon(Icons.mouse), text: 'Mouse'),
            Tab(icon: Icon(Icons.music_note), text: 'Media'),
            Tab(icon: Icon(Icons.web), text: 'Browser'),
            Tab(icon: Icon(Icons.window), text: 'Window'),
            Tab(icon: Icon(Icons.keyboard), text: 'Text'),
            Tab(icon: Icon(Icons.content_paste), text: 'Clipboard'),
            Tab(icon: Icon(Icons.file_present), text: 'Files'),
            Tab(icon: Icon(Icons.terminal), text: 'Commands'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ConnectionPanel(wsService: _wsService),
          MouseControlPanel(wsService: _wsService),
          MediaControlPanel(wsService: _wsService),
          BrowserControlPanel(wsService: _wsService),
          WindowControlPanel(wsService: _wsService),
          TextInputPanel(wsService: _wsService),
          ClipboardPanel(wsService: _wsService),
          FileSharePanel(wsService: _wsService),
          CommandsPanel(wsService: _wsService),
        ],
      ),
    );
  }
}
