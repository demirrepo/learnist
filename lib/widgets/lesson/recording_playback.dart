import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/speech_recorder.dart';
import '../../theme/app_theme.dart';
import 'lesson_common.dart';

/// Plays the student's finished speaking recording at [path] back, so they
/// can listen to it before and while it is graded.
///
/// Owns its player: removing the widget (a new recording starts, or the
/// student leaves the lesson) stops playback and releases it. The file
/// itself belongs to the caller.
class RecordingPlayback extends ConsumerStatefulWidget {
  const RecordingPlayback({super.key, required this.path});

  final String path;

  @override
  ConsumerState<RecordingPlayback> createState() => _RecordingPlaybackState();
}

class _RecordingPlaybackState extends ConsumerState<RecordingPlayback> {
  late final AudioPlayer _player = ref.read(recordingPlayerProvider)();
  StreamSubscription<PlayerState>? _stateSubscription;

  /// Position the finger is on, in milliseconds, while dragging the slider.
  double? _dragMs;

  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // just_audio leaves a finished track "playing" at the end; rewind so the
    // button reads Play again and starts from the top.
    _stateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _player.pause();
        _player.seek(Duration.zero);
      }
    });
    _load();
  }

  Future<void> _load() async {
    try {
      await _player.setFilePath(widget.path);
      if (mounted) setState(() => _loading = false);
    } catch (error) {
      if (kDebugMode) debugPrint('[Lesson] playback failed: $error');
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> _seek(double milliseconds) async {
    await _player.seek(Duration(milliseconds: milliseconds.round()));
    if (mounted) setState(() => _dragMs = null);
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );

    if (_failed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: lessonCardRadius,
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: AppColors.danger),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Your recording can't be played back.",
                style: labelStyle.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      );
    }

    final timeStyle = GoogleFonts.manrope(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColors.hint,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      decoration: const BoxDecoration(
        color: AppColors.track,
        borderRadius: lessonCardRadius,
      ),
      child: Row(
        children: [
          _PlayButton(
            player: _player,
            loading: _loading,
            onPressed: _loading ? null : _togglePlay,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? Duration.zero;
                final maxMs = duration.inMilliseconds.toDouble();

                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnapshot) {
                    final positionMs =
                        _dragMs ??
                        positionSnapshot.data?.inMilliseconds.toDouble() ??
                        0;
                    final clamped = positionMs.clamp(
                      0.0,
                      maxMs == 0 ? 0.0 : maxMs,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Your recording',
                                  style: labelStyle,
                                ),
                              ),
                              Text(
                                '${formatAudioTime(Duration(milliseconds: clamped.round()))}'
                                ' / ${formatAudioTime(duration)}',
                                style: timeStyle,
                              ),
                            ],
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: Colors.white,
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primarySoft,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                          ),
                          child: Slider(
                            value: clamped,
                            // A zero max would assert; keep the track inert
                            // until the duration arrives.
                            max: maxMs == 0 ? 1 : maxMs,
                            onChanged:
                                maxMs == 0
                                    ? null
                                    : (value) =>
                                        setState(() => _dragMs = value),
                            onChangeEnd: maxMs == 0 ? null : _seek,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Play / pause, with a spinner while the file loads.
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.player,
    required this.loading,
    required this.onPressed,
  });

  final AudioPlayer player;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;

        return IconButton(
          tooltip: playing ? 'Pause recording' : 'Play recording',
          onPressed: onPressed,
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary,
            fixedSize: const Size.square(48),
          ),
          icon:
              loading
                  ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                  : Icon(playing ? LucideIcons.pause : LucideIcons.play),
        );
      },
    );
  }
}
