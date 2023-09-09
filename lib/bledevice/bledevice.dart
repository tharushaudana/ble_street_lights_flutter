import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:ble_street_lights/bledevice/connectionprovider.dart';
import 'package:ble_street_lights/bledevice/data.dart';
import 'package:ble_street_lights/bledevice/filesender.dart';
import 'package:ble_street_lights/bledevice/message.dart';
import 'package:ble_street_lights/bledevice/packetsdecoder.dart';
import 'package:ble_street_lights/bledevice/request.dart';
import 'package:ble_street_lights/bledevice/requesthandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDevice extends BLEDeviceConnectionProviderLink {
  final String _characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String _characteristicUuidOtaTx = "beb5483e-36e1-4688-b7f5-ea07361b26a9";
  final String _characteristicUuidOtaRx = "beb5483e-36e1-4688-b7f5-ea07361b26a7";

  late BluetoothDevice device;

  late PacketsDecoder _packetsDecoder;
  late BLEDeviceRequestHandler _requestHandler;

  StreamSubscription<BluetoothConnectionState>? _stateSubscription;
  StreamSubscription<List<int>>? _characteristicValueStateSubscription;
  BluetoothCharacteristic? _characteristic;
  BluetoothCharacteristic? _characteristicOtaTx;
  BluetoothCharacteristic? _characteristicOtaRx;

  bool _isConnecting = false;

  final int requestMtu = 512;
  final int fileWriteMtu = 500;

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
    if (!deviceData.isConnected || _characteristicOtaTx == null || _characteristicOtaRx == null) return;

    await device.requestMtu(requestMtu);

    final sender = BleFileSender(buffer, _characteristicOtaRx!, _characteristicOtaTx!);
    sender.listen(onWrite, onDone);
    sender.start();

    /*int totalLen = buffer.lengthInBytes;
    int writtenLen = 0;

    while (writtenLen < totalLen) {
      int remain = totalLen - writtenLen;

      int readLen = fileWriteMtu;
      if (remain <= fileWriteMtu) readLen = remain;

      Uint8List bytes = buffer.asUint8List(writtenLen, readLen);

      Uint8List packet = Uint8List(requestMtu);

      //### fill the packet...
      for (int i = 0; i < fileWriteMtu; i++) {
        if (i == bytes.length) break;
        packet[i] = bytes[i];
      }

      await _characteristicOtaTx!.write(
        packet,
        withoutResponse: true,
      );

      writtenLen += bytes.length;

      onWrite(writtenLen);

      await Future.delayed(const Duration(milliseconds: 40));
    }

    onDone();*/
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
        deviceData.setOtaValues(message.data);
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
    _stateSubscription = device.connectionState.listen(null);

    _stateSubscription!.onData((BluetoothConnectionState state) {
      if (state == BluetoothConnectionState.connected) {
        onConnected();
        _getCharacteristic();
        deviceData.isConnected = true;
        notifyDeviceDataChange(deviceData);
      } else if (state == BluetoothConnectionState.disconnected) {
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
        if (c.uuid.toString() == _characteristicUuidOtaTx) {
          _characteristicOtaTx = c;
        }
        if (c.uuid.toString() == _characteristicUuidOtaRx) {
          _characteristicOtaRx = c;
        }
      }
    }

    if (_characteristic != null) {
      await _characteristic!.setNotifyValue(true);

      _characteristicValueStateSubscription =
          _characteristic!.lastValueStream.listen(null);

      _characteristicValueStateSubscription!.onData((data) {
        if (_packetsDecoder.processPacket(data)) {
          //String msg = utf8.decode(data);
          //if (msg.trim().isEmpty) return;
          //Do something...
        }
      });
    }

    if (_characteristicOtaRx != null) {
      await _characteristicOtaRx!.setNotifyValue(true);
    }

    _requestHandler.characteristic = _characteristic;
  }
}
