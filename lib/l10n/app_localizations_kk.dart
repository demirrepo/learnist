// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get navHome => 'Bas bet';

  @override
  String get navTopics => 'Temalar';

  @override
  String get navAiLab => 'AI Lab';

  @override
  String get navCheckup => 'Tekseriw';

  @override
  String get navProfile => 'Profil';

  @override
  String get navTeacherPanel => 'Panel';

  @override
  String get navTeacherPanelFull => 'Oqıtıwshı paneli';

  @override
  String get sidebarTagline => 'AI oqıw járdemshisi';

  @override
  String get sidebarDefaultUser => 'Learnist paydalanıwshısı';

  @override
  String get roleTeacher => 'Oqıtıwshı';

  @override
  String get roleStudent => 'Student';

  @override
  String get retry => 'Qaytadan urınıw';

  @override
  String get cancel => 'Biykar etiw';

  @override
  String get ok => 'OK';

  @override
  String get notAvailable => '—';

  @override
  String lessonLabel(int number) {
    return '$number-sabaq';
  }

  @override
  String semesterLabel(int number) {
    return '$number-semestr';
  }

  @override
  String get greetingMorning => 'Qayırlı tań';

  @override
  String get greetingAfternoon => 'Qayırlı kún';

  @override
  String get greetingEvening => 'Qayırlı kesh';

  @override
  String get homeWelcomeBack => 'Xosh keldińiz';

  @override
  String homeGreeting(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String homeCefrBadge(String level) {
    return 'CEFR dárejesi: $level';
  }

  @override
  String get homeCefrBadgeUnknown => 'CEFR dárejesi: ele anıqlanbaǵan';

  @override
  String get homeTodaysFocus => 'BÚGINGI MAQSET';

  @override
  String get homeHeadline =>
      'Hár bir qáteni túsingenińizde inglis tilińiz ósip baradı.';

  @override
  String get homeSubtitle => 'Keyingi shınıǵıw menen pátti saqlap qalıń.';

  @override
  String homeContinueLesson(int number) {
    return '$number-sabaqtı dawam ettiriw';
  }

  @override
  String get homeOpenAiLab => 'AI Labtı ashıw';

  @override
  String homeMastery(int percent) {
    return '$percent% ózlestirildi';
  }

  @override
  String get homeLearningSpace => 'Oqıw keńisligi';

  @override
  String get homeSwipe => 'Súyreń';

  @override
  String homeLessonCount(int count) {
    return '$count sabaq';
  }

  @override
  String get homePromptBetter => 'Jaqsıraq prompt';

  @override
  String get homeCefrTest => 'CEFR testi';

  @override
  String get homeSnapshot => 'Nátiyjelerińiz';

  @override
  String get statLessonsMastered => 'Ózlestirilgen sabaqlar';

  @override
  String get statCurrentLesson => 'Házirgi sabaq';

  @override
  String get statCefrEstimate => 'CEFR bahası';

  @override
  String get statTrackedMistakes => 'Baqlanıp atırǵan qáteler';

  @override
  String get lessonMastery => 'Sabaqtı ózlestiriw';

  @override
  String lessonMasterySemantics(String lesson, String percent) {
    return 'Sabaqtı ózlestiriw, $lesson: $percent';
  }

  @override
  String get topicsEyebrow => 'TEMALAR';

  @override
  String get topicsTitle => '52 sabaqlıq jol';

  @override
  String get topicsSemesters =>
      '1-semestr: 1–30-sabaqlar • 2-semestr: 31–52-sabaqlar';

  @override
  String get topicsSearchHint => 'Sabaqlardı izlew';

  @override
  String get topicsNoMatch => 'Izlewińizge sáykes sabaq tabılmadı.';

  @override
  String get topicsEmpty => 'Házirshe sabaqlar tabılmadı.';

  @override
  String get topicLocked => 'Qulıplanǵan';

  @override
  String get topicLockedMessage =>
      'Qulıplanǵan. Bul sabaq aldıńǵı sabaqlardı tamamlaǵannan keyin ashıladı.';

  @override
  String get aiLabEyebrow => 'PROMPT SAWATLÍLÍǴÍ';

  @override
  String get aiLabHeadline => 'Jaqsıraq soraw beriń. Óz betińizshe úyreniń.';

  @override
  String get aiLabIntro =>
      'Prompt — bul AI-ǵa beretuǵın kórsetpeńiz. Anıq prompt jay ǵana kóshirip alınatuǵın emes, al úyreniwge bolatuǵın juwap beredi.';

  @override
  String get aiLabExamplePrompt => 'PROMPT ÚLGISI';

  @override
  String get promptPartRole => 'Rol';

  @override
  String get promptPartTask => 'Wazıypa';

  @override
  String get promptPartLevel => 'Dáreje';

  @override
  String get promptPartContext => 'Kontekst';

  @override
  String get promptPartFormat => 'Format';

  @override
  String get aiCourseTitle => 'AI kursı';

  @override
  String aiCourseSubtitle(int count) {
    return 'Kúshli promptqa $count qısqa qádem.';
  }

  @override
  String get aiStepWhatTitle => 'Prompt degen ne?';

  @override
  String get aiStepWhatBody =>
      'Prompt — AI-ǵa jiberetuǵın xabarıńız. Ol qanshelli anıq bolsa, juwap sonshelli paydalı boladı.';

  @override
  String get aiStepRoleBody =>
      'AI-ǵa kim bolıwı kerekligin aytıń, sonda ol qánigedey juwap beredi.';

  @override
  String get aiStepTaskBody => 'Onnan anıq ne islewin qáleytuǵınıńızdı aytıń.';

  @override
  String get aiStepLevelBody =>
      'Juwap sizge sáykes bolıwı ushın inglis tili dárejeńizdi kórsetiń.';

  @override
  String get aiStepContextBody =>
      'Jaǵdaydı túsindiriń: tekst, soraw hám maqsetińiz.';

  @override
  String get aiStepFormatBody =>
      'Juwap formasın sorań: dizim, keste yamasa qısqa abzac.';

  @override
  String get aiStepExamplesTitle => 'Úlgi hám ton';

  @override
  String get aiStepExamplesBody => 'Úlgi kórsetiń hám kerekli tondı tańlań.';

  @override
  String get promptCheckerTitle => 'Prompt tekseriwi';

  @override
  String get promptCheckerHint => 'Prompt jazıń...';

  @override
  String get promptCheckerButton => 'Promptımdı tekseriw';

  @override
  String get promptCheckerFeedback => 'AI pikiri';

  @override
  String get promptCheckerUnexpected =>
      'Kútilmegen qátelik. Qaytadan urınıp kóriń.';

  @override
  String get comparisonTitle => 'Jaman prompt → jaqsıraq prompt';

  @override
  String get comparisonSubtitle =>
      'Soraw birdey, al juwaplar pútkilley basqasha.';

  @override
  String get comparisonBadNote =>
      'Rol, kontekst hám dáreje joq. AI ne kerekligin shamalawǵa májbúr, sonlıqtan juwap anıq emes shıǵadı.';

  @override
  String get comparisonGoodNote =>
      'Rol + soraw konteksti + dáreje + format. AI sizge qalay járdem beriwdi anıq biledi.';

  @override
  String get checkupEyebrow => 'HAQÍYQÍY DÁREJEŃIZ';

  @override
  String get checkupTitle => 'Dáreje Tekseriwi';

  @override
  String checkupMinutes(int minutes) {
    return '≈ $minutes minut';
  }

  @override
  String checkupQuestionRange(int count) {
    return 'A1 den C2 ge shekem $count soraw';
  }

  @override
  String get checkupLevelRule =>
      'Dárejeńiz — A1 den baslap izbe-iz ótken eń joqarı dárejeńiz.';

  @override
  String get checkupAnswers => 'Juwaplar';

  @override
  String get checkupSubmit => 'Tekseriwdi jiberiw';

  @override
  String checkupAnswerAll(int count) {
    return 'Barlıq $count sorawǵa juwap beriń.';
  }

  @override
  String get checkupNoQuestions => 'Sorawlar ele qosılmaǵan.';

  @override
  String get checkupConfirmTitle => 'Nátiyjeni jiberesiz be?';

  @override
  String checkupConfirmBody(int days) {
    return 'Jibergennen keyin, keyingi tekseriw $days kúnnen soń ashıladı.';
  }

  @override
  String get checkupConfirmSubmit => 'Jiberiw';

  @override
  String checkupResultTitle(String level) {
    return 'Dárejeńiz: $level';
  }

  @override
  String checkupResultBody(int score, int total, int days) {
    return '$score/$total durıs. Keyingi dáreje tekseriwi $days kúnnen soń ashıladı.';
  }

  @override
  String get checkupNextIn => 'Keyingi tekseriwge shekem';

  @override
  String checkupDays(int count) {
    return '$count kún';
  }

  @override
  String get checkupCooldownNote =>
      'Kútiw múddeti nátiyjeńizdi qısqa múddetli shınıǵıw tásirinen qorǵaydı.';

  @override
  String get checkupRetakeUnavailable => 'Házirshe qayta tapsırıwǵa bolmaydı';

  @override
  String get checkupGrowth => 'CEFR ósiwi';

  @override
  String checkupLastChecks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aqırǵı $count tekseriwińiz',
      one: 'Aqırǵı tekseriwińiz',
    );
    return '$_temp0';
  }

  @override
  String checkupLevelsGained(int count) {
    return '+$count dáreje';
  }

  @override
  String get checkupChartEmpty =>
      'Testti tapsırǵannan keyin ósiw grafigi payda boladı';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDefaultName => 'Paydalanıwshı';

  @override
  String get profileDefaultUniversity => 'Student';

  @override
  String profileUniversity(String name) {
    return 'Universitet: $name';
  }

  @override
  String get profileTopicsMastered => 'Úyrenilgen temalar';

  @override
  String get profileAverageResult => 'Ortasha nátiyje';

  @override
  String get profileEdit => 'Ózgertiw';

  @override
  String get profileErrorMap => 'Qáteler kartası';

  @override
  String get profileJoinGroup => 'Toparǵa qosılıw';

  @override
  String get profileLanguage => 'Til';

  @override
  String get profileChooseLanguage => 'Tildi tańlań';

  @override
  String get profileSignOut => 'Sistemadan shıǵıw';

  @override
  String get lessonTabGrammar => 'Grammatika';

  @override
  String get lessonTabReading => 'Oqıw';

  @override
  String get lessonTabListening => 'Tıńlap túsiniw';

  @override
  String get lessonTabWriting => 'Jazıw';

  @override
  String get lessonTabSpeaking => 'Sóylew';

  @override
  String get lessonGeneralRule => 'Ulıwma qaǵıyda';

  @override
  String get lessonNoGrammar => 'Bul sabaqta grammatika qaǵıydaları joq.';

  @override
  String get lessonNoReading => 'Bul sabaqta oqıw shınıǵıwı joq.';

  @override
  String get lessonNoListening => 'Bul sabaqta tıńlap túsiniw shınıǵıwı joq.';

  @override
  String get lessonNoWriting => 'Bul sabaqta jazıw tapsırması joq.';

  @override
  String get lessonNoSpeaking => 'Bul sabaqta sóylew tapsırması joq.';

  @override
  String get lessonVocabulary => 'Sózlik';

  @override
  String get lessonCheckResults => 'Nátiyjeni tekseriw';

  @override
  String get lessonAudioPending =>
      'Bul sabaq ushın audio ele tayarlanbaqta. Házirshe tekstten paydalanıń.';

  @override
  String get lessonAudioError =>
      'Audionı júklep bolmadı. Internet baylanısın tekserip, qaytadan urınıp kóriń.';

  @override
  String get lessonFinish => 'Sabaqtı juwmaqlaw';

  @override
  String get lessonUnlocked => 'Qutlıqlaymız! Jańa sabaq ashıldı';

  @override
  String get lessonSaveScoreError => 'Ball saqlanbadı. Qaytadan urınıp kóriń.';

  @override
  String get taskEmptyAnswer => 'Aldı menen juwabıńızdı jazıń.';

  @override
  String get taskEvaluationError =>
      'Bahalawda qátelik júz berdi. Qaytadan urınıp kóriń.';

  @override
  String get taskMicDenied => 'Dawıs jazıw ushın mikrofonǵa ruqsat beriń.';

  @override
  String get taskMicBlocked =>
      'Mikrofonǵa ruqsat berilmegen. Onı telefon sazlamalarınan qosıń.';

  @override
  String get taskRecordingError =>
      'Dawıs jazıwdı baslap bolmadı. Qaytadan urınıp kóriń.';

  @override
  String get taskTranscriptionError =>
      'Sóylewdi tekstke aylandırıp bolmadı. Qaytadan urınıp kóriń.';

  @override
  String get taskRecordingMissing => 'Jazıp alınǵan audio tabılmadı.';

  @override
  String get errorOffline =>
      'Internet baylanısı joq. Tarmaqtı tekserip, qaytadan urınıp kóriń.';

  @override
  String get lessonNotFound => 'Sabaq tabılmadı.';

  @override
  String get lessonLoadFailed =>
      'Sabaqlardı júklep bolmadı. Azdan soń qaytadan urınıp kóriń.';

  @override
  String get errorGeneric => 'Bir nárse qáte boldı. Qaytadan urınıp kóriń.';

  @override
  String lessonCompleteLowScore(int min) {
    return 'Ortasha ballıńız $min% dan tómen. Keyingi sabaqqa ótiw ushın bólimlerdi jaqsılań.';
  }

  @override
  String lessonCompleteLowScoreWithAverage(int min, int average) {
    return 'Ortasha ballıńız $min% dan tómen (házirgi: $average%). Keyingi sabaqqa ótiw ushın bólimlerdi jaqsılań.';
  }

  @override
  String get lessonCompleteFailed =>
      'Sabaqtı juwmaqlap bolmadı. Qaytadan urınıp kóriń.';

  @override
  String lessonKeyWords(int count) {
    return '$count tiykarǵı sóz';
  }

  @override
  String vocabularyListen(String word) {
    return '«$word» aytılıwın tıńlaw';
  }

  @override
  String get vocabularySpeakError => 'Aytılıwın oynatıp bolmadı.';

  @override
  String get askAiEyebrow => 'KONTEKSTLI ASK AI';

  @override
  String askAiTitle(String section) {
    return '$section boyınsha soraw';
  }

  @override
  String get askAiContextAttached => 'Kontekstińiz álleqashan biriktirilgen:';

  @override
  String askAiHint(int lesson) {
    return 'Mısalı: Sen oqıw boyınsha qánigesen. $lesson-sabaqtıń 4-sorawında men B nı tańladım. Pikirlewimniń ne ushın qáte bolıwı múmkin ekenin túsindir. Durıs juwaptı aytpay eki kórsetpe ber.';
  }

  @override
  String get askAiSubmit => 'Learnist AI dan soraw';

  @override
  String get askAiThinking => 'Learnist AI oylanbaqta…';

  @override
  String get askAiEmptyQuestion => 'Aldı menen sorawıńızdı jazıń.';

  @override
  String get askAiBusy =>
      'Learnist AI házir bánt. Azdan soń qaytadan urınıp kóriń.';

  @override
  String get askAiFailed =>
      'Learnist AI juwap bere almadı. Qaytadan urınıp kóriń.';

  @override
  String get close => 'Jabıw';

  @override
  String get teacherEyebrow => 'KLASS ANALITIKASI';

  @override
  String get teacherWorkspaceEyebrow => 'OQITÍWSHÍ JUMÍS ORNÍ';

  @override
  String get teacherWorkspaceHeadline =>
      'Kim oqıp atırǵanın hám qay jerde qıynalıp atırǵanın kóriń.';

  @override
  String get teacherWorkspaceBody =>
      'Klasslar jaratıń, studentlerdi klass logini hám paroli arqalı jalǵań hám sabaq barısın, CEFR tariyxın hám qaytalanatuǵın qátelik túrlerin baqlań.';

  @override
  String get teacherCreateGroup => 'Topar jaratıw';

  @override
  String get teacherConnectedStudents => 'JALǴANǴAN STUDENTLER';

  @override
  String teacherConnectedStudentCount(int count) {
    return '$count jalǵanǵan student';
  }

  @override
  String teacherGroupCount(int count) {
    return '$count topar';
  }

  @override
  String teacherStudentCount(int count) {
    return '$count student';
  }

  @override
  String get teacherClassOverview => 'Klass kórsetkishleri';

  @override
  String get teacherStudentsActive => 'Aktiv studentler';

  @override
  String get teacherAverageMastery => 'Ortasha ózlestiriw';

  @override
  String get teacherGroups => 'Toparlar';

  @override
  String get teacherGroupsAndStudents => 'Toparlar hám studentler';

  @override
  String get teacherNoGroups =>
      'Ele toparlar joq. Studentlerdi jalǵaw ushın topar jaratıń.';

  @override
  String get teacherNoStudents => 'Ele studentler jalǵanbaǵan.';

  @override
  String get groupClassLogin => 'Klass logini';

  @override
  String get teacherPasswordInline => 'parol';

  @override
  String get teacherColumnStudent => 'STUDENT';

  @override
  String get teacherColumnCurrentLesson => 'HÁZIRGI SABAQ';

  @override
  String get teacherColumnMastery => 'ÓZLESTIRIW';

  @override
  String get teacherColumnAction => 'HÁREKET';

  @override
  String teacherLessonShort(int number) {
    return '$number';
  }

  @override
  String get teacherChipLesson => 'Sabaq';

  @override
  String get teacherChipMastery => 'Ózlestiriw';

  @override
  String get teacherView => 'Kóriw';

  @override
  String teacherGroupCreated(String name) {
    return '«$name» toparı jaratıldı.';
  }

  @override
  String get teacherGroupName => 'Topar atı';

  @override
  String get teacherLoginHelper => '3–32 belgi: A–Z, 0–9, _ yamasa -';

  @override
  String get groupPassword => 'Parol';

  @override
  String get teacherGroupNameRequired => 'Topar atın kiritiń.';

  @override
  String get teacherLoginInvalid => 'Login 3–32 hárip, san, _ yamasa - bolsın.';

  @override
  String get teacherPasswordInvalid => 'Parol 4–64 belgiden ibarat bolsın.';

  @override
  String get teacherCreate => 'Jaratıw';

  @override
  String get teacherLoginTaken => 'Bul login bánt. Basqa login tańlań.';

  @override
  String get teacherCreateGroupFailed =>
      'Topar jaratılmadı. Qaytadan urınıp kóriń.';

  @override
  String get teacherLoadFailed =>
      'Maǵlıwmatlardı júklep bolmadı. Qaytadan urınıp kóriń.';

  @override
  String get teacherStudentDetail => 'STUDENT MAǴLÍWMATLARÍ';

  @override
  String teacherCurrentLesson(int number) {
    return 'házirgi sabaq: $number';
  }

  @override
  String get teacherLessonProgress => 'Sabaqlar boyınsha nátiyjeler';

  @override
  String teacherLessonInProgress(String title) {
    return '$title • orınlanıp atır';
  }

  @override
  String get teacherNoLessonsStarted => 'Ele hesh bir sabaq baslanbaǵan.';

  @override
  String get joinGroupIntro => 'Oqıtıwshıńız bergen login hám paroldi kiritiń.';

  @override
  String get joinGroupFieldRequired => 'Maydandı toltırıń.';

  @override
  String get joinGroupSubmit => 'Qosılıw';

  @override
  String joinGroupJoined(String name) {
    return '«$name» toparına qosıldıńız.';
  }

  @override
  String joinGroupAlreadyMember(String name) {
    return 'Siz álleqashan «$name» toparındasız.';
  }

  @override
  String get joinGroupInvalidCredentials => 'Login yamasa parol qáte.';

  @override
  String get joinGroupOwnGroup => 'Ózińiz jaratqan toparǵa qosıla almaysız.';

  @override
  String get joinGroupFailed =>
      'Toparǵa qosılıw múmkin bolmadı. Qaytadan urınıp kóriń.';

  @override
  String get authEyebrowSignUp => 'INGLIS TILI SAYAXATÍŃÍZDÍ BASLAŃ';

  @override
  String get authEyebrowSignIn => 'QAYTÍP KELGENIŃIZGE QUWANÍSHLÍMÍZ';

  @override
  String get authTitleSignUp => 'Akkaunt jaratıń';

  @override
  String get authTitleSignIn => 'Learnist\'ke kiriń';

  @override
  String get authSubtitleSignUp =>
      'CEFR sertifikatına tayarlanıp atırǵan mıńlaǵan studentlerge qosılıń.';

  @override
  String get authSubtitleSignIn => 'Toqtaǵan jerińizden dawam etiń.';

  @override
  String get authSignIn => 'Kiriw';

  @override
  String get authSignUp => 'Dizimnen ótiw';

  @override
  String get authCreateAccount => 'Akkaunt jaratıw';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailRequired => 'Emailińizdi kiritiń';

  @override
  String get authEmailInvalid => 'Email mánzili qáte';

  @override
  String get authPassword => 'Parol';

  @override
  String get authPasswordHint => 'Parolıńız';

  @override
  String get authPasswordHintNew => 'Keminde 6 belgi';

  @override
  String get authShowPassword => 'Paroldi kórsetiw';

  @override
  String get authHidePassword => 'Paroldi jasırıw';

  @override
  String get authPasswordRequired => 'Paroldi kiritiń';

  @override
  String get authPasswordTooShort => 'Parol keminde 6 belgiden ibarat bolsın';

  @override
  String get authForgotPassword => 'Paroldi umıttıńız ba?';

  @override
  String get authFullName => 'Tolıq atı';

  @override
  String get authFullNameHint => 'Tolıq atıńız';

  @override
  String get authFullNameRequired => 'Tolıq atıńızdı kiritiń';

  @override
  String get authUsername => 'Paydalanıwshı atı';

  @override
  String get authUsernameHint => 'mısalı, learner_01';

  @override
  String get authUsernameInvalid => '3–30 belgi: háripler, sanlar, _ yamasa .';

  @override
  String get authUniversity => 'Universitet';

  @override
  String get authUniversityHint => 'Universitetińizdi izleń';

  @override
  String get authUniversityRequired => 'Universitetińizdi tańlań';

  @override
  String get authOtherUniversity => 'Basqa';

  @override
  String get authUniversityName => 'Universitet atı';

  @override
  String get authUniversityNameHint => 'Universitetińiz atın jazıń';

  @override
  String get authUniversityNameRequired => 'Universitet atın kiritiń';

  @override
  String get authHaveAccount => 'Akkauntıńız bar ma?';

  @override
  String get authNewToLearnist => 'Learnist\'te jańasız ba?';

  @override
  String get authSignInInstead => 'Sistemaǵa kiriw';

  @override
  String get authCreateAnAccount => 'Akkaunt jaratıw';

  @override
  String get authConfirmEmailSent =>
      'Tastıyıqlaw siltemesi emailińizge jiberildi. Onı basıp, keyin sistemaǵa kiriń.';

  @override
  String get authResetTitle => 'Paroldi tiklew';

  @override
  String get authResetBody =>
      'Akkauntıńızǵa baylanǵan emaildi kiritiń — paroldi tiklew siltemesin jiberemiz.';

  @override
  String get authResetSend => 'Siltemeni jiberiw';

  @override
  String get authResetSent => 'Paroldi tiklew siltemesi pochtańızǵa jiberildi.';

  @override
  String get passwordEyebrow => 'AKKAUNTTÍ TIKLEW';

  @override
  String get passwordTitle => 'Jańa parol ornatıń';

  @override
  String get passwordBody =>
      'Akkauntıńız ushın jańa hám qáwipsiz parol kiritiń. Keyingi ret usı parol menen kiresiz.';

  @override
  String get passwordNew => 'Jańa parol';

  @override
  String get passwordNewRequired => 'Jańa paroldi kiritiń';

  @override
  String get passwordSave => 'Paroldi saqlaw';

  @override
  String get passwordUpdated => 'Parolıńız tabıslı jańalandı.';

  @override
  String get authRoleMismatchStudent =>
      'Siz student retinde dizimnen ótkensiz. \'Student\' bólimin tańlań.';

  @override
  String get authRoleMismatchTeacher =>
      'Siz oqıtıwshı retinde dizimnen ótkensiz. \'Oqıtıwshı\' bólimin tańlań.';

  @override
  String get authUsernameTaken =>
      'Bul paydalanıwshı atı álleqashan bánt. Basqa at tańlań.';

  @override
  String get errorServer =>
      'Serverde qátelik júz berdi. Biraz waqıttan soń qaytadan urınıp kóriń.';

  @override
  String get authResetOtherDevice =>
      'Siltemeni paroldi tiklewdi soraǵan qurılmada ashıń.';

  @override
  String get authLinkExpired =>
      'Silteme eskirgen yamasa álleqashan qollanılǵan. Jańa silteme sorań.';

  @override
  String get authEmailExists =>
      'Bul email menen álleqashan dizimnen ótilgen. Sistemaǵa kiriń.';

  @override
  String get authInvalidCredentials => 'Email yamasa parol qáte.';

  @override
  String get authEmailNotConfirmed =>
      'Emailińiz ele tastıyıqlanbaǵan. Pochtańızdaǵı siltemeni basıń.';

  @override
  String get authWeakPassword =>
      'Parol júdá ápiwayı. Keminde 6 belgiden ibarat kúshlirek parol kiritiń.';

  @override
  String get authSamePassword => 'Jańa parol eskisinen parıq qılıwı kerek.';

  @override
  String get authSessionExpired =>
      'Sessiya múddeti tawsılǵan. Jańa tiklew siltemesin sorań.';

  @override
  String get authEmailAddressInvalid => 'Email mánzili qáte kiritilgen.';

  @override
  String get authRateLimited =>
      'Júdá kóp urınıw boldı. Biraz waqıttan soń qaytadan urınıp kóriń.';

  @override
  String get authSignupDisabled => 'Dizimnen ótiw házirshe óshirilgen.';

  @override
  String get profileUsernameTaken => 'Bul paydalanıwshı atı bánt.';

  @override
  String get profileNotFound =>
      'Profilińiz tabılmadı. Sistemadan shıǵıp, qayta kiriń.';

  @override
  String get profileUpdateForbidden => 'Profildi ózgertiwge ruqsat joq.';

  @override
  String get save => 'Saqlaw';

  @override
  String get editProfileFullName => 'Atı hám familiyası';

  @override
  String get profileSaved => 'Ózgerisler tabıslı saqlandı';

  @override
  String get editProfileTitle => 'Profildi ózgertiw';

  @override
  String lessonTitleWithNumber(int number, String title) {
    return '$number-sabaq: $title';
  }

  @override
  String get lessonTagPracticalTask => 'Ámeliy tapsırma';

  @override
  String get lessonTagGrammarRule => 'Grammatika qaǵıydası';

  @override
  String get lessonTagSpeakingTask => 'Sóylew tapsırması';

  @override
  String get lessonTagWritingTask => 'Jazıw tapsırması';

  @override
  String get lessonAnalyzeAnswer => 'Juwabımdı talqılaw';

  @override
  String get lessonAnswerHint => 'Juwabıńızdı usı jerge jazıń…';

  @override
  String get lessonAssessWriting => 'Jazǵanımdı bahalaw';

  @override
  String get lessonWritingHint => 'Tekstińizdi usı jerge jazıń…';

  @override
  String lessonWordCount(int count, int min, int max) {
    return '$count / $min–$max sóz';
  }

  @override
  String get lessonCefrLenses => 'CEFR ólshemleri';

  @override
  String get lessonCefrLensesCaption =>
      'Jazǵanıńız usı dárejeler boyınsha bahalanadı.';

  @override
  String get lessonLensA1 =>
      'Sabaqtaǵı grammatikanı qollanǵan qısqa, durıs gápler.';

  @override
  String get lessonLensA2 =>
      'Pikirlerdi and, but hám because penen baylanıstırıń.';

  @override
  String get lessonLensB1 =>
      'Anıq abzaclarda tolıq maǵlıwmat hám sebeplerdi keltiriń.';

  @override
  String get lessonLensB2 => 'Sóz baylıǵı hám gáp dúzilisin túrlendiriń.';

  @override
  String get lessonTranscript => 'Tekst';

  @override
  String get lessonAssessSpeaking => 'Sóylewdi bahalaw';

  @override
  String get lessonSpeakingHint =>
      'Juwabıńızdı jazıp alıń yamasa aytqanıńızdı usı jerge jazıń…';

  @override
  String get lessonAskAi => 'AI\'dan soraw';

  @override
  String micIdle(int minutes) {
    return 'Mikrofondı basıp sóyleń (eń kóbi $minutes minut)';
  }

  @override
  String get micRecording => 'Jazılıp atır… Toqtatıw ushın basıń';

  @override
  String get micTranscribing => 'Tekstke aylandırılıp atır…';

  @override
  String get micStart => 'Jazıwdı baslaw';

  @override
  String get micStop => 'Jazıwdı toqtatıw';

  @override
  String taskMasteryReached(int score) {
    return 'Ózlestiriw dárejesi: $score%';
  }

  @override
  String get recordingTitle => 'Sizdiń jazbańız';

  @override
  String get recordingPlay => 'Jazbanı tıńlaw';

  @override
  String get recordingPause => 'Jazbanı toqtatıp turıw';

  @override
  String get recordingUnplayable => 'Jazbańızdı oynatıw múmkin bolmadı.';

  @override
  String get audioRestart => 'Basınan';

  @override
  String get audioPlay => 'Oynatıw';

  @override
  String get audioPause => 'Pauza';

  @override
  String get transcriptShow => 'Kórsetiw';

  @override
  String get transcriptHide => 'Jasırıw';

  @override
  String quizAnswerAll(int total) {
    return 'Nátiyjeni tekseriw ushın barlıq $total sorawǵa juwap beriń.';
  }

  @override
  String quizScore(int correct, int total) {
    return '$correct/$total durıs';
  }

  @override
  String get quizReviewHint =>
      'Nátiyjeńizdi jaqsılaw ushın tekstti qayta qarap shıǵıń hám jáne urınıp kóriń.';

  @override
  String get checkupCooldownError => 'Keyingi dáreje tekseriwi ele ashılmaǵan.';

  @override
  String get checkupInvalidAnswers =>
      'Barlıq sorawlarǵa juwap berip, qayta jiberiń.';

  @override
  String get errorNoResponse => 'Server juwap bermedi. Qaytadan urınıp kóriń.';

  @override
  String get recordingEmpty => 'Jazıp alınǵan audio bos.';

  @override
  String get transcriptionNoSpeech =>
      'Dawısıńız anıqlanbadı. Mikrofonǵa jaqınıraq sóylep, qaytadan urınıp kóriń.';

  @override
  String get aiEmptyPrompt => 'Aldın promptıńızdı jazıń.';

  @override
  String get aiBusy =>
      'AI házir bánt. Biraz waqıttan soń qaytadan urınıp kóriń.';

  @override
  String get aiFailed => 'AI juwap bere almadı. Qaytadan urınıp kóriń.';

  @override
  String get aiTimeout => 'AI juwap bermedi. Qaytadan urınıp kóriń.';

  @override
  String get aiEmptyReply => 'AI bos juwap qaytardı. Qaytadan urınıp kóriń.';

  @override
  String get aiUnreadableReply =>
      'AI juwabın oqıp bolmadı. Qaytadan urınıp kóriń.';

  @override
  String errorMapIntro(int count) {
    return 'Testlerde qayta-qayta qáte qılıp atırǵan sorawlarıńız. Keminde $count ret qaytalanǵan qáteler kórsetiledi — temanı qayta úyreniw ushın kartanı basıń.';
  }

  @override
  String get errorLegendHigh => 'Kóp qaytalanǵan (4+)';

  @override
  String get errorLegendMedium => 'Ortasha (2–3)';

  @override
  String get errorMapEmptyTitle => 'Ájayıp! Házirshe qaytalanǵan qáteler joq';

  @override
  String get errorMapEmptyBody =>
      'Testlerde bir sorawda eki ret qáte qılsańız, ol usı jerde payda boladı.';

  @override
  String errorMapQuestion(String section, int number) {
    return '$section: $number-soraw';
  }

  @override
  String errorMistakeCount(int count) {
    return 'Sońǵı testlerde $count ret qáte qılınǵan';
  }

  @override
  String get errorSeverityHigh => 'joqarı';

  @override
  String get errorSeverityMedium => 'orta';

  @override
  String errorPriority(String level) {
    return 'Ústinlik: $level';
  }

  @override
  String get errorReviewLesson => 'Sabaqtı qaytalaw';
}
