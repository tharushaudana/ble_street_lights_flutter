import 'dart:async';
import 'dart:developer';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/data.dart';
import 'package:ble_street_lights/bledevice/message.dart';
import 'package:ble_street_lights/bledevice/packetsdecoder.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:ble_street_lights/bledevice/requesthandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDevice extends BLEDeviceConnectionProviderLink {
  final String _characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  late BluetoothDevice device;
  late BLEDeviceData deviceData;

  late PacketsDecoder _packetsDecoder;
  late BLEDeviceRequestHandler _requestHandler;

  StreamSubscription<BluetoothDeviceState>? _stateSubscription;
  StreamSubscription<List<int>>? _characteristicValueStateSubscription;
  BluetoothCharacteristic? _characteristic;

  bool _isConnecting = false;

  final VoidCallback onConnected;
  final VoidCallback onDisconnected;
  final Function(BLEDeviceMessage message)? onMessage;

  BLEDevice(
    String id, {
    required this.onConnected,
    required this.onDisconnected,
    this.onMessage,
  }) {
    device = BluetoothDevice.fromId(id);
    deviceData = BLEDeviceData();

    _requestHandler = BLEDeviceRequestHandler();

    _packetsDecoder = PacketsDecoder(
      onStarted: () {},
      onMessage: (data) {
        log("message llllllll llkk");
        BLEDeviceMessage? message = BLEDeviceMessage.fromBytes(data);

        if (message == null) {
          return;
        }

        _saveAndNotifyRequiredData(message);

        _requestHandler.watchForResponse(message);

        if (onMessage != null) onMessage!(message);
      },
      onFailed: () {},
    );
  }

  @override
  initLink() {
    notifyDeviceDataChange(deviceData);
    return super.initLink();
  }

  @override
  void makeRequest(BLEDeviceRequest request) {
    if (!deviceData.isConnected) return;
    _requestHandler.handle(request);
  }

  _saveAndNotifyRequiredData(BLEDeviceMessage message) {
    switch (message.type) {
      case BLEDeviceMessage.MSGTYPE_CURRENT_VALUES:
        deviceData.currentValues = message.data;
        notifyDeviceDataChange(deviceData);
        break;
    }
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
      // ignore: empty_catches
    } catch (e) {}
  }

  _listenStateChanges() {
    _stateSubscription = device.state.listen(null);

    _stateSubscription!.onData((BluetoothDeviceState state) {
      if (state == BluetoothDeviceState.connected) {
        onConnected();
        _getCharacteristic();
        deviceData.isConnected = true;
        notifyDeviceDataChange(deviceData);
      } else if (state == BluetoothDeviceState.disconnected) {
        onDisconnected();
        deviceData.isConnected = false;
        notifyDeviceDataChange(deviceData);
        _characteristicValueStateSubscription!.cancel();
      }
    });
  }

  _getCharacteristic() async {
    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString() == _characteristicUuid) {
          _characteristic = c;
          break;
        }
      }
    }

    if (_characteristic != null) {
      _characteristic!.setNotifyValue(true);

      _characteristicValueStateSubscription =
          _characteristic!.value.listen(null);

      _characteristicValueStateSubscription!.onData((data) {
        if (_packetsDecoder.processPacket(data)) {
          //String msg = utf8.decode(data);
          //if (msg.trim().isEmpty) return;
          //Do something...
        }
      });
    }

    _requestHandler.characteristic = _characteristic;
  }
}
