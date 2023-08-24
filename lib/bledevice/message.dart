import 'dart:convert';
import 'dart:developer';

class BLEDeviceMessage {
  static const int MSGTYPE_CURRENT_VALUES = 0;
  static const int MSGTYPE_SETTINGS_DATA = 1;

  int type = -1;
  Map data = {};

  static BLEDeviceMessage? fromBytes(List<int> data) {
    try {
      String msg = utf8.decode(data);

      final json = jsonDecode(msg) as Map;
      
      if (!json.containsKey('t')) return null;

      final message = BLEDeviceMessage();

      message.type = json['t'];

      if (json.containsKey('d')) {
        message.data = json['d'];
      }

      return message;
    } catch(e) {
      log("utf8 decode error");
      log(e.toString());
      return null;
    }
  }
}