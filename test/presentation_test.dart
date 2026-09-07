import 'package:ridzs_passenger_app/core/services/navigation_service.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/view/home/main_page.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart';
import 'package:flutter/material.dart';
import 'package:ridzs_passenger_app/core/theme/size_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/core/theme/dark_theme.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/widgets/buttons/custom_button.dart';
import 'package:ridzs_passenger_app/widgets/buttons/custom_outlined_button.dart';
import 'package:ridzs_passenger_app/widgets/buttons/map_control_button.dart';
import 'package:ridzs_passenger_app/widgets/cards/title_row.dart';
import 'package:ridzs_passenger_app/widgets/containers/balance_summary.dart';

ThemeData previewTheme({bool dark = false}) => RidzsTheme.refine(ThemeData(
      useMaterial3: true,
      colorScheme: dark ? flexSchemeDark : flexSchemeLight,
      scaffoldBackgroundColor: dark ? const Color(0xff070707) : Colors.white,
      fontFamily: 'Poppins',
    ));

Widget host(Widget child, {bool dark = false, double scale = 1}) => MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      theme: previewTheme(dark: dark),
      home: Builder(builder: (context) {
        SizeConfig().init(context);
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: Scaffold(body: child),
        );
      }),
    );

void main() {
  setUpAll(() async {
    final loader = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  test('refinement preserves both existing palettes', () {
    expect(previewTheme().colorScheme, flexSchemeLight);
    expect(previewTheme(dark: true).colorScheme, flexSchemeDark);
    expect(previewTheme().textTheme.labelLarge!.letterSpacing, 0);
  });

  testWidgets('primary action supports taps, keyboard and disabled states',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(Center(
      child: CustomButton(text: 'Continue', onTap: () => taps++),
    )));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 2);

    await tester.pumpWidget(host(const CustomButton(text: 'Continue')));
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
  });

  testWidgets('loading blocks duplicate actions without resizing',
      (tester) async {
    var taps = 0;
    Widget buttons(bool loading) => host(
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            CustomButton(
                text: 'Confirm this ride',
                isLoading: loading,
                onTap: () => taps++),
            CustomOutlinedButton(
                text: 'Try again', isLoading: loading, onTap: () => taps++),
          ]),
        ),
        scale: 2);
    await tester.pumpWidget(buttons(false));
    final primarySize = tester.getSize(find.byType(ElevatedButton));
    final secondarySize = tester.getSize(find.byType(OutlinedButton));
    await tester.pumpWidget(buttons(true));
    expect(tester.getSize(find.byType(ElevatedButton)), primarySize);
    expect(tester.getSize(find.byType(OutlinedButton)), secondarySize);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
    expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull);
    await tester.tap(find.byType(ElevatedButton));
    await tester.tap(find.byType(OutlinedButton));
    expect(taps, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('map controls have tooltips, 48px targets and working callbacks',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(Center(
        child: MapControlButton(
      icon: Icons.my_location_rounded,
      tooltip: 'My location',
      onPressed: () => taps++,
    ))));
    expect(tester.getSize(find.byType(MapControlButton)), const Size(48, 48));
    await tester.tap(find.byTooltip('My location'));
    expect(taps, 1);
  });

  testWidgets('long balance and labels fit a narrow layout with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var taps = 0;
    await tester.pumpWidget(host(
        SingleChildScrollView(
            child: Column(children: [
          const TitleRowWidget(text: 'Payment adjustment and recovery'),
          BalanceSummary(
            label: 'Available balance',
            amount: r'$123,456,789.00',
            actionLabel: 'Top up wallet',
            actionIcon: Icons.add,
            onAction: () => taps++,
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                text: 'Confirm your payment and continue',
                onTap: () {},
              )),
        ])),
        scale: 2));
    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('destination sheet scrolls with recent trips on a small screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MapStore();
    addTearDown(store.dispose);
    store.rideHistory = [
      Ride.fromJson({
        'pickup': {'address': 'Downtown transit centre, main entrance'},
        'destination': {
          'address': 'Edmonton International Airport, departures terminal'
        },
      })
    ];
    await tester.pumpWidget(host(
        Align(
          alignment: Alignment.bottomCenter,
          child: DestinationSearchWidget(mapStore: store),
        ),
        scale: 2));
    await tester.pumpAndSettle();
    expect(find.text('Where to?'), findsOneWidget);
    expect(tester.getSize(find.byType(DestinationSearchWidget)).height,
        lessThanOrEqualTo(568 * .6));
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final variant in [
    (name: 'compact', size: const Size(320, 780), dark: false, scale: 1.0),
    (name: 'phone', size: const Size(390, 844), dark: false, scale: 1.0),
    (name: 'dark', size: const Size(390, 844), dark: true, scale: 1.0),
    (name: 'large_text', size: const Size(320, 1100), dark: false, scale: 2.0),
    (name: 'tablet', size: const Size(768, 1024), dark: false, scale: 1.0),
  ]) {
    testWidgets('presentation golden ${variant.name}', (tester) async {
      tester.view.physicalSize = variant.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host(
        RepaintBoundary(
          key: const ValueKey('presentation'),
          child: ColoredBox(
            color: variant.dark ? const Color(0xff070707) : Colors.white,
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TitleRowWidget(text: 'My wallet'),
                BalanceSummary(
                  label: 'Available balance',
                  amount: r'$248.50',
                  actionLabel: 'Top up wallet',
                  actionIcon: Icons.add,
                  onAction: () {},
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent transactions',
                            style: previewTheme(dark: variant.dark)
                                .textTheme
                                .titleMedium),
                        const SizedBox(height: 16),
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.receipt_long_outlined),
                          title: Text('Ride payment'),
                          subtitle: Text('Today, 10:42 AM'),
                        ),
                        const SizedBox(height: 20),
                        const TextField(
                            decoration: InputDecoration(
                                labelText: 'Amount',
                                hintText: '0.00',
                                prefixText: '\$ ')),
                        const SizedBox(height: 20),
                        CustomButton(text: 'Confirm payment', onTap: () {}),
                        const SizedBox(height: 12),
                        SizedBox(
                            width: double.infinity,
                            child: CustomOutlinedButton(
                                text: 'Cancel', onTap: () {})),
                        const SizedBox(height: 24),
                        Row(children: [
                          MapControlButton(
                              icon: Icons.menu_rounded,
                              tooltip: 'Open menu',
                              onPressed: () {}),
                          const SizedBox(width: 12),
                          MapControlButton(
                              icon: Icons.my_location_rounded,
                              tooltip: 'My location',
                              onPressed: () {}),
                        ]),
                      ]),
                ),
              ],
            )),
          ),
        ),
        dark: variant.dark,
        scale: variant.scale,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(find.byKey(const ValueKey('presentation')),
          matchesGoldenFile('goldens/presentation_${variant.name}.png'));
    });
  }
}
