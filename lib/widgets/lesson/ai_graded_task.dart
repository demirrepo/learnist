import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/deepgram_service.dart';
import '../../services/openai_service.dart';
import '../../services/progress_service.dart';
import '../../services/speech_recorder.dart';
import '../../theme/app_theme.dart';
import 'lesson_common.dart';
import 'section_score.dart';

const _emptyAnswerMessage = 'Avval javobingizni yozing.';
const _evaluationErrorMessage =
    "Baholashda xatolik yuz berdi. Iltimos qayta urinib ko'ring.";
const _micDeniedMessage = 'Ovoz yozish uchun mikrofonga ruxsat bering.';
const _micBlockedMessage =
    'Mikrofonga ruxsat berilmagan. Uni telefon sozlamalaridan yoqing.';
const _recordingErrorMessage =
    "Ovoz yozishni boshlab bo'lmadi. Iltimos qayta urinib ko'ring.";
const _transcriptionErrorMessage =
    "Nutqni matnga aylantirib bo'lmadi. Iltimos qayta urinib ko'ring.";

/// Answer field, grading button and result for an AI-graded task.
///
/// On tap it sends the answer to [evaluate], saves the score as the
/// lesson's [section] score and shows "Mastery reached: X%" with the
/// feedback. Kept alive, so the answer and result survive scrolling away
/// and switching tabs.
///
/// With [isSpeakingTask] the student can also record the answer: Deepgram
/// transcribes it into the field, where it can be corrected before grading.
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

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    if (_recorder case final recorder?) unawaited(recorder.cancel());
    _answer.dispose();
    super.dispose();
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
              ? _micBlockedMessage
              : _micDeniedMessage,
        );
        return;
      }
      await recorder.start();
    } catch (error) {
      if (kDebugMode) debugPrint('[Lesson] recording failed: $error');
      if (mounted) setState(() => _mic = _MicState.idle);
      showLessonError(messenger, _recordingErrorMessage);
      return;
    }

    if (!mounted) {
      unawaited(recorder.cancel());
      return;
    }
    setState(() {
      _recorder = recorder;
      _mic = _MicState.recording;
    });
  }

  Future<void> _stopAndTranscribe() async {
    final recorder = _recorder;
    if (recorder == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final deepgram = ref.read(deepgramServiceProvider);
    setState(() {
      _recorder = null;
      _mic = _MicState.transcribing;
    });

    String? path;
    try {
      path = await recorder.stop();
      if (path == null) {
        throw const DeepgramException('Yozib olingan audio topilmadi.');
      }
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
        error is DeepgramException ? error.message : _transcriptionErrorMessage,
      );
    } finally {
      if (path != null) unawaited(recorder.delete(path));
      if (mounted) setState(() => _mic = _MicState.idle);
    }
  }

  Future<void> _grade() async {
    if (_evaluating) return;
    final messenger = ScaffoldMessenger.of(context);
    final text = _answer.text;
    if (text.trim().isEmpty) {
      showLessonError(messenger, _emptyAnswerMessage);
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
      showLessonError(messenger, _evaluationErrorMessage);
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
            onPressed: _evaluating ? null : _toggleRecording,
          ),
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
/// recording it turns red and pulses; while transcribing it spins.
class _MicRecorder extends StatefulWidget {
  const _MicRecorder({super.key, required this.state, required this.onPressed});

  final _MicState state;
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
    final label = switch (widget.state) {
      _MicState.idle || _MicState.starting => 'Tap the mic and speak',
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
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
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
