import 'package:Feedy/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name, email;
  var image;
  int donations = 0;
  bool tapped = false;
  final formKey = GlobalKey<FormState>();
  var focus = FocusNode();
  var con = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .accentColor,
        appBar: AppBar(
          title: Text("Profile", style: GoogleFonts.alata(),),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 100),
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 1.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  getImage(context);
                                },
                                child: CircleAvatar(
                                  backgroundImage: image!=null? NetworkImage(image) : NetworkImage(null),
                                  radius: 70,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 30,),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    color: Theme
                                        .of(context)
                                        .accentColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width / 1.5,
                                  child: TextFormField(
                                    controller: con,
                                    focusNode: focus,
                                    onChanged: (textVal) {
                                      setState(() {
                                        name = textVal;
                                      });
                                    },
                                    validator: (pw) {
                                      if (pw.isEmpty) {
                                        return 'Field Is Empty';
                                      }

                                      return null;
                                    },
                                    onTap: () {
                                      tapped = true;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Name: " + name.toString(),
                                      border: InputBorder.none,
                                      hintStyle: GoogleFonts.montserrat(),
                                    ),
                                  ),

                                ),
                                SizedBox(height: 30,),
                                Text(
                                  "Email: " + email,
                                  style: GoogleFonts.montserrat(),
                                ),
                                SizedBox(height: 15,),
                                Text(
                                  "Active Donations: " + donations.toString(),
                                  style: GoogleFonts.montserrat(),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                      tapped ? Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 40, 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                if (formKey.currentState.validate()) {
                                  formKey.currentState.save();
                                  updateName(name);
                                  focus.unfocus();
                                  //TOAST
                                  tapped = false;
                                  con.clear();
                                  setState(() {

                                  });
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.blueAccent,
                                ),
                                child: Center(
                                  child: Text(
                                    "Save", style: GoogleFonts.montserrat(
                                      fontSize: 20, color: Colors.white70),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    FirebaseDatabase.instance.reference().child('Users').child(
        FirebaseAuth.instance.currentUser.uid).child('name').once().then((
        DataSnapshot data) {
      name = data.value.toString();

      setState(() {
      });
    });
    FirebaseDatabase.instance.reference().child('Users').child(
        FirebaseAuth.instance.currentUser.uid).child('image').once().then((
        DataSnapshot data) {
      image = data.value;

      setState(() {
      });
    });
    FirebaseDatabase.instance.reference().child('Users').child(
        FirebaseAuth.instance.currentUser.uid).child('email').once().then((
        DataSnapshot data) {
      email = data.value.toString();

      setState(() {
      });
    });
    DatabaseReference donationsRef = FirebaseDatabase.instance.reference();
    donationsRef.child("Donations").once().then((snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      for (var key in keys) {
        if (data[key]['owner'] == FirebaseAuth.instance.currentUser.uid) {
          donations++;
        }
        setState(() {

        });
      }
    });
  }

  void updateName(String textVal) {
    DatabaseReference rootRef = FirebaseDatabase.instance.reference().child(
        "Users");
    rootRef.child(FirebaseAuth.instance.currentUser.uid).child("name").set(
        textVal);
    setState(() {

    });
  }

  Future getImage(context) async {
    var image1 = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image1== null){

    }
    else {
      ProgressDialog pr = ProgressDialog(
          context, type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      await pr.show();
      await pr.show();
      String fileName = basename(image1.path);
      StorageReference ref = FirebaseStorage.instance.ref().child(
          "Profile Images").child(FirebaseAuth.instance.currentUser.uid).child(
          fileName);
      StorageUploadTask uploadTask = ref.putFile(image1);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      var downUrl = await taskSnapshot.ref.getDownloadURL();
      var url = downUrl.toString();
      DatabaseReference rootRef = FirebaseDatabase.instance.reference().child(
          "Users");
      rootRef.child(FirebaseAuth.instance.currentUser.uid).child("image").set(
          url);
      image = url;
      await pr.hide();

      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                  'Image Uploaded'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      setState(() {

      });
    }
  }
}
