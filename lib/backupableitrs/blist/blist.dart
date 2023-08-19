import 'dart:collection';

import 'package:ble_street_lights/backupableitrs/bmap/bmap.dart';

class BList extends ListBase<dynamic> {
  List _innerList = [];

  final List _previousList = [];

  List backupableChilds = [];
  
  BList(List list) {
    _innerList = list;

    for (dynamic v in list) {
      if (v.runtimeType == BMap || v.runtimeType == BList) {
        backupableChilds.add(v);
      }
    }

    _previousList.addAll(_innerList);
  }

  restoreBackup() {
    _innerList.clear();
    _innerList.addAll(_previousList);

    for (dynamic child in backupableChilds) {
      child.restoreBackup();
    }
  }

  clearBackup() {
    _previousList.clear();
    _previousList.addAll(_innerList);

    for (dynamic child in backupableChilds) {
      child.clearBackup();
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
  removeAt(int index) {
    return _innerList.removeAt(index);
  }
  
  @override
  set length(int newLength) {
    _innerList.length = newLength;
  }
}