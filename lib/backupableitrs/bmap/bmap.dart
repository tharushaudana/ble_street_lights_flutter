import 'dart:collection';

import 'package:ble_street_lights/backupableitrs/blist/blist.dart';

class BMap extends MapBase<dynamic, dynamic> {
  late Map<dynamic, dynamic> _innerMap = {};

  final Map _previousMap = {};
  
  BMap (Map<dynamic, dynamic> map) {
    _innerMap = map;
    _previousMap.addAll(_innerMap);
  }

  restoreBackup() {
    _innerMap.clear();
    _innerMap.addAll(_previousMap);

    notifyChilds((child) => child.restoreBackup());
  }

  clearBackup() {
    _previousMap.clear();
    _previousMap.addAll(_innerMap);

    notifyChilds((child) => child.clearBackup());
  }  

  notifyChilds(Function (dynamic child) cb) {
    for (dynamic v in _innerMap.values) {
      if (v.runtimeType == BMap || v.runtimeType == BList) {
        cb(v);
      }
    }
  }

  @override
  dynamic operator [](Object? key) {
    return _innerMap[key];
  }

  @override
  void operator []=(dynamic key, dynamic value) {
    if (_innerMap.containsKey(key) && !_previousMap.containsKey(key)) {
      _previousMap[key] = _innerMap[key];
    }

    _innerMap[key] = value;
  }

  @override
  void clear() {
    _innerMap.clear();
    _previousMap.clear();
  }

  @override
  String? remove(Object? key) {
    return _innerMap.remove(key);
  }
  
  @override
  Iterable<dynamic> get keys => _innerMap.keys;

  @override
  Iterable<dynamic> get values => _innerMap.values;
}