import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationFetcher extends StatefulWidget {
  const LocationFetcher({super.key});

  @override
  _LocationFetcherState createState() => _LocationFetcherState();
}

class _LocationFetcherState extends State<LocationFetcher> {
  String _locationMessage = "Fetching location...";
  String _address = "";

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Function to get user's current location
  Future<void> _getUserLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }

    // Check if the user has granted permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          _locationMessage = "Location permission denied.";
        });
        return;
      }
    }

    // Fetch the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get the latitude and longitude
    double latitude = position.latitude;
    double longitude = position.longitude;

    // Fetch the address using reverse geocoding from geocoding package
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      // If placemarks are found, extract the address details
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0]; // First placemark result
        setState(() {
          _locationMessage = "Lat: $latitude, Lng: $longitude";
          _address =
              '${place.street}, ${place.locality},${place.postalCode},${place.administrativeArea} ${place.country}';
        });
      } else {
        setState(() {
          _locationMessage = "No address found.";
          _address = "";
        });
      }
    } catch (e) {
      setState(() {
        _locationMessage = "Failed to fetch address.";
        _address = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Fetcher"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_locationMessage),
            SizedBox(height: 10),
            Text(_address),
          ],
        ),
      ),
    );
  }
}
