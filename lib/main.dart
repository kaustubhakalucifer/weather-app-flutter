import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

void main() => runApp(
  const MaterialApp(
    title: 'Weather App',
    home: Home(),
  ),
);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var temp;
  var feelsLike;
  var description;
  var currently;
  var humidity;
  var windspeed;
  var location;

  Future getWeather(String latitude, String longitude) async {
    http.Response response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=b724a55a85e1895be941e0bb4db4a759"));
    var results = jsonDecode(response.body);
    setState(() {
      this.temp = results['main']['temp'];
      this.feelsLike = results['main']['feels_like'];
      this.description = results['weather'][0]['description'];
      this.currently = results['weather'][0]['main'];
      this.humidity = results['main']['humidity'];
      this.windspeed = results['wind']['speed'];
      this.location = results['name'];
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled, please enable')),
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are denied"))
        );
        return false;
      }
    }

    if(permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions'))
      );
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if(!hasPermission) return;
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    ).then((Position position) {
      getWeather(position.latitude.toString(), position.longitude.toString());
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple Weather Application"),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(onPressed: (){}, icon: const FaIcon(FontAwesomeIcons.circleHalfStroke))
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
            width: MediaQuery.of(context).size.width,
            color: Colors.blue.shade400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                        location != null ? "Currently in $location" : 'Detecting location',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                ),
                Text(
                  temp != null ? "$temp\u00B0" : "Loading",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    currently != null ? currently.toString() : "Loading",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.temperatureFull),
                  title: const Text("Actual Temperature"),
                  trailing: Text(temp != null ? "$temp\u00B0" : "Loading"),
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.temperatureHalf),
                  title: const Text("Feels like"),
                  trailing: Text(feelsLike != null ? "$feelsLike\u00B0" : "Loading"),
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.cloud),
                  title: const Text("Weather"),
                  trailing: Text(description != null ? description.toString() : "Loading"),
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.sun),
                  title: const Text("Humidity"),
                  trailing: Text(humidity != null ? humidity.toString() : "Loading"),
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.wind),
                  title: const Text("Wind Speed"),
                  trailing: Text(windspeed != null ? windspeed.toString() : "Loading"),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}