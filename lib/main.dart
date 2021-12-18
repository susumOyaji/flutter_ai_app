import 'package:flutter/material.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import './secondpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<MyHomePage> {
  //final image = await _controller.takePicture();
  //final inputimage = await InputImage.fromFilePath(image.path);

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          enableTracking: true));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // 省略
          // 笑顔度を受け取ってセットする
          var result = "";
          await detectFace(inputimage).then((String value) {
            result = value;
            print("value : $value");
          });

          // If the picture was taken, display it on a new screen.
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayPictureScreen(
                // Pass the automatically generated path to
                // the DisplayPictureScreen widget.
                imagePath: image.path,
                smileText: result,
              ),
            ),
          );
        }, //onPressed
      ),
    );
  }
}

Future detectFace(InputImage inputImage) async {
  final faces = await faceDetector.processImage(inputImage);
  String resText = "No Face";
  print('Found ${faces.length} faces');

  if (faces.length != 0) {
    for (Face face in faces) {
      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
      final FaceLandmark? nose = face.getLandmark(FaceLandmarkType.noseBase);
      if (nose != null) {
        final Offset nosePos = nose.position;
        print("Nose Position : $nosePos");
      }

      // If classification was enabled with FaceDetectorOptions:
      if (face.smilingProbability != null) {
        final double? smileProb = face.smilingProbability;
        print("Smile Prob : $smileProb");
        //笑顔度を返す
        int intsmileProb = (smileProb! * 100).round();
        resText = "SMILE $intsmileProb %";
      }

      // If face tracking was enabled with FaceDetectorOptions:
      if (face.trackingId != null) {
        final int? id = face.trackingId;
        print("Id : $id");
      }
    }
  }
  return resText;
}

// A widget that displays the picture taken by the user.
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
