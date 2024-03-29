import 'dart:convert';
import 'dart:developer';
import 'dart:io';

class BLEDeviceMessage {
  static const int MSGTYPE_CURRENT_VALUES = 0;
  static const int MSGTYPE_SETTINGS_DATA = 1;
  static const int MSGTYPE_FIRMWARE_UPDATE_RESULT = 2;

  int type = -1;
  Map data = {};

  static BLEDeviceMessage? fromBytes(List<int> data) {
    try {
      //String msg = utf8.decode(data);
      String msg = bytesToString(data);

      final json = jsonDecode(msg) as Map;

      if (!json.containsKey('t')) return null;

      final message = BLEDeviceMessage();

      message.type = json['t'];

      if (json.containsKey('d')) {
        message.data = json['d'];
      }

      return message;
    } catch (e) {
      log("decode error");
      log(e.toString());
      return null;
    }
  }

  static bytesToString(List<int> data) {
    String s = const AsciiDecoder(
      allowInvalid: true,
    ).convert(data);
    return s;
  }
}
