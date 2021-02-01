import 'package:af/application/grid_model.dart';
import 'package:af/application/hardware_singleton.dart';
import 'package:af/application/simple_recorder.dart';
import 'package:af/application/states_singleton.dart';
import 'package:af/presentation/floating_menue_widget.dart';
import 'package:af/presentation/slider_widget.dart';
import 'package:af/presentation/widgetless_boxes.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class CameraOverlayWidget extends StatefulWidget {
  CameraOverlayWidget({Key key}) : super(key: key);

  @override
  _CameraOverlayWidgetState createState() => _CameraOverlayWidgetState();
}

class _CameraOverlayWidgetState extends State<CameraOverlayWidget>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    HardwareSingleton hardwareSingleton = HardwareSingleton();

    if (state == AppLifecycleState.inactive) {
      hardwareSingleton.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (hardwareSingleton.controller == null) {
        hardwareSingleton.initialiseCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    StatesSingleton statesSingleton = StatesSingleton();
    if (Provider.of<StatesSingleton>(context).previewImageBytes != null) {
      return Container();
    }
    HardwareSingleton hardwareSingleton =
        Provider.of<HardwareSingleton>(context);
    CameraController controller = hardwareSingleton.controller;

    if (controller == null) {
      return Container();
    }
    if (!controller.value.isInitialized) {
      return Container();
    }
    statesSingleton.previewAspectRatio = controller.value.aspectRatio;
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }
}

class GridWidget extends StatelessWidget {
  GridWidget({Key key}) : super(key: key);

  final GlobalKey gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: stackCameraAndOverlay(context, gridKey),
    );
  }
}

Widget stackCameraAndOverlay(BuildContext context, GlobalKey gridKey) {
  return Stack(
    alignment: Alignment.bottomCenter,
    children: [
      Positioned.fill(
        child: CameraOverlayWidget(),
      ),
      Positioned.fill(
        child: buildSnapshot(context),
      ),
      Positioned.fill(
        child: buildGrid(context, gridKey),
      ),
      getWidgetlessBoxes(context),
      Positioned(bottom: 5, child: Center(child: FloatingMenue())),
      buildSlider(context),
      SimpleRecorder()
    ],
  );
}

Widget buildSnapshot(BuildContext context) {
  StatesSingleton statesSingleton = StatesSingleton();
  if (statesSingleton.previewImageBytes == null) {
    return Container();
  } else {
    List<int> bytes = statesSingleton.previewImageBytes;

    return AspectRatio(
      aspectRatio: statesSingleton.previewAspectRatio,
      child: Image.memory(bytes),
    );
  }
}

Widget buildGrid(BuildContext context, GlobalKey gridKey) {
  //Index order is row then column
  // I.e. rows are collections of column widgets
  List<List<bool>> state = Provider.of<GridModel>(context).gridState;

  //building tile widgets
  List<List<Widget>> tileWidgets = [];
  state.asMap().forEach((rowIx, rowStates) {
    List<Widget> columnTiles = [];
    rowStates.asMap().forEach((colIx, coolumnState) {
      columnTiles.add(cell(coolumnState, colIx, rowIx, context));
    });
    tileWidgets.add(columnTiles);
  });

  //building actual row and column layout
  List<Widget> columnList = [];
  tileWidgets.forEach((rowWidgets) {
    columnList.add(Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: rowWidgets,
      ),
    ));
  });

  return GestureDetector(
    onPanUpdate: (details) {
      // print(details.localPosition);
      Map ixMap = panDetailsToIxs(details, context, gridKey);
      GridModel gridModel = Provider.of<GridModel>(context, listen: false);
      gridModel.toggleCell(ixMap['yIx'], ixMap['xIx']);
    },
    child: Column(key: gridKey, children: columnList),
  );
}

Widget cell(bool isActive, int rowIx, int colIx, BuildContext context) {
  Color cellColor = isActive
      ? Colors.redAccent.withAlpha(100)
      : Colors.greenAccent.withAlpha(20);
  return Expanded(
    child: Container(
      color: cellColor,
    ),
  );
}

Map<String, int> panDetailsToIxs(
    DragUpdateDetails details, BuildContext context, GlobalKey gridKey) {
  RenderBox gridRenderBox = gridKey.currentContext.findRenderObject();
  Size gridSizePixels = gridRenderBox.size;
  int dxIx = ((details.globalPosition.dx / gridSizePixels.width) * 20).floor();
  int dyIx = ((details.globalPosition.dy / gridSizePixels.height) * 20).floor();
  return {'xIx': dxIx, 'yIx': dyIx};
}
