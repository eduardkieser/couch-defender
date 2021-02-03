
import 'package:af/application/hardware_singleton.dart';
import 'package:af/application/states_singleton.dart';
import 'package:flutter/material.dart';

class SettingsMenueWidget extends StatelessWidget {


  Widget modelSelectorButton(){
    return Card(child: Column(children:[
      ListTile(title: Text('select model'),),
      RadioListTile(
        title: Text('YOLO'),
        value: 'YOLO', 
        groupValue: StatesSingleton().selectedModelString, 
        onChanged: (String value){
          StatesSingleton().setModelString(value);
          HardwareSingleton().loadModel();
          }
      ),
      RadioListTile(
        title: Text('SSD'),
        value: 'SSD', 
        groupValue: StatesSingleton().selectedModelString, 
        onChanged: (String value){
          StatesSingleton().setModelString(value);
          HardwareSingleton().loadModel();
          }
      )
      ]));
  }

  Widget returnButton(){
    return Card(child: ListTile(
      title: Text('done'),
      onTap: (){StatesSingleton().hideSettingsMenue();},
    ),);
  }


  @override
  Widget build(BuildContext context) {
    return StatesSingleton().isShowingSettingsMenue? Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            modelSelectorButton(),
            returnButton()
          ],
        )
      ,),
    ):
    Container();
  }
}