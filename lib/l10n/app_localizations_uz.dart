// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navTopics => 'Mavzular';

  @override
  String get navAiLab => 'AI Lab';

  @override
  String get navCheckup => 'Tekshiruv';

  @override
  String get navProfile => 'Profil';

  @override
  String get navTeacherPanel => 'Panel';

  @override
  String get navTeacherPanelFull => 'O\'qituvchi paneli';

  @override
  String get sidebarTagline => 'AI o\'quv hamrohi';

  @override
  String get sidebarDefaultUser => 'Learnist foydalanuvchisi';

  @override
  String get roleTeacher => 'O\'qituvchi';

  @override
  String get roleStudent => 'Talaba';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get ok => 'OK';

  @override
  String get notAvailable => '—';

  @override
  String lessonLabel(int number) {
    return '$number-dars';
  }

  @override
  String semesterLabel(int number) {
    return '$number-semestr';
  }

  @override
  String get greetingMorning => 'Xayrli tong';

  @override
  String get greetingAfternoon => 'Xayrli kun';

  @override
  String get greetingEvening => 'Xayrli kech';

  @override
  String get homeWelcomeBack => 'Xush kelibsiz';

  @override
  String homeGreeting(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String homeCefrBadge(String level) {
    return 'CEFR daraja: $level';
  }

  @override
  String get homeCefrBadgeUnknown => 'CEFR daraja: hali aniqlanmagan';

  @override
  String get homeTodaysFocus => 'BUGUNGI MAQSAD';

  @override
  String get homeHeadline =>
      'Har bir xatoni tushunganingizda ingliz tilingiz o\'sib boradi.';

  @override
  String get homeSubtitle =>
      'Keyingi mashg\'ulot bilan sur\'atni saqlab qoling.';

  @override
  String homeContinueLesson(int number) {
    return '$number-darsni davom ettirish';
  }

  @override
  String get homeOpenAiLab => 'AI Labni ochish';

  @override
  String homeMastery(int percent) {
    return '$percent% o\'zlashtirildi';
  }

  @override
  String get homeLearningSpace => 'O\'quv maydoni';

  @override
  String get homeSwipe => 'Suring';

  @override
  String homeLessonCount(int count) {
    return '$count ta dars';
  }

  @override
  String get homePromptBetter => 'Yaxshiroq prompt';

  @override
  String get homeCefrTest => 'CEFR testi';

  @override
  String get homeSnapshot => 'Natijalaringiz';

  @override
  String get statLessonsMastered => 'O\'zlashtirilgan darslar';

  @override
  String get statCurrentLesson => 'Joriy dars';

  @override
  String get statCefrEstimate => 'CEFR bahosi';

  @override
  String get statTrackedMistakes => 'Kuzatilayotgan xatolar';

  @override
  String get lessonMastery => 'Darsni o\'zlashtirish';

  @override
  String lessonMasterySemantics(String lesson, String percent) {
    return 'Darsni o\'zlashtirish, $lesson: $percent';
  }

  @override
  String get topicsEyebrow => 'MAVZULAR';

  @override
  String get topicsTitle => '52 darslik yo\'l';

  @override
  String get topicsSemesters =>
      '1-semestr: 1–30-darslar • 2-semestr: 31–52-darslar';

  @override
  String get topicsSearchHint => 'Darslarni qidirish';

  @override
  String get topicsNoMatch => 'Qidiruvingizga mos dars topilmadi.';

  @override
  String get topicsEmpty => 'Hozircha darslar topilmadi.';

  @override
  String get topicLocked => 'Qulflangan';

  @override
  String get topicLockedMessage =>
      'Qulflangan. Bu dars oldingi darslarni tugatgach ochiladi.';

  @override
  String get aiLabEyebrow => 'PROMPT SAVODXONLIGI';

  @override
  String get aiLabHeadline => 'Yaxshiroq savol bering. Mustaqilroq o\'rganing.';

  @override
  String get aiLabIntro =>
      'Prompt — bu AIga beradigan ko\'rsatmangiz. Aniq prompt shunchaki ko\'chirib olinadigan emas, balki o\'rganish mumkin bo\'lgan javob beradi.';

  @override
  String get aiLabExamplePrompt => 'PROMPT NAMUNASI';

  @override
  String get promptPartRole => 'Rol';

  @override
  String get promptPartTask => 'Vazifa';

  @override
  String get promptPartLevel => 'Daraja';

  @override
  String get promptPartContext => 'Kontekst';

  @override
  String get promptPartFormat => 'Format';

  @override
  String get aiCourseTitle => 'AI kursi';

  @override
  String aiCourseSubtitle(int count) {
    return 'Kuchli promptga $count ta qisqa qadam.';
  }

  @override
  String get aiStepWhatTitle => 'Prompt nima?';

  @override
  String get aiStepWhatBody =>
      'Prompt — AIga yuboradigan xabaringiz. U qanchalik aniq bo\'lsa, javob shunchalik foydali bo\'ladi.';

  @override
  String get aiStepRoleBody =>
      'AIga kim bo\'lishini ayting, shunda u mutaxassisdek javob beradi.';

  @override
  String get aiStepTaskBody =>
      'Undan aynan nima qilishini xohlayotganingizni ayting.';

  @override
  String get aiStepLevelBody =>
      'Javob sizga mos bo\'lishi uchun ingliz tili darajangizni ko\'rsating.';

  @override
  String get aiStepContextBody =>
      'Vaziyatni tushuntiring: matn, savol va maqsadingiz.';

  @override
  String get aiStepFormatBody =>
      'Javob shaklini so\'rang: ro\'yxat, jadval yoki qisqa paragraf.';

  @override
  String get aiStepExamplesTitle => 'Namuna va ohang';

  @override
  String get aiStepExamplesBody =>
      'Namuna ko\'rsating va kerakli ohangni tanlang.';

  @override
  String get promptCheckerTitle => 'Prompt tekshiruvi';

  @override
  String get promptCheckerHint => 'Prompt yozing...';

  @override
  String get promptCheckerButton => 'Promptimni tekshirish';

  @override
  String get promptCheckerFeedback => 'AI fikri';

  @override
  String get promptCheckerUnexpected =>
      'Kutilmagan xatolik. Qaytadan urinib ko\'ring.';

  @override
  String get comparisonTitle => 'Yomon prompt → yaxshiroq prompt';

  @override
  String get comparisonSubtitle =>
      'Savol bir xil, javoblar esa butunlay boshqa.';

  @override
  String get comparisonBadNote =>
      'Rol, kontekst va daraja yo\'q. AI nima kerakligini taxmin qilishga majbur, shuning uchun javob noaniq chiqadi.';

  @override
  String get comparisonGoodNote =>
      'Rol + savol konteksti + daraja + format. AI sizga qanday yordam berishni aniq biladi.';

  @override
  String get checkupEyebrow => 'HAQIQIY DARAJANGIZ';

  @override
  String get checkupTitle => 'Daraja Tekshiruvi';

  @override
  String checkupMinutes(int minutes) {
    return '≈ $minutes daqiqa';
  }

  @override
  String checkupQuestionRange(int count) {
    return 'A1 dan C2 gacha $count ta savol';
  }

  @override
  String get checkupLevelRule =>
      'Darajangiz — A1 dan boshlab ketma-ket o\'tgan eng yuqori darajangiz.';

  @override
  String get checkupAnswers => 'Javoblar';

  @override
  String get checkupSubmit => 'Tekshiruvni yuborish';

  @override
  String checkupAnswerAll(int count) {
    return 'Barcha $count ta savolga javob bering.';
  }

  @override
  String get checkupNoQuestions => 'Savollar hali qo\'shilmagan.';

  @override
  String get checkupConfirmTitle => 'Natijani yuborasizmi?';

  @override
  String checkupConfirmBody(int days) {
    return 'Yuborgach, keyingi tekshiruv $days kundan so\'ng ochiladi.';
  }

  @override
  String get checkupConfirmSubmit => 'Yuborish';

  @override
  String checkupResultTitle(String level) {
    return 'Darajangiz: $level';
  }

  @override
  String checkupResultBody(int score, int total, int days) {
    return '$score/$total to\'g\'ri. Keyingi daraja tekshiruvi $days kundan so\'ng ochiladi.';
  }

  @override
  String get checkupNextIn => 'Keyingi tekshiruvgacha';

  @override
  String checkupDays(int count) {
    return '$count kun';
  }

  @override
  String get checkupCooldownNote =>
      'Kutish muddati natijangizni qisqa muddatli mashq ta\'siridan himoya qiladi.';

  @override
  String get checkupRetakeUnavailable => 'Hozircha qayta topshirib bo\'lmaydi';

  @override
  String get checkupGrowth => 'CEFR o\'sishi';

  @override
  String checkupLastChecks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Oxirgi $count ta tekshiruvingiz',
      one: 'Oxirgi tekshiruvingiz',
    );
    return '$_temp0';
  }

  @override
  String checkupLevelsGained(int count) {
    return '+$count daraja';
  }

  @override
  String get checkupChartEmpty =>
      'Testni yechgach o\'sish grafigi paydo bo\'ladi';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDefaultName => 'Foydalanuvchi';

  @override
  String get profileDefaultUniversity => 'Talaba';

  @override
  String profileUniversity(String name) {
    return 'Universitet: $name';
  }

  @override
  String get profileTopicsMastered => 'O\'rganilgan mavzular';

  @override
  String get profileAverageResult => 'O\'rtacha natija';

  @override
  String get profileEdit => 'Tahrirlash';

  @override
  String get profileErrorMap => 'Xatolar xaritasi';

  @override
  String get profileJoinGroup => 'Guruhga qo\'shilish';

  @override
  String get profileLanguage => 'Til';

  @override
  String get profileChooseLanguage => 'Tilni tanlang';

  @override
  String get profileSignOut => 'Tizimdan chiqish';
}
