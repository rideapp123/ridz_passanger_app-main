import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ridzs_passenger_app/core/services/navigation_service.dart';
import 'package:ridzs_passenger_app/models/common/user/user.dart';
import 'package:ridzs_passenger_app/stores/users/user_store.dart';
import 'package:ridzs_passenger_app/view/my_rewards/my_rewards.dart';
import 'ad_reward_test.dart' show FakeRewards, reward;

class HistoryRewards extends FakeRewards {
  List<Map<String, dynamic>> rows = [];
  final pages = <int>[];
  Completer<List<Map<String, dynamic>>>? pendingHistory;
  @override
  Future<List<Map<String, dynamic>>> history(String token,
      {int page = 1}) async {
    pages.add(page);
    if (pendingHistory != null) return pendingHistory!.future;
    return page == 1 ? rows : [reward()..['id'] = 'session21'];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HistoryRewards service;
  late UserStore store;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'token-a'});
    service = HistoryRewards();
    store = UserStore()..setLoggedInUser(User(id: 'p1'));
  });
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(Provider<UserStore>.value(
        value: store,
        child: MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            home: MyRewards(service: service))));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'disabled offers do not hide history or label legacy evidence as earned',
      (tester) async {
    service.offerFails = true;
    service.rows = [
      reward(),
      reward(status: 'completed')..['id'] = 'session2',
      reward(status: 'completed')
        ..['id'] = 'legacy'
        ..remove('rules')
    ];
    await mount(tester);
    expect(find.text('Reward confirmed'), findsOneWidget);
    expect(find.text('Reward needs review'), findsOneWidget);
    expect(find.byTooltip('Check reward'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Watch ad'))
            .onPressed,
        isNull);
    expect(service.keys, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('history pagination requests next page without creating rewards',
      (tester) async {
    service.rows = List.generate(20, (i) => reward()..['id'] = 'session$i');
    await mount(tester);
    await tester.scrollUntilVisible(find.text('Load more'), 500);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(service.pages, [1, 2]);
    expect(service.keys, isEmpty);
    expect(find.text('Load more'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('history ignores late responses after an account change',
      (tester) async {
    service.pendingHistory = Completer<List<Map<String, dynamic>>>();
    await tester.pumpWidget(Provider<UserStore>.value(
        value: store,
        child: MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            home: MyRewards(service: service))));
    await tester.pump();
    store.setLoggedInUser(User(id: 'p2'));
    FlutterSecureStorage.setMockInitialValues({'access_token': 'token-b'});
    service.pendingHistory!.complete([reward(status: 'completed')]);
    await tester.pumpAndSettle();
    expect(find.text('Reward confirmed'), findsNothing);
    expect(find.text('Sign in again to view your rewards.'), findsOneWidget);
    expect(service.offers, 0);
    await tester.pumpWidget(const SizedBox());
  });
}
