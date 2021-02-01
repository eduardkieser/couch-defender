import 'package:af/application/grid_model.dart';
import 'package:af/application/hardware_singleton.dart';
import 'package:af/application/states_singleton.dart';
import 'package:provider/provider.dart';

class WarningHandlerSingleton {
  // ##### Aparently this makes this class a singleton ########
  static final WarningHandlerSingleton _WarningHandlerSingleton =
      WarningHandlerSingleton._internal();
  factory WarningHandlerSingleton() {
    return _WarningHandlerSingleton;
  }
  WarningHandlerSingleton._internal() {
    infractionsList = [];
  }
  // ################  End of singleton logic ##################

  List<DateTime> infractionsList;

  bool addInfraction() {
    // last infraction is less than 2 seconds old then add:
    if (infractionsList.length > 0) {
      Duration timeSinceInfraction =
          DateTime.now().difference(infractionsList.last);
      if (timeSinceInfraction < Duration(seconds: 3)) {
        return false;
      }
    }
    print('adding infraction, len: ${infractionsList.length}');
    infractionsList.add(DateTime.now());
    evaluateInfractions();
    return true;
  }

  evaluateInfractions() {
    // if there was one infraction in the last 20 seconds play warning 1
    // if there were two infractions inthe last 20 seconds play warning 2 ect
    int recentInfractionCount = 0;
    DateTime currentTime = DateTime.now();
    infractionsList.forEach((DateTime timeOfBooBoo) {
      if (currentTime.difference(timeOfBooBoo) < Duration(seconds: 20)) {
        recentInfractionCount++;
      }
    });

    emitWarning(recentInfractionCount.clamp(0, 3) - 1);
  }

  emitWarning(int warningType) {
    HardwareSingleton().playWarning(warningType);
  }

  bool reviewOutputs(DetectorOutputs outputs, context) {
    bool doesContainInfraction = false;
    List gridState = Provider.of<GridModel>(context, listen: false).gridState;
    outputs.outputs.forEach((output) {
      bool onNaughtyList =
          StatesSingleton().naughtyList.contains(output.detectedClass);
      bool inDangerZone = gridState[output.centerIx['y']][output.centerIx['x']];

      if (onNaughtyList && inDangerZone) {
        //return after discovering first infraction.
        addInfraction();
        doesContainInfraction = true;
      }
    });
    return doesContainInfraction;
  }
}
