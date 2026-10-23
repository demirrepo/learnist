// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navHome => 'Главная';

  @override
  String get navTopics => 'Темы';

  @override
  String get navAiLab => 'AI Lab';

  @override
  String get navCheckup => 'Проверка';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navTeacherPanel => 'Панель';

  @override
  String get navTeacherPanelFull => 'Панель преподавателя';

  @override
  String get sidebarTagline => 'AI-помощник в учёбе';

  @override
  String get sidebarDefaultUser => 'Пользователь Learnist';

  @override
  String get roleTeacher => 'Преподаватель';

  @override
  String get roleStudent => 'Студент';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get ok => 'OK';

  @override
  String get notAvailable => '—';

  @override
  String lessonLabel(int number) {
    return 'Урок $number';
  }

  @override
  String semesterLabel(int number) {
    return 'Семестр $number';
  }

  @override
  String get greetingMorning => 'Доброе утро';

  @override
  String get greetingAfternoon => 'Добрый день';

  @override
  String get greetingEvening => 'Добрый вечер';

  @override
  String get homeWelcomeBack => 'С возвращением';

  @override
  String homeGreeting(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String homeCefrBadge(String level) {
    return 'Уровень CEFR: $level';
  }

  @override
  String get homeCefrBadgeUnknown => 'Уровень CEFR: ещё не определён';

  @override
  String get homeTodaysFocus => 'ФОКУС ДНЯ';

  @override
  String get homeHeadline =>
      'Ваш английский растёт каждый раз, когда вы понимаете ошибку.';

  @override
  String get homeSubtitle =>
      'Сохраняйте темп — переходите к следующему занятию.';

  @override
  String homeContinueLesson(int number) {
    return 'Продолжить урок $number';
  }

  @override
  String get homeOpenAiLab => 'Открыть AI Lab';

  @override
  String homeMastery(int percent) {
    return 'Освоено $percent%';
  }

  @override
  String get homeLearningSpace => 'Учебное пространство';

  @override
  String get homeSwipe => 'Листайте';

  @override
  String homeLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count урока',
      many: '$count уроков',
      few: '$count урока',
      one: '$count урок',
    );
    return '$_temp0';
  }

  @override
  String get homePromptBetter => 'Лучшие промпты';

  @override
  String get homeCefrTest => 'Тест CEFR';

  @override
  String get homeSnapshot => 'Ваша сводка';

  @override
  String get statLessonsMastered => 'Освоено уроков';

  @override
  String get statCurrentLesson => 'Текущий урок';

  @override
  String get statCefrEstimate => 'Оценка CEFR';

  @override
  String get statTrackedMistakes => 'Отслеживаемые ошибки';

  @override
  String get lessonMastery => 'Освоение урока';

  @override
  String lessonMasterySemantics(String lesson, String percent) {
    return 'Освоение урока, $lesson: $percent';
  }

  @override
  String get topicsEyebrow => 'ТЕМЫ';

  @override
  String get topicsTitle => 'Путь из 52 уроков';

  @override
  String get topicsSemesters =>
      'Семестр 1: уроки 1–30 • Семестр 2: уроки 31–52';

  @override
  String get topicsSearchHint => 'Поиск уроков';

  @override
  String get topicsNoMatch => 'По вашему запросу уроков не найдено.';

  @override
  String get topicsEmpty => 'Уроки пока не найдены.';

  @override
  String get topicLocked => 'Закрыто';

  @override
  String get topicLockedMessage =>
      'Закрыто. Этот урок откроется после прохождения предыдущих.';

  @override
  String get aiLabEyebrow => 'ГРАМОТНЫЕ ПРОМПТЫ';

  @override
  String get aiLabHeadline =>
      'Задавайте вопросы лучше. Учитесь самостоятельнее.';

  @override
  String get aiLabIntro =>
      'Промпт — это инструкция, которую вы даёте ИИ. Чёткий промпт даёт ответ, на котором можно учиться, а не просто скопировать его.';

  @override
  String get aiLabExamplePrompt => 'ПРИМЕР ПРОМПТА';

  @override
  String get promptPartRole => 'Роль';

  @override
  String get promptPartTask => 'Задача';

  @override
  String get promptPartLevel => 'Уровень';

  @override
  String get promptPartContext => 'Контекст';

  @override
  String get promptPartFormat => 'Формат';

  @override
  String get aiCourseTitle => 'Курс по ИИ';

  @override
  String aiCourseSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count коротких шага',
      many: '$count коротких шагов',
      few: '$count коротких шага',
      one: '$count короткий шаг',
    );
    return '$_temp0 к сильному промпту.';
  }

  @override
  String get aiStepWhatTitle => 'Что такое промпт?';

  @override
  String get aiStepWhatBody =>
      'Промпт — это сообщение, которое вы отправляете ИИ. Чем оно яснее, тем полезнее ответ.';

  @override
  String get aiStepRoleBody =>
      'Скажите ИИ, кем быть, — и он ответит как эксперт.';

  @override
  String get aiStepTaskBody => 'Скажите точно, что нужно сделать.';

  @override
  String get aiStepLevelBody =>
      'Укажите свой уровень английского, чтобы ответ вам подошёл.';

  @override
  String get aiStepContextBody => 'Опишите ситуацию: текст, вопрос, вашу цель.';

  @override
  String get aiStepFormatBody =>
      'Попросите нужную форму ответа: список, таблицу или короткий абзац.';

  @override
  String get aiStepExamplesTitle => 'Примеры и тон';

  @override
  String get aiStepExamplesBody => 'Покажите пример и выберите нужный тон.';

  @override
  String get promptCheckerTitle => 'Проверка промпта';

  @override
  String get promptCheckerHint => 'Напишите промпт...';

  @override
  String get promptCheckerButton => 'Проверить промпт';

  @override
  String get promptCheckerFeedback => 'Отзыв ИИ';

  @override
  String get promptCheckerUnexpected =>
      'Непредвиденная ошибка. Попробуйте ещё раз.';

  @override
  String get comparisonTitle => 'Плохой промпт → хороший промпт';

  @override
  String get comparisonSubtitle => 'Вопрос тот же, а ответы совсем разные.';

  @override
  String get comparisonBadNote =>
      'Нет роли, контекста и уровня. ИИ приходится угадывать, что вам нужно, поэтому ответ расплывчатый.';

  @override
  String get comparisonGoodNote =>
      'Роль + контекст вопроса + уровень + формат. ИИ точно знает, как вам помочь.';

  @override
  String get checkupEyebrow => 'ВАШ НАСТОЯЩИЙ УРОВЕНЬ';

  @override
  String get checkupTitle => 'Проверка уровня';

  @override
  String checkupMinutes(int minutes) {
    return '≈ $minutes мин';
  }

  @override
  String checkupQuestionRange(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вопроса',
      many: '$count вопросов',
      few: '$count вопроса',
      one: '$count вопрос',
    );
    return '$_temp0 от A1 до C2';
  }

  @override
  String get checkupLevelRule =>
      'Ваш уровень — самый высокий, пройденный по порядку начиная с A1.';

  @override
  String get checkupAnswers => 'Ответы';

  @override
  String get checkupSubmit => 'Отправить проверку';

  @override
  String checkupAnswerAll(int count) {
    return 'Ответьте на все вопросы ($count).';
  }

  @override
  String get checkupNoQuestions => 'Вопросы ещё не добавлены.';

  @override
  String get checkupConfirmTitle => 'Отправить ответы?';

  @override
  String checkupConfirmBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня',
      many: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return 'После отправки следующая проверка откроется через $_temp0.';
  }

  @override
  String get checkupConfirmSubmit => 'Отправить';

  @override
  String checkupResultTitle(String level) {
    return 'Ваш уровень: $level';
  }

  @override
  String checkupResultBody(int score, int total, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня',
      many: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return 'Верно: $score/$total. Следующая проверка уровня откроется через $_temp0.';
  }

  @override
  String get checkupNextIn => 'Следующая проверка через';

  @override
  String checkupDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get checkupCooldownNote =>
      'Период ожидания защищает результат от эффекта краткосрочной тренировки.';

  @override
  String get checkupRetakeUnavailable => 'Пересдача пока недоступна';

  @override
  String get checkupGrowth => 'Рост CEFR';

  @override
  String checkupLastChecks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Последние проверки: $count',
      one: 'Ваша последняя проверка',
    );
    return '$_temp0';
  }

  @override
  String checkupLevelsGained(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count уровня',
      many: '+$count уровней',
      few: '+$count уровня',
      one: '+$count уровень',
    );
    return '$_temp0';
  }

  @override
  String get checkupChartEmpty => 'График роста появится после первой проверки';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileDefaultName => 'Пользователь';

  @override
  String get profileDefaultUniversity => 'Студент';

  @override
  String profileUniversity(String name) {
    return 'Университет: $name';
  }

  @override
  String get profileTopicsMastered => 'Освоено тем';

  @override
  String get profileAverageResult => 'Средний результат';

  @override
  String get profileEdit => 'Редактировать';

  @override
  String get profileErrorMap => 'Карта ошибок';

  @override
  String get profileJoinGroup => 'Вступить в группу';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileChooseLanguage => 'Выберите язык';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get lessonTabGrammar => 'Грамматика';

  @override
  String get lessonTabReading => 'Чтение';

  @override
  String get lessonTabListening => 'Аудирование';

  @override
  String get lessonTabWriting => 'Письмо';

  @override
  String get lessonTabSpeaking => 'Говорение';

  @override
  String get lessonGeneralRule => 'Общее правило';

  @override
  String get lessonNoGrammar => 'В этом уроке нет грамматических правил.';

  @override
  String get lessonNoReading => 'В этом уроке нет упражнения на чтение.';

  @override
  String get lessonNoListening => 'В этом уроке нет упражнения на аудирование.';

  @override
  String get lessonNoWriting => 'В этом уроке нет письменного задания.';

  @override
  String get lessonNoSpeaking => 'В этом уроке нет задания на говорение.';

  @override
  String get lessonVocabulary => 'Словарь';

  @override
  String get lessonCheckResults => 'Проверить результат';

  @override
  String get lessonAudioPending =>
      'Аудио для этого урока ещё готовится. Пока используйте текст.';

  @override
  String get lessonAudioError =>
      'Не удалось загрузить аудио. Проверьте подключение к интернету и попробуйте снова.';

  @override
  String get lessonFinish => 'Завершить урок';

  @override
  String get lessonUnlocked => 'Поздравляем! Открыт новый урок';

  @override
  String get lessonSaveScoreError =>
      'Балл не сохранён. Пожалуйста, попробуйте снова.';

  @override
  String get taskEmptyAnswer => 'Сначала напишите ответ.';

  @override
  String get taskEvaluationError =>
      'При оценке произошла ошибка. Пожалуйста, попробуйте снова.';

  @override
  String get taskMicDenied =>
      'Разрешите доступ к микрофону, чтобы записать голос.';

  @override
  String get taskMicBlocked =>
      'Доступ к микрофону запрещён. Включите его в настройках телефона.';

  @override
  String get taskRecordingError =>
      'Не удалось начать запись. Пожалуйста, попробуйте снова.';

  @override
  String get taskTranscriptionError =>
      'Не удалось преобразовать речь в текст. Пожалуйста, попробуйте снова.';

  @override
  String get taskRecordingMissing => 'Записанное аудио не найдено.';

  @override
  String get errorOffline =>
      'Нет подключения к интернету. Проверьте сеть и попробуйте снова.';

  @override
  String get lessonNotFound => 'Урок не найден.';

  @override
  String get lessonLoadFailed =>
      'Не удалось загрузить уроки. Попробуйте чуть позже.';

  @override
  String get errorGeneric =>
      'Что-то пошло не так. Пожалуйста, попробуйте снова.';

  @override
  String lessonCompleteLowScore(int min) {
    return 'Ваш средний балл ниже $min%. Улучшите результаты по разделам, чтобы перейти к следующему уроку.';
  }

  @override
  String lessonCompleteLowScoreWithAverage(int min, int average) {
    return 'Ваш средний балл ниже $min% (сейчас: $average%). Улучшите результаты по разделам, чтобы перейти к следующему уроку.';
  }

  @override
  String get lessonCompleteFailed =>
      'Не удалось завершить урок. Пожалуйста, попробуйте снова.';

  @override
  String lessonKeyWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ключевых слов',
      few: '$count ключевых слова',
      one: '$count ключевое слово',
    );
    return '$_temp0';
  }

  @override
  String vocabularyListen(String word) {
    return 'Прослушать «$word»';
  }

  @override
  String get vocabularySpeakError => 'Не удалось воспроизвести произношение.';

  @override
  String get askAiEyebrow => 'ASK AI С УЧЁТОМ КОНТЕКСТА';

  @override
  String askAiTitle(String section) {
    return 'Вопрос: $section';
  }

  @override
  String get askAiContextAttached => 'Ваш контекст уже прикреплён:';

  @override
  String askAiHint(int lesson) {
    return 'Например: Ты эксперт по чтению. В уроке $lesson, в вопросе 4, я выбрал B. Объясни, почему моё рассуждение может быть неверным. Дай две подсказки, не раскрывая правильный ответ.';
  }

  @override
  String get askAiSubmit => 'Спросить Learnist AI';

  @override
  String get askAiThinking => 'Learnist AI думает…';

  @override
  String get askAiEmptyQuestion => 'Сначала напишите вопрос.';

  @override
  String get askAiBusy => 'Learnist AI сейчас занят. Попробуйте чуть позже.';

  @override
  String get askAiFailed =>
      'Learnist AI не смог ответить. Пожалуйста, попробуйте снова.';

  @override
  String get close => 'Закрыть';

  @override
  String get teacherEyebrow => 'АНАЛИТИКА КЛАССА';

  @override
  String get teacherWorkspaceEyebrow => 'РАБОЧЕЕ ПРОСТРАНСТВО ПРЕПОДАВАТЕЛЯ';

  @override
  String get teacherWorkspaceHeadline =>
      'Узнайте, кто учится — и где возникают трудности.';

  @override
  String get teacherWorkspaceBody =>
      'Создавайте классы, подключайте студентов по логину и паролю класса и отслеживайте прогресс по урокам, историю уровней CEFR и повторяющиеся типы ошибок.';

  @override
  String get teacherCreateGroup => 'Создать группу';

  @override
  String get teacherConnectedStudents => 'ПОДКЛЮЧЁННЫЕ СТУДЕНТЫ';

  @override
  String teacherConnectedStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подключённых студента',
      many: '$count подключённых студентов',
      few: '$count подключённых студента',
      one: '$count подключённый студент',
    );
    return '$_temp0';
  }

  @override
  String teacherGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count группы',
      many: '$count групп',
      few: '$count группы',
      one: '$count группа',
    );
    return '$_temp0';
  }

  @override
  String teacherStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count студента',
      many: '$count студентов',
      few: '$count студента',
      one: '$count студент',
    );
    return '$_temp0';
  }

  @override
  String get teacherClassOverview => 'Обзор класса';

  @override
  String get teacherStudentsActive => 'Активные студенты';

  @override
  String get teacherAverageMastery => 'Средний уровень освоения';

  @override
  String get teacherGroups => 'Группы';

  @override
  String get teacherGroupsAndStudents => 'Группы и студенты';

  @override
  String get teacherNoGroups =>
      'Групп пока нет. Создайте группу, чтобы подключить студентов.';

  @override
  String get teacherNoStudents => 'Студенты пока не подключены.';

  @override
  String get groupClassLogin => 'Логин класса';

  @override
  String get teacherPasswordInline => 'пароль';

  @override
  String get teacherColumnStudent => 'СТУДЕНТ';

  @override
  String get teacherColumnCurrentLesson => 'ТЕКУЩИЙ УРОК';

  @override
  String get teacherColumnMastery => 'ОСВОЕНИЕ';

  @override
  String get teacherColumnAction => 'ДЕЙСТВИЕ';

  @override
  String teacherLessonShort(int number) {
    return '$number';
  }

  @override
  String get teacherChipLesson => 'Урок';

  @override
  String get teacherChipMastery => 'Освоение';

  @override
  String get teacherView => 'Открыть';

  @override
  String teacherGroupCreated(String name) {
    return 'Группа «$name» создана.';
  }

  @override
  String get teacherGroupName => 'Название группы';

  @override
  String get teacherLoginHelper => '3–32 символа: A–Z, 0–9, _ или -';

  @override
  String get groupPassword => 'Пароль';

  @override
  String get teacherGroupNameRequired => 'Введите название группы.';

  @override
  String get teacherLoginInvalid =>
      'Логин должен содержать 3–32 буквы, цифры, _ или -.';

  @override
  String get teacherPasswordInvalid =>
      'Пароль должен содержать от 4 до 64 символов.';

  @override
  String get teacherCreate => 'Создать';

  @override
  String get teacherLoginTaken =>
      'Этот логин занят. Пожалуйста, выберите другой.';

  @override
  String get teacherCreateGroupFailed =>
      'Не удалось создать группу. Пожалуйста, попробуйте снова.';

  @override
  String get teacherLoadFailed =>
      'Не удалось загрузить данные. Пожалуйста, попробуйте снова.';

  @override
  String get teacherStudentDetail => 'ДАННЫЕ СТУДЕНТА';

  @override
  String teacherCurrentLesson(int number) {
    return 'текущий урок: $number';
  }

  @override
  String get teacherLessonProgress => 'Прогресс по урокам';

  @override
  String teacherLessonInProgress(String title) {
    return '$title • в процессе';
  }

  @override
  String get teacherNoLessonsStarted => 'Уроки ещё не начаты.';

  @override
  String get joinGroupIntro =>
      'Введите логин и пароль класса, которые дал вам преподаватель.';

  @override
  String get joinGroupFieldRequired => 'Заполните это поле.';

  @override
  String get joinGroupSubmit => 'Вступить';

  @override
  String joinGroupJoined(String name) {
    return 'Вы вступили в группу «$name».';
  }

  @override
  String joinGroupAlreadyMember(String name) {
    return 'Вы уже состоите в группе «$name».';
  }

  @override
  String get joinGroupInvalidCredentials => 'Неверный логин или пароль.';

  @override
  String get joinGroupOwnGroup =>
      'Нельзя вступить в группу, которую вы создали.';

  @override
  String get joinGroupFailed =>
      'Не удалось вступить в группу. Пожалуйста, попробуйте снова.';

  @override
  String get authEyebrowSignUp => 'НАЧНИТЕ ИЗУЧАТЬ АНГЛИЙСКИЙ';

  @override
  String get authEyebrowSignIn => 'С ВОЗВРАЩЕНИЕМ';

  @override
  String get authTitleSignUp => 'Создайте аккаунт';

  @override
  String get authTitleSignIn => 'Войдите в Learnist';

  @override
  String get authSubtitleSignUp =>
      'Присоединяйтесь к тысячам студентов, которые готовятся к сертификату CEFR.';

  @override
  String get authSubtitleSignIn =>
      'Продолжайте с того места, где остановились.';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignUp => 'Регистрация';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authEmail => 'Эл. почта';

  @override
  String get authEmailRequired => 'Введите адрес эл. почты';

  @override
  String get authEmailInvalid => 'Неверный адрес эл. почты';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authPasswordHint => 'Ваш пароль';

  @override
  String get authPasswordHintNew => 'Не менее 6 символов';

  @override
  String get authShowPassword => 'Показать пароль';

  @override
  String get authHidePassword => 'Скрыть пароль';

  @override
  String get authPasswordRequired => 'Введите пароль';

  @override
  String get authPasswordTooShort =>
      'Пароль должен содержать не менее 6 символов';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authFullName => 'Полное имя';

  @override
  String get authFullNameHint => 'Ваше полное имя';

  @override
  String get authFullNameRequired => 'Введите полное имя';

  @override
  String get authUsername => 'Имя пользователя';

  @override
  String get authUsernameHint => 'например, learner_01';

  @override
  String get authUsernameInvalid => '3–30 символов: буквы, цифры, _ или .';

  @override
  String get authUniversity => 'Университет';

  @override
  String get authUniversityHint => 'Найдите свой университет';

  @override
  String get authUniversityRequired => 'Выберите университет';

  @override
  String get authOtherUniversity => 'Другой';

  @override
  String get authUniversityName => 'Название университета';

  @override
  String get authUniversityNameHint => 'Введите название университета';

  @override
  String get authUniversityNameRequired => 'Введите название университета';

  @override
  String get authHaveAccount => 'Уже есть аккаунт?';

  @override
  String get authNewToLearnist => 'Впервые в Learnist?';

  @override
  String get authSignInInstead => 'Войти';

  @override
  String get authCreateAnAccount => 'Создать аккаунт';

  @override
  String get authConfirmEmailSent =>
      'Мы отправили ссылку для подтверждения на вашу почту. Откройте её, затем войдите.';

  @override
  String get authResetTitle => 'Восстановление пароля';

  @override
  String get authResetBody =>
      'Введите адрес почты, привязанный к аккаунту, — мы пришлём ссылку для сброса пароля.';

  @override
  String get authResetSend => 'Отправить ссылку';

  @override
  String get authResetSent =>
      'Ссылка для сброса пароля отправлена на вашу почту.';

  @override
  String get passwordEyebrow => 'ВОССТАНОВЛЕНИЕ АККАУНТА';

  @override
  String get passwordTitle => 'Задайте новый пароль';

  @override
  String get passwordBody =>
      'Введите новый надёжный пароль для аккаунта. В следующий раз вы войдёте с ним.';

  @override
  String get passwordNew => 'Новый пароль';

  @override
  String get passwordNewRequired => 'Введите новый пароль';

  @override
  String get passwordSave => 'Сохранить пароль';

  @override
  String get passwordUpdated => 'Пароль успешно обновлён.';

  @override
  String get authRoleMismatchStudent =>
      'Вы зарегистрированы как студент. Пожалуйста, выберите вкладку «Студент».';

  @override
  String get authRoleMismatchTeacher =>
      'Вы зарегистрированы как преподаватель. Пожалуйста, выберите вкладку «Преподаватель».';

  @override
  String get authUsernameTaken =>
      'Это имя пользователя уже занято. Пожалуйста, выберите другое.';

  @override
  String get errorServer =>
      'На сервере произошла ошибка. Попробуйте чуть позже.';

  @override
  String get authResetOtherDevice =>
      'Откройте ссылку на устройстве, с которого запрашивали сброс пароля.';

  @override
  String get authLinkExpired =>
      'Ссылка устарела или уже использована. Пожалуйста, запросите новую.';

  @override
  String get authEmailExists =>
      'Аккаунт с этой почтой уже существует. Войдите в систему.';

  @override
  String get authInvalidCredentials => 'Неверная почта или пароль.';

  @override
  String get authEmailNotConfirmed =>
      'Ваша почта ещё не подтверждена. Перейдите по ссылке из письма.';

  @override
  String get authWeakPassword =>
      'Пароль слишком простой. Введите более надёжный пароль не короче 6 символов.';

  @override
  String get authSamePassword => 'Новый пароль должен отличаться от старого.';

  @override
  String get authSessionExpired =>
      'Сеанс истёк. Пожалуйста, запросите новую ссылку для сброса.';

  @override
  String get authEmailAddressInvalid => 'Адрес эл. почты введён неверно.';

  @override
  String get authRateLimited => 'Слишком много попыток. Попробуйте чуть позже.';

  @override
  String get authSignupDisabled => 'Регистрация временно отключена.';

  @override
  String get profileUsernameTaken => 'Это имя пользователя занято.';

  @override
  String get profileNotFound => 'Профиль не найден. Выйдите и войдите снова.';

  @override
  String get profileUpdateForbidden => 'Нет прав на изменение профиля.';

  @override
  String get save => 'Сохранить';

  @override
  String get editProfileFullName => 'Имя и фамилия';

  @override
  String get profileSaved => 'Изменения сохранены';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String lessonTitleWithNumber(int number, String title) {
    return 'Урок $number: $title';
  }

  @override
  String get lessonTagPracticalTask => 'Практическое задание';

  @override
  String get lessonTagGrammarRule => 'Грамматическое правило';

  @override
  String get lessonTagSpeakingTask => 'Задание по говорению';

  @override
  String get lessonTagWritingTask => 'Задание по письму';

  @override
  String get lessonAnalyzeAnswer => 'Проанализировать ответ';

  @override
  String get lessonAnswerHint => 'Напишите ответ здесь…';

  @override
  String get lessonAssessWriting => 'Оценить моё письмо';

  @override
  String get lessonWritingHint => 'Напишите текст здесь…';

  @override
  String lessonWordCount(int count, int min, int max) {
    return '$count / $min–$max слов';
  }

  @override
  String get lessonCefrLenses => 'Критерии CEFR';

  @override
  String get lessonCefrLensesCaption =>
      'Ваш текст оценивается по этим уровням.';

  @override
  String get lessonLensA1 =>
      'Короткие правильные предложения с грамматикой урока.';

  @override
  String get lessonLensA2 => 'Связывайте мысли с помощью and, but и because.';

  @override
  String get lessonLensB1 => 'Добавляйте детали и причины в чётких абзацах.';

  @override
  String get lessonLensB2 => 'Разнообразьте лексику и структуру предложений.';

  @override
  String get lessonTranscript => 'Расшифровка';

  @override
  String get lessonAssessSpeaking => 'Оценить речь';

  @override
  String get lessonSpeakingHint =>
      'Запишите ответ или напечатайте здесь то, что вы сказали…';

  @override
  String get lessonAskAi => 'Спросить ИИ';

  @override
  String micIdle(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes минут',
      one: '$minutes минуты',
    );
    return 'Нажмите на микрофон и говорите (до $_temp0)';
  }

  @override
  String get micRecording => 'Идёт запись… Нажмите, чтобы остановить';

  @override
  String get micTranscribing => 'Расшифровка…';

  @override
  String get micStart => 'Начать запись';

  @override
  String get micStop => 'Остановить запись';

  @override
  String taskMasteryReached(int score) {
    return 'Уровень освоения: $score%';
  }

  @override
  String get recordingTitle => 'Ваша запись';

  @override
  String get recordingPlay => 'Воспроизвести запись';

  @override
  String get recordingPause => 'Приостановить запись';

  @override
  String get recordingUnplayable => 'Не удалось воспроизвести запись.';

  @override
  String get audioRestart => 'Сначала';

  @override
  String get audioPlay => 'Воспроизвести';

  @override
  String get audioPause => 'Пауза';

  @override
  String get transcriptShow => 'Показать';

  @override
  String get transcriptHide => 'Скрыть';

  @override
  String quizAnswerAll(int total) {
    return 'Ответьте на все вопросы ($total), чтобы проверить результат.';
  }

  @override
  String quizScore(int correct, int total) {
    return '$correct/$total верно';
  }

  @override
  String get quizReviewHint =>
      'Перечитайте текст и попробуйте снова, чтобы улучшить результат.';

  @override
  String get checkupCooldownError =>
      'Следующая проверка уровня ещё не открыта.';

  @override
  String get checkupInvalidAnswers =>
      'Ответьте на все вопросы и отправьте снова.';

  @override
  String get errorNoResponse =>
      'Сервер не ответил. Пожалуйста, попробуйте снова.';

  @override
  String get recordingEmpty => 'Записанное аудио пустое.';

  @override
  String get transcriptionNoSpeech =>
      'Не удалось распознать голос. Говорите ближе к микрофону и попробуйте снова.';

  @override
  String get aiEmptyPrompt => 'Сначала напишите промпт.';

  @override
  String get aiBusy => 'ИИ сейчас занят. Попробуйте чуть позже.';

  @override
  String get aiFailed => 'ИИ не смог ответить. Попробуйте снова.';

  @override
  String get aiTimeout => 'ИИ не ответил. Попробуйте снова.';

  @override
  String get aiEmptyReply => 'ИИ прислал пустой ответ. Попробуйте снова.';

  @override
  String get aiUnreadableReply =>
      'Не удалось прочитать ответ ИИ. Попробуйте снова.';

  @override
  String errorMapIntro(int count) {
    return 'Вопросы, в которых вы раз за разом ошибаетесь в тестах. Показаны ошибки, повторённые не менее $count раз, — нажмите на карточку, чтобы повторить тему.';
  }

  @override
  String get errorLegendHigh => 'Часто повторяются (4+)';

  @override
  String get errorLegendMedium => 'Умеренно (2–3)';

  @override
  String get errorMapEmptyTitle => 'Отлично! Повторяющихся ошибок пока нет';

  @override
  String get errorMapEmptyBody =>
      'Если вы дважды ошибётесь в одном и том же вопросе теста, он появится здесь.';

  @override
  String errorMapQuestion(String section, int number) {
    return '$section: вопрос $number';
  }

  @override
  String errorMistakeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В последних тестах — $count ошибки',
      many: 'В последних тестах — $count ошибок',
      few: 'В последних тестах — $count ошибки',
      one: 'В последних тестах — $count ошибка',
    );
    return '$_temp0';
  }

  @override
  String get errorSeverityHigh => 'высокий';

  @override
  String get errorSeverityMedium => 'средний';

  @override
  String errorPriority(String level) {
    return 'Приоритет: $level';
  }

  @override
  String get errorReviewLesson => 'Повторить урок';
}
