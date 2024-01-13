import 'package:flutter/material.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';

class TextEditingNotifier extends ChangeNotifier {
  String _text = '';
  List<String> _textList = [];
  int _textColor = 0;
  double _textSize = 25.0;
  int _fontFamilyIndex = 0;
  int _fontAnimationIndex = 0;
  TextAlign _textAlign = TextAlign.center;
  Color _backGroundColor = Colors.transparent;
  TextAnimationType _animationType = TextAnimationType.none;
  bool _isFontFamily = true;
  bool _isTextAnimation = false;

  PageController _fontFamilyController = PageController(viewportFraction: .125);
  PageController _textAnimationController =
      PageController(viewportFraction: .125);
  TextEditingController _textController = TextEditingController();

  int _currentColorBackground = 0;
  final List<Color> _textColorBackGround = [
    Colors.transparent,
    Colors.black,
    Colors.white
  ];

  int _currentAlign = 0;
  final List<TextAlign> _texAlignment = [
    TextAlign.center,
    TextAlign.right,
    TextAlign.left
  ];

  int _currentAnimation = 0;
  final List<TextAnimationType> animationList = [
    TextAnimationType.none,
    TextAnimationType.fade,
    TextAnimationType.typer,
    TextAnimationType.typeWriter,
    TextAnimationType.scale,
    //TextAnimationType.colorize,
    TextAnimationType.wavy,
    TextAnimationType.flicker
  ];

  String get text => _text;
  int get textColor => _textColor;
  double get textSize => _textSize;
  int get fontFamilyIndex => _fontFamilyIndex;
  int get fontAnimationIndex => _fontAnimationIndex;
  TextAlign get textAlign => _textAlign;
  Color get backGroundColor => _backGroundColor;
  bool get isFontFamily => _isFontFamily;
  bool get isTextAnimation => _isTextAnimation;
  PageController get fontFamilyController => _fontFamilyController;
  PageController get textAnimationController => _textAnimationController;
  TextEditingController get textController => _textController;
  List<String> get textList => _textList;
  TextAnimationType get animationType => _animationType;

  set text(String text) {
    _text = text;
    notifyListeners();
  }

  set textColor(int color) {
    if (_backGroundColor == Colors.white && color == 0) {
      _textColor = 1;
      notifyListeners();
    } else if (_backGroundColor == Colors.black && color == 1) {
      _textColor = 0;
      notifyListeners();
    } else {
      _textColor = color;
      notifyListeners();
    }
  }

  set textSize(double size) {
    _textSize = size;
    notifyListeners();
  }

  set fontFamilyIndex(int fontIndex) {
    _fontFamilyIndex = fontIndex;
    notifyListeners();
  }

  set fontAnimationIndex(int fontIndex) {
    _fontAnimationIndex = fontIndex;
    notifyListeners();
  }

  set isFontFamily(bool isFamily) {
    _isFontFamily = isFamily;
    notifyListeners();
  }

  set isTextAnimation(bool isAnimation) {
    _isTextAnimation = isAnimation;
    notifyListeners();
  }

  set fontFamilyController(PageController controller) {
    _fontFamilyController = controller;
    notifyListeners();
  }

  set textAnimationController(PageController controller) {
    _textAnimationController = controller;
    notifyListeners();
  }

  set textController(TextEditingController textController) {
    _textController = textController;
    notifyListeners();
  }

  set backGroundColor(Color backGround) {
    _backGroundColor = backGround;
    notifyListeners();
  }

  set textAlign(TextAlign align) {
    _textAlign = align;
    notifyListeners();
  }

  set textList(List<String> list) {
    _textList = list;
    notifyListeners();
  }

  set animationType(TextAnimationType animation) {
    _animationType = animation;
    notifyListeners();
  }

  onBackGroundChange() {
    if (_currentColorBackground < _textColorBackGround.length - 1) {
      _currentColorBackground += 1;
      _backGroundColor = _textColorBackGround[_currentColorBackground];
      notifyListeners();
    } else {
      _currentColorBackground = 0;
      _backGroundColor = _textColorBackGround[_currentColorBackground];
      notifyListeners();
    }
  }

  onAlignmentChange() {
    if (_currentAlign < _texAlignment.length - 1) {
      _currentAlign += 1;
      _textAlign = _texAlignment[_currentAlign];
      notifyListeners();
    } else {
      _currentAlign = 0;
      _textAlign = _texAlignment[_currentAlign];
      notifyListeners();
    }
  }

  onAnimationChange() {
    if (_currentAnimation < animationList.length - 1) {
      _currentAnimation += 1;
      _animationType = animationList[_currentAnimation];
      notifyListeners();
    } else {
      _currentAnimation = 0;
      _animationType = animationList[_currentAnimation];
      notifyListeners();
    }
  }

  setDefaults() {
    _text = '';
    _textController.text = '';
    _textColor = 0;
    _textSize = 20.0;
    _fontFamilyIndex = 0;
    _fontAnimationIndex = 0;
    _textAlign = TextAlign.center;
    _backGroundColor = Colors.transparent;
    _fontFamilyController = PageController(viewportFraction: .125);
    _textAnimationController = PageController(viewportFraction: .125);
    _isFontFamily = true;
    _isTextAnimation = false;
    _textList = [];
    _animationType = TextAnimationType.none;
  }

  disposeController() {
    _textController.dispose();
    _fontFamilyController.dispose();
    _textAnimationController.dispose();
  }
}
