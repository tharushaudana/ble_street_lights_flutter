import 'dart:collection';

import 'package:ble_street_lights/backupableitrs/blist/blist.dart';

class BMap extends MapBase<dynamic, dynamic> {
  late Map<dynamic, dynamic> _innerMap = {};

  final Map _previousMap = {};

  List backupableChilds = [];
  
  BMap (Map<dynamic, dynamic> map) {
    _innerMap = map;

    for (dynamic v in map.values) {
      if (v.runtimeType == BMap || v.runtimeType == BList) {
        backupableChilds.add(v);
      }
    }

    _previousMap.addAll(_innerMap);
  }

  restoreBackup() {
    _innerMap.clear();
    _innerMap.addAll(_previousMap);

    for (dynamic child in backupableChilds) {
      child.restoreBackup();
    }
  }

  clearBackup() {
    _previousMap.clear();
    _previousMap.addAll(_innerMap);

    for (dynamic child in backupableChilds) {
      child.clearBackup();
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