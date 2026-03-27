import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_admin_assistant/app/localization/app_strings.dart';
import 'package:life_admin_assistant/core/models/app_enums.dart';
import 'package:life_admin_assistant/core/utils/formatters.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document.dart';
import 'package:life_admin_assistant/features/reminders/data/life_admin_repository.dart';
import 'package:life_admin_assistant/features/reminders/data/mock_life_admin_repository.dart';
import 'package:life_admin_assistant/features/reminders/domain/reminder_item.dart';
import 'package:life_admin_assistant/features/reminders/presentation/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const koreanLocale = Locale('ko', 'KR');
  const englishLocale = Locale('en', 'US');

  group('Home summary', () {
    testWidgets('원화만 있으면 단일 KRW 합계를 보여준다', (tester) async {
      final now = DateTime.now();
      final strings = AppStrings.forLocale(koreanLocale);
      final reminders = [
        _buildReminder(
          id: 'krw-1',
          title: '관리비 납부',
          dueAt: DateTime(now.year, now.month, 12, 9),
          amount: 70000,
          currency: 'KRW',
        ),
        _buildReminder(
          id: 'krw-2',
          title: '넷플릭스 결제',
          dueAt: DateTime(now.year, now.month, 18, 9),
          amount: 17000,
          currency: 'KRW',
        ),
      ];

      await _pumpHomeScreen(
        tester,
        reminders: reminders,
        locale: koreanLocale,
      );

      expect(
        find.text(
          AppFormatters.currency(
            87000,
            currencyCode: 'KRW',
            locale: koreanLocale,
            emptyAmountLabel: strings.noAmountLabel,
            unknownCurrencyLabel: strings.unknownCurrencyLabel,
          ),
        ),
        findsOneWidget,
      );
      expect(find.text(strings.homeMonthlyEstimateMixedSubtitle), findsNothing);
    });

    testWidgets('달러만 있으면 단일 USD 합계를 보여준다', (tester) async {
      final now = DateTime.now();
      final strings = AppStrings.forLocale(englishLocale);
      final reminders = [
        _buildReminder(
          id: 'usd-1',
          title: 'Domain renewal',
          dueAt: DateTime(now.year, now.month, 12, 9),
          amount: 10,
          currency: 'USD',
        ),
        _buildReminder(
          id: 'usd-2',
          title: 'Cloud invoice',
          dueAt: DateTime(now.year, now.month, 18, 9),
          amount: 5.25,
          currency: 'USD',
        ),
      ];

      await _pumpHomeScreen(
        tester,
        reminders: reminders,
        locale: englishLocale,
      );

      expect(
        find.text(
          AppFormatters.currency(
            15.25,
            currencyCode: 'USD',
            locale: englishLocale,
            emptyAmountLabel: strings.noAmountLabel,
            unknownCurrencyLabel: strings.unknownCurrencyLabel,
          ),
        ),
        findsOneWidget,
      );
      expect(find.text(strings.homeMonthlyEstimateMixedSubtitle), findsNothing);
    });

    testWidgets('원화와 달러가 섞이면 합산하지 않고 분리해서 보여준다', (tester) async {
      final now = DateTime.now();
      final strings = AppStrings.forLocale(koreanLocale);
      final reminders = [
        _buildReminder(
          id: 'mixed-krw-1',
          title: '관리비 납부',
          dueAt: DateTime(now.year, now.month, 12, 9),
          amount: 70000,
          currency: 'KRW',
        ),
        _buildReminder(
          id: 'mixed-krw-2',
          title: '넷플릭스 결제',
          dueAt: DateTime(now.year, now.month, 18, 9),
          amount: 17000,
          currency: 'KRW',
        ),
        _buildReminder(
          id: 'mixed-usd-1',
          title: '도메인 결제',
          dueAt: DateTime(now.year, now.month, 20, 9),
          amount: 10,
          currency: 'USD',
        ),
        _buildReminder(
          id: 'mixed-usd-2',
          title: '메일 서비스',
          dueAt: DateTime(now.year, now.month, 24, 9),
          amount: 5.25,
          currency: 'USD',
        ),
      ];

      await _pumpHomeScreen(
        tester,
        reminders: reminders,
        locale: koreanLocale,
      );

      expect(find.text(strings.homeMonthlyEstimateMixedSubtitle), findsOneWidget);
      expect(
        find.text(
          AppFormatters.currency(
            87000,
            currencyCode: 'KRW',
            locale: koreanLocale,
            emptyAmountLabel: strings.noAmountLabel,
            unknownCurrencyLabel: strings.unknownCurrencyLabel,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          AppFormatters.currency(
            15.25,
            currencyCode: 'USD',
            locale: koreanLocale,
            emptyAmountLabel: strings.noAmountLabel,
            unknownCurrencyLabel: strings.unknownCurrencyLabel,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          AppFormatters.currency(
            87015.25,
            locale: koreanLocale,
            emptyAmountLabel: strings.noAmountLabel,
            unknownCurrencyLabel: strings.unknownCurrencyLabel,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('통화가 비어 있으면 별도 통화 미설정 칩으로 보여준다', (tester) async {
      final now = DateTime.now();
      final strings = AppStrings.forLocale(koreanLocale);
      final reminders = [
        _buildReminder(
          id: 'unset-1',
          title: '직접 입력 일정',
          dueAt: DateTime(now.year, now.month, 12, 9),
          amount: 10000,
          currency: null,
        ),
        _buildReminder(
          id: 'unset-2',
          title: '보조 결제',
          dueAt: DateTime(now.year, now.month, 18, 9),
          amount: 5000,
          currency: null,
        ),
      ];

      await _pumpHomeScreen(
        tester,
        reminders: reminders,
        locale: koreanLocale,
      );

      expect(find.text(strings.homeMonthlyEstimateMixedSubtitle), findsOneWidget);
      expect(
        find.text(
          AppFormatters.currency(
            15000,
            locale: koreanLocale,
            emptyAmountLabel: strings.noAmountLabel,
            unknownCurrencyLabel: strings.unknownCurrencyLabel,
          ),
        ),
        findsOneWidget,
      );
      expect(find.textContaining(strings.unknownCurrencyLabel), findsWidgets);
    });
  });

  group('Home calendar', () {
    testWidgets('작은 안드로이드 높이에서도 월간 달력이 오버플로 없이 렌더링된다', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final now = DateTime.now();
      final crowdedDays = [3, 7, 12, 18, 21, 28]
          .where((day) => day != now.day)
          .toList();

      await _pumpHomeScreen(
        tester,
        reminders: [
          for (var index = 0; index < crowdedDays.length; index++)
            _buildReminder(
              id: 'compact-$index',
              title: '일정 $index',
              dueAt: DateTime(now.year, now.month, crowdedDays[index], 9),
              amount: 1000 + (index * 500),
              currency: 'KRW',
            ),
        ],
        locale: koreanLocale,
      );

      await tester.tap(
        find.text(AppStrings.forLocale(koreanLocale).homeCalendarViewLabel),
      );
      await tester.pumpAndSettle();
      await _scrollUntilVisible(
        tester,
        find.byIcon(Icons.chevron_left_rounded),
      );

      expect(tester.takeException(), isNull);
    });
    testWidgets('기본 보기에서는 목록 섹션이 먼저 보인다', (tester) async {
      await _pumpHomeScreen(
        tester,
        reminders: [_buildReminderForToday(id: 'today-1', title: '오늘 일정')],
        locale: koreanLocale,
      );

      await _scrollUntilVisible(tester, find.text('다가오는 일정'));

      expect(find.text('다가오는 일정'), findsOneWidget);
      expect(find.text('날짜로 보기'), findsNothing);
    });

    testWidgets('달력 보기로 전환하면 월간 달력이 보인다', (tester) async {
      final now = DateTime.now();

      await _pumpHomeScreen(
        tester,
        reminders: [_buildReminderForToday(id: 'today-1', title: '오늘 일정')],
        locale: koreanLocale,
      );

      await tester.tap(find.text('달력'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(
        tester,
        find.text(DateFormat('yyyy년 M월', 'ko_KR').format(DateTime(now.year, now.month))),
      );

      expect(
        find.text(DateFormat('yyyy년 M월', 'ko_KR').format(DateTime(now.year, now.month))),
        findsOneWidget,
      );
    });

    testWidgets('날짜를 선택하면 아래 리마인더 목록이 바뀐다', (tester) async {
      final now = DateTime.now();
      final dayOne = _firstDifferentDay(now.day, const [15, 18, 20, 24]);
      final dayTwo = _nextDifferentDay(now.day, {dayOne});

      await _pumpHomeScreen(
        tester,
        reminders: [
          _buildReminder(
            id: 'date-1',
            title: '첫 번째 일정',
            dueAt: DateTime(now.year, now.month, dayOne, 9),
            amount: 5000,
            currency: 'KRW',
          ),
          _buildReminder(
            id: 'date-2',
            title: '두 번째 일정',
            dueAt: DateTime(now.year, now.month, dayTwo, 9),
            amount: 7000,
            currency: 'KRW',
          ),
        ],
        locale: koreanLocale,
      );

      await tester.tap(find.text('달력'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('$dayOne'));

      await tester.tap(find.text('$dayOne'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('첫 번째 일정'));

      expect(find.text('첫 번째 일정'), findsOneWidget);
      expect(find.text('두 번째 일정'), findsNothing);

      await _scrollUntilVisible(tester, find.text('$dayTwo'));
      await tester.tap(find.text('$dayTwo'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('두 번째 일정'));

      expect(find.text('첫 번째 일정'), findsNothing);
      expect(find.text('두 번째 일정'), findsOneWidget);
    });

    testWidgets('일정이 없는 날짜를 선택하면 차분한 빈 상태를 보여준다', (tester) async {
      final now = DateTime.now();
      final reminderDay = _firstDifferentDay(now.day, const [15, 18, 20, 24]);
      final emptyDay = _nextDifferentDay(now.day, {reminderDay});

      await _pumpHomeScreen(
        tester,
        reminders: [
          _buildReminder(
            id: 'only-one',
            title: '하나뿐인 일정',
            dueAt: DateTime(now.year, now.month, reminderDay, 9),
            amount: 12000,
            currency: 'KRW',
          ),
        ],
        locale: koreanLocale,
      );

      await tester.tap(find.text('달력'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('$emptyDay'));
      await tester.tap(find.text('$emptyDay'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('선택한 날짜에는 일정이 없습니다'));

      expect(find.text('선택한 날짜에는 일정이 없습니다'), findsOneWidget);
      expect(
        find.text('다른 날짜를 선택하거나 목록 보기로 전체 일정을 살펴보세요.'),
        findsOneWidget,
      );
    });

    testWidgets('상세를 보고 돌아와도 달력 선택 상태가 유지된다', (tester) async {
      final now = DateTime.now();
      final selectedDay = _firstDifferentDay(now.day, const [15, 18, 20, 24]);
      final selectedDateText = AppFormatters.calendarDate(
        DateTime(now.year, now.month, selectedDay),
        locale: koreanLocale,
      );

      await _pumpHomeRouter(
        tester,
        reminders: [
          _buildReminder(
            id: 'detail-1',
            title: '상세 이동 일정',
            dueAt: DateTime(now.year, now.month, selectedDay, 9),
            amount: 5000,
            currency: 'KRW',
          ),
        ],
        locale: koreanLocale,
      );

      await tester.tap(find.text('달력'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('$selectedDay'));
      await tester.tap(find.text('$selectedDay'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('상세 이동 일정'));

      expect(find.text('상세 이동 일정'), findsOneWidget);
      expect(find.text('오늘로 이동'), findsOneWidget);

      await tester.tap(find.text('상세 보기'));
      await tester.pumpAndSettle();

      expect(find.textContaining('detail-screen'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text(selectedDateText));

      expect(find.text(selectedDateText), findsOneWidget);
      expect(find.text('오늘로 이동'), findsOneWidget);
      expect(find.text('상세 이동 일정'), findsOneWidget);
    });
  });

  group('Go to today', () {
    testWidgets('이미 오늘이 선택돼 있으면 오늘로 이동 버튼이 숨겨진다', (tester) async {
      await _pumpHomeScreen(
        tester,
        reminders: [_buildReminderForToday(id: 'today-1', title: '오늘 일정')],
        locale: koreanLocale,
      );

      await tester.tap(find.text('달력'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text(DateFormat('yyyy년 M월', 'ko_KR').format(DateTime.now())));

      expect(find.text('오늘로 이동'), findsNothing);
    });

    testWidgets('오늘이 아닌 날짜를 선택하면 오늘로 이동 버튼이 나타난다', (tester) async {
      final now = DateTime.now();
      final otherDay = _firstDifferentDay(now.day, const [15, 18, 20, 24]);

      await _pumpHomeScreen(
        tester,
        reminders: [
          _buildReminderForToday(id: 'today-1', title: '오늘 일정'),
          _buildReminder(
            id: 'other-1',
            title: '다른 날 일정',
            dueAt: DateTime(now.year, now.month, otherDay, 9),
            amount: 9000,
            currency: 'KRW',
          ),
        ],
        locale: koreanLocale,
      );

      await tester.tap(find.text('달력'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('$otherDay'));
      await tester.tap(find.text('$otherDay'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('오늘로 이동'));

      expect(find.text('오늘로 이동'), findsOneWidget);
    });

    testWidgets('오늘로 이동을 누르면 선택이 오늘로 돌아온다', (tester) async {
      final now = DateTime.now();
      final otherDay = _firstDifferentDay(now.day, const [15, 18, 20, 24]);

      await _pumpHomeScreen(
        tester,
        reminders: [
          _buildReminderForToday(id: 'today-1', title: '오늘 일정'),
          _buildReminder(
            id: 'other-1',
            title: '다른 날 일정',
            dueAt: DateTime(now.year, now.month, otherDay, 9),
            amount: 9000,
            currency: 'KRW',
          ),
        ],
        locale: koreanLocale,
      );

      await tester.tap(find.text('달력'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('$otherDay'));
      await tester.tap(find.text('$otherDay'));
      await tester.pumpAndSettle();
      final goToToday = find.text('오늘로 이동');
      expect(goToToday, findsOneWidget);
      await tester.ensureVisible(goToToday);
      await tester.pumpAndSettle();

      await tester.tap(goToToday);
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('오늘 일정'));

      expect(find.text('오늘 일정'), findsOneWidget);
      expect(find.text('다른 날 일정'), findsNothing);
      expect(find.text('오늘로 이동'), findsNothing);
    });
  });

  group('Localization sanity', () {
    testWidgets('영어에서도 혼합 통화와 빈 상태 문구가 자연스럽게 보인다', (tester) async {
      final now = DateTime.now();
      final mixedDay = _firstDifferentDay(now.day, const [15, 18, 20, 24]);
      final emptyDay = _nextDifferentDay(now.day, {mixedDay});

      await _pumpHomeScreen(
        tester,
        reminders: [
          _buildReminder(
            id: 'en-krw-1',
            title: 'Rent',
            dueAt: DateTime(now.year, now.month, mixedDay, 9),
            amount: 70000,
            currency: 'KRW',
          ),
          _buildReminder(
            id: 'en-krw-2',
            title: 'Utilities',
            dueAt: DateTime(now.year, now.month, mixedDay, 10),
            amount: 17000,
            currency: 'KRW',
          ),
          _buildReminder(
            id: 'en-usd-1',
            title: 'Hosting',
            dueAt: DateTime(now.year, now.month, mixedDay, 11),
            amount: 10,
            currency: 'USD',
          ),
          _buildReminder(
            id: 'en-usd-2',
            title: 'Domain',
            dueAt: DateTime(now.year, now.month, mixedDay, 12),
            amount: 5.25,
            currency: 'USD',
          ),
        ],
        locale: englishLocale,
      );

      expect(
        find.text('Amounts are shown separately when currencies are mixed or unclear.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('$emptyDay'));
      await tester.tap(find.text('$emptyDay'));
      await tester.pumpAndSettle();
      await _scrollUntilVisible(tester, find.text('No reminders on this date'));

      expect(find.text('No reminders on this date'), findsOneWidget);
      expect(
        find.text(
          'Choose another date or switch back to the list view to browse everything.',
        ),
        findsOneWidget,
      );
    });
  });
}

Future<void> _scrollUntilVisible(WidgetTester tester, Finder finder) async {
  final homeScrollable = find.descendant(
    of: find.byType(ListView).first,
    matching: find.byType(Scrollable),
  ).first;
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: homeScrollable,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpHomeScreen(
  WidgetTester tester, {
  required List<ReminderItem> reminders,
  Locale locale = const Locale('ko', 'KR'),
}) async {
  final repository = _TestLifeAdminRepository(
    initialState: AppDataState(reminders: reminders, documents: const {}),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        lifeAdminRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: HomeScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpHomeRouter(
  WidgetTester tester, {
  required List<ReminderItem> reminders,
  Locale locale = const Locale('ko', 'KR'),
}) async {
  final repository = _TestLifeAdminRepository(
    initialState: AppDataState(reminders: reminders, documents: const {}),
  );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: HomeScreen()),
      ),
      GoRoute(
        path: '/reminders/:id',
        builder: (context, state) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text('detail-screen:${state.pathParameters['id']}'),
          ),
        ),
      ),
    ],
  );

  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        lifeAdminRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        locale: locale,
        supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ReminderItem _buildReminder({
  required String id,
  required String title,
  required DateTime dueAt,
  required double? amount,
  required String? currency,
}) {
  final now = DateTime.now();
  return ReminderItem(
    id: id,
    documentId: 'doc-$id',
    title: title,
    category: ReminderCategory.utilities,
    dueAt: dueAt,
    amount: amount,
    currency: currency,
    note: null,
    repeatRule: ReminderRepeatRule.none,
    status: ReminderStatus.upcoming,
    createdAt: now,
    updatedAt: now,
    sourceSubtitle: '테스트 문서',
    reminderLeadDays: 1,
  );
}

ReminderItem _buildReminderForToday({
  required String id,
  required String title,
  double? amount = 1000,
  String? currency = 'KRW',
}) {
  final now = DateTime.now();
  return _buildReminder(
    id: id,
    title: title,
    dueAt: DateTime(now.year, now.month, now.day, 9),
    amount: amount,
    currency: currency,
  );
}

int _firstDifferentDay(int today, List<int> candidates) {
  return candidates.firstWhere((day) => day != today);
}

int _nextDifferentDay(int today, Set<int> excludedDays) {
  for (final day in const [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28]) {
    if (day != today && !excludedDays.contains(day)) {
      return day;
    }
  }
  throw StateError('Could not find a spare calendar day for the test.');
}

class _TestLifeAdminRepository implements LifeAdminRepository {
  _TestLifeAdminRepository({required this.initialState});

  final AppDataState initialState;

  @override
  AppDataState loadInitialState() => initialState;

  @override
  Future<AppDataState> clearAll() async => const AppDataState(reminders: [], documents: {});

  @override
  Future<AppDataState> deleteReminder(AppDataState current, String reminderId) async {
    return current.copyWith(
      reminders: current.reminders.where((item) => item.id != reminderId).toList(),
    );
  }

  @override
  Future<AppDataState> updateReminder(AppDataState current, ReminderItem reminder) async {
    return current.copyWith(
      reminders: [
        for (final item in current.reminders)
          if (item.id == reminder.id) reminder else item,
      ],
    );
  }

  @override
  Future<AppDataState> upsertReminder(
    AppDataState current, {
    required ReminderItem reminder,
    required Document document,
  }) async {
    final existingIndex = current.reminders.indexWhere((item) => item.id == reminder.id);
    final reminders = [...current.reminders];
    if (existingIndex == -1) {
      reminders.add(reminder);
    } else {
      reminders[existingIndex] = reminder;
    }
    return current.copyWith(reminders: reminders);
  }
}
