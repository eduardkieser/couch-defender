import 'package:af/application/grid_model.dart';
import 'package:af/application/hardware_singleton.dart';
import 'package:flutter/material.dart';
import 'package:af/application/states_singleton.dart';
import 'package:provider/provider.dart';

buildSlider(BuildContext context) {
  return Positioned(
    top: 30,
    left: 5,
    right: 5,
    child: Slider(
      value: HardwareSingleton().certaintyThreshold,
      min: 0,
      max: 1,
      divisions: 20,
      label: HardwareSingleton().certaintyThreshold.toString(),
      onChanged: (double value) {
        HardwareSingleton().certaintyThreshold = value;
        Provider.of<GridModel>(context, listen: false).poke();
      },
    ),
  );
}
