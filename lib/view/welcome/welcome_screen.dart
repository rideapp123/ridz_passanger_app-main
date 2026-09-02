import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class WelcomeScreen extends HookWidget {
  const WelcomeScreen({super.key});

  static const String routeNamed = 'WelcomeScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              Padding(
                padding: AppPadding.containerHorizontal20,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rid',
                        style: AppTextStyles.style64W700.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
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
              SizedBox(height: SizeConfig.screenHeight * 0.03),
              Align(
                alignment: Alignment.centerRight,
                child: CustomImageView(
                  imagePath: Assets.splashScreen,
                  fit: BoxFit.cover,
                  height: SizeConfig.screenHeight * 0.4,
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              Padding(
                padding: AppPadding.containerHorizontal20,
                child: Row(
                  children: [
                    Text(
                      AppStrings.welcomeTo,
                      style: AppTextStyles.style29white.copyWith(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    Text(
                      '\u{1F44B}',
                      style: AppTextStyles.style29white.copyWith(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppPadding.containerHorizontal20,
                child: Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style29white.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.03),
              Padding(
                padding: AppPadding.containerHorizontal20,
                child: Text(
                  AppStrings.splashScreenMsg,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.style15white
                      .copyWith(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.05),
              Padding(
                padding: AppPadding.containerHorizontal20,
                child: CustomButton(
                  onTap: () {
                    NavigationService().navigateTo(LoginPage.routeNamed);
                  },
                  borderRadius: 16,
                  text: AppStrings.getStarted,
                  color: Theme.of(context).colorScheme.primary,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
