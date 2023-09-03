import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
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
  final String _characteristicUuidOta = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  late BluetoothDevice device;

  late PacketsDecoder _packetsDecoder;
  late BLEDeviceRequestHandler _requestHandler;

  StreamSubscription<BluetoothDeviceState>? _stateSubscription;
  StreamSubscription<List<int>>? _characteristicValueStateSubscription;
  BluetoothCharacteristic? _characteristic;
  BluetoothCharacteristic? _characteristicOta;

  bool _isConnecting = false;

  final VoidCallback onConnected;
  final VoidCallback onDisconnected;
  final Function(BLEDeviceMessage message)? onMessage;
  final VoidCallback? onWrongMessage;

  BLEDevice(
    String id, {
    required this.onConnected,
    required this.onDisconnected,
    this.onMessage,
    this.onWrongMessage,
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
          if (onWrongMessage != null) onWrongMessage!();
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
  void makeRequest(BLEDeviceRequest request) {
    if (!deviceData.isConnected) return;
    _requestHandler.handle(request);
  }

  @override
  void sendFirmwareFile(
    ByteBuffer buffer, {
    required Function(int writtenLen) onWrite,
    required VoidCallback onDone,
  }) async {
    if (!deviceData.isConnected || _characteristicOta == null) return;

    int totalLen = buffer.lengthInBytes;
    int writtenLen = 0;

    while (writtenLen < totalLen) {
      int remain = totalLen - writtenLen;
      
      int readLen = 512;
      if (remain <= 512) readLen = remain;

      Uint8List bytes = buffer.asUint8List(writtenLen, readLen);
      writtenLen += bytes.length;
      await _characteristicOta!.write(bytes, withoutResponse: true);
      onWrite(writtenLen);
    }

    onDone();
  }

  _saveAndNotifyRequiredData(BLEDeviceMessage message) {
    switch (message.type) {
      case BLEDeviceMessage.MSGTYPE_CURRENT_VALUES:
        deviceData.setCurrentValues(message.data);
        notifyDeviceDataChange(deviceData);
        break;
      case BLEDeviceMessage.MSGTYPE_SETTINGS_DATA:
        deviceData.setSettingValues(message.data);
        notifyDeviceDataChange(deviceData);
        break;
      case BLEDeviceMessage.MSGTYPE_FIRMWARE_UPDATE_RESULT:
        deviceData.setFirmwareUpdateResult();
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
      _isConnecting = false;
    } catch (e) {
      _isConnecting = false;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await device.disconnect();
      // ignore: empty_catches
    } catch (e) {}
  }

  dispose() {
    _stateSubscription?.cancel();
    _characteristicValueStateSubscription?.cancel();
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
        }
        if (c.uuid.toString() == _characteristicUuidOta) {
          _characteristicOta = c;
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
