import 'dart:collection';

import 'package:ble_street_lights/backupableitrs/bmap/bmap.dart';

class BList extends ListBase<dynamic> {
  List _innerList = [];

  final List _previousList = [];
  
  BList(List list) {
    _innerList = list;
    _previousList.addAll(_innerList);
  }

  restoreBackup() {
    _innerList.clear();
    _innerList.addAll(_previousList);

    notifyChilds((child) => child.restoreBackup());
  }

  clearBackup() {
    _previousList.clear();
    _previousList.addAll(_innerList);

    notifyChilds((child) => child.clearBackup());
  }

  notifyChilds(Function (dynamic child) cb) {
    for (dynamic v in _innerList) {
      if (v.runtimeType == BMap || v.runtimeType == BList) {
        cb(v);
      }
    }
  }
  
  @override
  int get length => _innerList.length;

  @override
  operator [](int index) {
    return _innerList[index];
  }

  @override
  void operator []=(int index, value) {
    _innerList[index] = value;
  }

  @override
  void add(element) {
    _innerList.add(element);
  }

  @override
  void clear() {
    _innerList.clear();
  }

  @override
  removeAt(int index) {
    return _innerList.removeAt(index);
  }
  
  @override
  set length(int newLength) {
    _innerList.length = newLength;
  }
}