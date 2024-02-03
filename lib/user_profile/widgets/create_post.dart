import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({
    required this.selectedFilesDetails,
    super.key,
  });
  final SelectedImagesDetails selectedFilesDetails;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool isSwitched = false;
  final _busy = ValueNotifier(false);

  TextEditingController captionController = TextEditingController(text: '');
  bool isImage = true;
  late bool multiSelectionMode;
  late SelectedByte firstSelectedByte;
  late List<SelectedByte> selectedByte;

  late Uint8List firstFileByte;

  @override
  void initState() {
    super.initState();

    selectedByte = widget.selectedFilesDetails.selectedFiles;
    firstSelectedByte = widget.selectedFilesDetails.selectedFiles[0];
    multiSelectionMode = widget.selectedFilesDetails.multiSelectionMode;
    isImage = firstSelectedByte.isThatImage;
    firstFileByte = firstSelectedByte.selectedByte;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: context.isMobile ? appBar(context) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 10,
              end: 10,
              top: 10,
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: Stack(
                    children: [
                      if (isImage) Image.memory(firstFileByte),
                      if (multiSelectionMode)
                        const Padding(
                          padding: EdgeInsets.all(2),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Icon(
                              Icons.copy_rounded,
                              color: Colors.white,
                              size: AppSize.iconSizeSmall,
                            ),
                          ),
                        ),
                      if (!isImage)
                        const Padding(
                          padding: EdgeInsets.all(2),
                          child: Align(
                            child: Icon(
                              Icons.slow_motion_video_sharp,
                              color: Colors.white,
                              size: AppSize.iconSizeSmall,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: captionController,
                    style: context.bodyLarge,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Caption',
                      hintStyle: TextStyle(
                        color: context.theme.bottomAppBarTheme.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text(
        'New post',
        style: context.titleLarge?.copyWith(fontWeight: AppFontWeight.bold),
      ),
      actions: actionsWidgets(context),
    );
  }

  List<Widget> actionsWidgets(BuildContext context) {
    return [
      ValueListenableBuilder<bool>(
        valueListenable: _busy,
        builder: (context, busy, child) => busy
            ? const AppCircularProgress(Colors.blue)
            : IconButton(
                onPressed: () async {
                  await createPost(context);
                },
                icon: const Icon(
                  Icons.check_rounded,
                  size: AppSize.iconSize,
                  color: Colors.blue,
                ),
              ),
      ),
    ];
  }

  Future<void> createPost(BuildContext context) async {
    // context.read<UserProfileBloc>().add(
    //       UserProfilePostCreateRequested(
    //         postId: postId,
    //         userId: userId,
    //         caption: bodySmall,
    //         type: type,
    //         mediaUrl: mediaUrl,
    //         imagesUrl: imagesUrl,
    //       ),
    //     );

    // if (postCubit.newPostInfo != null) {
    //   if (!mounted) return;

    //   await UserInfoCubit.get(context).updateUserPostsInfo(
    //     userId: myPersonalId,
    //     postInfo: postCubit.newPostInfo!,
    //   );
    //   await postCubit.getPostsInfo(
    //     postsIds: myPersonalInfo.posts,
    //     isThatMyPosts: true,
    //   );
    WidgetsBinding.instance.addPostFrameCallback((_) => _busy.value = false);
    // }
    if (!mounted) return;
  }
}
