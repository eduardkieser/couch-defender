import 'package:flutter/material.dart';

class GridModel extends ChangeNotifier {
  GridModel({this.gridSize});
  Map<String, int> gridSize;
  List<List<bool>> gridState;
  bool setCellTo;

  GridModel.initGridState({this.gridSize}) {
    setCellTo = true;
    gridState = [];
    for (int rowIx = 0; rowIx < gridSize['height']; rowIx++) {
      gridState.add(List.filled(gridSize['width'], false));
    }
  }

  GridModel.default2020() {
    gridSize = {'height': 20, 'width': 20};
    setCellTo = true;
    gridState = [];
    for (int rowIx = 0; rowIx < 20; rowIx++) {
      gridState.add(List.filled(20, false));
    }
  }

  void toggleCell(int rowIx, int colIx) {
    gridState[rowIx][colIx] = this.setCellTo;
    notifyListeners();
  }

  void toggleSetTo() {
    setCellTo = !setCellTo;
    notifyListeners();
  }

  void resetGrid() {
    gridState = [];
    for (int rowIx = 0; rowIx < gridSize['height']; rowIx++) {
      gridState.add(List.filled(gridSize['width'], false));
    }
    notifyListeners();
  }

  void poke() {
    notifyListeners();
  }
}
