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

  @override
  String get lessonTabGrammar => 'Grammar';

  @override
  String get lessonTabReading => 'Reading';

  @override
  String get lessonTabListening => 'Listening';

  @override
  String get lessonTabWriting => 'Writing';

  @override
  String get lessonTabSpeaking => 'Speaking';

  @override
  String get lessonGeneralRule => 'General rule';

  @override
  String get lessonNoGrammar => 'This lesson has no grammar rules.';

  @override
  String get lessonNoReading => 'This lesson has no reading exercise.';

  @override
  String get lessonNoListening => 'This lesson has no listening exercise.';

  @override
  String get lessonNoWriting => 'This lesson has no writing task.';

  @override
  String get lessonNoSpeaking => 'This lesson has no speaking task.';

  @override
  String get lessonVocabulary => 'Vocabulary';

  @override
  String get lessonCheckResults => 'Check results';

  @override
  String get lessonAudioPending =>
      'Audio for this lesson is still being prepared. Use the transcript for now.';

  @override
  String get lessonAudioError =>
      'Couldn\'t load the audio. Check your internet connection and try again.';

  @override
  String get lessonFinish => 'Finish lesson';

  @override
  String get lessonUnlocked => 'Congratulations! A new lesson is unlocked';

  @override
  String get lessonSaveScoreError =>
      'Your score wasn\'t saved. Please try again.';

  @override
  String get taskEmptyAnswer => 'Write your answer first.';

  @override
  String get taskEvaluationError =>
      'Something went wrong while grading. Please try again.';

  @override
  String get taskMicDenied => 'Allow microphone access to record your voice.';

  @override
  String get taskMicBlocked =>
      'Microphone access is blocked. Turn it on in your phone settings.';

  @override
  String get taskRecordingError =>
      'Couldn\'t start recording. Please try again.';

  @override
  String get taskTranscriptionError =>
      'Couldn\'t turn your speech into text. Please try again.';

  @override
  String get taskRecordingMissing => 'No recorded audio was found.';

  @override
  String get errorOffline =>
      'No internet connection. Check your network and try again.';

  @override
  String get lessonNotFound => 'Lesson not found.';

  @override
  String get lessonLoadFailed =>
      'Couldn\'t load the lessons. Please try again in a moment.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String lessonCompleteLowScore(int min) {
    return 'Your average score is below $min%. Improve your sections to move on to the next lesson.';
  }

  @override
  String lessonCompleteLowScoreWithAverage(int min, int average) {
    return 'Your average score is below $min% (currently $average%). Improve your sections to move on to the next lesson.';
  }

  @override
  String get lessonCompleteFailed =>
      'Couldn\'t finish the lesson. Please try again.';

  @override
  String lessonKeyWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count key words',
      one: '1 key word',
    );
    return '$_temp0';
  }

  @override
  String vocabularyListen(String word) {
    return 'Listen to “$word”';
  }

  @override
  String get vocabularySpeakError => 'Couldn\'t play the pronunciation.';

  @override
  String get askAiEyebrow => 'CONTEXT-AWARE ASK AI';

  @override
  String askAiTitle(String section) {
    return 'Ask about $section';
  }

  @override
  String get askAiContextAttached => 'Your context is already attached:';

  @override
  String askAiHint(int lesson) {
    return 'Example: You are a reading expert. In Lesson $lesson, question 4, I chose B. Explain why my reasoning may be wrong. Give me two hints without revealing the correct answer.';
  }

  @override
  String get askAiSubmit => 'Ask Learnist AI';

  @override
  String get askAiThinking => 'Learnist AI is thinking…';

  @override
  String get askAiEmptyQuestion => 'Write your question first.';

  @override
  String get askAiBusy =>
      'Learnist AI is busy right now. Try again in a moment.';

  @override
  String get askAiFailed => 'Learnist AI couldn\'t answer. Please try again.';

  @override
  String get close => 'Close';

  @override
  String get teacherEyebrow => 'CLASS ANALYTICS';

  @override
  String get teacherWorkspaceEyebrow => 'TEACHER WORKSPACE';

  @override
  String get teacherWorkspaceHeadline =>
      'See who is learning — and where they struggle.';

  @override
  String get teacherWorkspaceBody =>
      'Create classes, connect students through a class login/password, and monitor lesson progress, CEFR history and recurring error categories.';

  @override
  String get teacherCreateGroup => 'Create group';

  @override
  String get teacherConnectedStudents => 'CONNECTED STUDENTS';

  @override
  String teacherConnectedStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count connected students',
      one: '1 connected student',
    );
    return '$_temp0';
  }

  @override
  String teacherGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String teacherStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '$_temp0';
  }

  @override
  String get teacherClassOverview => 'Class overview';

  @override
  String get teacherStudentsActive => 'Students active';

  @override
  String get teacherAverageMastery => 'Average mastery';

  @override
  String get teacherGroups => 'Groups';

  @override
  String get teacherGroupsAndStudents => 'Groups & students';

  @override
  String get teacherNoGroups =>
      'No groups yet. Create one to connect students.';

  @override
  String get teacherNoStudents => 'No students connected yet.';

  @override
  String get groupClassLogin => 'Class login';

  @override
  String get teacherPasswordInline => 'password';

  @override
  String get teacherColumnStudent => 'STUDENT';

  @override
  String get teacherColumnCurrentLesson => 'CURRENT LESSON';

  @override
  String get teacherColumnMastery => 'MASTERY';

  @override
  String get teacherColumnAction => 'ACTION';

  @override
  String teacherLessonShort(int number) {
    return 'L$number';
  }

  @override
  String get teacherChipLesson => 'Lesson';

  @override
  String get teacherChipMastery => 'Mastery';

  @override
  String get teacherView => 'View';

  @override
  String teacherGroupCreated(String name) {
    return 'Group «$name» created.';
  }

  @override
  String get teacherGroupName => 'Group name';

  @override
  String get teacherLoginHelper => '3–32 characters: A–Z, 0–9, _ or -';

  @override
  String get groupPassword => 'Password';

  @override
  String get teacherGroupNameRequired => 'Enter a group name.';

  @override
  String get teacherLoginInvalid =>
      'The login must be 3–32 letters, digits, _ or -.';

  @override
  String get teacherPasswordInvalid =>
      'The password must be 4–64 characters long.';

  @override
  String get teacherCreate => 'Create';

  @override
  String get teacherLoginTaken =>
      'This login is taken. Please choose another one.';

  @override
  String get teacherCreateGroupFailed =>
      'Couldn\'t create the group. Please try again.';

  @override
  String get teacherLoadFailed => 'Couldn\'t load the data. Please try again.';

  @override
  String get teacherStudentDetail => 'STUDENT DETAIL';

  @override
  String teacherCurrentLesson(int number) {
    return 'current lesson $number';
  }

  @override
  String get teacherLessonProgress => 'Lesson progress';

  @override
  String teacherLessonInProgress(String title) {
    return '$title • in progress';
  }

  @override
  String get teacherNoLessonsStarted => 'No lessons started yet.';

  @override
  String get joinGroupIntro =>
      'Enter the class login and password your teacher gave you.';

  @override
  String get joinGroupFieldRequired => 'Fill in this field.';

  @override
  String get joinGroupSubmit => 'Join';

  @override
  String joinGroupJoined(String name) {
    return 'You joined «$name».';
  }

  @override
  String joinGroupAlreadyMember(String name) {
    return 'You\'re already in «$name».';
  }

  @override
  String get joinGroupInvalidCredentials => 'Wrong login or password.';

  @override
  String get joinGroupOwnGroup => 'You can\'t join a group you created.';

  @override
  String get joinGroupFailed => 'Couldn\'t join the group. Please try again.';

  @override
  String get authEyebrowSignUp => 'START YOUR ENGLISH JOURNEY';

  @override
  String get authEyebrowSignIn => 'WELCOME BACK';

  @override
  String get authTitleSignUp => 'Create your account';

  @override
  String get authTitleSignIn => 'Sign in to Learnist';

  @override
  String get authSubtitleSignUp =>
      'Join thousands of students preparing for their CEFR certificate.';

  @override
  String get authSubtitleSignIn => 'Pick up right where you left off.';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailRequired => 'Enter your email';

  @override
  String get authEmailInvalid => 'That email address isn\'t valid';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Your password';

  @override
  String get authPasswordHintNew => 'At least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String get authPasswordTooShort =>
      'The password must be at least 6 characters';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authFullNameHint => 'Your full name';

  @override
  String get authFullNameRequired => 'Enter your full name';

  @override
  String get authUsername => 'Username';

  @override
  String get authUsernameHint => 'e.g. learner_01';

  @override
  String get authUsernameInvalid => '3–30 characters: letters, digits, _ or .';

  @override
  String get authUniversity => 'University';

  @override
  String get authUniversityHint => 'Search your university';

  @override
  String get authUniversityRequired => 'Choose your university';

  @override
  String get authOtherUniversity => 'Other';

  @override
  String get authUniversityName => 'University name';

  @override
  String get authUniversityNameHint => 'Type your university name';

  @override
  String get authUniversityNameRequired => 'Enter the university name';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authNewToLearnist => 'New to Learnist?';

  @override
  String get authSignInInstead => 'Sign in instead';

  @override
  String get authCreateAnAccount => 'Create an account';

  @override
  String get authConfirmEmailSent =>
      'We\'ve sent a confirmation link to your email. Open it, then sign in.';

  @override
  String get authResetTitle => 'Reset password';

  @override
  String get authResetBody =>
      'Enter the email linked to your account — we\'ll send you a reset link.';

  @override
  String get authResetSend => 'Send link';

  @override
  String get authResetSent =>
      'We\'ve sent a password reset link to your email.';

  @override
  String get passwordEyebrow => 'ACCOUNT RECOVERY';

  @override
  String get passwordTitle => 'Set a new password';

  @override
  String get passwordBody =>
      'Enter a new, secure password for your account. You\'ll use it the next time you sign in.';

  @override
  String get passwordNew => 'New password';

  @override
  String get passwordNewRequired => 'Enter a new password';

  @override
  String get passwordSave => 'Save password';

  @override
  String get passwordUpdated => 'Your password has been updated.';

  @override
  String get authRoleMismatchStudent =>
      'You registered as a student. Please pick the \'Student\' tab.';

  @override
  String get authRoleMismatchTeacher =>
      'You registered as a teacher. Please pick the \'Teacher\' tab.';

  @override
  String get authUsernameTaken =>
      'This username is already taken. Please choose another one.';

  @override
  String get errorServer =>
      'Something went wrong on the server. Please try again in a moment.';

  @override
  String get authResetOtherDevice =>
      'Open the link on the device where you asked to reset your password.';

  @override
  String get authLinkExpired =>
      'The link has expired or was already used. Please request a new one.';

  @override
  String get authEmailExists =>
      'An account with this email already exists. Please sign in.';

  @override
  String get authInvalidCredentials => 'Wrong email or password.';

  @override
  String get authEmailNotConfirmed =>
      'Your email isn\'t confirmed yet. Click the link in your inbox.';

  @override
  String get authWeakPassword =>
      'The password is too simple. Enter a stronger one of at least 6 characters.';

  @override
  String get authSamePassword =>
      'The new password must be different from the old one.';

  @override
  String get authSessionExpired =>
      'Your session has expired. Please request a new reset link.';

  @override
  String get authEmailAddressInvalid =>
      'The email address was entered incorrectly.';

  @override
  String get authRateLimited =>
      'Too many attempts. Please try again in a moment.';

  @override
  String get authSignupDisabled => 'Sign-up is turned off for now.';

  @override
  String get profileUsernameTaken => 'This username is taken.';

  @override
  String get profileNotFound =>
      'Your profile wasn\'t found. Sign out and sign in again.';

  @override
  String get profileUpdateForbidden =>
      'You\'re not allowed to change this profile.';

  @override
  String get save => 'Save';

  @override
  String get editProfileFullName => 'First and last name';

  @override
  String get profileSaved => 'Your changes have been saved';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String lessonTitleWithNumber(int number, String title) {
    return 'Lesson $number: $title';
  }

  @override
  String get lessonTagPracticalTask => 'Practical task';

  @override
  String get lessonTagGrammarRule => 'Grammar rule';

  @override
  String get lessonTagSpeakingTask => 'Speaking task';

  @override
  String get lessonTagWritingTask => 'Writing task';

  @override
  String get lessonAnalyzeAnswer => 'Analyze my answer';

  @override
  String get lessonAnswerHint => 'Write your answer here…';

  @override
  String get lessonAssessWriting => 'Assess my writing';

  @override
  String get lessonWritingHint => 'Write your text here…';

  @override
  String lessonWordCount(int count, int min, int max) {
    return '$count / $min–$max words';
  }

  @override
  String get lessonCefrLenses => 'CEFR lenses';

  @override
  String get lessonCefrLensesCaption =>
      'Your writing is assessed through these levels.';

  @override
  String get lessonLensA1 =>
      'Short, correct sentences using the lesson\'s grammar.';

  @override
  String get lessonLensA2 => 'Link ideas with and, but and because.';

  @override
  String get lessonLensB1 => 'Add details and reasons in clear paragraphs.';

  @override
  String get lessonLensB2 => 'Vary your vocabulary and sentence structure.';

  @override
  String get lessonTranscript => 'Transcript';

  @override
  String get lessonAssessSpeaking => 'Assess speaking';

  @override
  String get lessonSpeakingHint =>
      'Record your answer, or type what you said here…';

  @override
  String get lessonAskAi => 'Ask AI';

  @override
  String micIdle(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Tap the mic and speak (up to $_temp0)';
  }

  @override
  String get micRecording => 'Recording… Tap to stop';

  @override
  String get micTranscribing => 'Transcribing…';

  @override
  String get micStart => 'Start recording';

  @override
  String get micStop => 'Stop recording';

  @override
  String taskMasteryReached(int score) {
    return 'Mastery reached: $score%';
  }

  @override
  String get recordingTitle => 'Your recording';

  @override
  String get recordingPlay => 'Play recording';

  @override
  String get recordingPause => 'Pause recording';

  @override
  String get recordingUnplayable => 'Your recording can\'t be played back.';

  @override
  String get audioRestart => 'Restart';

  @override
  String get audioPlay => 'Play';

  @override
  String get audioPause => 'Pause';

  @override
  String get transcriptShow => 'Show';

  @override
  String get transcriptHide => 'Hide';

  @override
  String quizAnswerAll(int total) {
    return 'Answer all $total questions to check your results.';
  }

  @override
  String quizScore(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get quizReviewHint =>
      'Review the text and try again to improve your score.';

  @override
  String get checkupCooldownError => 'The next level check isn\'t open yet.';

  @override
  String get checkupInvalidAnswers => 'Answer every question and submit again.';

  @override
  String get errorNoResponse => 'The server didn\'t respond. Please try again.';

  @override
  String get recordingEmpty => 'The recorded audio is empty.';

  @override
  String get transcriptionNoSpeech =>
      'We couldn\'t hear you. Speak closer to the microphone and try again.';

  @override
  String get aiEmptyPrompt => 'Write your prompt first.';

  @override
  String get aiBusy => 'The AI is busy right now. Try again in a moment.';

  @override
  String get aiFailed => 'The AI couldn\'t answer. Try again.';

  @override
  String get aiTimeout => 'The AI didn\'t respond. Try again.';

  @override
  String get aiEmptyReply => 'The AI sent an empty reply. Try again.';

  @override
  String get aiUnreadableReply =>
      'The AI\'s reply couldn\'t be read. Try again.';

  @override
  String errorMapIntro(int count) {
    return 'Questions you keep getting wrong in tests. Mistakes repeated at least $count times are shown — tap a card to study the topic again.';
  }

  @override
  String get errorLegendHigh => 'Repeated often (4+)';

  @override
  String get errorLegendMedium => 'Moderate (2–3)';

  @override
  String get errorMapEmptyTitle => 'Great! No recurring mistakes yet';

  @override
  String get errorMapEmptyBody =>
      'If you get the same test question wrong twice, it will show up here.';

  @override
  String errorMapQuestion(String section, int number) {
    return '$section: question $number';
  }

  @override
  String errorMistakeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Missed $count times in recent tests',
      one: 'Missed once in recent tests',
    );
    return '$_temp0';
  }

  @override
  String get errorSeverityHigh => 'high';

  @override
  String get errorSeverityMedium => 'medium';

  @override
  String errorPriority(String level) {
    return 'Priority: $level';
  }

  @override
  String get errorReviewLesson => 'Review the lesson';
}
