import 'dart:developer';

import 'package:flutter/material.dart';

class Helper {
  State? state;
  bool canNotifyStateChanges = true;

  void setStateClass(State state) {
    this.state = state;
  }

  void setNotifyStateChanges(bool b) {
    canNotifyStateChanges = b;
  }

  void setState(func) {
    if (state == null || !canNotifyStateChanges) {
      func();
      return;
    }

    state!.setState(func);
  }

  void dispose() {

  }
}