import 'package:insta_blocks/insta_blocks.dart';

/// Signature of callbacks invoked when [BlockAction] is triggered.
typedef BlockActionCallback = void Function(BlockAction action);

/// Optional Signature of callbacks invoked when [BlockAction] is triggered.
typedef OptionalBlockActionCallback = void Function(BlockAction? action);
