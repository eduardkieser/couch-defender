import 'package:af/application/grid_model.dart';
import 'package:af/application/hardware_singleton.dart';
import 'package:af/application/states_singleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsMenueWidget extends StatelessWidget {
  Widget delaySlider(context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Select Delay Period'),
          ),
          Slider(
            value: StatesSingleton().delayPeriod,
            min: 0,
            max: 5,
            divisions: 5,
            label: StatesSingleton().delayPeriod.toString(),
            onChanged: (double value) {
              StatesSingleton().delayPeriod = value;
              Provider.of<GridModel>(context, listen: false).poke();
            },
          )
        ],
      ),
    );
  }

  Widget modelSelectorButton() {
    return Card(
        child: Column(children: [
      ListTile(
        title: Text('select model'),
      ),
      RadioListTile(
          title: Text('YOLO'),
          value: 'YOLO',
          groupValue: StatesSingleton().selectedModelString,
          onChanged: (String value) {
            StatesSingleton().setModelString(value);
            HardwareSingleton().loadModel();
          }),
      RadioListTile(
          title: Text('SSD'),
          value: 'SSD',
          groupValue: StatesSingleton().selectedModelString,
          onChanged: (String value) {
            StatesSingleton().setModelString(value);
            HardwareSingleton().loadModel();
          })
    ]));
  }

  Widget returnButton() {
    return Card(
      child: ListTile(
        title: Text('done'),
        onTap: () {
          StatesSingleton().hideSettingsMenue();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatesSingleton().isShowingSettingsMenue
        ? Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: ListView(
                children: [
                  modelSelectorButton(),
                  delaySlider(context),
                  returnButton()
                ],
              ),
            ),
          )
        : Container();
  }
}
