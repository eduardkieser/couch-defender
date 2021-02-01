import 'package:af/application/grid_model.dart';
import 'package:af/application/states_singleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:provider/provider.dart';

startRecordingFirstWarning() async {
  StatesSingleton statesSingleton = StatesSingleton();
  print("started");
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  recorder.openAudioSession();
  await recorder.startRecorder(
      toFile: await statesSingleton.localPath + '/1.adts');
  await Future.delayed(const Duration(seconds: 2), () {});
  await recorder.stopRecorder();
  await recorder.closeAudioSession();
  print('stopped');
}

playFirstWarning() async {
  StatesSingleton statesSingleton = StatesSingleton();
  FlutterSoundPlayer player = FlutterSoundPlayer();

  print("${statesSingleton.localPath}/1.adts}");

  await player.openAudioSession();
  await player.startPlayer(
      fromURI: await statesSingleton.localPath + '/1.adts');
  await player.startPlayer();
  await player.closeAudioSession();
}

Widget showRecorderMenue(context) {
  StatesSingleton statesSingleton = StatesSingleton();

  buildRecordingRow() {
    return Row(children: [
      IconButton(
          icon: Icon(Icons.record_voice_over),
          onPressed: () {
            startRecordingFirstWarning();
          })
    ]);
  }

  buildPlaybackRow() {
    return Row(children: [
      IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () {
            playFirstWarning();
          })
    ]);
  }

  buildExitButton(context) {
    return IconButton(
        icon: Icon(Icons.done),
        onPressed: () {
          GridModel gridModel = Provider.of<GridModel>(context, listen: false);
          StatesSingleton statesSingleton = StatesSingleton();
          statesSingleton.showRecordingUi = false;
          gridModel.poke();
        });
  }

  return statesSingleton.showRecordingUi
      ? Positioned.fill(
          child: Center(
          child: Container(
            width: 200,
            height: 200,
            color: Colors.white,
            child: Column(children: [
              buildRecordingRow(),
              buildPlaybackRow(),
              buildExitButton(context),
            ]),
          ),
        ))
      : Positioned.fill(
          child: Container(),
        );
}
