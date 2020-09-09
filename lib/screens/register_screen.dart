import 'package:Feedy/models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Feedy/screens/login_screen.dart';
import 'package:Feedy/utilities/styles.dart';
import 'package:Feedy/utilities/constants.dart';

import '../main.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final rootRef = FirebaseDatabase.instance.reference();
  String email, name, password, confirmPassword;
  final formKey = GlobalKey<FormState>();
  bool saveAttempted = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  ScrollController con = ScrollController();


  void _createUser(String email, String password){
    auth.createUserWithEmailAndPassword(email: email, password: password)
        .then((authResult) async {
      await authResult.user.sendEmailVerification();

      rootRef.child("Users").child(auth.currentUser.uid).set({
        'email':email,
        'image':'https://firebasestorage.googleapis.com/v0/b/feedyyy-bfff8.appspot.com/o/Profile%20Images%2Fprofile_00000_00000.png?alt=media&token=aee78404-64a0-4bb6-a5f2-39b4f9da9d92',
        'name':name,
        'uid':auth.currentUser.uid,
      });
      rootRef.child("Users").child(auth.currentUser.uid).child("Messages").child("3yw9EZK2cbO2EG1aSszIa5fYpgE3").child("-MGWODl3cuAN32xQ7Lqf").set({
          'sender': '3yw9EZK2cbO2EG1aSszIa5fYpgE3',
          'time': '12:00:AM',
          'date': '9/06/20',
          'unread': true,
          'text': 'Welcome To Feedy!',
          'hash': '-MGWODl3cuAN32xQ7Lqf',
      });

      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                  'Please Verify Email then Login'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => LoginScreen()));

                  },
                )

              ],
            );
          });

    }).catchError((err) {
      print(err.code);
      if (err.code == "email-already-in-use") {
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    'This Email Already Has an Account Associated With It'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, new MaterialPageRoute(builder: (context) => LoginScreen()));

                    },
                  )

                ],
              );
            });
      }
    });

        }

  Widget _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Full Name',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            autovalidate: saveAttempted,
            onChanged:(textValue){
              setState(() {
                name = textValue;
              });
            },
            // ignore: missing_return
            validator: (val){
              if(val.isEmpty){
                return "Name is Empty";
              }
            },
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              errorStyle: TextStyle(
                  fontWeight: FontWeight.bold),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
              hintText: 'Enter your Full Name',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(autovalidate: saveAttempted,
            onChanged:(textValue){
            setState(() {
              email = textValue;
            });
          },
              validator: (emailValue) {
              if(emailValue.isEmpty){
                return 'This Field is Empty';
              }

              String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                "\\@" +
                "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                "(" +
                "\\." +
                "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                ")+";
              RegExp regExp = new RegExp(p);
              if(regExp.hasMatch(emailValue)) {
                return null;
              }
              return 'Not A Valid Email';
          },
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              errorStyle: TextStyle(
                fontWeight: FontWeight.bold),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(autovalidate: saveAttempted,
            onChanged:(textValue){
            setState(() {
              password = textValue;
            });
          },
            validator: (pwValue) {
            if(pwValue.isEmpty){
              return 'This Field is Empty';
            }
            if(pwValue.length < 6){
              return 'Password Must be at least 6 Characters';
            }
            return null;
          },
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              errorStyle: TextStyle(
                  fontWeight: FontWeight.bold),
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReenterPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Confirm Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(autovalidate: saveAttempted,
            onChanged:(textValue){
            setState(() {
              confirmPassword = textValue;
            });
          },
            validator: (cPwValue) {
            if(cPwValue != password){
              return 'Passwords Do Not Match';
            }

            return null;
          },
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              errorStyle: TextStyle(
                  fontWeight: FontWeight.bold),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Re-Enter your Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: (){
          setState(() {
            saveAttempted = true;
          });
          if(formKey.currentState.validate()){
            formKey.currentState.save();
            _createUser(email, password);

          }
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'CREATE ACCOUNT',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }


  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }


  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => LoginScreen())),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF7986CB),
                        Color(0xFF5C6BC0),
                        Color(0xFF3F51B5),
                        Color(0xFF3949Ab),
                      ],
                      stops: [0.1, 0.4, 0.7, 0.9],
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  child: Scrollbar(
                    isAlwaysShown: true,
                    controller: con,
                    child: SingleChildScrollView(
                      controller: con,
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: MediaQuery.of(context).size.height/20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 20,),
                          Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'OpenSans',
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          _buildNameTF(),
                          SizedBox(height: 15.0),
                          _buildEmailTF(),
                          SizedBox(height: 30.0),
                          _buildPasswordTF(),
                          SizedBox(height: 15.0),
                          _buildReenterPasswordTF(),
                          _buildLoginBtn(),
                          SizedBox(height: 20,),
                          _buildSignupBtn(),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}