import 'package:Feedy/models/user_model.dart';

class Message {
  final String sender;
  final String  time; // Would usually be type DateTime or Firebase Timestamp in production apps
  final String date;
  final String text;
  final bool unread;
  final String hash;

  Message({
    this.sender,
    this.time,
    this.date,
    this.text,
    this.unread,
    this.hash,
  });


}
