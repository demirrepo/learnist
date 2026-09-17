import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/ai_lab/ai_course_list.dart';
import '../widgets/ai_lab/ai_hero_section.dart';
import '../widgets/ai_lab/prompt_checker_card.dart';
import '../widgets/ai_lab/prompt_comparison_section.dart';

const _pagePadding = 20.0;
const _sectionGap = 28.0;

class AiLabScreen extends StatelessWidget {
  const AiLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            _pagePadding,
            16,
            _pagePadding,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AiHeroSection(),
              const SizedBox(height: _sectionGap),
              PromptCheckerCard(
                onCheck:
                    () =>
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Prompt checker: tez orada.'),
                            ),
                          ),
              ),
              const SizedBox(height: _sectionGap),
              const PromptComparisonSection(),
              const SizedBox(height: _sectionGap),
              const AiCourseList(),
            ],
          ),
        ),
      ),
    );
  }
}
