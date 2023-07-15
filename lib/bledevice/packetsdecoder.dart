import 'dart:convert';

class PacketsDecoder {
  final _firstPacketStrPattern = RegExp(r'<s:(\d+)@(\d+)>');

  PacketsDecoder({
    required this.onStarted,
    required this.onMessage,
    required this.onFailed,
  });

  final Function onStarted;
  final Function onFailed;
  final Function(List<int> data) onMessage;

  List<int> data = [];

  bool startPacketReceived = false;
  int totalPackets = 0;
  int dataLen = 0;
  int receivedPackets = 0;

  bool processPacket(List<int> packet) {
    if (!startPacketReceived) {
      bool b = _decodeStartPacket(packet);
      if (b) onStarted();
      return b;
    } 

    if (receivedPackets < totalPackets) {
      data.addAll(packet);
      receivedPackets++;
    } else {
      _decodeEndPacket();
    }

    return true;
  }

  bool _decodeStartPacket(List<int> packet) {
    String str = utf8.decode(packet);

    if (!_firstPacketStrPattern.hasMatch(str)) return false;

    str = str.replaceAll(RegExp(r'<s:|>'), '');

    List<String> values = str.split(RegExp(r'@'));

    dataLen = int.parse(values[0]);
    totalPackets = int.parse(values[1]);

    if (dataLen <= 0 || totalPackets <= 0) {
      startPacketReceived = false;
      return false;
    }

    startPacketReceived = true;

    return true;
  }

  void _decodeEndPacket() {
    if (data.length == dataLen) {
      onMessage(data);
    } else {
      onFailed();
    }

    data.clear();

    startPacketReceived = false;
    totalPackets = 0;
    dataLen = 0;
    receivedPackets = 0;
  }
}
