import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapsPage extends StatefulWidget {
  LocationData locationData;

  GoogleMapsPage({this.locationData}) {
    if (locationData == null) {
      locationData =
          LocationData.fromMap({'lat': -9.5761606, 'lng': -35.7549023});
    }
  }

  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition cameraPosition;

  Set<Marker> markers = Set();
  LocationData locationData;
  @override
  void initState() {
    if (widget.locationData.latitude != null &&
        widget.locationData.longitude != null) {
      locationData = widget.locationData;
    } else {
      print('entrou no else');
      locationData = LocationData.fromMap(
          {'latitude': -9.5761606, 'longitude': -35.7549023});
    }
    cameraPosition = CameraPosition(
        target: LatLng(
          locationData.latitude,
          locationData.longitude,
        ),
        zoom: 16);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (markers.isEmpty)
            Get.dialog(AlertDialog(
              title: Text('Localização não salva'),
              content: Text('Deseja realmente sair sem a localização?'),
              actions: [
                FlatButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('CANCELAR')),
                FlatButton(
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    child: Text('SAIR'))
              ],
            ));
          else
            Get.back(result: markers.first.position);
        },
        child: Icon(Icons.check),
      ),
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          initialCameraPosition: cameraPosition,
          markers: markers,
          onTap: (LatLng latLng) {
            setState(() {
              if (markers.isNotEmpty) markers = Set();
              markers.add(Marker(markerId: MarkerId('asd'), position: latLng));
              print('markers: ${markers.first}');
            });
          },
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
