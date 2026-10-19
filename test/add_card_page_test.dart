import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ridzs_passenger_app/core/services/navigation_service.dart';
import 'package:ridzs_passenger_app/core/theme/size_config.dart';
import 'package:ridzs_passenger_app/stores/users/user_store.dart';
import 'package:ridzs_passenger_app/view/home/widget/add_new_card.dart';
import 'presentation_test.dart' show previewTheme;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    // Native text entry is device acceptance; this stub checks Flutter layout and controls.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            SystemChannels.platform_views, (_) async => null);
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, null);
  });

  for (final width in [320.0, 390.0, 800.0]) {
    testWidgets('secure card form and action states fit width $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = UserStore();
      await tester.pumpWidget(Provider<UserStore>.value(
        value: store,
        child: MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          theme: previewTheme(),
          home: Builder(builder: (context) {
            SizeConfig().init(context);
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: const AddNewCard(),
            );
          }),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TextFormField), findsOneWidget);
      final native = tester.widget<CardFormField>(find.byType(CardFormField));
      expect(native.dangerouslyGetFullCardDetails, isFalse);
      expect(native.dangerouslyUpdateFullCardDetails, isFalse);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull);
      native.onCardChanged!(const CardFieldInputDetails(complete: true));
      await tester.pump();
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull);
      final size = tester.getSize(find.byType(FilledButton));
      store.isAddingCard = true;
      await tester.pump();
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull);
      expect(tester.widget<CardFormField>(find.byType(CardFormField)).disabled,
          isTrue);
      expect(tester.getSize(find.byType(FilledButton)), size);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
