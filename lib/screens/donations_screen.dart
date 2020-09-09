import 'dart:async';
import 'dart:math';
import 'package:Feedy/screens/onBoarding_screen.dart';
import 'package:Feedy/widgets/category_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Feedy/screens/register_screen.dart';
import 'package:Feedy/utilities/styles.dart';
import 'package:Feedy/utilities/constants.dart';
import 'package:Feedy/screens/login_screen.dart';
import 'package:Feedy/models/donation_model.dart';
import 'package:Feedy/screens/viewDonation_screen.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shimmer/shimmer.dart';
import 'package:async/async.dart';


class DonationsScreen extends StatefulWidget {
  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .accentColor,
      body: Center(
        child: DelayedList(),
      ),
    );
  }


}

class DelayedList extends StatefulWidget {
  @override
  _DelayedListState createState() => _DelayedListState();
}

class _DelayedListState extends State<DelayedList> with AutomaticKeepAliveClientMixin{
  bool isLoading = true;
  List<Donation> donations = [];
  Location _location = new Location();
  var _distanceInMeters;
  RestartableTimer _restartTimer;
  bool dataChanging = false;
  bool show = false;


  @override
  void initState() {
    awaitDonations();
  }

  @override
  Widget build(BuildContext context) {
     _restartTimer = RestartableTimer(Duration(milliseconds: 1),_onTimerFinished);
    return isLoading | dataChanging ? ShimmerList() : DataList(donations);
  }

  _onTimerFinished(){
    if(!show) {
      _restartTimer.reset();
    }
    else {
      _restartTimer.cancel();
      setState(() {
        dataChanging = false;
        isLoading = false;
      });
    }
  }

  latLngfromAddress(String s) async {
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




  getDonations() {
    DatabaseReference donationsRef = FirebaseDatabase.instance.reference();
    donationsRef.child("Donations").onValue.listen((snap) async {
      dataChanging = true;
      show = false;
      setState(() {

      });
      var keys = snap.snapshot.value.keys;
      var data = snap.snapshot.value;
      donations.clear();
      for(var key in keys){
        await latLngfromAddress(data[key]['address'].toString());
        Donation d = new Donation(
          imageMain: data[key]['image1'].toString(),
          title: data[key]['title'],
          owner: data[key]['owner'],
          description: data[key]['description'],
          address: data[key]['address'],
          hash: data[key]['hash'],
          distanceAway: _distanceInMeters,
        );
        donations.add(d);
      }
      donations.sort((a, b) => double.parse(a.distanceAway).compareTo(double.parse(b.distanceAway)));
      show = true;

    });
  }

  void awaitDonations(){
    getDonations();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}

class ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int offset = 0;
    int time = 800;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
      decoration: BoxDecoration(
      color: Theme
          .of(context)
          .accentColor,
      borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30.0),
      topRight: Radius.circular(30.0),
      ),
      ),
        child: SafeArea(
          child: ListView.builder(
            itemCount: 4,
            itemBuilder: (BuildContext context, int index) {
              offset += 500;
              time = 800 + offset;

              print(time);

              return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Shimmer.fromColors(
                    highlightColor: Colors.white,
                    baseColor: Colors.grey[300],
                    child: ShimmerLayout(),
                    period: Duration(milliseconds: time),
                  ));
            },
          ),
        ),
      ),
    );
  }
}
class ShimmerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
            borderRadius: BorderRadius.circular(20),

          ),
        ),
      ],
    );
  }
}

class DataList extends StatefulWidget {
  List<Donation> donations = new List();

  DataList(this.donations);

  _DataListState createState() => _DataListState(donations);

}
class _DataListState extends State<DataList>  with AutomaticKeepAliveClientMixin{

  List<Donation> donations = new List();

  _DataListState(this.donations);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
                        itemCount: donations.length,
                        itemBuilder: (BuildContext context, int index) {
                          Donation donation = donations[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context, new MaterialPageRoute(builder: (
                                  context) =>
                                  ViewDonationScreen(
                                      donation.hash, donation.distanceAway, donation.title, donation.description, donation.address, donation.owner)));
                            },
                            child: Stack(
                              children: <Widget>[
                                Container(margin: EdgeInsets.fromLTRB(
                                    10.0, 5.0, 10.0, 5.0),
                                  constraints: BoxConstraints(
                                      minWidth: double.infinity,
                                      maxHeight: 195),
                                  width: double.infinity,
                                  decoration: BoxDecoration(color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        130.0, 10.0, 10, 20.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(right:5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Text(donation.title,

                                                    style: TextStyle(
                                                      fontSize: 17.0,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Column(
                                                  children: [
                                                    Text(donation.distanceAway,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 21.0,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text('miles away',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0.0, 20.0, 0.0, 0.0),
                                            child: Text(donation.description,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(donation.address,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20.0,
                                  top: 15.0,
                                  bottom: 15.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.network(donation.imageMain,fit: BoxFit.cover, width: 110,
                                      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null ?
                                            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}



