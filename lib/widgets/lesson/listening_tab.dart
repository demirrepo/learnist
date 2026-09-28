import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/lesson_model.dart';
import '../../services/progress_service.dart';
import '../../theme/app_theme.dart';
import 'lesson_common.dart';
import 'lesson_quiz.dart';
import 'section_score.dart';

const _noListeningMessage = "Ushbu darsda tinglab tushunish mashqi yo'q.";
const _noAudioMessage =
    "Bu dars uchun audio hali tayyorlanmoqda. Hozircha matndan foydalaning.";
const _audioErrorMessage =
    "Audioni yuklab bo'lmadi. Internet aloqasini tekshirib, qayta urinib ko'ring.";

const _speeds = [0.75, 1.0, 1.25, 1.5];

/// The audio, transcript and quiz, whose score is saved as the lesson's
/// `listening` section.
class ListeningTab extends ConsumerWidget {
  const ListeningTab({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transcript = lesson.listeningTranscript;
    if (transcript == null) {
      return const LessonTabBody(children: [LessonNotice(_noListeningMessage)]);
    }

    final questions = QuizQuestion.listFrom(lesson.listeningQuestions);
    return LessonTabBody(
      children: [
        _AudioCard(
          title: lesson.title,
          format: lesson.listeningFormat,
          audioUrl: lesson.audioUrl,
        ),
        _TranscriptCard(
          transcript: transcript,
          speakers: lesson.listeningSpeakers,
        ),
        if (questions.isNotEmpty)
          LessonQuiz(
            key: ValueKey('listening-quiz-${lesson.lessonNumber}'),
            questions: questions,
            onScored:
                (score) => saveSectionScoreOrWarn(
                  progress: ref.read(progressServiceProvider),
                  messenger: ScaffoldMessenger.of(context),
                  lessonNumber: lesson.lessonNumber,
                  section: 'listening',
                  score: score,
                ),
          ),
      ],
    );
  }
}

/// Lesson heading plus, when the lesson has audio, the streaming player.
class _AudioCard extends StatelessWidget {
  const _AudioCard({
    required this.title,
    required this.format,
    required this.audioUrl,
  });

  final String title;

  /// e.g. "two-speaker conversation".
  final String? format;

  /// Public MP3 in the `listening_audios` bucket; null until the lesson has
  /// been rendered by `generate_audios.py`.
  final String? audioUrl;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: LessonTag(icon: LucideIcons.headphones, label: 'Listening'),
          ),
          const SizedBox(height: 14),
          Text(title, style: lessonHeadingStyle),
          if (format case final format?) ...[
            const SizedBox(height: 4),
            Text(
              '${format[0].toUpperCase()}${format.substring(1)}',
              style: GoogleFonts.manrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.hint,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (audioUrl case final url?)
            // A new lesson means a new stream, so rebuild the player state.
            _AudioControls(key: ValueKey(url), url: url)
          else
            const _AudioPending(),
        ],
      ),
    );
  }
}

class _AudioPending extends StatelessWidget {
  const _AudioPending();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(LucideIcons.volumeX, size: 18, color: AppColors.hint),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _noAudioMessage,
            style: lessonBodyStyle.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

/// Seek bar, timestamps and transport for one streamed MP3.
class _AudioControls extends StatefulWidget {
  const _AudioControls({super.key, required this.url});

  final String url;

  @override
  State<_AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<_AudioControls> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSubscription;

  /// Position the finger is on, in milliseconds, while dragging the slider.
  /// The stream keeps reporting the old position until the seek lands, so the
  /// thumb follows this instead.
  double? _dragMs;

  bool _loading = true;
  bool _failed = false;
  int _speedIndex = _speeds.indexOf(1.0);

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
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      // Streams from the URL; nothing is downloaded until playback starts.
      await _player.setUrl(widget.url);
      if (mounted) setState(() => _loading = false);
    } catch (_) {
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

  void _cycleSpeed() {
    final next = (_speedIndex + 1) % _speeds.length;
    setState(() => _speedIndex = next);
    _player.setSpeed(_speeds[next]);
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return _AudioError(onRetry: _load);

    final timeStyle = GoogleFonts.manrope(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColors.hint,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder<Duration?>(
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
                final clamped = positionMs.clamp(0.0, maxMs == 0 ? 0.0 : maxMs);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.track,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primarySoft,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: clamped,
                        // A zero max would assert; keep the track inert until
                        // the duration arrives.
                        max: maxMs == 0 ? 1 : maxMs,
                        onChanged:
                            maxMs == 0
                                ? null
                                : (value) => setState(() => _dragMs = value),
                        onChangeEnd: maxMs == 0 ? null : _seek,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(
                              Duration(milliseconds: clamped.round()),
                            ),
                            style: timeStyle,
                          ),
                          Text(_formatTime(duration), style: timeStyle),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: 'Restart',
              onPressed: _loading ? null : () => _player.seek(Duration.zero),
              icon: const Icon(LucideIcons.rotateCcw),
              color: AppColors.textMuted,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.track,
                fixedSize: const Size.square(48),
              ),
            ),
            _PlayButton(
              player: _player,
              loading: _loading,
              onPressed: _loading ? null : _togglePlay,
            ),
            SizedBox(
              width: 48,
              child: TextButton(
                onPressed: _loading ? null : _cycleSpeed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.square(48),
                  shape: const CircleBorder(),
                  backgroundColor: AppColors.primarySoft,
                  textStyle: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text('${_speeds[_speedIndex]}x'.replaceAll('.0x', 'x')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Play / pause, with a spinner while the stream loads or rebuffers.
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
        final state = snapshot.data;
        final playing = state?.playing ?? false;
        final buffering =
            loading ||
            state?.processingState == ProcessingState.loading ||
            state?.processingState == ProcessingState.buffering;

        return IconButton(
          tooltip: playing ? 'Pause' : 'Play',
          onPressed: onPressed,
          iconSize: 28,
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary,
            fixedSize: const Size.square(64),
          ),
          icon:
              buffering
                  ? const SizedBox.square(
                    dimension: 24,
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

class _AudioError extends StatelessWidget {
  const _AudioError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 18,
              color: AppColors.danger,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _audioErrorMessage,
                style: lessonBodyStyle.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          label: const Text('Qayta urinish'),
        ),
      ],
    );
  }
}

String _formatTime(Duration duration) {
  String two(int value) => value.toString().padLeft(2, '0');
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return '${two(minutes)}:${two(seconds)}';
}

/// Transcript is blurred until the learner chooses to reveal it.
class _TranscriptCard extends StatefulWidget {
  const _TranscriptCard({required this.transcript, required this.speakers});

  /// "Speaker: line" pairs separated by newlines.
  final String transcript;
  final List<String> speakers;

  @override
  State<_TranscriptCard> createState() => _TranscriptCardState();
}

class _TranscriptCardState extends State<_TranscriptCard> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final text = _TranscriptText(
      transcript: widget.transcript,
      speakers: widget.speakers,
    );

    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Transcript',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                  _visible ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                ),
                label: Text(_visible ? 'Hide' : 'Show'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child:
                _visible
                    ? text
                    // Blurred text is still in the tree; hide it from
                    // screen readers too.
                    : ExcludeSemantics(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: text,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

/// Bolds a known speaker's name at the start of each line.
class _TranscriptText extends StatelessWidget {
  const _TranscriptText({required this.transcript, required this.speakers});

  final String transcript;
  final List<String> speakers;

  @override
  Widget build(BuildContext context) {
    final style = lessonBodyStyle.copyWith(color: AppColors.textPrimary);
    final lines = transcript.split('\n');

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final (i, line) in lines.indexed) ...[
            if (i > 0) const TextSpan(text: '\n'),
            ..._lineSpans(line),
          ],
        ],
      ),
    );
  }

  List<TextSpan> _lineSpans(String line) {
    final colon = line.indexOf(': ');
    if (colon > 0 && speakers.contains(line.substring(0, colon))) {
      return [
        TextSpan(
          text: line.substring(0, colon + 1),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        TextSpan(text: line.substring(colon + 1)),
      ];
    }
    return [TextSpan(text: line)];
  }
}
