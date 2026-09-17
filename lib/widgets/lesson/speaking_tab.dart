import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'lesson_common.dart';

class SpeakingTab extends StatelessWidget {
  const SpeakingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonTabBody(
      children: [
        const LessonCard(
          child: LessonPrompt(
            tagIcon: LucideIcons.mic,
            tag: 'Speaking task',
            title: 'Talk about yourself',
            body: 'Record a short introduction for your new classmates. '
                'Talk about your name, age, hometown, family and studies. '
                'Try to speak for the full time.',
          ),
        ),
        const _SpeakingTimer(),
        LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Transcript',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const LessonTextField(
                hint: 'Your speech transcript will appear here…',
                readOnly: true,
                minLines: 5,
              ),
              const SizedBox(height: 16),
              LessonPrimaryButton(
                label: 'Assess speaking',
                onPressed: () => showComingSoon(context, 'Speaking assessment'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mock recorder: the button only toggles its own appearance.
class _SpeakingTimer extends StatefulWidget {
  const _SpeakingTimer();

  @override
  State<_SpeakingTimer> createState() => _SpeakingTimerState();
}

class _SpeakingTimerState extends State<_SpeakingTimer> {
  bool _recording = false;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySoft,
            ),
            child: const Icon(LucideIcons.timer, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speaking time',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hint,
                  ),
                ),
                Text(
                  '05:00',
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: _recording ? 'Stop recording' : 'Start recording',
            onPressed: () => setState(() => _recording = !_recording),
            icon: Icon(_recording ? LucideIcons.square : LucideIcons.mic),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor:
                  _recording ? AppColors.danger : AppColors.primary,
              fixedSize: const Size.square(56),
            ),
          ),
        ],
      ),
    );
  }
}
