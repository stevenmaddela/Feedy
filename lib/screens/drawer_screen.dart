import 'package:Feedy/screens/profile_screen.dart';
import 'package:Feedy/screens/t&c_screen.dart';
import 'package:Feedy/widgets/configuration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String name;
  var image;


  @override
  void initState() {
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.fromLTRB(0, 70, 15, 0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(name.toString(),
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: Color(0xFF376996),
                      ),
                      ),
                      Text("Active Status",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF40916c),
                        ),)

                    ],
                  ),
                  SizedBox(width: 10,),
                  CircleAvatar(
                    backgroundImage: image!=null? NetworkImage(image) : NetworkImage(null),
                  ),
                ],
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: drawerItems.map((element) => Padding(
                        padding: EdgeInsets.fromLTRB(0,20,15,10),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: (){
                                if(element['title']=='Contact Us'){
                                  final Uri _emailLaunchUri = Uri(
                                    scheme: 'mailto',
                                    path: 'syfn.games@gmail.com',
                                  );
                                  _launchURL(_emailLaunchUri.toString());
                                }
                                if(element['title']=='Profile'){
                                  Navigator.push(context,MaterialPageRoute(builder: (_) => ProfileScreen()));
                                }
                                if(element['title']=='Rate Us'){

                                }
                                if(element['title']=='T&C'){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => tcScreen(),
                                    ),
                                  );
                                }
                                if(element['title']=='Logout'){
                                  auth.signOut();
                                }
                              },
                                child: Text(element['title'],
                                  style: GoogleFonts.montserrat(fontSize: 25,
                                    color: element['title']=='Logout'? Color(0xFFda1e37): Color(0xFF376996),

                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                            ),
                            SizedBox(width: 10,),
                            InkWell(
                              onTap: (){
                                if(element['title']=='Contact Us'){
                                  final Uri _emailLaunchUri = Uri(
                                    scheme: 'mailto',
                                    path: 'syfn.games@gmail.com',
                                  );
                                  _launchURL(_emailLaunchUri.toString());
                                }

                                if(element['title']=='Profile'){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(),
                                    ),
                                  );
                                }
                                if(element['title']=='Rate Us'){

                                }
                                if(element['title']=='T&C'){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => tcScreen(),
                                    ),
                                  );
                                }
                                if(element['title']=='Logout'){
                                  auth.signOut();
                                }
                              },
                                child: Icon(element['icon'],
                                  color: element['title']=='Logout'? Color(0xFFa71e34): Color(0xFF376996),
                                  size: 35,)
                            ),

                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Text('\n\n\n'),
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

  getData() async {
    await getDat();
}

  getDat() async{
    FirebaseDatabase.instance.reference().child('Users').child(FirebaseAuth.instance.currentUser.uid).child('name').onValue.listen((data) {
      setState(() {
        name = data.snapshot.value.toString();
      });
    });
    FirebaseDatabase.instance.reference().child('Users').child(FirebaseAuth.instance.currentUser.uid).child('image').onValue.listen((data) {
      setState(() {
        image = data.snapshot.value;
      });
    });
  }
}
