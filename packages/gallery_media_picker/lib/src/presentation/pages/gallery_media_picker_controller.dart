import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:photo_manager/photo_manager.dart';

mixin PhotoDataController on ChangeNotifier {
  /// save params model
  MediaPickerParamsModel? _paramsModel;
  MediaPickerParamsModel? get paramsModel => _paramsModel;
  set paramsModel(MediaPickerParamsModel? model) {
    _paramsModel = model;
    notifyListeners();
  }

  /// current gallery album
  final currentAlbumNotifier = ValueNotifier<AssetPathEntity?>(null);
  AssetPathEntity? _current;
  AssetPathEntity? get currentAlbum => _current;
  set currentAlbum(AssetPathEntity? current) {
    if (_current != current) {
      _current = current;
      currentAlbumNotifier.value = current;
    }
  }

  /// save path in list
  List<AssetPathEntity> pathList = [];
  final pathListNotifier = ValueNotifier<List<AssetPathEntity>>([]);

  /// order path by date
  static int _defaultSort(
    AssetPathEntity a,
    AssetPathEntity b,
  ) {
    if (a.isAll) {
      return -1;
    }
    if (b.isAll) {
      return 1;
    }
    return 0;
  }

  /// add assets to a list
  void resetPathList(
    List<AssetPathEntity> list, {
    int defaultIndex = 0,
    int Function(
      AssetPathEntity a,
      AssetPathEntity b,
    )
        sortBy = _defaultSort,
  }) {
    list.sort(sortBy);
    pathList.clear();
    pathList.addAll(list);
    currentAlbum = list.isNotEmpty ? list[defaultIndex] : null;
    pathListNotifier.value = pathList;
    notifyListeners();
  }
}

class GalleryMediaPickerController extends ChangeNotifier
    with PhotoDataController {
  /// Notification when max is modified.
  final maxNotifier = ValueNotifier(0);
  int get max => maxNotifier.value;
  set max(int value) => maxNotifier.value = value;
  final onPickMax = ChangeNotifier();

  /// In single-select mode, when you click an unselected item, the old one is automatically cleared and the new one is selected.
  bool get singlePickMode => _singlePickMode;
  bool _singlePickMode = false;
  set singlePickMode(bool singlePickMode) {
    _singlePickMode = singlePickMode;
    if (singlePickMode) {
      maxNotifier.value = 1;
      notifyListeners();
    }
    maxNotifier.value = max;
    notifyListeners();
  }

  /// pick asset entity
  /// notify changes
  final pickedNotifier = ValueNotifier<List<AssetEntity>>([]);
  List<AssetEntity> picked = [];
  void pickEntity(AssetEntity entity) {
    if (singlePickMode) {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        picked.clear();
        picked.add(entity);
      }
    } else {
      if (picked.contains(entity)) {
        picked.remove(entity);
      } else {
        if (picked.length == max) {
          onPickMax.notifyListeners();
          return;
        }
        picked.add(entity);
      }
    }
    pickedNotifier.value = picked;
    pickedNotifier.notifyListeners();
    notifyListeners();
  }

  /// metadata map
  final pickedFileNotifier = ValueNotifier<List<PickedAssetModel>>([]);
  List<PickedAssetModel> pickedFile = [];
  void pickPath(PickedAssetModel path) {
    if (singlePickMode) {
      if (pickedFile.where((element) => element.id == path.id).isNotEmpty) {
        pickedFile.removeWhere((val) => val.id == path.id);
      } else {
        pickedFile.clear();
        pickedFile.add(path);
      }
    } else {
      if (pickedFile.where((element) => element.id == path.id).isNotEmpty) {
        pickedFile.removeWhere((val) => val.id == path.id);
      } else {
        if (pickedFile.length == max) {
          onPickMax.notifyListeners();
          return;
        }
        pickedFile.add(path);
      }
    }
    pickedFileNotifier.value = pickedFile;
    pickedFileNotifier.notifyListeners();
    notifyListeners();
  }

  /// picked path index
  int pickIndex(AssetEntity entity) {
    return picked.indexOf(entity);
  }

  /// get assets album count
  int _assetCount = 0;
  get assetCount => _assetCount;
  final assetCountNotifier = ValueNotifier<int>(0);

  setAssetCount() async {
    Future.delayed(const Duration(seconds: 1), () async {
      if (currentAlbum != null) {
        _assetCount = await currentAlbum!.assetCountAsync;
        assetCountNotifier.value = _assetCount;
        assetCountNotifier.notifyListeners();
        notifyListeners();
      } else {
        assetCountNotifier.value = _assetCount;
        assetCountNotifier.notifyListeners();
        notifyListeners();
      }
    });
  }
}
