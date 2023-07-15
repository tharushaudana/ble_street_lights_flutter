import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeviceLocationViewer extends StatefulWidget {
  const DeviceLocationViewer({
    super.key,
    this.isPreview = false,
    required this.deviceName,
    required this.position,
    required this.onEditClick,
  });

  final bool isPreview;
  final String deviceName;
  final LatLng position;
  final VoidCallback onEditClick;

  @override
  State<StatefulWidget> createState() => _DeviceLocationViewerState();
}

class _DeviceLocationViewerState extends State<DeviceLocationViewer> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  onLongPress(LatLng pos) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: Container(
            height: 210,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sync_rounded,
                  size: 90,
                  color: Colors.blue,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Sync is required for change device's location.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Nunito'),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("SYNC NOW"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final map = GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: CameraPosition(
        target: widget.position,
        zoom: 14.5,
      ),
      zoomControlsEnabled: false,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      markers: {
        Marker(
          markerId: const MarkerId("device_location"),
          position: widget.position,
          infoWindow: InfoWindow(
            title: widget.deviceName,
            //snippet: "lat: ${widget.position.latitude} \n lng: ${widget.position.longitude}",
          ),
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        controller.showMarkerInfoWindow(const MarkerId("device_location"));
        //_controller.complete(controller);
      },
      onLongPress: onLongPress,
    );

    //### Render the Widget

    if (widget.isPreview) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(0),
            ),
            child: map,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            color: Colors.black.withOpacity(0.6),
            child: Row(
              children: [
                const Icon(
                  Icons.my_location_rounded,
                  color: Colors.white,
                  size: 25,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Device's Location",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: widget.onEditClick,
                  child: const Icon(Icons.edit),
                  //color: Colors.blue,
                )
              ],
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Choose Location"),
        ),
        body: map,
      );
    }
  }
}
