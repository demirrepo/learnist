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
}
