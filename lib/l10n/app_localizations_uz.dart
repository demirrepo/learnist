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

  @override
  String get lessonTabGrammar => 'Grammatika';

  @override
  String get lessonTabReading => 'O\'qish';

  @override
  String get lessonTabListening => 'Tinglab tushunish';

  @override
  String get lessonTabWriting => 'Yozish';

  @override
  String get lessonTabSpeaking => 'Gapirish';

  @override
  String get lessonGeneralRule => 'Umumiy qoida';

  @override
  String get lessonNoGrammar => 'Ushbu darsda grammatika qoidalari yo\'q.';

  @override
  String get lessonNoReading => 'Ushbu darsda o\'qish mashqi yo\'q.';

  @override
  String get lessonNoListening =>
      'Ushbu darsda tinglab tushunish mashqi yo\'q.';

  @override
  String get lessonNoWriting => 'Ushbu darsda yozish mashqi yo\'q.';

  @override
  String get lessonNoSpeaking => 'Ushbu darsda gapirish mashqi yo\'q.';

  @override
  String get lessonVocabulary => 'Lug\'at';

  @override
  String get lessonCheckResults => 'Natijani tekshirish';

  @override
  String get lessonAudioPending =>
      'Bu dars uchun audio hali tayyorlanmoqda. Hozircha matndan foydalaning.';

  @override
  String get lessonAudioError =>
      'Audioni yuklab bo\'lmadi. Internet aloqasini tekshirib, qayta urinib ko\'ring.';

  @override
  String get lessonFinish => 'Darsni yakunlash';

  @override
  String get lessonUnlocked => 'Tabriklaymiz! Yangi dars ochildi';

  @override
  String get lessonSaveScoreError =>
      'Ball saqlanmadi. Iltimos qayta urinib ko\'ring.';

  @override
  String get taskEmptyAnswer => 'Avval javobingizni yozing.';

  @override
  String get taskEvaluationError =>
      'Baholashda xatolik yuz berdi. Iltimos qayta urinib ko\'ring.';

  @override
  String get taskMicDenied => 'Ovoz yozish uchun mikrofonga ruxsat bering.';

  @override
  String get taskMicBlocked =>
      'Mikrofonga ruxsat berilmagan. Uni telefon sozlamalaridan yoqing.';

  @override
  String get taskRecordingError =>
      'Ovoz yozishni boshlab bo\'lmadi. Iltimos qayta urinib ko\'ring.';

  @override
  String get taskTranscriptionError =>
      'Nutqni matnga aylantirib bo\'lmadi. Iltimos qayta urinib ko\'ring.';

  @override
  String get taskRecordingMissing => 'Yozib olingan audio topilmadi.';

  @override
  String get errorOffline =>
      'Internet aloqasi yo\'q. Tarmoqni tekshirib, qayta urinib ko\'ring.';

  @override
  String get lessonNotFound => 'Dars topilmadi.';

  @override
  String get lessonLoadFailed =>
      'Darslarni yuklab bo\'lmadi. Birozdan so\'ng qayta urinib ko\'ring.';

  @override
  String get errorGeneric =>
      'Nimadir xato ketdi. Iltimos, qayta urinib ko\'ring.';

  @override
  String lessonCompleteLowScore(int min) {
    return 'O\'rtacha ballingiz $min% dan past. Keyingi darsga o\'tish uchun bo\'limlarni yaxshilang.';
  }

  @override
  String lessonCompleteLowScoreWithAverage(int min, int average) {
    return 'O\'rtacha ballingiz $min% dan past (hozirgi: $average%). Keyingi darsga o\'tish uchun bo\'limlarni yaxshilang.';
  }

  @override
  String get lessonCompleteFailed =>
      'Darsni yakunlab bo\'lmadi. Iltimos, qayta urinib ko\'ring.';

  @override
  String lessonKeyWords(int count) {
    return '$count ta kalit so\'z';
  }

  @override
  String vocabularyListen(String word) {
    return '«$word» talaffuzini tinglash';
  }

  @override
  String get vocabularySpeakError => 'Talaffuzni ijro etib bo\'lmadi.';

  @override
  String get askAiEyebrow => 'KONTEKSTLI ASK AI';

  @override
  String askAiTitle(String section) {
    return '$section bo\'yicha savol';
  }

  @override
  String get askAiContextAttached => 'Kontekstingiz allaqachon biriktirilgan:';

  @override
  String askAiHint(int lesson) {
    return 'Masalan: Sen o\'qish bo\'yicha mutaxassissan. $lesson-darsning 4-savolida men B ni tanladim. Fikrlashim nega noto\'g\'ri bo\'lishi mumkinligini tushuntir. To\'g\'ri javobni aytmasdan ikkita maslahat ber.';
  }

  @override
  String get askAiSubmit => 'Learnist AI\'dan so\'rash';

  @override
  String get askAiThinking => 'Learnist AI o\'ylamoqda…';

  @override
  String get askAiEmptyQuestion => 'Avval savolingizni yozing.';

  @override
  String get askAiBusy =>
      'Learnist AI hozir band. Birozdan so\'ng qayta urinib ko\'ring.';

  @override
  String get askAiFailed =>
      'Learnist AI javob bera olmadi. Qayta urinib ko\'ring.';

  @override
  String get close => 'Yopish';

  @override
  String get teacherEyebrow => 'SINF TAHLILI';

  @override
  String get teacherWorkspaceEyebrow => 'O\'QITUVCHI ISH MAYDONI';

  @override
  String get teacherWorkspaceHeadline =>
      'Kim o\'qiyotganini va qayerda qiynalayotganini ko\'ring.';

  @override
  String get teacherWorkspaceBody =>
      'Sinflar yarating, talabalarni sinf logini va paroli orqali ulang hamda dars jarayoni, CEFR tarixi va takrorlanuvchi xato turlarini kuzating.';

  @override
  String get teacherCreateGroup => 'Guruh yaratish';

  @override
  String get teacherConnectedStudents => 'ULANGAN TALABALAR';

  @override
  String teacherConnectedStudentCount(int count) {
    return '$count ta ulangan talaba';
  }

  @override
  String teacherGroupCount(int count) {
    return '$count ta guruh';
  }

  @override
  String teacherStudentCount(int count) {
    return '$count ta talaba';
  }

  @override
  String get teacherClassOverview => 'Sinf ko\'rsatkichlari';

  @override
  String get teacherStudentsActive => 'Faol talabalar';

  @override
  String get teacherAverageMastery => 'O\'rtacha o\'zlashtirish';

  @override
  String get teacherGroups => 'Guruhlar';

  @override
  String get teacherGroupsAndStudents => 'Guruhlar va talabalar';

  @override
  String get teacherNoGroups =>
      'Hali guruhlar yo\'q. Talabalarni ulash uchun guruh yarating.';

  @override
  String get teacherNoStudents => 'Hali talabalar ulanmagan.';

  @override
  String get groupClassLogin => 'Sinf logini';

  @override
  String get teacherPasswordInline => 'parol';

  @override
  String get teacherColumnStudent => 'TALABA';

  @override
  String get teacherColumnCurrentLesson => 'JORIY DARS';

  @override
  String get teacherColumnMastery => 'O\'ZLASHTIRISH';

  @override
  String get teacherColumnAction => 'AMAL';

  @override
  String teacherLessonShort(int number) {
    return '$number';
  }

  @override
  String get teacherChipLesson => 'Dars';

  @override
  String get teacherChipMastery => 'O\'zlashtirish';

  @override
  String get teacherView => 'Ko\'rish';

  @override
  String teacherGroupCreated(String name) {
    return '«$name» guruhi yaratildi.';
  }

  @override
  String get teacherGroupName => 'Guruh nomi';

  @override
  String get teacherLoginHelper => '3–32 ta belgi: A–Z, 0–9, _ yoki -';

  @override
  String get groupPassword => 'Parol';

  @override
  String get teacherGroupNameRequired => 'Guruh nomini kiriting.';

  @override
  String get teacherLoginInvalid =>
      'Login 3–32 ta harf, raqam, _ yoki - bo\'lsin.';

  @override
  String get teacherPasswordInvalid =>
      'Parol 4–64 ta belgidan iborat bo\'lsin.';

  @override
  String get teacherCreate => 'Yaratish';

  @override
  String get teacherLoginTaken =>
      'Bu login band. Iltimos, boshqa login tanlang.';

  @override
  String get teacherCreateGroupFailed =>
      'Guruh yaratilmadi. Iltimos, qayta urinib ko\'ring.';

  @override
  String get teacherLoadFailed =>
      'Ma\'lumotlarni yuklab bo\'lmadi. Iltimos, qayta urinib ko\'ring.';

  @override
  String get teacherStudentDetail => 'TALABA MA\'LUMOTLARI';

  @override
  String teacherCurrentLesson(int number) {
    return 'joriy dars: $number';
  }

  @override
  String get teacherLessonProgress => 'Darslar bo\'yicha natijalar';

  @override
  String teacherLessonInProgress(String title) {
    return '$title • jarayonda';
  }

  @override
  String get teacherNoLessonsStarted => 'Hali birorta dars boshlanmagan.';

  @override
  String get joinGroupIntro =>
      'O\'qituvchingiz bergan login va parolni kiriting.';

  @override
  String get joinGroupFieldRequired => 'Maydonni to\'ldiring.';

  @override
  String get joinGroupSubmit => 'Qo\'shilish';

  @override
  String joinGroupJoined(String name) {
    return '«$name» guruhiga qo\'shildingiz.';
  }

  @override
  String joinGroupAlreadyMember(String name) {
    return 'Siz allaqachon «$name» guruhidasiz.';
  }

  @override
  String get joinGroupInvalidCredentials => 'Login yoki parol noto\'g\'ri.';

  @override
  String get joinGroupOwnGroup =>
      'O\'zingiz yaratgan guruhga qo\'shila olmaysiz.';

  @override
  String get joinGroupFailed =>
      'Guruhga qo\'shilib bo\'lmadi. Iltimos, qayta urinib ko\'ring.';

  @override
  String get authEyebrowSignUp => 'INGLIZ TILI SAYOHATINGIZNI BOSHLANG';

  @override
  String get authEyebrowSignIn => 'QAYTGANINGIZDAN XURSANDMIZ';

  @override
  String get authTitleSignUp => 'Hisob yarating';

  @override
  String get authTitleSignIn => 'Learnist\'ga kiring';

  @override
  String get authSubtitleSignUp =>
      'CEFR sertifikatiga tayyorlanayotgan minglab talabalarga qo\'shiling.';

  @override
  String get authSubtitleSignIn => 'To\'xtagan joyingizdan davom eting.';

  @override
  String get authSignIn => 'Kirish';

  @override
  String get authSignUp => 'Ro\'yxatdan o\'tish';

  @override
  String get authCreateAccount => 'Hisob yaratish';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailRequired => 'Emailingizni kiriting';

  @override
  String get authEmailInvalid => 'Email manzili noto\'g\'ri';

  @override
  String get authPassword => 'Parol';

  @override
  String get authPasswordHint => 'Parolingiz';

  @override
  String get authPasswordHintNew => 'Kamida 6 ta belgi';

  @override
  String get authShowPassword => 'Parolni ko\'rsatish';

  @override
  String get authHidePassword => 'Parolni yashirish';

  @override
  String get authPasswordRequired => 'Parolni kiriting';

  @override
  String get authPasswordTooShort =>
      'Parol kamida 6 ta belgidan iborat bo\'lsin';

  @override
  String get authForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get authFullName => 'To\'liq ism';

  @override
  String get authFullNameHint => 'To\'liq ismingiz';

  @override
  String get authFullNameRequired => 'To\'liq ismingizni kiriting';

  @override
  String get authUsername => 'Foydalanuvchi nomi';

  @override
  String get authUsernameHint => 'masalan, learner_01';

  @override
  String get authUsernameInvalid =>
      '3–30 ta belgi: harflar, raqamlar, _ yoki .';

  @override
  String get authUniversity => 'Universitet';

  @override
  String get authUniversityHint => 'Universitetingizni qidiring';

  @override
  String get authUniversityRequired => 'Universitetingizni tanlang';

  @override
  String get authOtherUniversity => 'Boshqa';

  @override
  String get authUniversityName => 'Universitet nomi';

  @override
  String get authUniversityNameHint => 'Universitetingiz nomini yozing';

  @override
  String get authUniversityNameRequired => 'Universitet nomini kiriting';

  @override
  String get authHaveAccount => 'Hisobingiz bormi?';

  @override
  String get authNewToLearnist => 'Learnist\'da yangimisiz?';

  @override
  String get authSignInInstead => 'Tizimga kirish';

  @override
  String get authCreateAnAccount => 'Hisob yaratish';

  @override
  String get authConfirmEmailSent =>
      'Tasdiqlash havolasi emailingizga yuborildi. Uni bosib, so\'ng tizimga kiring.';

  @override
  String get authResetTitle => 'Parolni tiklash';

  @override
  String get authResetBody =>
      'Hisobingizga bog\'langan emailni kiriting — parolni tiklash havolasini yuboramiz.';

  @override
  String get authResetSend => 'Havolani yuborish';

  @override
  String get authResetSent =>
      'Parolni tiklash havolasi pochtangizga yuborildi.';

  @override
  String get passwordEyebrow => 'HISOBNI TIKLASH';

  @override
  String get passwordTitle => 'Yangi parol o\'rnating';

  @override
  String get passwordBody =>
      'Hisobingiz uchun yangi va xavfsiz parol kiriting. Keyingi safar shu parol bilan kirasiz.';

  @override
  String get passwordNew => 'Yangi parol';

  @override
  String get passwordNewRequired => 'Yangi parolni kiriting';

  @override
  String get passwordSave => 'Parolni saqlash';

  @override
  String get passwordUpdated => 'Parolingiz muvaffaqiyatli yangilandi.';

  @override
  String get authRoleMismatchStudent =>
      'Siz talaba sifatida ro\'yxatdan o\'tgansiz. Iltimos, \'Talaba\' bo\'limini tanlang.';

  @override
  String get authRoleMismatchTeacher =>
      'Siz o\'qituvchi sifatida ro\'yxatdan o\'tgansiz. Iltimos, \'O\'qituvchi\' bo\'limini tanlang.';

  @override
  String get authUsernameTaken =>
      'Bu foydalanuvchi nomi allaqachon band. Iltimos, boshqa nom tanlang.';

  @override
  String get errorServer =>
      'Serverda xatolik yuz berdi. Birozdan so\'ng qayta urinib ko\'ring.';

  @override
  String get authResetOtherDevice =>
      'Havolani parolni tiklashni so\'ragan qurilmada oching.';

  @override
  String get authLinkExpired =>
      'Havola eskirgan yoki allaqachon ishlatilgan. Iltimos, yangi havola so\'rang.';

  @override
  String get authEmailExists =>
      'Bu email bilan allaqachon ro\'yxatdan o\'tilgan. Tizimga kiring.';

  @override
  String get authInvalidCredentials => 'Email yoki parol noto\'g\'ri.';

  @override
  String get authEmailNotConfirmed =>
      'Emailingiz hali tasdiqlanmagan. Pochtangizdagi havolani bosing.';

  @override
  String get authWeakPassword =>
      'Parol juda oddiy. Kamida 6 ta belgidan iborat kuchliroq parol kiriting.';

  @override
  String get authSamePassword => 'Yangi parol eskisidan farq qilishi kerak.';

  @override
  String get authSessionExpired =>
      'Sessiya muddati tugagan. Iltimos, yangi tiklash havolasini so\'rang.';

  @override
  String get authEmailAddressInvalid => 'Email manzili noto\'g\'ri kiritilgan.';

  @override
  String get authRateLimited =>
      'Juda ko\'p urinish bo\'ldi. Birozdan so\'ng qayta urinib ko\'ring.';

  @override
  String get authSignupDisabled => 'Ro\'yxatdan o\'tish hozircha o\'chirilgan.';

  @override
  String get profileUsernameTaken => 'Bu foydalanuvchi nomi band.';

  @override
  String get profileNotFound =>
      'Profilingiz topilmadi. Tizimdan chiqib, qayta kiring.';

  @override
  String get profileUpdateForbidden => 'Profilni o\'zgartirishga ruxsat yo\'q.';

  @override
  String get save => 'Saqlash';

  @override
  String get editProfileFullName => 'Ism va familiya';

  @override
  String get profileSaved => 'O\'zgarishlar muvaffaqiyatli saqlandi';

  @override
  String get editProfileTitle => 'Profilni tahrirlash';

  @override
  String lessonTitleWithNumber(int number, String title) {
    return '$number-dars: $title';
  }

  @override
  String get lessonTagPracticalTask => 'Amaliy topshiriq';

  @override
  String get lessonTagGrammarRule => 'Grammatika qoidasi';

  @override
  String get lessonTagSpeakingTask => 'Gapirish topshirig\'i';

  @override
  String get lessonTagWritingTask => 'Yozish topshirig\'i';

  @override
  String get lessonAnalyzeAnswer => 'Javobimni tahlil qilish';

  @override
  String get lessonAnswerHint => 'Javobingizni shu yerga yozing…';

  @override
  String get lessonAssessWriting => 'Yozganimni baholash';

  @override
  String get lessonWritingHint => 'Matningizni shu yerga yozing…';

  @override
  String lessonWordCount(int count, int min, int max) {
    return '$count / $min–$max so\'z';
  }

  @override
  String get lessonCefrLenses => 'CEFR mezonlari';

  @override
  String get lessonCefrLensesCaption =>
      'Yozganingiz shu darajalar bo\'yicha baholanadi.';

  @override
  String get lessonLensA1 =>
      'Darsdagi grammatikadan foydalangan qisqa, to\'g\'ri gaplar.';

  @override
  String get lessonLensA2 => 'Fikrlarni and, but va because bilan bog\'lang.';

  @override
  String get lessonLensB1 =>
      'Aniq xatboshilarda tafsilot va sabablar keltiring.';

  @override
  String get lessonLensB2 =>
      'So\'z boyligi va gap tuzilishini xilma-xil qiling.';

  @override
  String get lessonTranscript => 'Matn';

  @override
  String get lessonAssessSpeaking => 'Nutqni baholash';

  @override
  String get lessonSpeakingHint =>
      'Javobingizni yozib oling yoki aytganingizni shu yerga yozing…';

  @override
  String get lessonAskAi => 'AI\'dan so\'rash';

  @override
  String micIdle(int minutes) {
    return 'Mikrofonni bosing va gapiring (ko\'pi bilan $minutes daqiqa)';
  }

  @override
  String get micRecording => 'Yozilmoqda… To\'xtatish uchun bosing';

  @override
  String get micTranscribing => 'Matnga aylantirilmoqda…';

  @override
  String get micStart => 'Yozishni boshlash';

  @override
  String get micStop => 'Yozishni to\'xtatish';

  @override
  String taskMasteryReached(int score) {
    return 'O\'zlashtirish darajasi: $score%';
  }

  @override
  String get recordingTitle => 'Sizning yozuvingiz';

  @override
  String get recordingPlay => 'Yozuvni tinglash';

  @override
  String get recordingPause => 'Yozuvni to\'xtatib turish';

  @override
  String get recordingUnplayable => 'Yozuvingizni ijro etib bo\'lmadi.';

  @override
  String get audioRestart => 'Boshidan';

  @override
  String get audioPlay => 'Ijro etish';

  @override
  String get audioPause => 'Pauza';

  @override
  String get transcriptShow => 'Ko\'rsatish';

  @override
  String get transcriptHide => 'Yashirish';

  @override
  String quizAnswerAll(int total) {
    return 'Natijani tekshirish uchun barcha $total ta savolga javob bering.';
  }

  @override
  String quizScore(int correct, int total) {
    return '$correct/$total to\'g\'ri';
  }

  @override
  String get quizReviewHint =>
      'Natijangizni yaxshilash uchun matnni qayta ko\'rib chiqing va yana urinib ko\'ring.';

  @override
  String get checkupCooldownError =>
      'Keyingi daraja tekshiruvi hali ochilmagan.';

  @override
  String get checkupInvalidAnswers =>
      'Barcha savollarga javob berib, qayta yuboring.';

  @override
  String get errorNoResponse =>
      'Server javob bermadi. Iltimos qayta urinib ko\'ring.';

  @override
  String get recordingEmpty => 'Yozib olingan audio bo\'sh.';

  @override
  String get transcriptionNoSpeech =>
      'Ovozingiz aniqlanmadi. Mikrofonga yaqinroq gapirib, qayta urinib ko\'ring.';

  @override
  String get aiEmptyPrompt => 'Avval promptingizni yozing.';

  @override
  String get aiBusy =>
      'AI hozir band. Birozdan so\'ng qaytadan urinib ko\'ring.';

  @override
  String get aiFailed => 'AI javob bera olmadi. Qaytadan urinib ko\'ring.';

  @override
  String get aiTimeout => 'AI javob bermadi. Qaytadan urinib ko\'ring.';

  @override
  String get aiEmptyReply =>
      'AI bo\'sh javob qaytardi. Qaytadan urinib ko\'ring.';

  @override
  String get aiUnreadableReply =>
      'AI javobini o\'qib bo\'lmadi. Qaytadan urinib ko\'ring.';

  @override
  String errorMapIntro(int count) {
    return 'Testlarda qayta-qayta xato qilayotgan savollaringiz. Kamida $count marta takrorlangan xatolar ko\'rsatiladi — mavzuni qayta o\'rganish uchun kartani bosing.';
  }

  @override
  String get errorLegendHigh => 'Ko\'p takrorlangan (4+)';

  @override
  String get errorLegendMedium => 'O\'rtacha (2–3)';

  @override
  String get errorMapEmptyTitle =>
      'Ajoyib! Hozircha takrorlangan xatolar yo\'q';

  @override
  String get errorMapEmptyBody =>
      'Testlarda bir xil savolda ikki marta xato qilsangiz, u shu yerda paydo bo\'ladi.';

  @override
  String errorMapQuestion(String section, int number) {
    return '$section: $number-savol';
  }

  @override
  String errorMistakeCount(int count) {
    return 'So\'nggi testlarda $count marta xato qilingan';
  }

  @override
  String get errorSeverityHigh => 'yuqori';

  @override
  String get errorSeverityMedium => 'o\'rta';

  @override
  String errorPriority(String level) {
    return 'Ustuvorlik: $level';
  }

  @override
  String get errorReviewLesson => 'Darsni takrorlash';
}
