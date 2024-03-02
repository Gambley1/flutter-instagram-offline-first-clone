/// A Flutter package that contains UI components for Instagram blocks.
library instagram_blocks_ui;

export 'package:video_player/video_player.dart';

export 'src/attachments/index.dart';
export 'src/better_stream_builder.dart';
export 'src/blocks_settings.dart';
export 'src/media_carousel_settings.dart';
export 'src/post_large/index.dart';
export 'src/post_small/index.dart';
export 'src/posts/index.dart';
export 'src/safe_set_state_mixin.dart';
export 'src/smooth_video_progress_indicator.dart' hide VideoScrubber;
export 'src/user_profile/index.dart';
export 'src/widgets/widgets.dart'
    show
        AnimatedCircleBorderPainter,
        AnimatedVisibility,
        AvatarImagePicker,
        ExpandableText,
        FollowButton,
        MediaCarousel,
        PoppingIconAnimationOverlay,
        PostSponsored,
        PromoFloatingAction,
        RunningText,
        ShimmerPlaceholder,
        SwipeDirection,
        Swipeable,
        TimeAgo,
        TwoRotatingArc,
        UserComment,
        VideoPlay;
