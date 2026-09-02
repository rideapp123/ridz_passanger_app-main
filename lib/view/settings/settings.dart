import 'dart:developer';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/home/app.dart';
import 'package:ridzs_passenger_app/view/terms_and_condition_screen.dart';
import 'package:ridzs_passenger_app/widgets/dialogs/app_dialog.dart';

class Settings extends HookWidget {
  static const String routeNamed = 'Settings';

  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userStore = userStoreProvider();
    final themeColor = Theme.of(context).colorScheme;

    final selectedTheme = useState('');

    useEffect(() {
      log('Theme mode: ${userStore.themeMode.name}');
      selectedTheme.value = '${userStore.themeMode.name.capitalize} Theme';
      return;
    }, []);

    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TitleRowWidget(
              text: AppStrings.settings,
              imageColor: themeColor.tertiary,
              textStyle: AppTextStyles.style23W600.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),

            //
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //
                    Text(
                      'General Settings',
                      style: AppTextStyles.style12W500.copyWith(
                        color: themeColor.tertiary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: themeColor.surfaceContainerHigh,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          DetailsContainer(
                            iconPath: Assets.savePlaceIc,
                            themeColor: themeColor,
                            title: 'Add Saved places',
                          ),
                          Divider(
                            thickness: .6,
                            color: themeColor.tertiaryFixedDim
                                .withValues(alpha: 0.3),
                          ),
                          DetailsContainer(
                            iconPath: isDarkMode
                                ? Assets.safetyIc2Dark
                                : Assets.safetyIc2,
                            themeColor: themeColor,
                            title: 'Safety tools',
                          ),
                          Divider(
                            thickness: .6,
                            color: themeColor.tertiaryFixedDim
                                .withValues(alpha: 0.3),
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AppDialog(
                                    isDelete: true,
                                    onYesPressed: () {
                                      NavigationService().pop();
                                      userStoreProvider().logoutUser(
                                        ignoreApiCall: true,
                                      );
                                    },
                                    subTitle: AppStrings.deletePermissionText,
                                    title: AppStrings.deleteAccount,
                                    actionButtonTitle: 'Delete',
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                    icon: Assets.deleteIc,
                                  );
                                },
                              );
                            },
                            child: DetailsContainer(
                              iconPath: Assets.deleteIc,
                              themeColor: themeColor,
                              title: 'Delete Account',
                              subTitle:
                                  'Permanently remove account & data proceed with caution',
                              titleTextStyle: AppTextStyles.body.copyWith(
                                color: themeColor.error,
                                fontWeight: FontWeight.w500,
                              ),
                              subTitleTextStyle:
                                  AppTextStyles.style10W400.copyWith(
                                color: themeColor.surfaceDim,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      'Appearance',
                      style: AppTextStyles.style12W500.copyWith(
                        color: themeColor.tertiary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: themeColor.surfaceContainerHigh,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PopupMenuButton(
                            color: themeColor.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onSelected: (value) async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (_) {
                                  return AppDialog(
                                    onYesPressed: () {
                                      NavigationService().pop(true);
                                    },
                                    subTitle:
                                        'A quick reload is needed to apply your theme',
                                    title: 'Apply Changes',
                                    actionButtonTitle: 'Apply Changes',
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    iconColor:
                                        Theme.of(context).colorScheme.primary,
                                    icon: Assets.reportIc,
                                  );
                                },
                              );

                              if (result == true) {
                                if (!context.mounted) return;
                                selectedTheme.value =
                                    '${value.name.capitalize} Theme';
                                userStore.setThemeMode(value);

                                RestartWidget.restartApp(context);
                                NavigationService().pushNameAndRemoveUntil(
                                  MainPage.routeNamed,
                                );

                                // final mapStore = mapStoreProvider();
                                // rootBundle
                                //     .loadString(isDarkMode
                                //         ? 'assets/map_style/map_style_dark.json'
                                //         : 'assets/map_style/map_style.json')
                                //     .then((string) {
                                //   mapStore.mapStyleString = string;
                                //   if (!context.mounted) return;
                                // });
                              }
                            },
                            itemBuilder: (_) {
                              return ThemeMode.values.map((option) {
                                return PopupMenuItem<ThemeMode>(
                                  value: option,
                                  child: Text(
                                    '${option.name.capitalize} Theme',
                                    style: AppTextStyles.style16W600.copyWith(
                                      color: themeColor.tertiary,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            child: DetailsContainer(
                              iconPath: '',
                              themeColor: themeColor,
                              title: 'Theme',
                              value: selectedTheme.value,
                            ),
                          ),
                          Divider(
                            thickness: .6,
                            color: themeColor.tertiaryFixedDim
                                .withValues(alpha: 0.3),
                          ),
                          DetailsContainer(
                            iconPath: '',
                            themeColor: themeColor,
                            title: 'Language',
                            value: 'US English',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Text(
                      'Legal',
                      style: AppTextStyles.style12W500.copyWith(
                        color: themeColor.tertiary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: themeColor.surfaceContainerHigh,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              NavigationService().navigateTo(
                                TermsAndConditionScreen.routeNamed,
                              );
                            },
                            child: DetailsContainer(
                              iconPath: '',
                              themeColor: themeColor,
                              title: 'Terms of Services',
                            ),
                          ),
                          Divider(
                            thickness: .6,
                            color: themeColor.tertiaryFixedDim
                                .withValues(alpha: 0.3),
                          ),
                          DetailsContainer(
                            iconPath: '',
                            themeColor: themeColor,
                            title: 'Privacy Policy',
                          ),
                          Divider(
                            thickness: .6,
                            color: themeColor.tertiaryFixedDim
                                .withValues(alpha: 0.3),
                          ),
                          DetailsContainer(
                            iconPath: '',
                            themeColor: themeColor,
                            title: 'License',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsContainer extends StatelessWidget {
  final ColorScheme themeColor;
  final String title;
  final String iconPath;
  final String? value;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;
  final String? subTitle;

  const DetailsContainer({
    super.key,
    required this.themeColor,
    required this.title,
    required this.iconPath,
    this.value,
    this.titleTextStyle,
    this.subTitleTextStyle,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              //
              if (iconPath.isNotEmpty)
                CustomImageView(
                  svgPath: iconPath,
                  height: 24,
                  width: 24,
                ),

              if (iconPath.isNotEmpty) const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titleTextStyle ??
                          AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                            color: themeColor.tertiary,
                          ),
                    ),
                    subTitle != null
                        ? Text(
                            subTitle!,
                            style: subTitleTextStyle ??
                                AppTextStyles.style10W400.copyWith(),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              if (value != null)
                Text(
                  value!,
                  style: AppTextStyles.style12W500.copyWith(
                    color: themeColor.onSecondaryFixed,
                  ),
                ),

              if (value != null) const SizedBox(width: 10),

              Icon(
                Icons.arrow_forward_ios_outlined,
                color: themeColor.surfaceDim,
                size: 16,
              )
            ],
          ),
        ),
      ],
    );
  }
}
