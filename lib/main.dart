import 'package:flutter/material.dart';
import 'package:flutter_location/geo.dart';
import 'package:flutter_location/home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationFetcher(),
    );
  }
}
