import 'package:flutter/material.dart';
import 'package:google_map/MapScreen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {

  checkLocationPermission;

  runApp(
    MaterialApp(
      home: Scaffold(
        body: MapScreen(),
      ),
    ),
  );
}

void checkLocationPermission() async {
  if (await Permission.location.request().isGranted) {
  } else {
  }
}