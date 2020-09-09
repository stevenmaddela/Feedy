import 'dart:math';

import 'package:Feedy/screens/onBoarding_screen.dart';
import 'package:Feedy/screens/viewDonation_screen.dart';
import 'package:Feedy/widgets/category_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Feedy/screens/register_screen.dart';
import 'package:Feedy/utilities/styles.dart';
import 'package:Feedy/utilities/constants.dart';
import 'package:Feedy/screens/login_screen.dart';
import 'package:geocoder/geocoder.dart';
import 'dart:async';
import 'package:location/location.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin{
  GoogleMapController _controller;
  Location _location = Location();
  List<Marker> markers = [];
  LatLng pos;
  LatLng startPos;
  BitmapDescriptor customIcon;
  var _distanceInMeters;



  @override
  void initState() {
    getMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      body: startPos==null ? Container(
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.redAccent),
          backgroundColor: Colors.black12,
          ),
        ),
      ) :
          Container(
            color: Theme.of(context).accentColor,
            child : 
            Container(
              color: Theme.of(context).primaryColor,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Container(
                  color: Theme.of(context).accentColor,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: startPos,
                      tilt: 45,
                      zoom: 15,
                    ),
                    markers: Set.from(markers),
                    myLocationEnabled: true,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      new Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),
                    ].toSet()
                    ,),
                ),
              ),
            ),
          ),
    );
  }

  setCurrentLocation(GoogleMapController _cntrl) {
    _controller = _cntrl;
  }

  latLngfromAddress(String s) async{
    var addresses = await Geocoder.local.findAddressesFromQuery(s);
    var first = addresses.first;
    setState(() {

    });
    pos = LatLng(first.coordinates.latitude, first.coordinates.longitude);

  }

  void getMarkers() async{

    await getLoc().then((value) => null);
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
        'assets/images/star.jpg')
        .then((d) {
      customIcon = d;
    });
    DatabaseReference donationsRef = FirebaseDatabase.instance.reference();
    donationsRef.child("Donations").once().then((DataSnapshot snap) async {
      var keys = snap.value.keys;
      var data = snap.value;
      markers.clear();
      for(var key in keys){
        await latLngfromAddress(data[key]['address']);
        Marker m = new Marker(
            markerId: MarkerId(data[key]['title']),
            visible: true,
            position: pos,
            icon: customIcon,
          onTap: () async {
            await latLngfromAddress1(data[key]['address']);
            Navigator.push(
                context, new MaterialPageRoute(builder: (
                context) =>
                ViewDonationScreen(
                    data[key]['hash'], _distanceInMeters, data[key]['title'], data[key]['description'], data[key]['address'], data[key]['owner'])));
          },
        );
        markers.add(m);
      }
      setState(() {

      });
    });
  }

  getLoc() async {
    Location location = new Location();
    await location.getLocation().then((value){
      startPos = LatLng(value.latitude, value.longitude);
    });
  }

  @override
  bool get wantKeepAlive => true;

  latLngfromAddress1(String s) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(s);
    var first = addresses.first;
    double lon1 = first.coordinates.longitude;
    double lat1 = first.coordinates.latitude;
    double lon2;
    double lat2;
    Location location = new Location();
    await location.getLocation().then((value) {
      lon2 = value.longitude;
      lat2 = value.latitude;
    });

    _distanceInMeters = distance(lat1, lon1, lat2, lon2, 'M');
  }

  String distance(
      double lat1, double lon1, double lat2, double lon2, String unit) {
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = (dist * 60 * 1.1515)*1.19;
    if (unit == 'K') {
      dist = dist * 1.609344;
    } else if (unit == 'N') {
      dist = dist * 0.8684;
    }
    return dist.toStringAsFixed(2);
  }

  double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  double rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }

}