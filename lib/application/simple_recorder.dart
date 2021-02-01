/*
 * Copyright 2018, 2019, 2020 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3 (LGPL-V3), as published by
 * the Free Software Foundation.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Flutter-Sound.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:io';
import 'package:af/application/grid_model.dart';
import 'package:af/application/states_singleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

/*
 * This is an example showing how to record to a Dart Stream.
 * It writes all the recorded data from a Stream to a File, which is completely stupid:
 * if an App wants to record something to a File, it must not use Streams.
 *
 * The real interest of recording to a Stream is for example to feed a
 * Speech-to-Text engine, or for processing the Live data in Dart in real time.
 *
 */

///
typedef _Fn = void Function();

/// Example app.
class SimpleRecorder extends StatefulWidget {
  @override
  _SimpleRecorderState createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String _mPath;

  @override
  void initState() {
    // Be careful : openAudioSession return a Future.
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    stopPlayer();
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    stopRecorder();
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    if (_mPath != null) {
      var outputFile = File(_mPath);
      if (outputFile.existsSync()) {
        outputFile.delete();
      }
    }
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    String _mPath = await StatesSingleton().getLocalSoundPath(0);
    var outputFile = File(_mPath);
    if (outputFile.existsSync()) {
      _mplaybackReady = true;
    }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  Future<void> record(int warningIndex) async {
    assert(_mRecorderIsInited && _mPlayer.isStopped);
    await _mRecorder.startRecorder(
      toFile: await StatesSingleton().getLocalSoundPath(warningIndex),
      codec: Codec.aacADTS,
    );
    setState(() {});
  }

  recordWrapper0() => record(0);
  recordWrapper1() => record(1);
  recordWrapper2() => record(2);

  playerWrapper0() => play(0);
  playerWrapper1() => play(1);
  playerWrapper2() => play(2);

  Function getRecordingFunctionFromIndex(int warningIndex) {
    switch (warningIndex) {
      case 0:
        return recordWrapper0;
      case 1:
        return recordWrapper1;
      case 2:
        return recordWrapper2;
    }
  }

  Function getPlaybackFunctionFromIndex(int warningIndex) {
    switch (warningIndex) {
      case 0:
        return playerWrapper0;
      case 1:
        return playerWrapper1;
      case 2:
        return playerWrapper2;
    }
  }

  Future<void> stopRecorder() async {
    await _mRecorder.stopRecorder();
    _mplaybackReady = true;
  }

  void play(int warningIndex) async {
    String _mPath = await StatesSingleton().getLocalSoundPath(warningIndex);
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);
    await _mPlayer.startPlayer(
        fromURI: _mPath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer() async {
    await _mPlayer.stopPlayer();
  }

// ----------------------------- UI --------------------------------------------

  _Fn getRecorderFn(int warningIndex) {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped
        ? getRecordingFunctionFromIndex(warningIndex)
        : () {
            stopRecorder().then((value) => setState(() {}));
          };
  }

  _Fn getPlaybackFn(int warningIndex) {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped
        ? getPlaybackFunctionFromIndex(warningIndex)
        : () {
            stopPlayer().then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buildButtonsFromWarningIndex(int warningIndex) {
      return [
        Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(3),
          height: 80,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFFAF0E6),
            border: Border.all(
              color: Colors.indigo,
              width: 3,
            ),
          ),
          child: Row(children: [
            RaisedButton(
              onPressed: getRecorderFn(warningIndex),
              color: Colors.white,
              disabledColor: Colors.grey,
              child: Text(_mRecorder.isRecording ? 'Stop' : 'Record'),
            ),
            SizedBox(
              width: 20,
            ),
            Text(_mRecorder.isRecording
                ? 'Recording in progress'
                : 'Recorder is stopped'),
          ]),
        ),
        Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(3),
          height: 80,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFFAF0E6),
            border: Border.all(
              color: Colors.indigo,
              width: 3,
            ),
          ),
          child: Row(children: [
            RaisedButton(
              onPressed: getPlaybackFn(warningIndex),
              color: Colors.white,
              disabledColor: Colors.grey,
              child: Text(_mPlayer.isPlaying ? 'Stop' : 'Play'),
            ),
            SizedBox(
              width: 20,
            ),
            Text(_mPlayer.isPlaying
                ? 'Playback in progress'
                : 'Player is stopped'),
          ]),
        ),
      ];
    }

    Widget makeBody() {
      return ListView(
        children: [
          Center(
            child: Text('warning 1'),
          ),
          ...buildButtonsFromWarningIndex(0),
          ...buildButtonsFromWarningIndex(1),
          ...buildButtonsFromWarningIndex(2),
          RaisedButton(
            onPressed: (() {
              StatesSingleton().showRecordingUi = false;
              Provider.of<GridModel>(context, listen: false).poke();
            }),
            child: Text('done'),
          )
        ],
      );
    }

    return StatesSingleton().showRecordingUi
        ? Scaffold(
            backgroundColor: Colors.blue,
            appBar: AppBar(
              title: const Text('Simple Recorder'),
            ),
            body: makeBody(),
          )
        : Container();
  }
}
