import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/utils/app_assets.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';

/// Temporary networked video player for Connection Detail AI Video tab.
class AiTestVideoPlayer extends StatefulWidget {
  const AiTestVideoPlayer({
    super.key,
    this.url = AppConstant.aiTestVideoUrl,
    this.posterAsset = AppIcons.aiPlaceholder,
    this.aspectRatio = 3 / 4,
  });

  final String url;
  final String? posterAsset;

  /// Portrait frame by default (3:4), matching AI video memory design.
  final double aspectRatio;

  @override
  State<AiTestVideoPlayer> createState() => _AiTestVideoPlayerState();
}

class _AiTestVideoPlayerState extends State<AiTestVideoPlayer> {
  VideoPlayerController? _controller;
  var _ready = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant AiTestVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeController();
      _ready = false;
      _failed = false;
      _init();
    }
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    controller.addListener(_onTick);
    try {
      await controller.setLooping(true);
      await controller.initialize();
      if (!mounted || _controller != controller) return;
      setState(() {
        _ready = true;
        _failed = false;
      });
    } catch (_) {
      if (!mounted || _controller != controller) return;
      setState(() => _failed = true);
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    controller?.removeListener(_onTick);
    controller?.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (!_ready || controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null) return;
    final muted = controller.value.volume == 0;
    controller.setVolume(muted ? 1 : 0);
  }

  Future<void> _openFullscreen() async {
    final controller = _controller;
    if (!_ready || controller == null) return;

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: AppColors.onPrimary,
        pageBuilder: (_, _, _) => _AiFullscreenVideoPage(
          controller: controller,
          posterAsset: widget.posterAsset,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: _VideoSurface(
        controller: _controller,
        ready: _ready,
        failed: _failed,
        posterAsset: widget.posterAsset,
        borderRadius: BorderRadius.circular(14),
        showBorder: true,
        onPlayTap: _togglePlay,
        onMuteTap: _toggleMute,
        onFullscreenTap: _openFullscreen,
        fullscreenIcon: Icons.fullscreen_rounded,
      ),
    );
  }
}

class _AiFullscreenVideoPage extends StatefulWidget {
  const _AiFullscreenVideoPage({
    required this.controller,
    this.posterAsset,
  });

  final VideoPlayerController controller;
  final String? posterAsset;

  @override
  State<_AiFullscreenVideoPage> createState() => _AiFullscreenVideoPageState();
}

class _AiFullscreenVideoPageState extends State<_AiFullscreenVideoPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlay() {
    final controller = widget.controller;
    if (!controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _toggleMute() {
    final muted = widget.controller.value.volume == 0;
    widget.controller.setVolume(muted ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final size = value.isInitialized ? value.size : Size.zero;
    final videoAspect = size.width > 0 && size.height > 0
        ? size.width / size.height
        : 9 / 16;

    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: videoAspect,
                child: _VideoSurface(
                  controller: widget.controller,
                  ready: value.isInitialized,
                  failed: false,
                  posterAsset: widget.posterAsset,
                  borderRadius: BorderRadius.zero,
                  showBorder: false,
                  onPlayTap: _togglePlay,
                  onMuteTap: _toggleMute,
                  onFullscreenTap: () => Navigator.of(context).pop(),
                  fullscreenIcon: Icons.fullscreen_exit_rounded,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({
    required this.controller,
    required this.ready,
    required this.failed,
    required this.onPlayTap,
    required this.onMuteTap,
    required this.onFullscreenTap,
    required this.fullscreenIcon,
    this.posterAsset,
    this.borderRadius = BorderRadius.zero,
    this.showBorder = false,
  });

  final VideoPlayerController? controller;
  final bool ready;
  final bool failed;
  final String? posterAsset;
  final BorderRadius borderRadius;
  final bool showBorder;
  final VoidCallback onPlayTap;
  final VoidCallback onMuteTap;
  final VoidCallback onFullscreenTap;
  final IconData fullscreenIcon;

  @override
  Widget build(BuildContext context) {
    final value = controller?.value;
    final progress = (!ready ||
            value == null ||
            value.duration.inMilliseconds == 0)
        ? 0.0
        : value.position.inMilliseconds / value.duration.inMilliseconds;
    final poster = posterAsset?.trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: borderRadius,
        border: showBorder
            ? Border.all(color: AppColors.border, width: 1.2)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: failed
          ? Stack(
              fit: StackFit.expand,
              children: [
                if (poster.isNotEmpty)
                  Image.asset(poster, fit: BoxFit.cover)
                else
                  const ColoredBox(color: AppColors.surfaceElevated),
                const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.textPrimary,
                    size: 32,
                  ),
                ),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                if (ready && value != null && value.isInitialized)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: value.size.width,
                      height: value.size.height,
                      child: VideoPlayer(controller!),
                    ),
                  )
                else if (poster.isNotEmpty)
                  Image.asset(poster, fit: BoxFit.cover)
                else
                  const ColoredBox(color: AppColors.surfaceElevated),
                if (!ready)
                  const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.clear,
                          AppColors.onPrimary.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onPlayTap,
                            child: Icon(
                              (value?.isPlaying ?? false)
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.textPrimary,
                              size: 28,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onMuteTap,
                            child: Icon(
                              (value?.volume ?? 1) == 0
                                  ? Icons.volume_off_outlined
                                  : Icons.volume_up_outlined,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                          14.width,
                          GestureDetector(
                            onTap: onFullscreenTap,
                            child: Icon(
                              fullscreenIcon,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ),
                          10.width,
                          const Icon(
                            Icons.more_vert_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ],
                      ),
                      8.height,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 2.5,
                          backgroundColor: AppColors.textDisabled,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
