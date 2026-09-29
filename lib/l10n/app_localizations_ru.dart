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
}
