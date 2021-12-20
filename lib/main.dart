import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature = 0;
  String location = 'Ahmedabad';
  int woeid = 2295402;
  String weather = 'clear';
  int windspeed = 0;
  int humidity = 0;
  String abbreviation = '';
  List<int> minTemp = List.filled(7, 0);
  List<int> maxTemp = List.filled(7, 0);
  List<String> abbForecast = List.filled(7, '');

  //String weather = 'clear';
  //String weather = 'clear';
  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  initState() {
    // TODO: implement initState
    super.initState();
    fetchLocation();
    getLocationDay();
  }

  void fetchSearch(String input) async {
    var searchResult = await http.get(searchApiUrl + input);
    var result = json.decode(searchResult.body)[0];
    //print(result);
    setState(() {
      location = result["title"];
      woeid = result["woeid"];
    });
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];
    print(data);

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
      windspeed = data["wind_speed"].round();
      humidity = data["humidity"].round();
    });
  }

  void getLocationDay() async {
    var today = new DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(locationApiUrl +
          woeid.toString() +
          '/' +
          new DateFormat('y/M/d')
              .format(today.add(new Duration(days: i + 1)))
              .toString());
      var result = json.decode(locationDayResult.body);
      var data = result[0];

      setState(() {
        minTemp[i] = data["min_temp"].round();
        maxTemp[i] = data["max_temp"].round();
        abbForecast[i] = data["weather_state_abbr"];
      });
    }
  }

  void onTextFieldSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
    await getLocationDay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/back_weather.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 300,
                      child: TextField(
                        onSubmitted: (String input) {
                          onTextFieldSubmitted(input);
                        },
                        style: TextStyle(color: Colors.white, fontSize: 25),
                        decoration: InputDecoration(
                          hintText: 'Enter the Location',
                          hintStyle:
                          TextStyle(color: Colors.white, fontSize: 18.0),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Center(
                      child: Image.network(
                        'https://www.metaweather.com/static/img/weather/png/' +
                            abbreviation +
                            '.png',
                        width: 75,
                      ),
                    ),

                    Center(
                      child: Text(
                        temperature.toString() + ' °C',
                        style: TextStyle(color: Colors.white, fontSize: 60.0),
                      ),
                    ),
                    Center(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.white, fontSize: 40.0),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Humidity: ' + humidity.toString() + ' %',
                        style: TextStyle(color: Colors.white, fontSize: 25.0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.speed_sharp, color: Colors.white),
                        Text(
                          ' ' + windspeed.toString() + ' Mph',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ],
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for (var i = 0; i < 7; i++)
                        forecastElement(
                            i + 1,
                            abbForecast[i],
                            minTemp[i],
                            maxTemp[i]),
                    ],
                  ),
                ),

              ],
            ),
          )),
    );
  }
}

Widget forecastElement(
    daysFromNow, abbreviation, minTemperature, maxTemperature) {
  var now = new DateTime.now();
  var oneDayFromNow = now.add(new Duration(days: daysFromNow));
  return Padding(
    padding: const EdgeInsets.only(left: 16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              new DateFormat.E().format(oneDayFromNow),
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            Text(
              new DateFormat.MMMd().format(oneDayFromNow),
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Image.network(
                'https://www.metaweather.com/static/img/weather/png/' +
                    abbreviation +
                    '.png',
                width: 50,
              ),
            ),
            Text(
              'High: ' + maxTemperature.toString() + ' °C',
              style: TextStyle(color: Colors.black, fontSize: 20.0),
            ),
            Text(
              'Low: ' + minTemperature.toString() + ' °C',
              style: TextStyle(color: Colors.black, fontSize: 20.0),
            ),
          ],
        ),
      ),
    ),
  );
}
