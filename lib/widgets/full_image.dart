
import 'package:flutter/material.dart';

class FullPhoto extends StatelessWidget{

  final String image;

  FullPhoto({this.image});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
      ),
      body: Container(
        alignment: Alignment.center,
        child: Image.network(image,fit: BoxFit.fill,
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
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    State createState() => FullPhotoScreenState();
  }

}
class FullPhotoScreenState extends State<FullPhotoScreen>{
  final String image;

  FullPhotoScreenState({this.image});

  @override
  Widget build(BuildContext context) {
     return Container(
       color: Colors.black38,
       padding: EdgeInsets.all(30),
       child: Image(
         image: AssetImage(image),
       ),
     );
  }

  @override
  void initState() {
    super.initState();
  }
}

