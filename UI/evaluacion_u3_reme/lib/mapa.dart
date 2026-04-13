import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatelessWidget {
  final double lat;
  final double lng;

  const MapaPage({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubicación")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, lng),
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("entrega"),
            position: LatLng(lat, lng),
          )
        },
      ),
    );
  }
}