import 'package:flutter/material.dart';

class SafeState<T extends StatefulWidget> extends State<T> {  
  bool disposed = false;
  
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  void setState(VoidCallback fn) {
    if (disposed) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}