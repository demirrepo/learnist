import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../../services/deepgram_service.dart';
import '../../services/openai_service.dart';
import '../../services/progress_service.dart';
import '../../services/speech_recorder.dart';
import '../../theme/app_theme.dart';
import 'lesson_common.dart';
import 'recording_playback.dart';
import 'section_score.dart';

/// Answer field, grading button and result for an AI-graded task.
///
/// On tap it sends the answer to [evaluate], saves the score as the
/// lesson's [section] score and shows "Mastery reached: X%" with the
/// feedback. Kept alive, so the answer and result survive scrolling away
/// and switching tabs.
///
/// With [isSpeakingTask] the student can also record the answer, for up to
/// [maxRecording]: Deepgram transcribes it into the field, where it can be
/// corrected before grading, and the recording can be played back until
/// the next one replaces it.
class AiGradedTask extends ConsumerStatefulWidget {
  const AiGradedTask({
    super.key,
    required this.lessonNumber,
    required this.section,
    required this.buttonLabel,
    required this.hint,
    required this.evaluate,
    this.minLines = 4,
    this.maxLines = 8,
    this.fieldFooter,
    this.onAskAi,
    this.isSpeakingTask = false,
  });

  /// Recording stops itself, and is transcribed, after this long.
  static const maxRecording = Duration(minutes: 5);

  final int lessonNumber;

  /// One of [lessonSections].
  final String section;
  final String buttonLabel;
  final String hint;
  final Future<AiEvaluation> Function(OpenAIService ai, String answer) evaluate;
  final int minLines;
  final int maxLines;

  /// Built under the field from the current answer, e.g. a word count.
  final Widget Function(String answer)? fieldFooter;

  /// Adds an "Ask AI" button beside the grading button.
  final VoidCallback? onAskAi;

  /// Adds a microphone that fills the field with a transcript. Not on the
  /// web, where recordings are blob URLs rather than files.
  final bool isSpeakingTask;

  @override
  ConsumerState<AiGradedTask> createState() => _AiGradedTaskState();
}

class _AiGradedTaskState extends ConsumerState<AiGradedTask>
    with AutomaticKeepAliveClientMixin {
  final _answer = TextEditingController();
  bool _evaluating = false;
  AiEvaluation? _result;
  _MicState _mic = _MicState.idle;

  /// Set while a recording is running, so leaving the lesson stops it.
  SpeechRecorder? _recorder;

  /// Ticks once a second while recording, up to [AiGradedTask.maxRecording].
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  /// The last finished recording, kept for playback until the next
  /// recording starts or the student leaves the lesson.
  ({SpeechRecorder recorder, String path})? _lastRecording;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _ticker?.cancel();
    if (_recorder case final recorder?) unawaited(recorder.cancel());
    _discardLastRecording();
    _answer.dispose();
    super.dispose();
  }

  /// Deletes the kept recording's file. Callers rebuild if they need to.
  void _discardLastRecording() {
    if (_lastRecording case (:final recorder, :final path)) {
      unawaited(recorder.delete(path));
    }
    _lastRecording = null;
  }

  void _toggleRecording() {
    switch (_mic) {
      case _MicState.idle:
        _startRecording();
      case _MicState.recording:
        _stopAndTranscribe();
      case _MicState.starting || _MicState.transcribing:
        break;
    }
  }

  Future<void> _startRecording() async {
    if (_evaluating) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final recorder = ref.read(speechRecorderProvider);
    FocusScope.of(context).unfocus();
    setState(() => _mic = _MicState.starting);

    try {
      final permission = await recorder.requestPermission();
      if (permission != MicPermission.granted) {
        if (mounted) setState(() => _mic = _MicState.idle);
        showLessonError(
          messenger,
          permission == MicPermission.permanentlyDenied
              ? l10n.taskMicBlocked
              : l10n.taskMicDenied,
        );
        return;
      }
      await recorder.start();
    } catch (error) {
      if (kDebugMode) debugPrint('[Lesson] recording failed: $error');
      if (mounted) setState(() => _mic = _MicState.idle);
      showLessonError(messenger, l10n.taskRecordingError);
      return;
    }

    if (!mounted) {
      unawaited(recorder.cancel());
      return;
    }
    setState(() {
      _discardLastRecording();
      _recorder = recorder;
      _mic = _MicState.recording;
      _elapsed = Duration.zero;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final elapsed = _elapsed + const Duration(seconds: 1);
    setState(() => _elapsed = elapsed);
    if (elapsed >= AiGradedTask.maxRecording) _stopAndTranscribe();
  }

  Future<void> _stopAndTranscribe() async {
    final recorder = _recorder;
    if (recorder == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final deepgram = ref.read(deepgramServiceProvider);
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _recorder = null;
      _mic = _MicState.transcribing;
    });

    try {
      final path = await recorder.stop();
      if (path == null) {
        throw DeepgramException(l10n.taskRecordingMissing);
      }
      if (!mounted) {
        unawaited(recorder.delete(path));
        return;
      }
      setState(() => _lastRecording = (recorder: recorder, path: path));
      final text = await deepgram.transcribeAudio(path);
      if (mounted) {
        _answer.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    } catch (error) {
      if (kDebugMode) debugPrint('[Lesson] transcription failed: $error');
      showLessonError(
        messenger,
        error is DeepgramException
            ? error.message
            : l10n.taskTranscriptionError,
      );
    } finally {
      if (mounted) setState(() => _mic = _MicState.idle);
    }
  }

  Future<void> _grade() async {
    if (_evaluating) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final text = _answer.text;
    if (text.trim().isEmpty) {
      showLessonError(messenger, l10n.taskEmptyAnswer);
      return;
    }

    // Read before the awaits: the student may leave the lesson meanwhile,
    // and the score must still be saved.
    final ai = ref.read(openaiServiceProvider);
    final progress = ref.read(progressServiceProvider);
    final section = widget.section;
    final lessonNumber = widget.lessonNumber;
    FocusScope.of(context).unfocus();
    setState(() => _evaluating = true);

    final AiEvaluation result;
    try {
      result = await widget.evaluate(ai, text);
    } catch (error) {
      if (kDebugMode) debugPrint('[Lesson] grading $section failed: $error');
      if (mounted) setState(() => _evaluating = false);
      showLessonError(messenger, l10n.taskEvaluationError);
      return;
    }

    await saveSectionScoreOrWarn(
      progress: progress,
      messenger: messenger,
      lessonNumber: lessonNumber,
      section: section,
      score: result.score,
    );

    if (!mounted) return;
    setState(() {
      _evaluating = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final footer = widget.fieldFooter;
    final onAskAi = widget.onAskAi;
    final micBusy = _mic != _MicState.idle;
    final onGrade = micBusy ? null : _grade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LessonTextField(
          key: ValueKey('${widget.section}-answer'),
          hint: widget.hint,
          controller: _answer,
          readOnly: _evaluating || micBusy,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
        ),
        if (widget.isSpeakingTask && !kIsWeb) ...[
          const SizedBox(height: 12),
          _MicRecorder(
            key: ValueKey('${widget.section}-mic'),
            state: _mic,
            elapsed: _elapsed,
            onPressed: _evaluating ? null : _toggleRecording,
          ),
          // Gone while a new recording starts, which stops its playback.
          if (_lastRecording case (
            recorder: _,
            :final path,
          ) when _mic == _MicState.idle || _mic == _MicState.transcribing) ...[
            const SizedBox(height: 10),
            RecordingPlayback(key: ValueKey(path), path: path),
          ],
        ],
        if (footer != null) ...[
          const SizedBox(height: 8),
          ValueListenableBuilder(
            valueListenable: _answer,
            builder: (context, value, _) => footer(value.text),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 16),
        if (onAskAi != null)
          LessonActionRow(
            primaryLabel: widget.buttonLabel,
            onPrimary: onGrade,
            primaryLoading: _evaluating,
            onAskAi: onAskAi,
          )
        else
          LessonPrimaryButton(
            label: widget.buttonLabel,
            onPressed: onGrade,
            loading: _evaluating,
          ),
        if (_result case final result?) ...[
          const SizedBox(height: 18),
          _EvaluationResult(
            key: ValueKey('${widget.section}-result'),
            result: result,
          ),
        ],
      ],
    );
  }
}

enum _MicState { idle, starting, recording, transcribing }

/// Microphone button with its state spelled out beside it. While
/// recording it turns red, pulses and counts up to the limit; while
/// transcribing it spins.
class _MicRecorder extends StatefulWidget {
  const _MicRecorder({
    super.key,
    required this.state,
    required this.elapsed,
    required this.onPressed,
  });

  final _MicState state;

  /// How long the running recording has gone on.
  final Duration elapsed;
  final VoidCallback? onPressed;

  @override
  State<_MicRecorder> createState() => _MicRecorderState();
}

class _MicRecorderState extends State<_MicRecorder>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  bool get _recording => widget.state == _MicState.recording;

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(_MicRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    if (_recording) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recording = _recording;
    final accent = recording ? AppColors.danger : AppColors.primary;
    final limit = AiGradedTask.maxRecording;
    final label = switch (widget.state) {
      _MicState.idle || _MicState.starting =>
        'Tap the mic and speak (up to ${limit.inMinutes} minutes)',
      _MicState.recording => 'Recording… Tap to stop',
      _MicState.transcribing => 'Transcribing…',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: recording ? AppColors.dangerSoft : AppColors.primarySoft,
        borderRadius: lessonCardRadius,
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (recording)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder:
                        (context, _) => Transform.scale(
                          scale: 1 + 0.35 * _pulse.value,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.danger.withValues(
                                alpha: 0.35 * (1 - _pulse.value),
                              ),
                            ),
                          ),
                        ),
                  ),
                if (widget.state == _MicState.transcribing)
                  const SizedBox.square(
                    dimension: 56,
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                else
                  IconButton(
                    tooltip: recording ? 'Stop recording' : 'Start recording',
                    onPressed:
                        widget.state == _MicState.starting
                            ? null
                            : widget.onPressed,
                    icon: Icon(
                      recording ? LucideIcons.square : LucideIcons.mic,
                      size: 26,
                    ),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: accent,
                      disabledBackgroundColor: AppColors.hint,
                      fixedSize: const Size.square(56),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                if (recording) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${formatAudioTime(widget.elapsed)} / '
                    '${formatAudioTime(limit)}',
                    key: const ValueKey('recording-elapsed'),
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Mastery reached: X%" and the AI's feedback. Green once the score
/// reaches the 80% the next lesson needs.
class _EvaluationResult extends StatelessWidget {
  const _EvaluationResult({super.key, required this.result});

  final AiEvaluation result;

  @override
  Widget build(BuildContext context) {
    final passed = result.score >= InsufficientScoreException.minAverage;
    final background = passed ? AppColors.successSoft : AppColors.primarySoft;
    final accent = passed ? AppColors.successDark : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: lessonCardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.award, size: 20, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mastery reached: ${result.score}%',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.feedback,
            style: lessonBodyStyle.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
