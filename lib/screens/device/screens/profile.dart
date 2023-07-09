import 'package:ble_street_lights/components/wastyleappbar/wastyleappbar.dart';
import 'package:flutter/material.dart';

class DeviceProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DeviceProfileScreenState();
}

class _DeviceProfileScreenState extends State<DeviceProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          WaStyleAppBar(
            title: Text("Hello World"),
            image: Image(
              image: AssetImage("assets/images/device_icon.png"),
              width: 30,
              height: 30,
            ),
          ),
          /*SliverAppBar(
            leading: IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_back),
            ),
            expandedHeight: 168,
            pinned: true,
            titleSpacing: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              expandedTitleScale: 2.5,
              centerTitle: true,
              background: Container(
                color: Colors.blue,
              ),
              title: const Hero(
                tag: 'img_profile',
                child: Image(
                  image: AssetImage("assets/images/device_icon.png"),
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),*/
          /*const Hero(
            tag: 'img_profile',
            child: Image(
              image: AssetImage("assets/images/device_icon.png"),
              width: 90,
              height: 90,
            ),
          ),*/
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 400,
                  color: Colors.deepPurple[200],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 400,
                  color: Colors.deepPurple[200],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 400,
                  color: Colors.deepPurple[200],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
