// ignore_for_file: lines_longer_than_80_chars

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/chat_context.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/chat_message_factory.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/message_caption.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/message_content.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message/short_info_factory.dart';
import 'package:flutter_instagram_offline_first_clone/chats/chat/widgets/message_wrap.dart';
import 'package:shared/shared.dart';

class MessageWrapShowcasePage extends StatelessWidget {
  const MessageWrapShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: const AppDarkTheme().theme,
      debugShowCheckedModeBanner: false,
      home: AppScaffold(
        appBar: AppBar(title: const Text('Message Showcase')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ChatContext(
                  data: ChatContextData.desktop(
                    width: constraints.maxWidth,
                    maxWidth: context.screenWidth * .85,
                  ),
                  child: const _Body(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TestMessageContent extends StatelessWidget {
  const TestMessageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MessageContent(
      children: [
        RepliedMessageBubble(
          message: Message(
            id: uuid.v4(),
            message: 'Hello world!',
            sender: PostAuthor.randomConfirmed(),
            isEdited: true,
          ),
        ),
      ],
    );
  }
}

class MessageAnimation extends StatelessWidget {
  const MessageAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    const chatMessageFactory = ChatMessageFactory();
    const shortInfoFactory = ShortInfoFactory();
    // const replyInfoFactory = ReplyInfoFactory();
    final chatContextData = ChatContext.of(context);

    return chatMessageFactory.createConversationMessage(
      context: context,
      isOutgoing: true,
      senderTitle: null,
      reply: null,
      blocks: <Widget>[
        MessageCaption(
          padding: EdgeInsets.only(
            left: chatContextData.horizontalPadding,
            right: chatContextData.horizontalPadding,
            top: chatContextData.verticalPadding,
          ),
          text: CustomRichText.planeText(
            'Hi fa fe fa fa f',
          ),
          shortInfo: shortInfoFactory.create(
            context: context,
            isOutgoing: true,
            padding: EdgeInsets.only(bottom: chatContextData.verticalPadding),
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        MessageAnimation(),
      ],
    );
  }
}

class Example1 extends StatelessWidget {
  const Example1({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        content: Text.rich(
          const TextSpan(
            text: 'Text with Widget',
            children: <InlineSpan>[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.bookmark),
              ),
            ],
          ),
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(backgroundColor: Colors.amber),
        ),
        shortInfo: Container(
          width: 150,
          height: 16,
          color: Colors.red,
        ),
      ),
    );
  }
}

class Example2 extends StatelessWidget {
  const Example2({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        wrapGravity: WrapGravity.top,
        content: Text(
          '[Gravity Top] The text style to apply to descendant [Text] widgets which do not have an explicit style',
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(backgroundColor: Colors.amber),
        ),
        shortInfo: Container(
          width: 150,
          height: 4,
          color: Colors.red,
        ),
      ),
    );
  }
}

class Example10 extends StatelessWidget {
  const Example10({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        content: Text(
          '[Gravity Top] The text style to apply to descendant [Text] widgets which do not have an explicit style',
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(backgroundColor: Colors.amber),
        ),
        shortInfo: Container(
          width: 150,
          height: 4,
          color: Colors.red,
        ),
      ),
    );
  }
}

class Example4 extends StatelessWidget {
  const Example4({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        content: Text(
          '🤯',
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(backgroundColor: Colors.amber, fontSize: 30),
        ),
        shortInfo: Container(
          width: 150,
          height: 16,
          color: Colors.red,
        ),
      ),
    );
  }
}

class Example5 extends StatelessWidget {
  const Example5({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        content: Container(
          width: 50,
          height: 32,
          color: Colors.blue,
        ),
        shortInfo: Container(
          width: 150,
          height: 16,
          color: Colors.red,
          child: const Text('text'),
        ),
      ),
    );
  }
}

class Example6 extends StatelessWidget {
  const Example6({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        content: const Text(''),
        shortInfo: Container(
          width: 100,
          height: 16,
          color: Colors.red,
        ),
      ),
    );
  }
}

class Example7 extends StatelessWidget {
  const Example7({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        content: Column(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              color: Colors.yellow,
            ),
            const Text('Gravity bottom'),
            Text(
              'Support column',
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(backgroundColor: Colors.amber, fontSize: 20),
            ),
          ],
        ),
        shortInfo: Container(
          width: 50,
          height: 16,
          color: Colors.red,
        ),
      ),
    );
  }
}

class Example11 extends StatelessWidget {
  const Example11({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        wrapGravity: WrapGravity.top,
        content: Column(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              color: Colors.yellow,
            ),
            const Text('Gravity top'),
            Text(
              'Support column',
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(backgroundColor: Colors.amber, fontSize: 20),
            ),
          ],
        ),
        shortInfo: Container(
          width: 50,
          height: 16,
          color: Colors.red,
        ),
      ),
    );
  }
}

class Example8 extends StatelessWidget {
  const Example8({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        wrapGravity: WrapGravity.top,
        content: Container(
          width: 50,
          height: 32,
          color: Colors.blue,
        ),
        shortInfo: Container(
          width: 150,
          height: 16,
          color: Colors.red,
          child: const Text('with top gravity'),
        ),
      ),
    );
  }
}

class Example9 extends StatelessWidget {
  const Example9({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: MessageWrap(
        wrapGravity: WrapGravity.top,
        content: Text(
          'TEXT',
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(backgroundColor: Colors.amber, fontSize: 30),
        ),
        shortInfo: Container(
          width: 150,
          height: 16,
          color: Colors.red,
          child: const Text('with top gravity'),
        ),
      ),
    );
  }
}
