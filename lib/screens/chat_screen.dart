import 'package:Feedy/widgets/full_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Feedy/models/message_model.dart';
import 'package:Feedy/models/user_model.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;

import 'package:progress_dialog/progress_dialog.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String lastHash;

  ChatScreen({this.userId, this.name, this.lastHash});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<Message> messages = [];
  bool isMessagesSmall = true;
  DatabaseReference rootRef = FirebaseDatabase.instance.reference();
  String currentUserId = FirebaseAuth.instance.currentUser.uid;
  String senderUserId;
  String text;
  var textController = TextEditingController();
  var node1 = FocusNode();
  var con1 = ScrollController();


  @override
  void initState() {
    senderUserId = widget.userId;
    run();
  }

  _buildMessage(Message message, bool isMe) {
    final Container msg = Container(
      margin: isMe
          ? EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 80.0,
      )
          : EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isMe ? Color(0xFFc7d8e8) : Color(0xFF9ba9d0),
        borderRadius: isMe
            ? BorderRadius.only(
          topLeft: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
        )
            : BorderRadius.only(
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      child: message.text.indexOf("https://firebasestorage.googleapis.com/v0/b/feedy-a90a8.appspot.com")==-1? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                message.time.substring(0,message.time.indexOf(":")+3) + " " + message.time.substring(message.time.length-2) +"  -",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                message.date,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            message.text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: ()=> Navigator.push(context, new MaterialPageRoute(builder: (context) =>  FullPhoto(image: message.text))),
            child: Image.network(message.text,fit: BoxFit.fill,
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
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Text(
                message.time.substring(0,message.time.indexOf(":")+3) + " " + message.time.substring(message.time.length-2) +"  -",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                message.date,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (isMe) {
      return msg;
    }
    return Row(
      children: <Widget>[
        msg,
    ]
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(12,0,8,0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child : Material(
              color: Colors.transparent,
              child : InkWell(
                child : Padding(
                  padding : const EdgeInsets.all(7),
                  child : Icon(Icons.photo_camera, size: 24, color: Theme.of(context).primaryColor,),
                ),
                onTap : () async {
                  var image1 = await ImagePicker.pickImage(source: ImageSource.camera);
                  if(image1==null){

                  }
                  else {
                    ProgressDialog pr = ProgressDialog(
                        context, type: ProgressDialogType.Normal,
                        isDismissible: false,
                        showLogs: false);
                    pr.style(
                      message: "Sending Image...",
                    );
                    await pr.show();
                    await pr.show();
                    String fileName = Path.basename(image1.path);
                    StorageReference ref = FirebaseStorage.instance.ref().child(
                        "Text Images").child(
                        FirebaseAuth.instance.currentUser.uid).child(
                        fileName);
                    StorageUploadTask uploadTask = ref.putFile(image1);
                    StorageTaskSnapshot taskSnapshot = await uploadTask
                        .onComplete;
                    var downUrl = await taskSnapshot.ref.getDownloadURL();
                    var url = downUrl.toString();
                    uploadMessage(url);
                    await pr.hide();
                  }
                },
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child : Material(
              color: Colors.transparent,
              child : InkWell(
                child : Padding(
                  padding : const EdgeInsets.only(left: 7, right: 10),
                  child : Icon(
                    Icons.photo, size: 24, color: Theme.of(context).primaryColor,
                  ),
                ),
                onTap : () async {
                  var image1 = await ImagePicker.pickImage(source: ImageSource.gallery);
                  if(image1 == null){

                  }
                  else {
                    ProgressDialog pr = ProgressDialog(
                        context, type: ProgressDialogType.Normal,
                        isDismissible: false,
                        showLogs: false);
                    pr.style(
                      message: "Sending Image...",
                    );
                    await pr.show();
                    await pr.show();
                    String fileName = Path.basename(image1.path);
                    StorageReference ref = FirebaseStorage.instance.ref().child(
                        "Text Images").child(
                        FirebaseAuth.instance.currentUser.uid).child(
                        fileName);
                    StorageUploadTask uploadTask = ref.putFile(image1);
                    StorageTaskSnapshot taskSnapshot = await uploadTask
                        .onComplete;
                    var downUrl = await taskSnapshot.ref.getDownloadURL();
                    var url = downUrl.toString();
                    uploadMessage(url);
                    await pr.hide();
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                  ),
                ],
              ),
              child: TextFormField(
                focusNode: node1,
                controller: textController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  setState(() {
                    text = value;

                  });
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Send a message...',
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              uploadMessage(text);
              textController.text = "";
              node1.unfocus();
              if(messages.length<8) {
                con1.animateTo(
                  con1.position.maxScrollExtent,
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                );
              }
              else{}
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(widget.name==null? "test":widget.name,
          style: GoogleFonts.alata(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: ListView.builder(
                    controller: con1,
                    reverse: isMessagesSmall ? false: true,
                    padding: EdgeInsets.only(top: 15.0),
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Message message = messages[index];
                      final bool isMe = message.sender == FirebaseAuth.instance.currentUser.uid;
                      return _buildMessage(message, isMe);
                    },
                  ),
                ),
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  void uploadMessage(String text) {
    var now = new DateTime.now();
    var formatter = new DateFormat('MM/dd/yyyy');
    String month = formatter.format(now);

    String hash = rootRef.child("Users")
        .child(currentUserId)
        .child("Messages")
        .child(senderUserId)
        .push()
        .key;
    rootRef.child("Users").child(currentUserId).child("Messages").child(senderUserId).child(
        hash).set({
      'sender': currentUserId,
      'time': DateFormat.jms().format(DateTime.now()),
      'date': month,
      'text': text,
      'unread': false,
      'key':hash,
    });
    rootRef.child("Users").child(senderUserId).child("Messages").child(currentUserId).child(
        hash).set({
      'sender': currentUserId,
      'time': DateFormat.jms().format(DateTime.now()),
      'date': month,
      'text': text,
      'unread': true,
      'key':hash,

    });
  }

  Future<void> getMessages() {
    DatabaseReference usersRef = FirebaseDatabase.instance.reference();
    usersRef.child("Users").child(FirebaseAuth.instance.currentUser.uid).child("Messages").child(widget.userId).onValue.listen((value){
      messages.clear();
      var keys = value.snapshot.value.keys;
      var data = value.snapshot.value;
      for(var key in keys) {
        Message x = new Message(
          sender: data[key]['sender'],
          time: data[key]['time'],
          date: data[key]['date'],
          unread: data[key]['unread'],
          text: data[key]['text'],
          hash: data[key]['key']
        );
        messages.add(x);
        setState(() {


          if(messages.length<7){
            isMessagesSmall = true;
          }
          else
            isMessagesSmall = false;
        });
        if(isMessagesSmall){
          messages.sort((a, b) {
            var timeOne = a.time.substring(0,a.time.indexOf(":")+6);
            var timetwo= b.time.substring(0,a.time.indexOf(":")+6);

            var dateOne = a.date;
            var datetwo= b.date;

            if(dateOne==datetwo){
              return timeOne.compareTo(timetwo);
            }
            else
              return dateOne.compareTo(datetwo);
          });
        }
        else{

          messages.sort((b, a) {
            var timeOne = a.time.substring(0,a.time.indexOf(":")+6);
            var timetwo= b.time.substring(0,a.time.indexOf(":")+6);

            var dateOne = a.date;
            var datetwo= b.date;

            if(dateOne==datetwo){
              return timeOne.compareTo(timetwo);
            }
            else
              return dateOne.compareTo(datetwo);
          });
        }
      }
    });
  }

  Future<void> setMessageRead() async {
    if(widget.lastHash!=null) {
      DatabaseReference usersRef = FirebaseDatabase.instance.reference();
      usersRef.child("Users").child(FirebaseAuth.instance.currentUser.uid)
          .child("Messages").child(widget.userId).child(widget.lastHash)
          .update({
        'unread': false,
      });
    }
  }

  Future<void> run() async {

    await getMessages();
    await setMessageRead();
  }


}