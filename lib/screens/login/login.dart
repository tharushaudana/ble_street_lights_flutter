import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            child: Image(
              image: AssetImage("assets/images/street1.jpg"),
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(left: 20, right: 20, top: 200,),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 0),
                    blurRadius: 10,
                    blurStyle: BlurStyle.outer
                    //spreadRadius: 2,
                  ),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
          )
        ],
      ),
    );
  }
}
