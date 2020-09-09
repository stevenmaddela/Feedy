import 'dart:io';

import 'package:Feedy/models/donation_model.dart';
import 'package:Feedy/models/user_model.dart';
import 'package:Feedy/screens/donations_screen.dart';
import 'package:Feedy/screens/onBoarding_screen.dart';
import 'package:Feedy/widgets/BaseAlertDialog.dart';
import 'package:Feedy/widgets/category_selector.dart';
import 'package:Feedy/widgets/full_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;

import 'package:Feedy/screens/register_screen.dart';
import 'package:Feedy/utilities/styles.dart';
import 'package:Feedy/utilities/constants.dart';
import 'package:Feedy/screens/login_screen.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';


import '../main.dart';
import 'chat_screen.dart';

class CreateDonationsScreen extends StatefulWidget {
  @override
  _CreateDonationScreenState createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationsScreen> {
  List<File> images = new List();
  final _controller = ScrollController();
  final con1 = ScrollController();
  var txt = TextEditingController();
  String title, description;
  String address = "null";
  bool autovalidate = false;
  final rootRef = FirebaseDatabase.instance.reference();
  final formKey = GlobalKey<FormState>();
  var _textController = TextEditingController();
  var _textController2 = TextEditingController();
  FocusNode focus1 = new FocusNode();
  FocusNode focus2 = new FocusNode();


  @override
  void initState() {
    images.add(null);
  }

  Widget _titleTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Color(0xDDe4e6ed),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          width: double.infinity,
          alignment: Alignment.centerLeft,

          child: TextFormField(
            focusNode: focus1,
            controller: _textController,
            autovalidate: autovalidate,
            onChanged: (textVal){
              setState(() {
                title = textVal;
              });
            },
            // ignore: missing_return
            validator: (val){
              if(val.isEmpty){
                return "Title is Empty";
              }
            },
            maxLines: null,
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _descriptionTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xDDe4e6ed),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            focusNode: focus2,
            controller: _textController2,
            autovalidate: autovalidate,
            onChanged: (textVal){
              setState(() {
                description = textVal;
              });
            },
            // ignore: missing_return
            validator: (val){
              if(val.isEmpty){
                return "Description is Empty";
              }
            },
            maxLines: null,
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addressTF() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xDDe4e6ed),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            onTap: ()async{
              Prediction p = await PlacesAutocomplete.show(context: context, apiKey: "AIzaSyDhrAC1DVBJKv7VNYFxm6jdA23kopkKzCw");
              setState(() {
                address = p.description;
                txt.text = address;
              });
            },
            child: TextFormField(
              enabled: false,
              controller: txt,
              maxLines: null,
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: GestureDetector(
        onTap: ()=> FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scrollbar(
              controller: con1,
              isAlwaysShown: true,
              child: SingleChildScrollView(
                controller: con1,
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          color: Theme.of(context).primaryColor,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(30,15, 30, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Title",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    _titleTF(),
                                    SizedBox(height: 40.0),
                                    Text(
                                      'Address',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    _addressTF(),
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
                                  controller: _controller,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    itemBuilder: (BuildContext context, int index){
                                    if(images[index]==null) {
                                      return Container(
                                        margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                        width: 150.0,
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              width: 150,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                    10.0),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                    20),
                                              ),
                                              child: Stack(
                                                children: <Widget>[
                                                  ClipRRect(
                                                    borderRadius: BorderRadius
                                                        .circular(20),
                                                    child: InkWell(
                                                      child: Container(
                                                        color: Theme
                                                            .of(context)
                                                            .accentColor,
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 40,
                                                            color: Colors.redAccent,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        addImage();
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    else{
                                      return Container(
                                        margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                    10.0),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(
                                                    20),
                                              ),
                                              child: Stack(
                                                children: <Widget>[
                                                  ClipRRect(
                                                    borderRadius: BorderRadius
                                                        .circular(20),
                                                    child: InkWell(
                                                      child: Image.file(images[index]),
                                                      onTap: () {

                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
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
                                  _descriptionTF(),
                                  SizedBox(height: 30.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      RawMaterialButton(
                                        padding: EdgeInsets.all(18.0),
                                        shape: CircleBorder(),
                                        elevation: 2.0,
                                        fillColor: Colors.black,
                                        child: Icon(
                                          Icons.cloud_upload,
                                          color: Colors.white,
                                          size: 35.0,
                                        ),
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          setState(() {
                                            autovalidate = true;
                                          });
                                          if (formKey.currentState.validate()) {
                                            formKey.currentState.save();
                                          }
                                          if(images.length<3 && address=="null"){
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: Text(
                                                      'Add a Minimum of 3 Images and Select Address'),
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
                                          }
                                          else if(images.length<3){
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: Text(
                                                      'Add a Minimum of 3 Images'),
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
                                          }
                                          else if(address=="null"){
                                              showCupertinoDialog(
                                                context: context,
                                                builder: (context) {
                                                  return CupertinoAlertDialog(
                                                    title: Text(
                                                        'Select Address'),
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
                                          }
                                          else{
                                            var baseDialog = BaseAlertDialog(
                                                title: "Confirm Donation",
                                                content: "I agree that the information provided is true and cannot be edited.",
                                                yesOnPressed: () async {
                                                  Navigator.of(context, rootNavigator: true)
                                                      .pop();
                                                  ProgressDialog pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false,);
                                                  pr.style(
                                                      message: "Uploading Donation to Databases, Please Wait",
                                                  );
                                                  await pr.show();
                                                  String hash = rootRef.child("Donations").push().key;
                                                  for(int i = 0; i < images.length; i++){
                                                    if(images[i]!=null){
                                                      String fileName = Path.basename(images[i].path);
                                                      StorageReference ref = FirebaseStorage.instance.ref().child(
                                                          "Donation Images").child(hash).child(fileName);
                                                      StorageUploadTask uploadTask = ref.putFile(images[i]);
                                                      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
                                                      var downUrl = await taskSnapshot.ref.getDownloadURL();
                                                      var url = downUrl.toString();
                                                      rootRef.child("Donations").child(hash).child("image"+i.toString()).set(
                                                        url);
                                                    }
                                                  }
                                                  rootRef.child("Donations").child(hash).child("address").set(address);
                                                  rootRef.child("Donations").child(hash).child("description").set(description);
                                                  rootRef.child("Donations").child(hash).child("owner").set(FirebaseAuth.instance.currentUser.uid);
                                                  rootRef.child("Donations").child(hash).child("title").set(title);
                                                  rootRef.child("Donations").child(hash).child("hash").set(hash);
                                                  images.clear();
                                                  images.add(null);
                                                  setState(() {

                                                  });
                                                  setState(() async {
                                                    _textController.text = " ";
                                                    _textController2.text = " ";
                                                    focus1.unfocus();
                                                    focus2.unfocus();
                                                    txt.clear();
                                                    con1.animateTo(0.0,
                                                        duration: Duration(milliseconds: 500), curve: Curves.ease);
                                                    await pr.hide();
                                                    showCupertinoDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return CupertinoAlertDialog(
                                                          title: Text(
                                                              'Donation Created'),
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
                                                  });
                                                },
                                                noOnPressed: () {

                                                  Navigator.of(context, rootNavigator: true)
                                                      .pop();
                                                },
                                                yes: "Confirm",
                                                no: "Cancel");
                                            showDialog(context: context, builder: (BuildContext context) => baseDialog);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30,)
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
          ),
        ),
      ),
    );
  }

  Future<void> addImage() async {
      if(images.length<6) {
        var image1 = await ImagePicker.pickImage(source: ImageSource.gallery);
        if(image1!= null) {
          images.add(image1);
        }
      }
      else{
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    'Maximum of 5 Images Allowed'),
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
      }

      setState(() {

      });
  }
}