import 'package:flutter/foundation.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class ServerBluetoothService {
  static final ServerBluetoothService _instance = ServerBluetoothService._internal();
  factory ServerBluetoothService() => _instance;
  ServerBluetoothService._internal();

  static const String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String characteristicUuid = "0000ffe1-0000-1000-8000-00805f9b34fb";

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  Future<void> startAdvertising(String serverName) async {
    final AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: serviceUuid,
      localName: serverName,
    );

    if (await _peripheral.isSupported) {
      await _peripheral.start(advertiseData: advertiseData);
      debugPrint("Bluetooth Advertising started: $serverName");
    } else {
      debugPrint("Bluetooth Peripheral mode not supported on this device.");
    }
  }

  Future<void> stopAdvertising() async {
    await _peripheral.stop();
    debugPrint("Bluetooth Advertising stopped.");
  }

  Stream<PeripheralState> get state => _peripheral.onPeripheralStateChanged ?? Stream<PeripheralState>.empty();
}
