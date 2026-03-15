import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../widgets/connection_panel.dart';
import '../widgets/mouse_control_panel.dart';
import '../widgets/media_control_panel.dart';
import '../widgets/browser_control_panel.dart';
import '../widgets/window_control_panel.dart';
import '../widgets/text_input_panel.dart';
import '../widgets/clipboard_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final WebSocketService _wsService = WebSocketService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
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
        ],
      ),
    );
  }
}
