import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'lesson_common.dart';
import 'lesson_quiz.dart';

// Placeholder content until lessons come from the backend.
const _transcript =
    "Hi, I'm Tom. I'm from Manchester in England. I'm 20 years old and I'm a "
    "student at a university in Tashkent. My best friend here is Aziz. He's "
    "from Bukhara. We're in the same English group, and our teacher is from "
    'Canada.';

const _questions = [
  QuizQuestion(
    prompt: 'How old is Tom?',
    options: ['18', '19', '20', '21'],
    correctIndex: 2,
  ),
  QuizQuestion(
    prompt: 'Where is their teacher from?',
    options: ['England', 'Canada', 'Uzbekistan', 'The USA'],
    correctIndex: 1,
  ),
];

const _speeds = ['0.75x', '1x', '1.25x', '1.5x'];
const _voices = ['US · Female', 'US · Male', 'UK · Female', 'UK · Male'];

class ListeningTab extends StatelessWidget {
  const ListeningTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const LessonTabBody(
      children: [
        _AudioPlayerCard(),
        _TranscriptCard(),
        LessonQuiz(questions: _questions),
      ],
    );
  }
}

/// Mock player: controls only change local UI state, nothing plays yet.
class _AudioPlayerCard extends StatefulWidget {
  const _AudioPlayerCard();

  @override
  State<_AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<_AudioPlayerCard> {
  bool _playing = false;
  String _speed = '1x';
  String _voice = _voices.first;

  @override
  Widget build(BuildContext context) {
    final timeStyle = GoogleFonts.manrope(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColors.hint,
    );

    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: LessonTag(icon: LucideIcons.headphones, label: 'Listening'),
          ),
          const SizedBox(height: 14),
          Text('Meet Tom', style: lessonHeadingStyle),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 6,
              backgroundColor: AppColors.track,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00', style: timeStyle),
              Text('00:42', style: timeStyle),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Restart',
                onPressed: () => setState(() => _playing = false),
                icon: const Icon(LucideIcons.rotateCcw),
                color: AppColors.textMuted,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.track,
                  fixedSize: const Size.square(48),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                tooltip: _playing ? 'Pause' : 'Play',
                onPressed: () => setState(() => _playing = !_playing),
                icon: Icon(_playing ? LucideIcons.pause : LucideIcons.play),
                iconSize: 28,
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  fixedSize: const Size.square(64),
                ),
              ),
              // Mirrors the restart button so play stays centred.
              const SizedBox(width: 68),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _Dropdown(
                  label: 'Speed',
                  value: _speed,
                  items: _speeds,
                  onChanged: (value) => setState(() => _speed = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _Dropdown(
                  label: 'Voice',
                  value: _voice,
                  items: _voices,
                  onChanged: (value) => setState(() => _voice = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      style: style,
      borderRadius: BorderRadius.circular(16),
      dropdownColor: AppColors.surface,
      icon: const Icon(LucideIcons.chevronDown, size: 18),
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item,
            child: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

/// Transcript is blurred until the learner chooses to reveal it.
class _TranscriptCard extends StatefulWidget {
  const _TranscriptCard();

  @override
  State<_TranscriptCard> createState() => _TranscriptCardState();
}

class _TranscriptCardState extends State<_TranscriptCard> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      _transcript,
      style: lessonBodyStyle.copyWith(color: AppColors.textPrimary),
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
            child: _visible
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
