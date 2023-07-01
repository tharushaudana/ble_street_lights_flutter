import 'package:ble_street_lights/components/celluarbar/celluarbar.dart';
import 'package:flutter/material.dart';

class DeviceDetailsDialog extends StatefulWidget {
  const DeviceDetailsDialog({super.key, required this.device, required this.onAddClicked});

  final List device;
  final VoidCallback onAddClicked;

  @override
  State<StatefulWidget> createState() => _DeviceDetailsDialogState();
}

class _DeviceDetailsDialogState extends State<DeviceDetailsDialog> {
  @override
  Widget build(BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          title: Row(
            children: [
              const Image(
                image: AssetImage("assets/images/device_icon.png"),
                width: 42,
                height: 42,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.device[0],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.device[1],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(width: 15),
              Stack(
                children: [
                  Container(
                    width: 33,
                    height: 15,
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${widget.device[2]} dBm",
                      style: const TextStyle(
                        fontSize: 7,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 38,
                    alignment: Alignment.centerRight,
                    child: CelluarBar(
                      width: 27,
                      rssi: widget.device[2],
                    ),
                  ),
                ],
              )
            ],
          ),
          content: Container(
            child: TextButton(
              onPressed: () => widget.onAddClicked(),
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 7),
                  Text("ADD"),
                ],
              ),
            ),
          ),
        );
  }

}