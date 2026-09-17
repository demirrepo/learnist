import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';

const lessonCardRadius = BorderRadius.all(Radius.circular(16));

/// Scrollable body for one lesson tab. Kept alive so typed answers and quiz
/// selections survive switching tabs.
class LessonTabBody extends StatefulWidget {
  const LessonTabBody({super.key, required this.children});

  final List<Widget> children;

  @override
  State<LessonTabBody> createState() => _LessonTabBodyState();
}

class _LessonTabBodyState extends State<LessonTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        for (var i = 0; i < widget.children.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          widget.children[i],
        ],
      ],
    );
  }
}

/// White rounded card with a soft shadow.
class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: lessonCardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Small purple pill with an icon, e.g. "Practical task".
class LessonTag extends StatelessWidget {
  const LessonTag({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag + heading + body copy, used at the top of most task cards.
class LessonPrompt extends StatelessWidget {
  const LessonPrompt({
    super.key,
    required this.tagIcon,
    required this.tag,
    required this.title,
    required this.body,
  });

  final IconData tagIcon;
  final String tag;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LessonTag(icon: tagIcon, label: tag),
        const SizedBox(height: 14),
        Text(title, style: lessonHeadingStyle),
        const SizedBox(height: 8),
        Text(body, style: lessonBodyStyle),
      ],
    );
  }
}

final lessonHeadingStyle = GoogleFonts.manrope(
  fontSize: 19,
  height: 1.3,
  fontWeight: FontWeight.w800,
  color: AppColors.textPrimary,
);

final lessonBodyStyle = GoogleFonts.manrope(
  fontSize: 15,
  height: 1.55,
  fontWeight: FontWeight.w500,
  color: AppColors.textMuted,
);

/// Grey-filled multi-line answer field.
class LessonTextField extends StatelessWidget {
  const LessonTextField({
    super.key,
    required this.hint,
    this.minLines = 4,
    this.maxLines = 8,
    this.controller,
    this.readOnly = false,
    this.onChanged,
  });

  final String hint;
  final int minLines;
  final int maxLines;
  final TextEditingController? controller;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.manrope(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintMaxLines: 3,
        fillColor: AppColors.background,
        alignLabelWithHint: true,
      ),
    );
  }
}

/// Primary purple action, stretched to the available width.
class LessonPrimaryButton extends StatelessWidget {
  const LessonPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = LucideIcons.sparkles,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

/// Light purple secondary action.
class AskAiButton extends StatelessWidget {
  const AskAiButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(LucideIcons.messageCircle, size: 18),
      label: const Text('Ask AI', maxLines: 1),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.primarySoft,
        side: BorderSide.none,
        minimumSize: const Size(0, 58),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.manrope(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Primary action with a compact "Ask AI" button beside it.
class LessonActionRow extends StatelessWidget {
  const LessonActionRow({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onAskAi,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onAskAi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LessonPrimaryButton(
            label: primaryLabel,
            onPressed: onPrimary,
          ),
        ),
        const SizedBox(width: 10),
        AskAiButton(onPressed: onAskAi),
      ],
    );
  }
}

/// Stand-in for actions that will call the backend later.
void showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
}
