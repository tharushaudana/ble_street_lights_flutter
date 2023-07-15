import 'dart:convert';

class BLEDeviceMessage {
  static const int MSGTYPE_CURRENT_VALUES = 0;

  int type = -1;
  Map data = {};

  static BLEDeviceMessage? fromBytes(List<int> data) {
    String msg = utf8.decode(data);

    try {
      final json = jsonDecode(msg) as Map;
      
      if (!json.containsKey('t')) return null;

      final message = BLEDeviceMessage();

      message.type = json['t'];

      if (json.containsKey('d')) {
        message.data = json['d'];
      }

      return message;
    } catch(e) {
      return null;
    }
  }
}