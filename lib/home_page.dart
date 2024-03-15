import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'apiData.dart' as api;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<HomePage> {
  bool isLoaded = false;
  num? temp;
  num? press;
  num? hum;
  num? cover;
  num? air_speed;
  String cityname = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white,
        backgroundColor:
            const Color.fromARGB(255, 151, 207, 253).withOpacity(0.75),
        title: const Text(
          "Weather",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 151, 207, 253),
        child: Visibility(
          visible: isLoaded,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: ListView(
              children: <Widget>[
                searchBar(),
                SizedBox(height: 20),
                location(),
                SizedBox(height: 20),
                temperature(),
                SizedBox(height: 20),
                windSpeed(),
                SizedBox(height: 20),
                humidity(),
                SizedBox(height: 20),
                pressure(),
                SizedBox(height: 20),
                cloud(),
              ],
            ),
          ),
          replacement: Center(
            child: CircularProgressIndicator(),
            //     ),
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(
            20,
          ),
        ),
      ),
      child: Center(
        child: TextFormField(
          onFieldSubmitted: (String s) {
            setState(() {
              cityname = s;
              getCityWeather(s);
              isLoaded = false;
              controller.clear();
            });
          },
          controller: controller,
          cursorColor: Colors.black,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Search city',
            hintStyle: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 25,
              color: Colors.black,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget location() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pin_drop,
            color: Colors.red,
            size: 40,
          ),
          Text(
            cityname,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget temperature() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.yellow,
        border: Border.all(width: 2),
      ),
      child: Row(
        children: [
          Image(
            image: AssetImage('assets/images/thermometer.png'),
            width: MediaQuery.of(context).size.width * 0.12,
          ),
          SizedBox(width: 10),
          Text(
            'Temperature: ${temp?.toInt()} ºC',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget humidity() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.yellow,
        border: Border.all(width: 2),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Image(
            image: AssetImage('assets/images/humidity.png'),
            width: MediaQuery.of(context).size.width * 0.12,
          ),
          SizedBox(width: 10),
          Text(
            'Humidity: ${hum?.toInt()} %',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget windSpeed() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.yellow,
        border: Border.all(width: 2),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Image(
            image: AssetImage('assets/images/air.png'),
            width: MediaQuery.of(context).size.width * 0.12,
          ),
          SizedBox(width: 10),
          Text(
            'Wind Speed: ${air_speed?.toInt()} m/s',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget pressure() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.yellow,
        border: Border.all(width: 2),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Image(
            image: AssetImage('assets/images/barometer.png'),
            width: MediaQuery.of(context).size.width * 0.12,
          ),
          SizedBox(width: 10),
          Text(
            'Pressure: ${press?.toInt()} hPa',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget cloud() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.yellow,
        border: Border.all(width: 2),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Image(
            image: AssetImage('assets/images/cloud.png'),
            width: MediaQuery.of(context).size.width * 0.12,
          ),
          SizedBox(width: 10),
          Text(
            'Cloud: ${cover?.toInt()} %',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    var p = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
    if (permission != null) {
      getCurrentCityWeather(p);
    } else {
      print('Data unavailable');
    }
  }

  getCityWeather(String cityname) async {
    var client = http.Client();
    var uri = '${api.domain}q=$cityname&appid=${api.apiKey}';
    var url = Uri.parse(uri);
    var response = await client.get(url);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodeData = json.decode(data);
      updateUI(decodeData);
      setState(() {
        isLoaded = true;
      });
    } else {
      print(response.statusCode);
    }
  }

  getCurrentCityWeather(Position position) async {
    var client = http.Client();
    var uri =
        '${api.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${api.apiKey}';
    var url = Uri.parse(uri);
    var response = await client.get(url);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodeData = json.decode(data);

      updateUI(decodeData);
      setState(() {
        isLoaded = true;
      });
    } else {}
  }

  updateUI(var decodedData) {
    setState(() {
      if (decodedData == null) {
        temp = 0;
        press = 0;
        hum = 0;
        cover = 0;
        cityname = 'Not available';
      } else {
        temp = decodedData['main']['temp'] - 273;
        press = decodedData['main']['pressure'];
        hum = decodedData['main']['humidity'];
        cover = decodedData['clouds']['all'];
        cityname = decodedData['name'];
        air_speed = decodedData['wind']['speed'];
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
