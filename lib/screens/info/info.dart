import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Info"),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "BLE STREET LIGHTS",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              "v1.0",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            Text("Developer Team", style: TextStyle(fontSize: 15, color: Colors.grey,),),
            SizedBox(height: 20),
            Text("Sanjula Nipun"),
            SizedBox(height: 5),
            Text("Chaminda Prasad"),
            SizedBox(height: 5),
            Text("Tharusha Udana"),
          ],
        ),
      ),
    );
  }
}
