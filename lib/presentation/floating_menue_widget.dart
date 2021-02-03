import 'package:af/application/grid_model.dart';
import 'package:af/application/hardware_singleton.dart';
import 'package:af/application/states_singleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FloatingMenue extends StatelessWidget {
  const FloatingMenue({Key key}) : super(key: key);

  Widget buildFloatingMenue(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: StatesSingleton().isDetecting ? Colors.red : Colors.blue,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Provider.of<GridModel>(context, listen: false).resetGrid();
            },
            icon: Icon(Icons.clear),
          ),
          IconButton(
            onPressed: () {
              Provider.of<GridModel>(context, listen: false).toggleSetTo();
            },
            icon: Icon(Icons.invert_colors),
          ),
          // IconButton(
          //   onPressed: () {
          //     Provider.of<StatesSingleton>(context, listen: false)
          //         .clearSnapshot();
          //     Provider.of<GridModel>(context, listen: false).poke();
          //   },
          //   icon: Icon(Icons.clear),
          // ),
          IconButton(
            onPressed: () {
              Provider.of<HardwareSingleton>(context, listen: false)
                  .startReading(context);
              Provider.of<GridModel>(context, listen: false).poke();
            },
            icon: Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () {
              Provider.of<HardwareSingleton>(context, listen: false)
                  .stopReading(context);
              Provider.of<GridModel>(context, listen: false).poke();
            },
            icon: Icon(Icons.stop),
          ),
          IconButton(
            onPressed: () {
              Provider.of<StatesSingleton>(context, listen: false)
                  .showRecordingUi = true;
              Provider.of<GridModel>(context, listen: false).poke();
            },
            icon: Icon(Icons.music_note),
          ),
          IconButton(
            onPressed: () {
              StatesSingleton().showSettingsMenue();
            },
            icon: Icon(Icons.menu),
          )
        ],
      ),
    );
  }

  @override
  build(BuildContext context){
    return StatesSingleton().isShowingFloatingMenue?
    buildFloatingMenue(context):
    Container();
  }
}
