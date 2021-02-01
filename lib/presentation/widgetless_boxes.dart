import 'package:af/application/grid_model.dart';
import 'package:af/application/states_singleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

getWidgetlessBoxes(context) {
  Size screenSize = MediaQuery.of(context).size;
  List<Widget> boxes = [];
  GridModel gridModel = Provider.of<GridModel>(context);
  StatesSingleton statesSingleton = Provider.of<StatesSingleton>(context);
  if (statesSingleton.detectorOutputs == null) {
    return Positioned.fill(child: Container());
  }
  statesSingleton.detectorOutputs.outputs.forEach((element) {
    boxes.add(Positioned(
        top: element.rect['y'] * screenSize.height,
        left: element.rect['x'] * screenSize.width,
        height: element.rect['h'] * screenSize.height,
        width: element.rect['w'] * screenSize.width,
        child: statesSingleton.naughtyList.contains(element.detectedClass)
            ? Container(
                //dog or cat
                color: gridModel.gridState[element.centerIx['y']]
                        [element.centerIx['x']]
                    ? Colors.red.withAlpha(200)
                    : Colors.green.withAlpha(50),
                child: Center(
                  child: Icon(
                    Icons.crop_square_sharp,
                    color: Colors.red,
                  ),
                ),
              )
            : Container(
                //something else
                // color: Colors.blue.withAlpha(50),
                // child: Center(child: Text("${element.detectedClass}")),
                )));
  });
  return Positioned.fill(child: Stack(children: boxes));
}
