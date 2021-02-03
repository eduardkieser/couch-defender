import 'dart:io';

import 'package:af/application/warning_handler_singleton.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StatesSingleton extends ChangeNotifier {
  // ##### Aparently this makes this class a singleton ########
  static final StatesSingleton _statesSingleton = StatesSingleton._internal();
  factory StatesSingleton() {
    return _statesSingleton;
  }
  StatesSingleton._internal() {
    // initialisation
  }
  // ############################################################

  DetectorOutputs detectorOutputs;

  List<int> _previewImageBytes;

  List<String> naughtyList = ['cat', 'dog'];

  num _previewAspectRatio = 1.6;

  Directory appDirectory;

  bool showRecordingUi = false;

  bool isShowingSettingsMenue = false;

  bool isShowingFloatingMenue = true;

  bool isPlayingWarning = false;

  bool isDetecting = false;

  double certaintyThreshold = 0.5;

  String selectedModelString = 'SSD';

  void clearSnapshot() {
    _previewImageBytes = null;
    notifyListeners();
  }

  List<int> get previewImageBytes {
    return _previewImageBytes;
  }

  set previewImageBytes(List<int> bytes) {
    _previewImageBytes = bytes;
    notifyListeners();
  }

  void showSettingsMenue(){
    isShowingSettingsMenue = true;
    isShowingFloatingMenue = false;
    notifyListeners();
  }

  void hideSettingsMenue(){
    isShowingSettingsMenue = false;
    isShowingFloatingMenue = true;
    notifyListeners();
  }

  void setModelString(String newModelString){
    selectedModelString = newModelString;
    notifyListeners();
  }

  num get previewAspectRatio => _previewAspectRatio;

  set previewAspectRatio(aspectRatio) {
    _previewAspectRatio = aspectRatio;
  }

  bool parseRecognitions(recognitions, context) {
    detectorOutputs = DetectorOutputs.fromResutls(recognitions);
    return WarningHandlerSingleton().reviewOutputs(detectorOutputs, context);
  }

  Future<String> get localPath async {
    if (appDirectory == null) {
      appDirectory = await getApplicationDocumentsDirectory();
    }
    return appDirectory.path;
  }

  Future<String> getLocalSoundPath(int index) async {
    if (appDirectory == null) {
      appDirectory = await getApplicationDocumentsDirectory();
    }
    return '${appDirectory.path}/sound$index.aac';
  }

  Future<Directory> get localDir async {
    if (appDirectory == null) {
      appDirectory = await getApplicationDocumentsDirectory();
    }
    return appDirectory;
  }
}

class DetectorOutput {
  String detectedClass;
  double confidenceInClass;
  dynamic rect;
  Map<String, int> centerIx;
  DetectorOutput({this.confidenceInClass, this.detectedClass, this.rect}) {
    centerIx = Map();
    centerIx['x'] = ((rect['x'] + rect['w'] / 2) * 20).toInt();
    centerIx['y'] = ((rect['y'] + rect['h'] / 2) * 20).toInt();
  }
}

class DetectorOutputs {
  List<DetectorOutput> outputs;
  DetectorOutputs.fromResutls(List newOutputs) {
    outputs = [];
    newOutputs.forEach((outputI) {
      DetectorOutput parsedOutput = DetectorOutput(
          confidenceInClass: outputI['confidenceInClass'],
          detectedClass: outputI['detectedClass'],
          rect: outputI['rect']);
      if (outputI['confidenceInClass'] > 0.3) {
        outputs.add(parsedOutput);
      }
    });
  }
}
