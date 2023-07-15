import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDevice {
  final String _characteristic_uuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  late BluetoothDevice device;

  StreamSubscription<BluetoothDeviceState>? _stateSubscription;
  StreamSubscription<List<int>>? _characteristicValueStateSubscription;
  BluetoothCharacteristic? _characteristic;

  bool _isConnecting = false;

  final VoidCallback onConnected;
  final VoidCallback onDisconnected;

  BLEDevice(
    String id, {
    required this.onConnected,
    required this.onDisconnected,
  }) {
    device = BluetoothDevice.fromId(id);
  }

  Future<void> connect(int timeoutMillis) async {
    if (_isConnecting) return;

    _isConnecting = true;

    try {
      await device.connect(
        autoConnect: true,
        timeout: Duration(milliseconds: timeoutMillis),
      );
      _listenStateChanges();
    } catch (e) {
      _isConnecting = false;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _stateSubscription?.cancel();
    _characteristicValueStateSubscription?.cancel();
    try {
      await device.disconnect();
    } catch (e) {
      
    }
  }

  _listenStateChanges() {
    _stateSubscription = device.state.listen(null);

    _stateSubscription!.onData((BluetoothDeviceState state) {
      if (state == BluetoothDeviceState.connected) {
        onConnected();
      } else if (state == BluetoothDeviceState.disconnected) {
        onDisconnected();
      }
    });
  }
}
