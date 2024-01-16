import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/presentation/widgets/tool_button.dart';

class TopTextTools extends StatelessWidget {
  final void Function() onDone;
  
  const TopTextTools({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Consumer<TextEditingNotifier>(
      builder: (context, editorNotifier, child) {
        return Container(
          padding: const EdgeInsets.only(top: 15),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// font family / font color
                  ToolButton(
                    onTap: () {
                      editorNotifier.isFontFamily =
                          !editorNotifier.isFontFamily;
                      editorNotifier.isTextAnimation = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (editorNotifier.fontFamilyController.hasClients) {
                          editorNotifier.fontFamilyController.animateToPage(
                              editorNotifier.fontFamilyIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        }
                      });
                    },
                    child: Transform.scale(
                        scale: !editorNotifier.isFontFamily ? 0.8 : 1.3,
                        child: !editorNotifier.isFontFamily
                            ? const ImageIcon(
                                AssetImage('assets/icons/text.png',
                                    package: 'stories_editor'),
                                size: 20,
                                color: Colors.white,
                              )
                            : Image.asset(
                                'assets/icons/circular_gradient.png',
                                package: 'stories_editor',
                              )),
                  ),

                  /// text align
                  ToolButton(
                    onTap: editorNotifier.onAlignmentChange,
                    child: Transform.scale(
                        scale: 0.8,
                        child: Icon(
                          editorNotifier.textAlign == TextAlign.center
                              ? Icons.format_align_center
                              : editorNotifier.textAlign == TextAlign.right
                                  ? Icons.format_align_right
                                  : Icons.format_align_left,
                          color: Colors.white,
                        )),
                  ),

                  /// background color
                  ToolButton(
                    onTap: editorNotifier.onBackGroundChange,
                    child: Transform.scale(
                        scale: 0.7,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.only(left: 5, bottom: 3),
                            child: ImageIcon(
                              AssetImage('assets/icons/font_backGround.png',
                                  package: 'stories_editor'),
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ),
                  ToolButton(
                    onTap: () {
                      editorNotifier.isTextAnimation =
                          !editorNotifier.isTextAnimation;

                      /// animate to selected animation page
                      if (editorNotifier.isTextAnimation) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (editorNotifier
                              .textAnimationController.hasClients) {
                            editorNotifier.textAnimationController
                                .animateToPage(
                                    editorNotifier.fontAnimationIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn);
                          }
                        });
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (editorNotifier.fontFamilyController.hasClients) {
                            editorNotifier.fontFamilyController.animateToPage(
                                editorNotifier.fontFamilyIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          }
                        });
                      }
                    },
                    child: Transform.scale(
                        scale: 0.7,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: ImageIcon(
                              AssetImage('assets/icons/video_trim.png',
                                  package: 'stories_editor'),
                              color: Colors.white,
                            ),
                          ),
                        )),
                  )
                ],
              ),

              /// close and create item
              GestureDetector(
                onTap: onDone,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
