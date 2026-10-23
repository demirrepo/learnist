import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
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
    Locale('kk'),
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

  /// No description provided for @lessonTabGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get lessonTabGrammar;

  /// No description provided for @lessonTabReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get lessonTabReading;

  /// No description provided for @lessonTabListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get lessonTabListening;

  /// No description provided for @lessonTabWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get lessonTabWriting;

  /// No description provided for @lessonTabSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get lessonTabSpeaking;

  /// No description provided for @lessonGeneralRule.
  ///
  /// In en, this message translates to:
  /// **'General rule'**
  String get lessonGeneralRule;

  /// No description provided for @lessonNoGrammar.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no grammar rules.'**
  String get lessonNoGrammar;

  /// No description provided for @lessonNoReading.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no reading exercise.'**
  String get lessonNoReading;

  /// No description provided for @lessonNoListening.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no listening exercise.'**
  String get lessonNoListening;

  /// No description provided for @lessonNoWriting.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no writing task.'**
  String get lessonNoWriting;

  /// No description provided for @lessonNoSpeaking.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no speaking task.'**
  String get lessonNoSpeaking;

  /// No description provided for @lessonVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get lessonVocabulary;

  /// No description provided for @lessonCheckResults.
  ///
  /// In en, this message translates to:
  /// **'Check results'**
  String get lessonCheckResults;

  /// No description provided for @lessonAudioPending.
  ///
  /// In en, this message translates to:
  /// **'Audio for this lesson is still being prepared. Use the transcript for now.'**
  String get lessonAudioPending;

  /// No description provided for @lessonAudioError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the audio. Check your internet connection and try again.'**
  String get lessonAudioError;

  /// No description provided for @lessonFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish lesson'**
  String get lessonFinish;

  /// No description provided for @lessonUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! A new lesson is unlocked'**
  String get lessonUnlocked;

  /// No description provided for @lessonSaveScoreError.
  ///
  /// In en, this message translates to:
  /// **'Your score wasn\'t saved. Please try again.'**
  String get lessonSaveScoreError;

  /// No description provided for @taskEmptyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Write your answer first.'**
  String get taskEmptyAnswer;

  /// No description provided for @taskEvaluationError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while grading. Please try again.'**
  String get taskEvaluationError;

  /// No description provided for @taskMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone access to record your voice.'**
  String get taskMicDenied;

  /// No description provided for @taskMicBlocked.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is blocked. Turn it on in your phone settings.'**
  String get taskMicBlocked;

  /// No description provided for @taskRecordingError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start recording. Please try again.'**
  String get taskRecordingError;

  /// No description provided for @taskTranscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t turn your speech into text. Please try again.'**
  String get taskTranscriptionError;

  /// No description provided for @taskRecordingMissing.
  ///
  /// In en, this message translates to:
  /// **'No recorded audio was found.'**
  String get taskRecordingMissing;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorOffline;

  /// No description provided for @lessonNotFound.
  ///
  /// In en, this message translates to:
  /// **'Lesson not found.'**
  String get lessonNotFound;

  /// No description provided for @lessonLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the lessons. Please try again in a moment.'**
  String get lessonLoadFailed;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @lessonCompleteLowScore.
  ///
  /// In en, this message translates to:
  /// **'Your average score is below {min}%. Improve your sections to move on to the next lesson.'**
  String lessonCompleteLowScore(int min);

  /// No description provided for @lessonCompleteLowScoreWithAverage.
  ///
  /// In en, this message translates to:
  /// **'Your average score is below {min}% (currently {average}%). Improve your sections to move on to the next lesson.'**
  String lessonCompleteLowScoreWithAverage(int min, int average);

  /// No description provided for @lessonCompleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t finish the lesson. Please try again.'**
  String get lessonCompleteFailed;

  /// No description provided for @lessonKeyWords.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 key word} other{{count} key words}}'**
  String lessonKeyWords(int count);

  /// No description provided for @vocabularyListen.
  ///
  /// In en, this message translates to:
  /// **'Listen to “{word}”'**
  String vocabularyListen(String word);

  /// No description provided for @vocabularySpeakError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play the pronunciation.'**
  String get vocabularySpeakError;

  /// No description provided for @askAiEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CONTEXT-AWARE ASK AI'**
  String get askAiEyebrow;

  /// No description provided for @askAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about {section}'**
  String askAiTitle(String section);

  /// No description provided for @askAiContextAttached.
  ///
  /// In en, this message translates to:
  /// **'Your context is already attached:'**
  String get askAiContextAttached;

  /// No description provided for @askAiHint.
  ///
  /// In en, this message translates to:
  /// **'Example: You are a reading expert. In Lesson {lesson}, question 4, I chose B. Explain why my reasoning may be wrong. Give me two hints without revealing the correct answer.'**
  String askAiHint(int lesson);

  /// No description provided for @askAiSubmit.
  ///
  /// In en, this message translates to:
  /// **'Ask Learnist AI'**
  String get askAiSubmit;

  /// No description provided for @askAiThinking.
  ///
  /// In en, this message translates to:
  /// **'Learnist AI is thinking…'**
  String get askAiThinking;

  /// No description provided for @askAiEmptyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Write your question first.'**
  String get askAiEmptyQuestion;

  /// No description provided for @askAiBusy.
  ///
  /// In en, this message translates to:
  /// **'Learnist AI is busy right now. Try again in a moment.'**
  String get askAiBusy;

  /// No description provided for @askAiFailed.
  ///
  /// In en, this message translates to:
  /// **'Learnist AI couldn\'t answer. Please try again.'**
  String get askAiFailed;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @teacherEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CLASS ANALYTICS'**
  String get teacherEyebrow;

  /// No description provided for @teacherWorkspaceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'TEACHER WORKSPACE'**
  String get teacherWorkspaceEyebrow;

  /// No description provided for @teacherWorkspaceHeadline.
  ///
  /// In en, this message translates to:
  /// **'See who is learning — and where they struggle.'**
  String get teacherWorkspaceHeadline;

  /// No description provided for @teacherWorkspaceBody.
  ///
  /// In en, this message translates to:
  /// **'Create classes, connect students through a class login/password, and monitor lesson progress, CEFR history and recurring error categories.'**
  String get teacherWorkspaceBody;

  /// No description provided for @teacherCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get teacherCreateGroup;

  /// No description provided for @teacherConnectedStudents.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED STUDENTS'**
  String get teacherConnectedStudents;

  /// No description provided for @teacherConnectedStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 connected student} other{{count} connected students}}'**
  String teacherConnectedStudentCount(int count);

  /// No description provided for @teacherGroupCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 group} other{{count} groups}}'**
  String teacherGroupCount(int count);

  /// No description provided for @teacherStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student} other{{count} students}}'**
  String teacherStudentCount(int count);

  /// No description provided for @teacherClassOverview.
  ///
  /// In en, this message translates to:
  /// **'Class overview'**
  String get teacherClassOverview;

  /// No description provided for @teacherStudentsActive.
  ///
  /// In en, this message translates to:
  /// **'Students active'**
  String get teacherStudentsActive;

  /// No description provided for @teacherAverageMastery.
  ///
  /// In en, this message translates to:
  /// **'Average mastery'**
  String get teacherAverageMastery;

  /// No description provided for @teacherGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get teacherGroups;

  /// No description provided for @teacherGroupsAndStudents.
  ///
  /// In en, this message translates to:
  /// **'Groups & students'**
  String get teacherGroupsAndStudents;

  /// No description provided for @teacherNoGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet. Create one to connect students.'**
  String get teacherNoGroups;

  /// No description provided for @teacherNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students connected yet.'**
  String get teacherNoStudents;

  /// No description provided for @groupClassLogin.
  ///
  /// In en, this message translates to:
  /// **'Class login'**
  String get groupClassLogin;

  /// Lowercase label after the class login, e.g. "Class login: ELT301 • password: elt301".
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get teacherPasswordInline;

  /// No description provided for @teacherColumnStudent.
  ///
  /// In en, this message translates to:
  /// **'STUDENT'**
  String get teacherColumnStudent;

  /// No description provided for @teacherColumnCurrentLesson.
  ///
  /// In en, this message translates to:
  /// **'CURRENT LESSON'**
  String get teacherColumnCurrentLesson;

  /// No description provided for @teacherColumnMastery.
  ///
  /// In en, this message translates to:
  /// **'MASTERY'**
  String get teacherColumnMastery;

  /// No description provided for @teacherColumnAction.
  ///
  /// In en, this message translates to:
  /// **'ACTION'**
  String get teacherColumnAction;

  /// Compact current-lesson cell in the student table.
  ///
  /// In en, this message translates to:
  /// **'L{number}'**
  String teacherLessonShort(int number);

  /// No description provided for @teacherChipLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get teacherChipLesson;

  /// No description provided for @teacherChipMastery.
  ///
  /// In en, this message translates to:
  /// **'Mastery'**
  String get teacherChipMastery;

  /// No description provided for @teacherView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get teacherView;

  /// No description provided for @teacherGroupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group «{name}» created.'**
  String teacherGroupCreated(String name);

  /// No description provided for @teacherGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get teacherGroupName;

  /// No description provided for @teacherLoginHelper.
  ///
  /// In en, this message translates to:
  /// **'3–32 characters: A–Z, 0–9, _ or -'**
  String get teacherLoginHelper;

  /// No description provided for @groupPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get groupPassword;

  /// No description provided for @teacherGroupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name.'**
  String get teacherGroupNameRequired;

  /// No description provided for @teacherLoginInvalid.
  ///
  /// In en, this message translates to:
  /// **'The login must be 3–32 letters, digits, _ or -.'**
  String get teacherLoginInvalid;

  /// No description provided for @teacherPasswordInvalid.
  ///
  /// In en, this message translates to:
  /// **'The password must be 4–64 characters long.'**
  String get teacherPasswordInvalid;

  /// No description provided for @teacherCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get teacherCreate;

  /// No description provided for @teacherLoginTaken.
  ///
  /// In en, this message translates to:
  /// **'This login is taken. Please choose another one.'**
  String get teacherLoginTaken;

  /// No description provided for @teacherCreateGroupFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the group. Please try again.'**
  String get teacherCreateGroupFailed;

  /// No description provided for @teacherLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the data. Please try again.'**
  String get teacherLoadFailed;

  /// No description provided for @teacherStudentDetail.
  ///
  /// In en, this message translates to:
  /// **'STUDENT DETAIL'**
  String get teacherStudentDetail;

  /// No description provided for @teacherCurrentLesson.
  ///
  /// In en, this message translates to:
  /// **'current lesson {number}'**
  String teacherCurrentLesson(int number);

  /// No description provided for @teacherLessonProgress.
  ///
  /// In en, this message translates to:
  /// **'Lesson progress'**
  String get teacherLessonProgress;

  /// No description provided for @teacherLessonInProgress.
  ///
  /// In en, this message translates to:
  /// **'{title} • in progress'**
  String teacherLessonInProgress(String title);

  /// No description provided for @teacherNoLessonsStarted.
  ///
  /// In en, this message translates to:
  /// **'No lessons started yet.'**
  String get teacherNoLessonsStarted;

  /// No description provided for @joinGroupIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the class login and password your teacher gave you.'**
  String get joinGroupIntro;

  /// No description provided for @joinGroupFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Fill in this field.'**
  String get joinGroupFieldRequired;

  /// No description provided for @joinGroupSubmit.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinGroupSubmit;

  /// No description provided for @joinGroupJoined.
  ///
  /// In en, this message translates to:
  /// **'You joined «{name}».'**
  String joinGroupJoined(String name);

  /// No description provided for @joinGroupAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re already in «{name}».'**
  String joinGroupAlreadyMember(String name);

  /// No description provided for @joinGroupInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong login or password.'**
  String get joinGroupInvalidCredentials;

  /// No description provided for @joinGroupOwnGroup.
  ///
  /// In en, this message translates to:
  /// **'You can\'t join a group you created.'**
  String get joinGroupOwnGroup;

  /// No description provided for @joinGroupFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t join the group. Please try again.'**
  String get joinGroupFailed;

  /// No description provided for @authEyebrowSignUp.
  ///
  /// In en, this message translates to:
  /// **'START YOUR ENGLISH JOURNEY'**
  String get authEyebrowSignUp;

  /// No description provided for @authEyebrowSignIn.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get authEyebrowSignIn;

  /// No description provided for @authTitleSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authTitleSignUp;

  /// No description provided for @authTitleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Learnist'**
  String get authTitleSignIn;

  /// No description provided for @authSubtitleSignUp.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of students preparing for their CEFR certificate.'**
  String get authSubtitleSignUp;

  /// No description provided for @authSubtitleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Pick up right where you left off.'**
  String get authSubtitleSignIn;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That email address isn\'t valid'**
  String get authEmailInvalid;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get authPasswordHint;

  /// No description provided for @authPasswordHintNew.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authPasswordHintNew;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 6 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPassword;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get authFullNameHint;

  /// No description provided for @authFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameRequired;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. learner_01'**
  String get authUsernameHint;

  /// No description provided for @authUsernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'3–30 characters: letters, digits, _ or .'**
  String get authUsernameInvalid;

  /// No description provided for @authUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get authUniversity;

  /// No description provided for @authUniversityHint.
  ///
  /// In en, this message translates to:
  /// **'Search your university'**
  String get authUniversityHint;

  /// No description provided for @authUniversityRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose your university'**
  String get authUniversityRequired;

  /// University list entry for a university that isn't listed.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get authOtherUniversity;

  /// No description provided for @authUniversityName.
  ///
  /// In en, this message translates to:
  /// **'University name'**
  String get authUniversityName;

  /// No description provided for @authUniversityNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type your university name'**
  String get authUniversityNameHint;

  /// No description provided for @authUniversityNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the university name'**
  String get authUniversityNameRequired;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authNewToLearnist.
  ///
  /// In en, this message translates to:
  /// **'New to Learnist?'**
  String get authNewToLearnist;

  /// No description provided for @authSignInInstead.
  ///
  /// In en, this message translates to:
  /// **'Sign in instead'**
  String get authSignInInstead;

  /// No description provided for @authCreateAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAnAccount;

  /// No description provided for @authConfirmEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a confirmation link to your email. Open it, then sign in.'**
  String get authConfirmEmailSent;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetTitle;

  /// No description provided for @authResetBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email linked to your account — we\'ll send you a reset link.'**
  String get authResetBody;

  /// No description provided for @authResetSend.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get authResetSend;

  /// No description provided for @authResetSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to your email.'**
  String get authResetSent;

  /// No description provided for @passwordEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT RECOVERY'**
  String get passwordEyebrow;

  /// No description provided for @passwordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get passwordTitle;

  /// No description provided for @passwordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter a new, secure password for your account. You\'ll use it the next time you sign in.'**
  String get passwordBody;

  /// No description provided for @passwordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNew;

  /// No description provided for @passwordNewRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get passwordNewRequired;

  /// No description provided for @passwordSave.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get passwordSave;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated.'**
  String get passwordUpdated;

  /// No description provided for @authRoleMismatchStudent.
  ///
  /// In en, this message translates to:
  /// **'You registered as a student. Please pick the \'Student\' tab.'**
  String get authRoleMismatchStudent;

  /// No description provided for @authRoleMismatchTeacher.
  ///
  /// In en, this message translates to:
  /// **'You registered as a teacher. Please pick the \'Teacher\' tab.'**
  String get authRoleMismatchTeacher;

  /// No description provided for @authUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Please choose another one.'**
  String get authUsernameTaken;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server. Please try again in a moment.'**
  String get errorServer;

  /// No description provided for @authResetOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Open the link on the device where you asked to reset your password.'**
  String get authResetOtherDevice;

  /// No description provided for @authLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'The link has expired or was already used. Please request a new one.'**
  String get authLinkExpired;

  /// No description provided for @authEmailExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please sign in.'**
  String get authEmailExists;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your email isn\'t confirmed yet. Click the link in your inbox.'**
  String get authEmailNotConfirmed;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too simple. Enter a stronger one of at least 6 characters.'**
  String get authWeakPassword;

  /// No description provided for @authSamePassword.
  ///
  /// In en, this message translates to:
  /// **'The new password must be different from the old one.'**
  String get authSamePassword;

  /// No description provided for @authSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please request a new reset link.'**
  String get authSessionExpired;

  /// No description provided for @authEmailAddressInvalid.
  ///
  /// In en, this message translates to:
  /// **'The email address was entered incorrectly.'**
  String get authEmailAddressInvalid;

  /// No description provided for @authRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again in a moment.'**
  String get authRateLimited;

  /// No description provided for @authSignupDisabled.
  ///
  /// In en, this message translates to:
  /// **'Sign-up is turned off for now.'**
  String get authSignupDisabled;

  /// No description provided for @profileUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is taken.'**
  String get profileUsernameTaken;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Your profile wasn\'t found. Sign out and sign in again.'**
  String get profileNotFound;

  /// No description provided for @profileUpdateForbidden.
  ///
  /// In en, this message translates to:
  /// **'You\'re not allowed to change this profile.'**
  String get profileUpdateForbidden;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editProfileFullName.
  ///
  /// In en, this message translates to:
  /// **'First and last name'**
  String get editProfileFullName;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Your changes have been saved'**
  String get profileSaved;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @lessonTitleWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}: {title}'**
  String lessonTitleWithNumber(int number, String title);

  /// No description provided for @lessonTagPracticalTask.
  ///
  /// In en, this message translates to:
  /// **'Practical task'**
  String get lessonTagPracticalTask;

  /// No description provided for @lessonTagGrammarRule.
  ///
  /// In en, this message translates to:
  /// **'Grammar rule'**
  String get lessonTagGrammarRule;

  /// No description provided for @lessonTagSpeakingTask.
  ///
  /// In en, this message translates to:
  /// **'Speaking task'**
  String get lessonTagSpeakingTask;

  /// No description provided for @lessonTagWritingTask.
  ///
  /// In en, this message translates to:
  /// **'Writing task'**
  String get lessonTagWritingTask;

  /// No description provided for @lessonAnalyzeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Analyze my answer'**
  String get lessonAnalyzeAnswer;

  /// No description provided for @lessonAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Write your answer here…'**
  String get lessonAnswerHint;

  /// No description provided for @lessonAssessWriting.
  ///
  /// In en, this message translates to:
  /// **'Assess my writing'**
  String get lessonAssessWriting;

  /// No description provided for @lessonWritingHint.
  ///
  /// In en, this message translates to:
  /// **'Write your text here…'**
  String get lessonWritingHint;

  /// No description provided for @lessonWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / {min}–{max} words'**
  String lessonWordCount(int count, int min, int max);

  /// No description provided for @lessonCefrLenses.
  ///
  /// In en, this message translates to:
  /// **'CEFR lenses'**
  String get lessonCefrLenses;

  /// No description provided for @lessonCefrLensesCaption.
  ///
  /// In en, this message translates to:
  /// **'Your writing is assessed through these levels.'**
  String get lessonCefrLensesCaption;

  /// No description provided for @lessonLensA1.
  ///
  /// In en, this message translates to:
  /// **'Short, correct sentences using the lesson\'s grammar.'**
  String get lessonLensA1;

  /// No description provided for @lessonLensA2.
  ///
  /// In en, this message translates to:
  /// **'Link ideas with and, but and because.'**
  String get lessonLensA2;

  /// No description provided for @lessonLensB1.
  ///
  /// In en, this message translates to:
  /// **'Add details and reasons in clear paragraphs.'**
  String get lessonLensB1;

  /// No description provided for @lessonLensB2.
  ///
  /// In en, this message translates to:
  /// **'Vary your vocabulary and sentence structure.'**
  String get lessonLensB2;

  /// No description provided for @lessonTranscript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get lessonTranscript;

  /// No description provided for @lessonAssessSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Assess speaking'**
  String get lessonAssessSpeaking;

  /// No description provided for @lessonSpeakingHint.
  ///
  /// In en, this message translates to:
  /// **'Record your answer, or type what you said here…'**
  String get lessonSpeakingHint;

  /// No description provided for @lessonAskAi.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get lessonAskAi;

  /// No description provided for @micIdle.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic and speak (up to {minutes, plural, =1{1 minute} other{{minutes} minutes}})'**
  String micIdle(int minutes);

  /// No description provided for @micRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording… Tap to stop'**
  String get micRecording;

  /// No description provided for @micTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing…'**
  String get micTranscribing;

  /// No description provided for @micStart.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get micStart;

  /// No description provided for @micStop.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get micStop;

  /// No description provided for @taskMasteryReached.
  ///
  /// In en, this message translates to:
  /// **'Mastery reached: {score}%'**
  String taskMasteryReached(int score);

  /// No description provided for @recordingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your recording'**
  String get recordingTitle;

  /// No description provided for @recordingPlay.
  ///
  /// In en, this message translates to:
  /// **'Play recording'**
  String get recordingPlay;

  /// No description provided for @recordingPause.
  ///
  /// In en, this message translates to:
  /// **'Pause recording'**
  String get recordingPause;

  /// No description provided for @recordingUnplayable.
  ///
  /// In en, this message translates to:
  /// **'Your recording can\'t be played back.'**
  String get recordingUnplayable;

  /// No description provided for @audioRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get audioRestart;

  /// No description provided for @audioPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get audioPlay;

  /// No description provided for @audioPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get audioPause;

  /// No description provided for @transcriptShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get transcriptShow;

  /// No description provided for @transcriptHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get transcriptHide;

  /// No description provided for @quizAnswerAll.
  ///
  /// In en, this message translates to:
  /// **'Answer all {total} questions to check your results.'**
  String quizAnswerAll(int total);

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} correct'**
  String quizScore(int correct, int total);

  /// No description provided for @quizReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Review the text and try again to improve your score.'**
  String get quizReviewHint;

  /// No description provided for @checkupCooldownError.
  ///
  /// In en, this message translates to:
  /// **'The next level check isn\'t open yet.'**
  String get checkupCooldownError;

  /// No description provided for @checkupInvalidAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answer every question and submit again.'**
  String get checkupInvalidAnswers;

  /// No description provided for @errorNoResponse.
  ///
  /// In en, this message translates to:
  /// **'The server didn\'t respond. Please try again.'**
  String get errorNoResponse;

  /// No description provided for @recordingEmpty.
  ///
  /// In en, this message translates to:
  /// **'The recorded audio is empty.'**
  String get recordingEmpty;

  /// No description provided for @transcriptionNoSpeech.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t hear you. Speak closer to the microphone and try again.'**
  String get transcriptionNoSpeech;

  /// No description provided for @aiEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Write your prompt first.'**
  String get aiEmptyPrompt;

  /// No description provided for @aiBusy.
  ///
  /// In en, this message translates to:
  /// **'The AI is busy right now. Try again in a moment.'**
  String get aiBusy;

  /// No description provided for @aiFailed.
  ///
  /// In en, this message translates to:
  /// **'The AI couldn\'t answer. Try again.'**
  String get aiFailed;

  /// No description provided for @aiTimeout.
  ///
  /// In en, this message translates to:
  /// **'The AI didn\'t respond. Try again.'**
  String get aiTimeout;

  /// No description provided for @aiEmptyReply.
  ///
  /// In en, this message translates to:
  /// **'The AI sent an empty reply. Try again.'**
  String get aiEmptyReply;

  /// No description provided for @aiUnreadableReply.
  ///
  /// In en, this message translates to:
  /// **'The AI\'s reply couldn\'t be read. Try again.'**
  String get aiUnreadableReply;

  /// No description provided for @errorMapIntro.
  ///
  /// In en, this message translates to:
  /// **'Questions you keep getting wrong in tests. Mistakes repeated at least {count} times are shown — tap a card to study the topic again.'**
  String errorMapIntro(int count);

  /// No description provided for @errorLegendHigh.
  ///
  /// In en, this message translates to:
  /// **'Repeated often (4+)'**
  String get errorLegendHigh;

  /// No description provided for @errorLegendMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate (2–3)'**
  String get errorLegendMedium;

  /// No description provided for @errorMapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Great! No recurring mistakes yet'**
  String get errorMapEmptyTitle;

  /// No description provided for @errorMapEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'If you get the same test question wrong twice, it will show up here.'**
  String get errorMapEmptyBody;

  /// Card title for a mistake with no description yet.
  ///
  /// In en, this message translates to:
  /// **'{section}: question {number}'**
  String errorMapQuestion(String section, int number);

  /// No description provided for @errorMistakeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Missed once in recent tests} other{Missed {count} times in recent tests}}'**
  String errorMistakeCount(int count);

  /// No description provided for @errorSeverityHigh.
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get errorSeverityHigh;

  /// No description provided for @errorSeverityMedium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get errorSeverityMedium;

  /// No description provided for @errorPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority: {level}'**
  String errorPriority(String level);

  /// No description provided for @errorReviewLesson.
  ///
  /// In en, this message translates to:
  /// **'Review the lesson'**
  String get errorReviewLesson;
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
      <String>['en', 'kk', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
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
