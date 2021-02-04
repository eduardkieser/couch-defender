import 'package:af/application/grid_model.dart';
import 'package:af/application/image_recorder_singleton.dart';
import 'package:af/application/image_utils.dart';
import 'package:af/application/states_singleton.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image/image.dart' as imglib;
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:tflite/tflite.dart';

class HardwareSingleton extends ChangeNotifier {
  // ##### Aparently this makes this class a singleton ########
  static final HardwareSingleton _hardwareSingleton =
      HardwareSingleton._internal();
  factory HardwareSingleton() {
    return _hardwareSingleton;
  }
  HardwareSingleton._internal() {
    this.initialiseCamera();
    this.loadModel();
    pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
  }
  // ################  End of singleton logic ##################

  // ################ Start of camera logic ####################
  CameraController controller;
  List<CameraDescription> cameras;
  CameraImage snapShotImage;
  imglib.PngEncoder pngEncoder;
  double certaintyThreshold = 0.6;
  DateTime lastDetection = DateTime.now();
  Duration timeSinceLastDetection = Duration(seconds: 3);

  void initialiseCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize();
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    try {
      switch (StatesSingleton().selectedModelString) {
        case 'YOLO':
          res = await Tflite.loadModel(
            model: "assets/yolov2_tiny.tflite",
            labels: "assets/yolov2_tiny.txt",
            // useGpuDelegate: true,
          );
          print('Loaded yolo model');
          break;
        default:
          res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt",
            // useGpuDelegate: true,
          );
          print('Loaded ssd model');
          break;
      }
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future<void> getSnapshot() {
    StatesSingleton statesSingleton = StatesSingleton();
    statesSingleton.previewAspectRatio = controller.value.aspectRatio;
    controller.startImageStream((CameraImage image) {
      controller.stopImageStream();
      imglib.Image decodedImage = aVeryGoodCameraImageConverter(image);
      decodedImage = imglib.copyRotate(decodedImage, 90);

      statesSingleton.previewImageBytes = pngEncoder.encodeImage(decodedImage);
      notifyListeners();
    });
    return null;
  }

  stopReading(context) {
    if (!controller.value.isStreamingImages) {
      return;
    }
    try {
      controller.stopImageStream();
      StatesSingleton statesSingleton = StatesSingleton();
      statesSingleton.parseRecognitions([], context);
    } on Exception {
      print('could not stop image stream because of some ecxeption...');
    }
  }

  Future<void> startReadingImages(context) {
    if (controller.value.isStreamingImages) {
      return null;
    }
    controller.startImageStream((CameraImage img) async {
      timeSinceLastDetection = DateTime.now().difference(lastDetection);
      if (!StatesSingleton().isDetecting && (timeSinceLastDetection>Duration(seconds: StatesSingleton().delayPeriod.round()))) {
        lastDetection = DateTime.now();
        StatesSingleton().isDetecting = true;
        Provider.of<GridModel>(context, listen: false).poke();
        
        var recognitions = await runModel(img);

        StatesSingleton statesSingleton = StatesSingleton();
        //Parse recognitions will return true if an infraction is detected in the image;
        bool didDetectInfraction =
            statesSingleton.parseRecognitions(recognitions, context);
        print('did detect something: $didDetectInfraction');
        if (didDetectInfraction) {
          print('should save image');
          await ImageRecorderSingleton().saveSnapshot(img);
        }
        statesSingleton.isDetecting = false;
        notifyListeners();
        Provider.of<GridModel>(context, listen: false).poke();
      }
    });
    return null;
  }

  Future<List<dynamic>> runSSD(CameraImage img)async{
    var recognitions = await Tflite.detectObjectOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(), // required
          model: "SSDMobileNet",
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: 127.5, // defaults to 127.5
          imageStd: 127.5, // defaults to 127.5
          rotation: 90, // defaults to 90, Android only
          threshold: certaintyThreshold, // defaults to 0.1
          asynch: true, // defaults to true
          // numResultsPerClass: 2
        );
    return recognitions;
  }

  Future<List<dynamic>> runYOLO(CameraImage img)async{
          var recognitions = await Tflite.detectObjectOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(), // required
            model: "YOLO",
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: 0, // defaults to 127.5
            imageStd: 255.0, // defaults to 127.5
            // numResults: 2,        // defaults to 5
            threshold: 0.1, // defaults to 0.1
            numResultsPerClass: 2, // defaults to 5
            // anchors: anchors,     // defaults to [0.57273,0.677385,1.87446,2.06253,3.33843,5.47434,7.88282,3.52778,9.77052,9.16828]
            blockSize: 32, // defaults to 32
            numBoxesPerBlock: 5, // defaults to 5
            asynch: true);
            return recognitions;
  }

  void startReading(context) {
    startReadingImages(context);
  }

  Future<List<dynamic>> runModel(CameraImage img){
    if(StatesSingleton().selectedModelString=='SSD'){
      return runSSD(img);
    }
    else if (StatesSingleton().selectedModelString=='YOLO'){
      return runYOLO(img);
    }
    else{
      print('Invalid Model Selection String!!');
      throw Error();
    }
  }

  Future<void> hackyDoubleSnapshot() async {
    await getSnapshot();
    await Future.delayed(const Duration(seconds: 1), () => {});
    await getSnapshot();
  }

  void playWarning(int warningIndex) async {
    print('playing warning');
    if (!StatesSingleton().isPlayingWarning) {
      StatesSingleton().isPlayingWarning = true;
      FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
      await _mPlayer.openAudioSession();
      String _mPath = await StatesSingleton().getLocalSoundPath(warningIndex);
      print('playing $_mPath');
      await _mPlayer.startPlayer(
          fromURI: _mPath,
          codec: Codec.aacADTS,
          whenFinished: () {
            StatesSingleton().isPlayingWarning = false;
            _mPlayer.closeAudioSession();
          });
    }
  }
}
