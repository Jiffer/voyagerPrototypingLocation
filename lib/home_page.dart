import 'dart:ffi';
import 'dart:async';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

// GLOBALS

// audio file
const sunFilePath = 'audio/welcomeToTheSun.mp3';
const audioFilePaths = ['audio/welcomeToTheSun.mp3',
  'audio/mercury.mp3',
  'audio/venus.mp3',
  'audio/earth.mp3'];

Position _currentPosition = Position(latitude: 40.0029, longitude: -105.13757);
Position _sunPosition = Position(latitude: 40.0029, longitude: -105.13757);
final Distance distance = new Distance();
double _currentDistance;

var globalGeolocator = Geolocator();
var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 1);

int globalOrbit = 1;
int globalOrbitSize = 30;

AudioCache cachePlayer = AudioCache();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Where am I"),
      ),
      body: Center(
        child: StreamBuilder<Object>(
          stream: globalGeolocator.getPositionStream(locationOptions),
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text("play sound"),
                  onPressed: (){
                    cachePlayer.play(sunFilePath);
                  }
                ),
                Text(
                    "Sun Position Lat: ${_sunPosition.latitude}, LNG: ${_sunPosition
                        .longitude}"),
                FlatButton(
                  child: Text("Set Sun"),
                  onPressed: () {
                    _setSunLocation();

                  },
                ),
                  Text(
                      "My Lat: ${_currentPosition.latitude}, LNG: ${_currentPosition
                         .longitude}"),
                Text("Distance from Sun:  $_currentDistance (m)"),
              ],
            );
          }
        ),
      ),
    );
  }

  // Homepage methods:
  _setSunLocation() {
    _sunPosition = _currentPosition;
  }


  StreamSubscription<Position> positionStream = globalGeolocator.getPositionStream(locationOptions).listen(
          (Position position) {

          if(position != null){
            print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
            _currentPosition = position;
            print(_calcDistance(position.latitude, position.longitude));

            int tempOrobitCalc = ((_currentDistance) / globalOrbitSize).truncate();
            int tempOrobitMod = ((_currentDistance) % globalOrbitSize).truncate();
            print( "orbit calculation: $tempOrobitCalc");

            if (tempOrobitCalc != globalOrbit){
              // changed orbit zone
              // play a sound and update zone
              _playSound(tempOrobitCalc);
              globalOrbit = tempOrobitCalc;
            }
          }
      });


  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    // GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus(); // must add async to function
    // print(geolocationStatus); // if(!GeolocationStatus.granted)...

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;

      });
    }).catchError((e) {
      print(e);
    });
  }
   static double _calcDistance(double checkLat, double checkLong){
    final Distance distance = new Distance();
    final double distanceInMeters = distance.as(LengthUnit.Meter,
        new LatLng(_sunPosition.latitude, _sunPosition.longitude),
        new LatLng(checkLat, checkLong));
    _currentDistance = distanceInMeters;
    return distanceInMeters;
  }

  //
  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  static void _playSound(int index) {
    if(index < audioFilePaths.length) {
      print("playing audio file at index $index aka $audioFilePaths[index]");
      cachePlayer.play(audioFilePaths[index]);
    }
  }
}


