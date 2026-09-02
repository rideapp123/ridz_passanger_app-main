import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ridzs_passenger_app/core/theme/app_layout.dart';
import 'package:ridzs_passenger_app/core/theme/app_text_styles.dart';
import '../../../stores/ui/ui_store.dart';
import '../../../stores/users/user_store.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  static const String routeNamed = 'SplashPage';

  @override
  Widget build(BuildContext context) {
    final userStore = userStoreProvider();
    useEffect(() {
      Future<void> navigate() async {
        await Future.wait([
          uiStoreProvider().initApp(),
          userStore.getSavedTheme(),
          userStoreProvider().getMe(),
        ]);
      }

      navigate();

      return null;
    }, []);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppPadding.containerHorizontal20,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'Rid',
                      style: AppTextStyles.style64W700.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                      )),
                  TextSpan(
                    text: 'Zs',
                    style: AppTextStyles.style64W700.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
