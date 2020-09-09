import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Donation{
  final String imageMain;
  final String title;
  final String owner;
  final String description;
  final String address;
  final String hash;
  final String distanceAway;

  Donation({
    this.imageMain,
    this.title,
    this.owner,
    this.description,
    this.address,
    this.hash,
    this.distanceAway,
  });
}