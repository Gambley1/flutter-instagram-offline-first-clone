import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';

class AnimationSelector extends StatelessWidget {
  const AnimationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Consumer2<TextEditingNotifier, ControlNotifier>(
      builder: (context, editorNotifier, controlNotifier, child) {
        return Container(
          height: size.width * 0.1,
          width: size.width,
          alignment: Alignment.center,
          child: PageView.builder(
            controller: editorNotifier.textAnimationController,
            itemCount: editorNotifier.animationList.length,
            onPageChanged: (index) {
              editorNotifier.fontAnimationIndex = index;
              HapticFeedback.heavyImpact();
            },
            physics: const BouncingScrollPhysics(),
            allowImplicitScrolling: true,
            pageSnapping: false,
            itemBuilder: (context, index) {
              return AnimatedOnTapButton(
                onTap: () {
                  editorNotifier.fontAnimationIndex = index;
                  editorNotifier.textAnimationController.jumpToPage(index);
                },
                child: Container(
                  height: size.width * 0.25,
                  width: size.width * 0.25,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: index == editorNotifier.fontAnimationIndex
                          ? Colors.white
                          : Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: DefaultTextStyle(
                    style: TextStyle(
                            fontFamily: controlNotifier
                                .fontList![editorNotifier.fontFamilyIndex],
                            package: controlNotifier.isCustomFontList
                                ? null
                                : 'stories_editor')
                        .copyWith(
                            color: index == editorNotifier.fontAnimationIndex
                                ? Colors.red
                                : Colors.white,
                            fontWeight: FontWeight.bold),
                    child: editorNotifier.animationList[index] ==
                            TextAnimationType.none
                        ? const Text('Aa')
                        : AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [
                              if (editorNotifier.animationList[index] ==
                                  TextAnimationType.scale)
                                ScaleAnimatedText('Aa',
                                    duration:
                                        const Duration(milliseconds: 600)),
                              if (editorNotifier.animationList[index] ==
                                  TextAnimationType.fade)
                                FadeAnimatedText('Aa',
                                    duration:
                                        const Duration(milliseconds: 600)),
                              if (editorNotifier.animationList[index] ==
                                  TextAnimationType.typer)
                                TyperAnimatedText('Aa',
                                    speed: const Duration(milliseconds: 500)),
                              if (editorNotifier.animationList[index] ==
                                  TextAnimationType.typeWriter)
                                TypewriterAnimatedText(
                                  'Aa',
                                  speed: const Duration(milliseconds: 500),
                                ),
                              if (editorNotifier.animationList[index] ==
                                  TextAnimationType.wavy)
                                WavyAnimatedText(
                                  'Aa',
                                  speed: const Duration(milliseconds: 500),
                                ),
                              if (editorNotifier.animationList[index] ==
                                  TextAnimationType.flicker)
                                FlickerAnimatedText(
                                  'Aa',
                                  speed: const Duration(milliseconds: 500),
                                ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
