import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobx/mobx.dart';
import 'package:ridzs_passenger_app/core/theme/app_text_styles.dart';
import 'package:ridzs_passenger_app/view/welcome/welcome_screen.dart';
import '../../../core/services/navigation_service.dart';
import '../../../stores/ui/ui_store.dart';
import '../../../stores/users/user_store.dart';

class LoadingPage extends HookWidget {
  const LoadingPage({super.key});

  static const routeNamed = 'LoadingPage';

  @override
  Widget build(BuildContext context) {
    // Use `useEffect` to handle side-effects like `initState` and `dispose`
    useEffect(() {
      Future<void> init() async {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          NavigationService().replaceWith(WelcomeScreen.routeNamed);
          var user = userStoreProvider().loggedInUser;
          if (user != null) {
            await userStoreProvider().registerFCMToken();
          }

          // if (user != null && user.hasCommunityAccess) {
          // await CommunityPageStoreProvider().loadPages();
          // Future.wait([
          //   CommunityPostStoreProvider().loadGlobalFeedPosts(),
          // ]);
          // }

          Future.wait([
            // Add necessary futures here
          ]);

          Future.wait([
            // Add necessary futures here
          ]);

          // NavigationService().replaceWith(MainPage.routeNamed);
        });
      }

      init();

      // ReactionDisposer for MobX state management
      final reactionDisposer = reaction(
        (_) => userStoreProvider().loggedInUser != null
            ? uiStoreProvider().currentNavigationIndex == 0
            : true,
        (bool v) {
          if (v) {
            // NavigationService().replaceWith(MainPage.routeNamed);
          }
        },
      );

      return reactionDisposer.call;
    }, []); // Empty dependency array means this runs once

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: 'Rid',
                  style: AppTextStyles.style64W700
                      .copyWith(color: Theme.of(context).colorScheme.tertiary)),
              TextSpan(
                  text: 'Zs',
                  style: AppTextStyles.style64W700
                      .copyWith(color: Theme.of(context).colorScheme.primary)),
            ])),
            const SizedBox(height: 20),
            Text(
              'Ridzs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                color: Theme.of(context).colorScheme.tertiary,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
