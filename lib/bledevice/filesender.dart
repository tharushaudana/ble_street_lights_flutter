import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleFileSender {
  final int BUFFER_MAX_LEN = 16384;
  final int DATA_MTU = 500;

  int _total = 0;
  int _totalWritten = 0;

  late ByteBuffer _source;

  late BluetoothCharacteristic _tx;
  late BluetoothCharacteristic _rx;
  late StreamSubscription<List<int>> _rxValueSubscription;

  Function(int writtenLen)? _onWrite;
  VoidCallback? _onDone;

  BleFileSender(ByteBuffer source, BluetoothCharacteristic rx, BluetoothCharacteristic tx) {
    _source = source;
    _rx = rx;
    _tx = tx;

    _total = _source.lengthInBytes;

    log(_total.toString());

    _rxValueSubscription = _rx.lastValueStream.listen(null);

    _rxValueSubscription.onData((data) {
      if (data.length != 1) return;
  
      bool isWritten = data[0] == 1;

      if (!isWritten) return;

      _sendPart();
    });
  }

  listen(Function(int writtenLen) onWrite, VoidCallback onDone) {
    _onWrite = onWrite;
    _onDone = onDone;
  }

  start() {
    _sendPart();
  }

  /*_sendPart() async {
    int totalRemain = _total - _totalWritten;

    int bufLen = totalRemain < BUFFER_MAX_LEN ? totalRemain : BUFFER_MAX_LEN;

    int writtenDataLen = 0;
    
    while (writtenDataLen + DATA_MTU <= bufLen) {
      int remain = bufLen - writtenDataLen;

      int readLen = DATA_MTU;
      if (remain <= DATA_MTU) readLen = remain;

      Uint8List data = _source.asUint8List(_totalWritten, readLen);

      Uint8List packet = Uint8List(512);

      for (int i = 0; i < readLen; i++) {
        packet[i] = data[i];
      }

      await _tx.write(packet, withoutResponse: true);

      writtenDataLen += data.length;
    }

    _totalWritten += writtenDataLen;

    log("Written Part: " + writtenDataLen.toString() + " | " + _totalWritten.toString());

    if (_onWrite != null) _onWrite!(_totalWritten);

    if (_totalWritten != _total) {    
      //await _waitForResult();  
      return;
    } 

    _finishSend();
  }*/

  _sendPart() async {
    int totalRemain = _total - _totalWritten;

    int bufLen = totalRemain < BUFFER_MAX_LEN ? totalRemain : BUFFER_MAX_LEN;

    int written = 0;

    Uint8List buffer = _source.asUint8List(_totalWritten, bufLen);

    while (written < bufLen) {
      int bytesRemain = bufLen - written;
      int partSize = bytesRemain < DATA_MTU ? bytesRemain : DATA_MTU;

      Uint8List bytes = Uint8List(partSize);
      for (int i = 0; i < partSize; i++) {
        bytes[i] = buffer[written + i];
      }

      Uint8List packet = _createPacket(bytes);

      await _writePacket(packet);

      written += partSize;
    }

    _totalWritten += bufLen;

    log("Written Buff: $bufLen | $_totalWritten");

    if (_onWrite != null) _onWrite!(_totalWritten);

    if (_totalWritten != _total) return;

    _finishSend();
  }

  _writePacket(Uint8List packet) async {
    await _tx.write(packet, withoutResponse: true);
  }

  Uint8List _createPacket(Uint8List dataBytes) {
    Uint8List packet = Uint8List(512);

    for (int i = 0; i < dataBytes.length; i++) {
      packet[i] = dataBytes[i];
    }

    return packet;
  }

  _finishSend() {
    if (_onDone != null) _onDone!();
    
    _rxValueSubscription.cancel();
    _onWrite = null;
    _onDone = null;
  }
}