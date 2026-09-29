/// What a tracked quiz mistake means, for the "Xatolar xaritasi" cards:
/// the rule behind the question and a typical wrong / right sentence.
class MistakeMetadata {
  const MistakeMetadata({
    required this.title,
    required this.wrongText,
    required this.rightText,
  });

  final String title;
  final String wrongText;
  final String rightText;
}

/// Keyed by `(lessonNumber, section, questionIndex)`, the columns that
/// identify a row of `user_mistakes`. Indexes are 0-based positions in the
/// lesson's `reading_questions` / `listening_questions`.
///
/// Only a few Lesson 1 questions are described so far; mistakes without
/// an entry still appear on the map with a generic title.
const mistakesMetadata = <(int, String, int), MistakeMetadata>{
  // "Which sentence demonstrates the grammar focus of this lesson?"
  (1, 'reading', 6): MistakeMetadata(
    title: 'Subject pronouns: am / is / are',
    wrongText: 'She are a student.',
    rightText: 'She is a student.',
  ),
  // "Which sentence uses today's target grammar?"
  (1, 'listening', 5): MistakeMetadata(
    title: 'Questions with to be: Are you…? / Is he…?',
    wrongText: 'You are from Tashkent?',
    rightText: 'Are you from Tashkent?',
  ),
  // "In this text, what is the best meaning of “orientation”?"
  (1, 'reading', 7): MistakeMetadata(
    title: 'Vocabulary: orientation',
    wrongText: 'Orientation is an exam result.',
    rightText: 'Orientation is an introduction week for new students.',
  ),
};

/// The entry for one tracked mistake, or null if it isn't described yet.
MistakeMetadata? mistakeMetadataFor(
  int lessonNumber,
  String section,
  int questionIndex,
) => mistakesMetadata[(lessonNumber, section, questionIndex)];
