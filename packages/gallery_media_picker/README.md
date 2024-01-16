Gallery Photo Picker is based in [photo_widget](https://pub.dev/packages/photo_widget) package and has the same concept as image_picker but with a more attractive interface to choose an image or video from the device gallery, whether it is Android or iOS.

### Flutter 3.7.11
## Features

[✔] pick image

[✔] pick video

[✔] pick multi image / video

[✔] cover thumbnail (preview first image on gallery)

[❌] take picture or video from camera

## Demo (custom view)
<img src="https://github.com/camilo1498/gallery_media_picker/blob/master/screenshots/demo_custom_view.gif" alt="showcase gif" title="custom view" width="200"/>

## Demo (preset view)
<img src="https://github.com/camilo1498/gallery_media_picker/blob/master/screenshots/demo_preset_view.gif" alt="showcase gif" title="preset view" width="200"/>

## Installation
1) This package has only tested in android, add `gallery_media_picker: 0.1.0 in your `pubspec.yaml`
2) import `gallery_media_picker`

```dart
import 'package:gallery_media_picker/gallery_media_picker.dart';
```

## Getting started

1) update kotlin version to `1.6.0` in your `build.gradle`
2) in `android` set the `minSdkVersion` to `25` in your `build.gradle`
3)
#### Android
add uses-permission `AndroidMAnifest.xml` file
 ```xml
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
 ```
#### ios
add this config in your `info.plist` file
 ```xml
     <key>NSPhotoLibraryUsageDescription</key>
     <string>Privacy - Photo Library Usage Description</string>
     <key>NSMotionUsageDescription</key>
     <string>Motion usage description</string>
     <key>NSPhotoLibraryAddUsageDescription</key>
     <string>NSPhotoLibraryAddUsageDescription</string>
 ```

## How to use
Create a `GalleryMediaPicker()` widget:
```dart
Scaffold(
    body: GalleryMediaPicker(
        /// required params
        pathList: (List<PickedAssetModel> paths) { /// => (typeList<PickedAssetModel>) return a list map with selected media metadata
          /// returned data model
          //PickedAssetModel(
          //   'id': String,
          //   'path': String,
          //   'type': String,
          //   'videoDuration': Duration,
          //   'createDateTime': DateTime,
          //   'latitude': double,
          //   'longitude': double,
          //   'thumbnail': Uint8List,
          //   'height': double,
          //   'width': double,
          //   'orientationHeight': int,
          //   'orientationWidth': int,
          //   'orientationSize': Size,
          //   'file': Future<File>,
          //   'modifiedDateTime': DateTime,
          //   'title': String,
          //   'size': Size,
          // )
        },

        /// optional params
        mediaPickerParams: MediaPickerParamsModel(
            maxPickImages: , /// (type int)
            singlePick: , /// (type bool)
            appBarColor: , /// (type Color)
            albumBackGroundColor: , /// (type Color)
            albumDividerColor: , /// (type Color)
            albumTextColor: , /// (type Color)
            appBarIconColor, /// (type Color)
            appBarTextColor: , /// (type Color)
            crossAxisCount, /// /// (type int)
            gridViewBackgroundColor: , /// (type Color)
            childAspectRatio, /// (type double)
            appBarLeadingWidget, /// (type Widget)
            appBarHeight: , /// (type double)
            imageBackgroundColor: , /// (type Color)
            gridPadding: /// (type EdgeInset)
            gridViewController:, /// (type ScrollController)
            gridViewPhysics: /// (type ScrollPhysics)
            selectedBackgroundColor: /// (type Color)
            selectedCheckColor: , /// (type Color)
            thumbnailBoxFix: , /// (type BoxFit)
            selectedCheckBackgroundColor: , /// (type Color)
            onlyImages: , /// (type bool)
            onlyVideos: , /// (type bool)
            thumbnailQuality: , /// (type int) optional param, you can set the gallery thumbnail quality (higher is better but reduce performance)
        )
));
```

## Example
```dart
import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';

void main() => runApp(const Example());

class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GalleryMediaPicker(
            pathList: (List<PickedAssetModel> paths){}
        ),
    );
  }
}

```

if you can use only cover thumbnail use this code line:
```dart
import 'package:flutter/material.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';

void main() => runApp(const Example());

class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        color: Colors.black,
        child: Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2
                                  ),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                /// this is the line to show the first image on gallery
                                child: const CoverThumbnail(
                                    thumbnailQuality: 200,
                                    thumbnailFit: BoxFit.cover
                                ),
                              )
                          )
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 15,bottom: 50),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'Only show the first image on gallery',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10
                            ),
                          ),
                        ),
                      )
                    ],
                  )
              )
            ]
        ),
      ),
    );
  }
}

```
