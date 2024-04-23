import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _greenlandCenterPosition = LatLng(37.5665, 126.9780);
  Set<Marker> _markers = {};
  final Set<String> _storeTypes = {'lotto'};
  Location _location = Location();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Greenland Center'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _searchAndShowConvenienceStores();
        },
        initialCameraPosition: CameraPosition(
          target: _greenlandCenterPosition,
          zoom: 12,
        ),*-
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _searchAndShowConvenienceStores();
        },
      ),
    );
  }

  void _searchAndShowConvenienceStores() async {
    try {
      LocationData currentLocation = await _location.getLocation();

      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 15.0,
        ),
      ));

      final places.PlacesSearchResponse placesResponse =
          await places.GoogleMapsPlaces(
        apiKey: "AIzaSyA8CylSYIoBRKgT1OdyIOa7iWEFSGoVVYs",
      ).searchNearbyWithRadius(
        places.Location(
          lat: currentLocation.latitude!,
          lng: currentLocation.longitude!,
        ),
        30000,
        keyword: _storeTypes.first,
      );

      final Set<Marker> markers = {};

      print("PlaceResponse : " + placesResponse.results.length.toString());

      if (placesResponse.results.isNotEmpty) {
        setState(() {
          placesResponse.results.forEach((result) {
            final Marker marker = Marker(
              markerId: MarkerId(result.placeId),
              position: LatLng(
                result.geometry!.location.lat,
                result.geometry!.location.lng,
              ),
              infoWindow: InfoWindow(title: result.name),
            );
            markers.add(marker);
          });
          _markers = markers;
        });
      } else {
        print('No convenience stores found.');
      }
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  Future<void> _requestPermission() async {
    if (await Permission.location.request().isGranted) {
      LocationData currentLocation = await _location.getLocation();
      setState(() {
        _greenlandCenterPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      });
    }
  }
}
