import 'package:flutter/material.dart';

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Container(
        child: Stack(
          children: [
            Image.asset(
              'images/back.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
