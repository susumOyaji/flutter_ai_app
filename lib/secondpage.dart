import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String smileText;

  const DisplayPictureScreen(
      {Key? key, required this.imagePath, required this.smileText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Display the Picture'),
          backgroundColor: Colors.blue),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(children: [
        Image.file(File(imagePath)),
        Center(
          child: Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.all(30.0),
            child: Text(
              smileText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50.0,
                  color: Colors.deepOrangeAccent),
            ),
          ),
        )
      ], fit: StackFit.expand),
    );
  }
}
