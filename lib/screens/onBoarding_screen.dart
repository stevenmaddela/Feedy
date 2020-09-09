import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Feedy/screens/register_screen.dart';
import 'package:Feedy/utilities/styles.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui';
import 'login_screen.dart';


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();

}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;


  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }



  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Color(0xFF7B51D3),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.4, 0.7, 0.9],
            colors: [
              Color(0xFF3594DD),
              Color(0xFF4563DB),
              Color(0xFF5036D5),
              Color(0xFF5B16D0),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height/1.15,
                child: PageView(
                  physics: ClampingScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Center(
                              child: Image.asset('assets/images/undraw_statistic_chart_38b6.png', height:MediaQuery.of(context).size.height/3, width:MediaQuery.of(context).size.width/1.5,),
                            ),

                            SizedBox(height: 30.0),
                            Wrap(
                              children: [Text(
                                'Lets feed those in need',
                                style: kTitleStyle,
                              ),
                      ],
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'America is #1 in wasted food in the world. 13% of the entire food supply in America is wasted and large amounts are simply thrown away by restaurants daily.',
                              style: kSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Center(
                            child: Image.asset('assets/images/undraw_takeout_boxes_ap54.png', height:MediaQuery.of(context).size.height/3, width:MediaQuery.of(context).size.width/1.5, ),
                          ),

                          SizedBox(height: 30.0),
                          Wrap(
                            children: [Text(
                              'Put wasted food to use with us!',
                              style: kTitleStyle,
                            ),
        ],
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Food is precious, don\'t throw away wasted food. As a restaurant or donor with lots of excess food, you can donate it to those who need it in their tough times.',
                            style: kSubtitleStyle,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(40.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                            Center(
                              child: Image.asset('assets/images/undraw_map_1r69.png', height:MediaQuery.of(context).size.height/3.5, width:MediaQuery.of(context).size.width/1.5, ),
                            ),
                            SizedBox(height: 30.0),
                            Wrap(
                              children: [Text(
                                'Find donations for your charity or organizations',
                                style: kTitleStyle,
                              ),
                      ],
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Find donation points and chat with donors to receive their donated food for your charity or organizations as a user.',
                              style: kSubtitleStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
              _currentPage != _numPages - 1
                  ? Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomRight,
                  child: FlatButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : Text(''),
            ],
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Container(
        height: 100.0,
        width: double.infinity,
        child: InkWell(
          onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => RegisterScreen())),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: Text(
                'Get started',
                style: TextStyle(
                  color: Color(0xFF5B16D0),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      )
          : Text(''),
    );
  }


}