import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  TextEditingController zipcodeController = TextEditingController();

  Future<Map<String, String>> fetchLocationDetails(String pincode) async {
    final url =
        'https://api.postalpincode.in/pincode/$pincode'; // API endpoint for Indian PIN codes

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[0]['Status'] == 'Success') {
          final String city = data[0]['PostOffice'][0]['Division'];
          final String state = data[0]['PostOffice'][0]['State'];

          return {'city': city, 'state': state};
        } else {
          throw Exception('Invalid PIN code');
        }
      } else {
        throw Exception('Failed to load location details');
      }
    } catch (e) {
      throw Exception('Error fetching location details: $e');
    }
  }

  String city = '';
  String state = '';
  void _onPincodeChanged(String pincode) async {
    if (pincode.length == 6) {
      // India has 6-digit PIN codes
      try {
        final locationDetails = await fetchLocationDetails(pincode);
        setState(() {
          city = locationDetails['city'] ?? '';
          state = locationDetails['state'] ?? '';
        });
      } catch (e) {
        setState(() {
          city = '';
          state = '';
        });
        print('Error fetching location details: $e');
      }
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
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: zipcodeController,
              decoration: const InputDecoration(
                labelText: 'PIN Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: _onPincodeChanged,
            ),
            SizedBox(height: 20),
            Text('City: $city'),
            Text('State: $state'),
          ],
        ),
      ),
    );
  }
}
