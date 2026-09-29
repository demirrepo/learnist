import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get navTopics;

  /// No description provided for @navAiLab.
  ///
  /// In en, this message translates to:
  /// **'AI Lab'**
  String get navAiLab;

  /// No description provided for @navCheckup.
  ///
  /// In en, this message translates to:
  /// **'Check-up'**
  String get navCheckup;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Short bottom-bar label for the teacher panel.
  ///
  /// In en, this message translates to:
  /// **'Panel'**
  String get navTeacherPanel;

  /// Sidebar label for the teacher panel.
  ///
  /// In en, this message translates to:
  /// **'Teacher panel'**
  String get navTeacherPanelFull;

  /// No description provided for @sidebarTagline.
  ///
  /// In en, this message translates to:
  /// **'AI Learning Companion'**
  String get sidebarTagline;

  /// No description provided for @sidebarDefaultUser.
  ///
  /// In en, this message translates to:
  /// **'Learnist user'**
  String get sidebarDefaultUser;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleTeacher;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Shown instead of a CEFR level before the first check-up.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @lessonLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}'**
  String lessonLabel(int number);

  /// No description provided for @semesterLabel.
  ///
  /// In en, this message translates to:
  /// **'Semester {number}'**
  String semesterLabel(int number);

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcomeBack;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name} 👋'**
  String homeGreeting(String greeting, String name);

  /// No description provided for @homeCefrBadge.
  ///
  /// In en, this message translates to:
  /// **'CEFR level: {level}'**
  String homeCefrBadge(String level);

  /// No description provided for @homeCefrBadgeUnknown.
  ///
  /// In en, this message translates to:
  /// **'CEFR level: not determined yet'**
  String get homeCefrBadgeUnknown;

  /// No description provided for @homeTodaysFocus.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S FOCUS'**
  String get homeTodaysFocus;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your English grows every time you understand a mistake.'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the momentum going with your next guided practice.'**
  String get homeSubtitle;

  /// No description provided for @homeContinueLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue Lesson {number}'**
  String homeContinueLesson(int number);

  /// No description provided for @homeOpenAiLab.
  ///
  /// In en, this message translates to:
  /// **'Open AI Lab'**
  String get homeOpenAiLab;

  /// No description provided for @homeMastery.
  ///
  /// In en, this message translates to:
  /// **'{percent}% mastery'**
  String homeMastery(int percent);

  /// No description provided for @homeLearningSpace.
  ///
  /// In en, this message translates to:
  /// **'Learning space'**
  String get homeLearningSpace;

  /// No description provided for @homeSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get homeSwipe;

  /// No description provided for @homeLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String homeLessonCount(int count);

  /// No description provided for @homePromptBetter.
  ///
  /// In en, this message translates to:
  /// **'Prompt better'**
  String get homePromptBetter;

  /// No description provided for @homeCefrTest.
  ///
  /// In en, this message translates to:
  /// **'CEFR test'**
  String get homeCefrTest;

  /// No description provided for @homeSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Your snapshot'**
  String get homeSnapshot;

  /// No description provided for @statLessonsMastered.
  ///
  /// In en, this message translates to:
  /// **'Lessons mastered'**
  String get statLessonsMastered;

  /// No description provided for @statCurrentLesson.
  ///
  /// In en, this message translates to:
  /// **'Current lesson'**
  String get statCurrentLesson;

  /// No description provided for @statCefrEstimate.
  ///
  /// In en, this message translates to:
  /// **'CEFR estimate'**
  String get statCefrEstimate;

  /// No description provided for @statTrackedMistakes.
  ///
  /// In en, this message translates to:
  /// **'Tracked mistakes'**
  String get statTrackedMistakes;

  /// No description provided for @lessonMastery.
  ///
  /// In en, this message translates to:
  /// **'Lesson mastery'**
  String get lessonMastery;

  /// No description provided for @lessonMasterySemantics.
  ///
  /// In en, this message translates to:
  /// **'Lesson mastery, {lesson}: {percent}'**
  String lessonMasterySemantics(String lesson, String percent);

  /// No description provided for @topicsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TOPICS'**
  String get topicsEyebrow;

  /// No description provided for @topicsTitle.
  ///
  /// In en, this message translates to:
  /// **'52-lesson pathway'**
  String get topicsTitle;

  /// No description provided for @topicsSemesters.
  ///
  /// In en, this message translates to:
  /// **'Semester 1: Lessons 1-30 • Semester 2: Lessons 31-52'**
  String get topicsSemesters;

  /// No description provided for @topicsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search lessons'**
  String get topicsSearchHint;

  /// No description provided for @topicsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No lessons match your search.'**
  String get topicsNoMatch;

  /// No description provided for @topicsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No lessons found yet.'**
  String get topicsEmpty;

  /// No description provided for @topicLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get topicLocked;

  /// No description provided for @topicLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Locked. This lesson opens after you finish the previous ones.'**
  String get topicLockedMessage;

  /// No description provided for @aiLabEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PROMPT LITERACY'**
  String get aiLabEyebrow;

  /// No description provided for @aiLabHeadline.
  ///
  /// In en, this message translates to:
  /// **'Ask better questions. Learn more independently.'**
  String get aiLabHeadline;

  /// No description provided for @aiLabIntro.
  ///
  /// In en, this message translates to:
  /// **'A prompt is the instruction you give an AI. A clear prompt gets you an answer you can learn from, not just one to copy.'**
  String get aiLabIntro;

  /// No description provided for @aiLabExamplePrompt.
  ///
  /// In en, this message translates to:
  /// **'EXAMPLE PROMPT'**
  String get aiLabExamplePrompt;

  /// No description provided for @promptPartRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get promptPartRole;

  /// No description provided for @promptPartTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get promptPartTask;

  /// No description provided for @promptPartLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get promptPartLevel;

  /// No description provided for @promptPartContext.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get promptPartContext;

  /// No description provided for @promptPartFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get promptPartFormat;

  /// No description provided for @aiCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'AI course'**
  String get aiCourseTitle;

  /// No description provided for @aiCourseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} short steps to a strong prompt.'**
  String aiCourseSubtitle(int count);

  /// No description provided for @aiStepWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is a prompt?'**
  String get aiStepWhatTitle;

  /// No description provided for @aiStepWhatBody.
  ///
  /// In en, this message translates to:
  /// **'A prompt is the message you send to an AI. The clearer it is, the more useful the answer.'**
  String get aiStepWhatBody;

  /// No description provided for @aiStepRoleBody.
  ///
  /// In en, this message translates to:
  /// **'Tell the AI who to be, so it answers like an expert.'**
  String get aiStepRoleBody;

  /// No description provided for @aiStepTaskBody.
  ///
  /// In en, this message translates to:
  /// **'Say exactly what you want it to do.'**
  String get aiStepTaskBody;

  /// No description provided for @aiStepLevelBody.
  ///
  /// In en, this message translates to:
  /// **'Give your English level so the answer fits you.'**
  String get aiStepLevelBody;

  /// No description provided for @aiStepContextBody.
  ///
  /// In en, this message translates to:
  /// **'Share the background: the text, the question, your goal.'**
  String get aiStepContextBody;

  /// No description provided for @aiStepFormatBody.
  ///
  /// In en, this message translates to:
  /// **'Ask for the shape of the answer: a list, a table or a short paragraph.'**
  String get aiStepFormatBody;

  /// No description provided for @aiStepExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Examples & Tone'**
  String get aiStepExamplesTitle;

  /// No description provided for @aiStepExamplesBody.
  ///
  /// In en, this message translates to:
  /// **'Show an example and choose the tone you want.'**
  String get aiStepExamplesBody;

  /// No description provided for @promptCheckerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prompt checker'**
  String get promptCheckerTitle;

  /// No description provided for @promptCheckerHint.
  ///
  /// In en, this message translates to:
  /// **'Write a prompt...'**
  String get promptCheckerHint;

  /// No description provided for @promptCheckerButton.
  ///
  /// In en, this message translates to:
  /// **'Check my prompt'**
  String get promptCheckerButton;

  /// No description provided for @promptCheckerFeedback.
  ///
  /// In en, this message translates to:
  /// **'AI feedback'**
  String get promptCheckerFeedback;

  /// No description provided for @promptCheckerUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Please try again.'**
  String get promptCheckerUnexpected;

  /// No description provided for @comparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Bad prompt → better prompt'**
  String get comparisonTitle;

  /// No description provided for @comparisonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same question, very different answers.'**
  String get comparisonSubtitle;

  /// No description provided for @comparisonBadNote.
  ///
  /// In en, this message translates to:
  /// **'No role, no context, no level. The AI has to guess what you need, so the answer is vague.'**
  String get comparisonBadNote;

  /// No description provided for @comparisonGoodNote.
  ///
  /// In en, this message translates to:
  /// **'Role + question context + level + format. The AI knows exactly how to help you.'**
  String get comparisonGoodNote;

  /// No description provided for @checkupEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR TRUE LEVEL'**
  String get checkupEyebrow;

  /// No description provided for @checkupTitle.
  ///
  /// In en, this message translates to:
  /// **'Level check-up'**
  String get checkupTitle;

  /// No description provided for @checkupMinutes.
  ///
  /// In en, this message translates to:
  /// **'≈ {minutes} min'**
  String checkupMinutes(int minutes);

  /// No description provided for @checkupQuestionRange.
  ///
  /// In en, this message translates to:
  /// **'{count} questions from A1 to C2'**
  String checkupQuestionRange(int count);

  /// No description provided for @checkupLevelRule.
  ///
  /// In en, this message translates to:
  /// **'Your level is the highest one you pass in order, from A1 up.'**
  String get checkupLevelRule;

  /// No description provided for @checkupAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get checkupAnswers;

  /// No description provided for @checkupSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit check-up'**
  String get checkupSubmit;

  /// No description provided for @checkupAnswerAll.
  ///
  /// In en, this message translates to:
  /// **'Answer all {count} questions.'**
  String checkupAnswerAll(int count);

  /// No description provided for @checkupNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions have been added yet.'**
  String get checkupNoQuestions;

  /// No description provided for @checkupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit your answers?'**
  String get checkupConfirmTitle;

  /// No description provided for @checkupConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'After you submit, the next check-up opens in {days, plural, =1{1 day} other{{days} days}}.'**
  String checkupConfirmBody(int days);

  /// No description provided for @checkupConfirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get checkupConfirmSubmit;

  /// No description provided for @checkupResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your level: {level}'**
  String checkupResultTitle(String level);

  /// No description provided for @checkupResultBody.
  ///
  /// In en, this message translates to:
  /// **'{score}/{total} correct. Your next level check opens in {days, plural, =1{1 day} other{{days} days}}.'**
  String checkupResultBody(int score, int total, int days);

  /// No description provided for @checkupNextIn.
  ///
  /// In en, this message translates to:
  /// **'Next level check in'**
  String get checkupNextIn;

  /// No description provided for @checkupDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String checkupDays(int count);

  /// No description provided for @checkupCooldownNote.
  ///
  /// In en, this message translates to:
  /// **'A cooldown protects your result from short-term practice effects.'**
  String get checkupCooldownNote;

  /// No description provided for @checkupRetakeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Retake unavailable'**
  String get checkupRetakeUnavailable;

  /// No description provided for @checkupGrowth.
  ///
  /// In en, this message translates to:
  /// **'CEFR growth'**
  String get checkupGrowth;

  /// No description provided for @checkupLastChecks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your last check} other{Your last {count} checks}}'**
  String checkupLastChecks(int count);

  /// No description provided for @checkupLevelsGained.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 level} other{+{count} levels}}'**
  String checkupLevelsGained(int count);

  /// No description provided for @checkupChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your growth chart appears after your first check-up'**
  String get checkupChartEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileDefaultName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profileDefaultName;

  /// No description provided for @profileDefaultUniversity.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get profileDefaultUniversity;

  /// No description provided for @profileUniversity.
  ///
  /// In en, this message translates to:
  /// **'University: {name}'**
  String profileUniversity(String name);

  /// No description provided for @profileTopicsMastered.
  ///
  /// In en, this message translates to:
  /// **'Topics mastered'**
  String get profileTopicsMastered;

  /// No description provided for @profileAverageResult.
  ///
  /// In en, this message translates to:
  /// **'Average result'**
  String get profileAverageResult;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileErrorMap.
  ///
  /// In en, this message translates to:
  /// **'Mistakes map'**
  String get profileErrorMap;

  /// No description provided for @profileJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join a group'**
  String get profileJoinGroup;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get profileChooseLanguage;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
