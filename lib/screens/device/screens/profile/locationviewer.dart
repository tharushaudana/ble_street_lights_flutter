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
    required this.onFullscreenClick,
    required this.onCreated,
  });

  final bool isPreview;
  final String deviceName;
  final LatLng position;
  final VoidCallback onFullscreenClick;
  final Function(GoogleMapController controller) onCreated;

  @override
  State<StatefulWidget> createState() => _DeviceLocationViewerState();
}

class _DeviceLocationViewerState extends State<DeviceLocationViewer> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final map = GoogleMap(
      mapType: MapType.hybrid,
      trafficEnabled: true,
      buildingsEnabled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: !widget.isPreview,
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
        widget.onCreated(controller);
        //_controller.complete(controller);
      },
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
                  onPressed: widget.onFullscreenClick,
                  child: const Icon(Icons.fullscreen_rounded),
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
