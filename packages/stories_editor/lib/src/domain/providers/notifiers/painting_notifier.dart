import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stories_editor/src/domain/models/painting_model.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';

class PaintingNotifier extends ChangeNotifier {
  /// here all line Paths will be save
  List<PaintingModel> _lines = <PaintingModel>[];

  /// color index
  int _lineColor = 0;

  /// line width
  double _lineWidth = 10;

  /// tool index
  int _selectedToolIndex = 0;

  /// painter type
  PaintingType _paintingType = PaintingType.pen;

  /// listen all draw lines
  StreamController<List<PaintingModel>> _linesStreamController =
      StreamController<List<PaintingModel>>.broadcast();

  /// listen pan gesture events
  StreamController<PaintingModel> _currentLineStreamController =
      StreamController<PaintingModel>.broadcast();

  List<PaintingModel> get lines => _lines;
  int get lineColor => _lineColor;
  double get lineWidth => _lineWidth;
  int get selectedToolIndex => _selectedToolIndex;
  StreamController<List<PaintingModel>> get linesStreamController =>
      _linesStreamController;
  StreamController<PaintingModel> get currentLineStreamController =>
      _currentLineStreamController;
  PaintingType get paintingType => _paintingType;

  set lines(List<PaintingModel> line) {
    _lines = line;
    notifyListeners();
  }

  set itemLine(List<Widget> item) {
    notifyListeners();
  }

  set lineColor(int color) {
    _lineColor = color;
    notifyListeners();
  }

  set lineWidth(double width) {
    _lineWidth = width;
    notifyListeners();
  }

  set selectedToolIndex(int index) {
    _selectedToolIndex = index;
    notifyListeners();
  }

  set linesStreamController(StreamController<List<PaintingModel>> stream) {
    _linesStreamController = stream;
    notifyListeners();
  }

  set currentLineStreamController(StreamController<PaintingModel> stream) {
    _currentLineStreamController = stream;
    notifyListeners();
  }

  set paintingType(PaintingType type) {
    _paintingType = type;
    notifyListeners();
  }

  clearAll() {
    _lines = [];
    notifyListeners();
  }

  removeLast() {
    if (_lines.isNotEmpty) {
      _lines.removeLast();
      notifyListeners();
    } else {
      _lines = [];
      notifyListeners();
    }
  }

  resetDefaults() {
    _lineWidth = 10;
    _lineColor = 0;
    _paintingType = PaintingType.pen;
    notifyListeners();
  }

  closeConnection() {
    _currentLineStreamController.close();
    _linesStreamController.close();
  }
}
