import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storegcargo/constants.dart';

class MapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  const MapPage({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialPos = CameraPosition(target: LatLng(latitude, longitude), zoom: 16);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: kTextRedWanningColor,
        title: Text('ตำแหน่งผู้รับ', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: GoogleMap(
        initialCameraPosition: initialPos,
        markers: {Marker(markerId: MarkerId('receiver'), position: LatLng(latitude, longitude))},
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}
