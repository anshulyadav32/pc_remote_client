import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  static const String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String characteristicUuid = "0000ffe1-0000-1000-8000-00805f9b34fb";

  fb.BluetoothDevice? _connectedDevice;
  fb.BluetoothCharacteristic? _targetCharacteristic;
  StreamSubscription<List<fb.ScanResult>>? _scanSubscription;
  final _scanResultsController = StreamController<List<fb.ScanResult>>.broadcast();

  Stream<List<fb.ScanResult>> get scanResults => _scanResultsController.stream;
  bool get isConnected => _connectedDevice != null;

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> startScan() async {
    if (await fb.FlutterBluePlus.isSupported == false) return;

    await _scanSubscription?.cancel();
    _scanSubscription = fb.FlutterBluePlus.onScanResults.listen((results) {
      _scanResultsController.add(results);
    });

    await fb.FlutterBluePlus.startScan(
      withServices: [fb.Guid(serviceUuid)],
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> stopScan() async {
    await fb.FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<bool> connect(fb.BluetoothDevice device) async {
    try {
      await device.connect(license: fb.License.free);
      _connectedDevice = device;

      final services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == serviceUuid) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == characteristicUuid) {
              _targetCharacteristic = characteristic;
              break;
            }
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint("Connection error: $e");
      return false;
    }
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _targetCharacteristic = null;
  }

  Future<void> sendCommand(String command) async {
    if (_targetCharacteristic != null) {
      await _targetCharacteristic!.write(command.codeUnits);
    }
  }
}
