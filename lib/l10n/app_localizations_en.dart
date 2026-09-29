// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navTopics => 'Topics';

  @override
  String get navAiLab => 'AI Lab';

  @override
  String get navCheckup => 'Check-up';

  @override
  String get navProfile => 'Profile';

  @override
  String get navTeacherPanel => 'Panel';

  @override
  String get navTeacherPanelFull => 'Teacher panel';

  @override
  String get sidebarTagline => 'AI Learning Companion';

  @override
  String get sidebarDefaultUser => 'Learnist user';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get roleStudent => 'Student';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get notAvailable => 'N/A';

  @override
  String lessonLabel(int number) {
    return 'Lesson $number';
  }

  @override
  String semesterLabel(int number) {
    return 'Semester $number';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String homeGreeting(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String homeCefrBadge(String level) {
    return 'CEFR level: $level';
  }

  @override
  String get homeCefrBadgeUnknown => 'CEFR level: not determined yet';

  @override
  String get homeTodaysFocus => 'TODAY\'S FOCUS';

  @override
  String get homeHeadline =>
      'Your English grows every time you understand a mistake.';

  @override
  String get homeSubtitle =>
      'Keep the momentum going with your next guided practice.';

  @override
  String homeContinueLesson(int number) {
    return 'Continue Lesson $number';
  }

  @override
  String get homeOpenAiLab => 'Open AI Lab';

  @override
  String homeMastery(int percent) {
    return '$percent% mastery';
  }

  @override
  String get homeLearningSpace => 'Learning space';

  @override
  String get homeSwipe => 'Swipe';

  @override
  String homeLessonCount(int count) {
    return '$count lessons';
  }

  @override
  String get homePromptBetter => 'Prompt better';

  @override
  String get homeCefrTest => 'CEFR test';

  @override
  String get homeSnapshot => 'Your snapshot';

  @override
  String get statLessonsMastered => 'Lessons mastered';

  @override
  String get statCurrentLesson => 'Current lesson';

  @override
  String get statCefrEstimate => 'CEFR estimate';

  @override
  String get statTrackedMistakes => 'Tracked mistakes';

  @override
  String get lessonMastery => 'Lesson mastery';

  @override
  String lessonMasterySemantics(String lesson, String percent) {
    return 'Lesson mastery, $lesson: $percent';
  }

  @override
  String get topicsEyebrow => 'TOPICS';

  @override
  String get topicsTitle => '52-lesson pathway';

  @override
  String get topicsSemesters =>
      'Semester 1: Lessons 1-30 • Semester 2: Lessons 31-52';

  @override
  String get topicsSearchHint => 'Search lessons';

  @override
  String get topicsNoMatch => 'No lessons match your search.';

  @override
  String get topicsEmpty => 'No lessons found yet.';

  @override
  String get topicLocked => 'Locked';

  @override
  String get topicLockedMessage =>
      'Locked. This lesson opens after you finish the previous ones.';

  @override
  String get aiLabEyebrow => 'PROMPT LITERACY';

  @override
  String get aiLabHeadline => 'Ask better questions. Learn more independently.';

  @override
  String get aiLabIntro =>
      'A prompt is the instruction you give an AI. A clear prompt gets you an answer you can learn from, not just one to copy.';

  @override
  String get aiLabExamplePrompt => 'EXAMPLE PROMPT';

  @override
  String get promptPartRole => 'Role';

  @override
  String get promptPartTask => 'Task';

  @override
  String get promptPartLevel => 'Level';

  @override
  String get promptPartContext => 'Context';

  @override
  String get promptPartFormat => 'Format';

  @override
  String get aiCourseTitle => 'AI course';

  @override
  String aiCourseSubtitle(int count) {
    return '$count short steps to a strong prompt.';
  }

  @override
  String get aiStepWhatTitle => 'What is a prompt?';

  @override
  String get aiStepWhatBody =>
      'A prompt is the message you send to an AI. The clearer it is, the more useful the answer.';

  @override
  String get aiStepRoleBody =>
      'Tell the AI who to be, so it answers like an expert.';

  @override
  String get aiStepTaskBody => 'Say exactly what you want it to do.';

  @override
  String get aiStepLevelBody =>
      'Give your English level so the answer fits you.';

  @override
  String get aiStepContextBody =>
      'Share the background: the text, the question, your goal.';

  @override
  String get aiStepFormatBody =>
      'Ask for the shape of the answer: a list, a table or a short paragraph.';

  @override
  String get aiStepExamplesTitle => 'Examples & Tone';

  @override
  String get aiStepExamplesBody =>
      'Show an example and choose the tone you want.';

  @override
  String get promptCheckerTitle => 'Prompt checker';

  @override
  String get promptCheckerHint => 'Write a prompt...';

  @override
  String get promptCheckerButton => 'Check my prompt';

  @override
  String get promptCheckerFeedback => 'AI feedback';

  @override
  String get promptCheckerUnexpected => 'Unexpected error. Please try again.';

  @override
  String get comparisonTitle => 'Bad prompt → better prompt';

  @override
  String get comparisonSubtitle => 'Same question, very different answers.';

  @override
  String get comparisonBadNote =>
      'No role, no context, no level. The AI has to guess what you need, so the answer is vague.';

  @override
  String get comparisonGoodNote =>
      'Role + question context + level + format. The AI knows exactly how to help you.';

  @override
  String get checkupEyebrow => 'YOUR TRUE LEVEL';

  @override
  String get checkupTitle => 'Level check-up';

  @override
  String checkupMinutes(int minutes) {
    return '≈ $minutes min';
  }

  @override
  String checkupQuestionRange(int count) {
    return '$count questions from A1 to C2';
  }

  @override
  String get checkupLevelRule =>
      'Your level is the highest one you pass in order, from A1 up.';

  @override
  String get checkupAnswers => 'Answers';

  @override
  String get checkupSubmit => 'Submit check-up';

  @override
  String checkupAnswerAll(int count) {
    return 'Answer all $count questions.';
  }

  @override
  String get checkupNoQuestions => 'No questions have been added yet.';

  @override
  String get checkupConfirmTitle => 'Submit your answers?';

  @override
  String checkupConfirmBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'After you submit, the next check-up opens in $_temp0.';
  }

  @override
  String get checkupConfirmSubmit => 'Submit';

  @override
  String checkupResultTitle(String level) {
    return 'Your level: $level';
  }

  @override
  String checkupResultBody(int score, int total, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$score/$total correct. Your next level check opens in $_temp0.';
  }

  @override
  String get checkupNextIn => 'Next level check in';

  @override
  String checkupDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get checkupCooldownNote =>
      'A cooldown protects your result from short-term practice effects.';

  @override
  String get checkupRetakeUnavailable => 'Retake unavailable';

  @override
  String get checkupGrowth => 'CEFR growth';

  @override
  String checkupLastChecks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your last $count checks',
      one: 'Your last check',
    );
    return '$_temp0';
  }

  @override
  String checkupLevelsGained(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count levels',
      one: '+1 level',
    );
    return '$_temp0';
  }

  @override
  String get checkupChartEmpty =>
      'Your growth chart appears after your first check-up';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDefaultName => 'User';

  @override
  String get profileDefaultUniversity => 'Student';

  @override
  String profileUniversity(String name) {
    return 'University: $name';
  }

  @override
  String get profileTopicsMastered => 'Topics mastered';

  @override
  String get profileAverageResult => 'Average result';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileErrorMap => 'Mistakes map';

  @override
  String get profileJoinGroup => 'Join a group';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileChooseLanguage => 'Choose a language';

  @override
  String get profileSignOut => 'Sign out';
}
