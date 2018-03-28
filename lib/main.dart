import 'package:attendance/homepage.dart';
import 'package:attendance/splash.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Attendee',
      theme: new ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.blue,
      ),
      home: new SplashScreen(),
    );
  }
}


