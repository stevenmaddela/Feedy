import 'package:Feedy/models/donation_model.dart';
import 'package:Feedy/models/user_model.dart';
import 'package:Feedy/screens/donations_screen.dart';
import 'package:Feedy/screens/map_screen.dart';
import 'package:Feedy/widgets/BaseAlertDialog.dart';
import 'package:Feedy/widgets/full_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;

import 'package:Feedy/screens/chat_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class ViewDonationScreen extends StatefulWidget {
  final String hash;
  final String distance;
  final String title;
  final String description;
  final String address;
  final String owner;

  const ViewDonationScreen(this.hash, this.distance, this.title, this.description, this.address, this.owner);

  @override
  _ViewDonationScreenState createState() => _ViewDonationScreenState();

}

class _ViewDonationScreenState extends State<ViewDonationScreen> with AutomaticKeepAliveClientMixin{
  _ViewDonationScreenState();
  Donation donation;
  String ownerName;
  bool isMine = false;
  List<String> images = [];

  @override
  void initState() {

    getImages();

    if(widget.owner==FirebaseAuth.instance.currentUser.uid){
      isMine = true;
    }
    super.initState();

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).primaryColor,
                    child: Column(
                      children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(30, 60, 30, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      widget.distance,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      "miles away",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 40.0),
                            Text(
                              "Title",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 40.0),
                            Text(
                              'Address',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              widget.address,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 40.0),
                            Text(
                              "Images",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10.0),
                          ],
                        ),
                      ),
                        Container(
                          padding: EdgeInsets.only(left: 25),
                          height: 230,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (BuildContext context, int index){
                                return Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: InkWell(
                                        child: images[index].substring(0,5)!='video'? Image.network(images[index],fit: BoxFit.fill, height: 200,
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
                                        ) : 
                                            Container(height: 200,
                                              child: InkWell(
                                                onTap: (){
                                                  _launchURL('https://youtu.be/Ooecmb59r5w');
                                                },
                                                child: Stack(children: <Widget>[Image(image: AssetImage('assets/images/trailerPic.PNG'),),
                                                Row(
                                                  children: [
                                                    Center(
                                                        child: Icon(
                                                          Icons.video_library,
                                                          color: Colors.transparent,
                                                          size: 60,)
                                                    ),
                                                    Center(
                                                        child: Icon(
                                                          Icons.video_library,
                                                          color: Colors.transparent,
                                                          size: 60,)
                                                    ),Center(
                                                        child: Icon(
                                                          Icons.video_library,
                                                          color: Colors.redAccent,
                                                          size: 90,)
                                                    )
                                                  ],
                                                )
                                                ],
                                                ),
                                              ),
                                            ),
                                        onTap: ()=> Navigator.push(context, new MaterialPageRoute(builder: (context) =>  FullPhoto(image: images[index]))),

                                  ),
                                    ),
                                  ),
                                );
                              }),

                        ),

                    ],

                    ),


                  ),

                ],
              ),
              SizedBox(height: 40.0),
              Container(
                transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30.0,
                          right: 30.0,
                          top: 40.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(widget.description,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16.0,
                              ),
                              maxLines: 11,
                            ),
                            SizedBox(height: 20.0,),

                            !isMine? Row(
                              children: <Widget>[
                                RawMaterialButton(
                                padding: EdgeInsets.all(18.0),
                                shape: CircleBorder(),
                                elevation: 2.0,
                                fillColor: Colors.black,
                                child: Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                  size: 35.0,
                                ),
                                  onPressed: (){
                                    FirebaseDatabase.instance.reference().child('Users').child(widget.owner).child('name').once().then((DataSnapshot data) {
                                        ownerName = data.value.toString();
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(userId: widget.owner,name: ownerName, lastHash: null,),),);

                                    });
                                  },
                                ),
                                Text(
                                  "Chat with The Donor",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ): Row(
                              children: <Widget>[
                                RawMaterialButton(
                                  padding: EdgeInsets.all(18.0),
                                  shape: CircleBorder(),
                                  elevation: 2.0,
                                  fillColor: Colors.redAccent,
                                  child: Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                    size: 35.0,
                                  ),
                                  onPressed: () async {
                                    var baseDialog = BaseAlertDialog(
                                        title: "Delete Donation",
                                        content: "Are Your Sure You Want To Delete This Donation?",
                                        yes: "Yes",
                                        no: "No",
                                        yesOnPressed: () async {
                                          Navigator.of(context, rootNavigator: true)
                                              .pop();
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: Text(
                                                      'Donation Deleted'),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      child: Text('OK'),
                                                      onPressed: () {
                                                        FirebaseDatabase.instance.reference().child('Donations').child(widget.hash).remove();
                                                        Navigator.of(context, rootNavigator: true).pop("Discard");

                                                        showCupertinoDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return CupertinoAlertDialog(
                                                              title: Text(
                                                                  'Donation Deleted'),
                                                              actions: <Widget>[
                                                                CupertinoDialogAction(
                                                                  child: Text('OK'),
                                                                  onPressed: () {
                                                                    Navigator.of(context, rootNavigator: true).pop("Discard");
                                                                                                                                      },
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        );

                                                        Navigator.of(context, rootNavigator: true)
                                                            .pop("Discard");

                                                        Navigator.of(context, rootNavigator: true)
                                                            .pop("Discard");

                                                      },
                                                    )
                                                  ],
                                                );
                                              },
                                            );

                                          }

                                          );
                                    showDialog(context: context, builder: (BuildContext context) => baseDialog);

                                  },
                                ),
                                Text(
                                  "Delete This Donation",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20,)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  getImages() {
    DatabaseReference donationsRef = FirebaseDatabase.instance.reference();
    donationsRef.child("Donations").child(widget.hash).once().then((DataSnapshot snap){
      var data = snap.value;
        if(data['image1']!=null){
        images.add(data['image1']);
      }
      if(data['image2']!=null && data['owner']!='3yw9EZK2cbO2EG1aSszIa5fYpgE3'){
        images.add(data['image2']);
      }
      else{
        images.add('video'+data['image2']);
      }
      if(data['image3']!=null){
        images.add(data['image3']);
      }
      if(data['image4']!=null){
        images.add(data['image4']);
      }
      if(data['image5']!=null){
        images.add(data['image5']);
      }
      setState(() {

      });
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}