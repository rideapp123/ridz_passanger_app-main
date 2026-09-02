import 'package:bot_toast/bot_toast.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/main.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/configs/app_routes.dart';
import '../../../core/theme/dark_theme.dart';
import '../../../core/theme/light_theme.dart';
import '../splash/splash_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final userStore = UserStore();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userStore.getSavedTheme();
    });

    Future.wait([
      firebaseNotificationService.registerNotification(),
      firebaseNotificationService.setupInteractedMessage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Observer(builder: (context) {
      final themeMode = userStore.themeMode;
      return SkeletonizerConfig(
        data: SkeletonizerConfigData(
          justifyMultiLineText: true,
          containersColor: const Color(0xfff5f5f5),
          effect: const ShimmerEffect(duration: Duration(milliseconds: 1500)),
          textBorderRadius: TextBoneBorderRadius(BorderRadius.circular(10)),
          ignoreContainers: false,
          enableSwitchAnimation: false,
          switchAnimationConfig: const SwitchAnimationConfig(
            duration: Duration(milliseconds: 500),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: MaterialApp(
            theme: FlexThemeData.light(
              scheme: FlexScheme.blumineBlue,
              colorScheme: flexSchemeLight,
              scaffoldBackground: flexSchemeLight.secondary,
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              extensions: [
                SkeletonizerConfigData(
                  justifyMultiLineText: true,
                  containersColor: const Color(0xfff5f5f5),
                  effect: const ShimmerEffect(
                      duration: Duration(milliseconds: 1500)),
                  textBorderRadius:
                      TextBoneBorderRadius(BorderRadius.circular(10)),
                  ignoreContainers: false,
                  enableSwitchAnimation: false,
                  switchAnimationConfig: const SwitchAnimationConfig(
                    duration: Duration(milliseconds: 500),
                  ),
                ),
              ],
              blendLevel: 7,
              subThemesData: const FlexSubThemesData(
                blendOnLevel: 10,
                blendOnColors: false,
                useMaterial3Typography: true,
                useM2StyleDividerInM3: true,
                alignedDropdown: true,
                useInputDecoratorThemeInDialogs: true,
              ),
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              useMaterial3: true,
              swapLegacyOnMaterial3: true,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
            darkTheme: FlexThemeData.dark(
              scheme: FlexScheme.blumineBlue,
              colorScheme: flexSchemeDark,
              surfaceMode:
                  FlexSurfaceMode.levelSurfacesLowScaffoldVariantDialog,
              blendLevel: 19,
              subThemesData: const FlexSubThemesData(
                blendOnLevel: 20,
                useMaterial3Typography: true,
                useM2StyleDividerInM3: true,
                alignedDropdown: true,
                useInputDecoratorThemeInDialogs: true,
              ),
              extensions: [
                SkeletonizerConfigData.dark(
                  justifyMultiLineText: true,
                  containersColor: const Color(0xff1C1C1C),
                  effect: const ShimmerEffect(
                      duration: Duration(milliseconds: 1500)),
                  textBorderRadius:
                      TextBoneBorderRadius(BorderRadius.circular(10)),
                  ignoreContainers: false,
                  enableSwitchAnimation: false,
                  switchAnimationConfig: const SwitchAnimationConfig(
                    duration: Duration(milliseconds: 500),
                  ),
                ),
              ],
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              useMaterial3: true,
              swapLegacyOnMaterial3: true,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
            themeMode: themeMode,
            title: 'Ridzs',
            debugShowCheckedModeBanner: false,
            onGenerateRoute: generateRoute,
            home: const SplashScreen(),
            navigatorKey: NavigationService.navigatorKey,
            builder: BotToastInit(),
            navigatorObservers: [
              BotToastNavigatorObserver(),
              KeyboardStateNavigatorObserver(),
            ],
          ),
        ),
      );
    });
  }
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
