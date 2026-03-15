import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyService {
  static final NearbyService _instance = NearbyService._internal();
  factory NearbyService() => _instance;
  NearbyService._internal();

  static const String serviceId = "com.remote.pc_remote.nearby";
  static const Strategy strategy = Strategy.P2P_POINT_TO_POINT;

  final Map<String, ConnectionInfo> endpointMap = {};
  String? connectedEndpointId;

  // Callback for when data is received (for server mode)
  Function(String)? onCommandReceived;

  Future<bool> checkPermissions() async {
    final statuses = await Future.wait([
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].map((p) => p.status));

    return statuses.every((s) => s.isGranted);
  }

  Future<void> askPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();
  }

  // SERVER ROLE: Start advertising to be found by other phones
  Future<void> startAdvertising(String deviceName) async {
    try {
      await Nearby().startAdvertising(
        deviceName,
        strategy,
        onConnectionInitiated: (id, info) {
          endpointMap[id] = info;
          Nearby().acceptConnection(id, onPayLoadRecieved: (endpointId, payload) {
            if (payload.type == PayloadType.BYTES) {
              String str = utf8.decode(payload.bytes!);
              onCommandReceived?.call(str);
            }
          });
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            connectedEndpointId = id;
          }
        },
        onDisconnected: (id) {
          endpointMap.remove(id);
          if (connectedEndpointId == id) connectedEndpointId = null;
        },
        serviceId: serviceId,
      );
    } catch (e) {
      debugPrint("Advertising error: $e");
    }
  }

  // CLIENT ROLE: Start discovering other phones
  Future<void> startDiscovery(String userName, Function(String, String) onDeviceFound) async {
    try {
      await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          onDeviceFound(id, name);
        },
        onEndpointLost: (id) {
          // Handle lost endpoint
        },
        serviceId: serviceId,
      );
    } catch (e) {
      debugPrint("Discovery error: $e");
    }
  }

  Future<void> connectToDevice(String userName, String endpointId) async {
    await Nearby().requestConnection(
      userName,
      endpointId,
      onConnectionInitiated: (id, info) {
        Nearby().acceptConnection(id, onPayLoadRecieved: (id, payload) {});
      },
      onConnectionResult: (id, status) {
        if (status == Status.CONNECTED) {
          connectedEndpointId = id;
        }
      },
      onDisconnected: (id) {
        if (connectedEndpointId == id) connectedEndpointId = null;
      },
    );
  }

  Future<void> sendCommand(String command) async {
    if (connectedEndpointId != null) {
      await Nearby().sendBytesPayload(connectedEndpointId!, utf8.encode(command));
    }
  }

  Future<void> stopAll() async {
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    await Nearby().stopAllEndpoints();
    connectedEndpointId = null;
    endpointMap.clear();
  }
}
