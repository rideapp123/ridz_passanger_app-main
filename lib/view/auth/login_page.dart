import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/terms_and_condition_screen.dart';

class LoginPage extends HookWidget {
  const LoginPage({super.key});

  static const String routeNamed = 'LoginPage';

  @override
  Widget build(BuildContext context) {
    final selectedCountry = useState<Country>(Country.from(json: {
      'e164_cc': '91',
      'iso2_cc': 'IN',
      'e164_sc': 0,
      'geographic': true,
      'level': 0,
      'name': 'India',
      'example': '9123456789',
      'display_name': 'India (IN) [+91]',
      'display_name_no_e164_cc': 'India (IN)',
      'e164_key': '91-IN-0',
      'capital': 'New Delhi',
      'language': 'Hindi, English',
      'calling_code': '+91',
      'flag_emoji': '🇮🇳',
    }));
    final loginInFormKey = useRef(GlobalKey<FormState>());
    final mobileNumber = useTextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        leading: CommonIconButton(
          icon: Icons.arrow_back,
          onPressed: () {
            NavigationService().pop();
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: loginInFormKey.value,
            child: Observer(
              builder: (context) {
                return Padding(
                  padding: AppPadding.containerHorizontal40,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: SizeConfig.screenHeight * 0.20),
                        Text(AppStrings.logInWithMobileNumber,
                            style: AppTextStyles.style23W600.copyWith(
                                color: Theme.of(context).colorScheme.tertiary)),
                        SizedBox(height: SizeConfig.screenHeight * 0.03),
                        customTextFormField(
                          controller: mobileNumber,
                          inputFormatters: [
                            PhoneInputFormatter(
                              shouldCorrectNumber: true,
                              allowEndlessPhone: true,
                              defaultCountryCode:
                                  selectedCountry.value.countryCode,
                            ),
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                                selectedCountry.value.example.length),
                          ],
                          textInputType: TextInputType.phone,
                          customValidator: (value) {
                            if (mobileNumber.text.isEmpty) {
                              return 'Please enter your mobile number';
                            } else if (mobileNumber.text.length !=
                                selectedCountry.value.example.length) {
                              return 'Please enter your mobile number in the correct format';
                            }
                            return null;
                          },
                          label: AppStrings.mobileNumber,
                          prefix: GestureDetector(
                            onTap: () {
                              CountrySelector(
                                context: context,
                                countryPreferred: <String>['US'],
                                showPhoneCode: true,
                                appBarTitle: "Select Country",
                                onSelect: (Country country) {
                                  selectedCountry.value = country;
                                },
                                listType: ListType.list,
                                appBarBackgroundColour:
                                    Theme.of(context).colorScheme.secondary,
                                appBarFontSize: 20,
                                appBarFontStyle: FontStyle.normal,
                                appBarFontWeight: FontWeight.bold,
                                appBarTextColour:
                                    Theme.of(context).colorScheme.tertiary,
                                appBarTextCenterAlign: true,
                                backgroundColour:
                                    Theme.of(context).colorScheme.secondary,
                                backIcon: Icons.arrow_back,
                                backIconColour:
                                    Theme.of(context).colorScheme.tertiary,
                                countryFontStyle: FontStyle.normal,
                                countryFontWeight: FontWeight.bold,
                                countryTextColour:
                                    Theme.of(context).colorScheme.tertiary,
                                countryTitleSize: 16,
                                dividerColour:
                                    Theme.of(context).colorScheme.tertiary,
                                searchBarAutofocus: true,
                                searchBarIcon: Icons.search,
                                searchBarBackgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                searchBarBorderColor:
                                    Theme.of(context).colorScheme.tertiary,
                                searchBarBorderWidth: 2,
                                searchBarOuterBackgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                searchBarTextColor:
                                    Theme.of(context).colorScheme.tertiary,
                                searchBarHintColor:
                                    Theme.of(context).colorScheme.tertiary,
                                countryTheme: const CountryThemeData(
                                  appBarBorderRadius: 10,
                                ),
                                showSearchBox: true,
                              );
                            },
                            child: SizedBox(
                              width: SizeConfig.screenWidth * 0.29,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 5),
                                  Text(
                                      selectedCountry.value.flagEmojiText ?? '',
                                      style: AppTextStyles.style23W500.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary)),
                                  Icon(Icons.keyboard_arrow_down_sharp,
                                      size: 25,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                  const SizedBox(width: 5),
                                  Text(
                                      selectedCountry.value.callingCode
                                          .toString(),
                                      style: AppTextStyles.style15w400.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary)),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ),
                          labelColor: Theme.of(context).colorScheme.tertiary,
                          hintText: selectedCountry.value.example,
                        ),
                        SizedBox(height: SizeConfig.screenHeight * 0.05),
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: AppStrings.byContinuingYouAgreeToThe,
                              style: AppTextStyles.link.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer),
                              children: [
                                TextSpan(
                                  text: AppStrings.terms,
                                  style: AppTextStyles.link.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      NavigationService().navigateTo(
                                        TermsAndConditionScreen.routeNamed,
                                      );
                                    },
                                ),
                                TextSpan(
                                  text: ' & \n',
                                  style: AppTextStyles.link.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer),
                                ),
                                TextSpan(
                                  text: AppStrings.privacyPolicy,
                                  style: AppTextStyles.link.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                                TextSpan(
                                  text: AppStrings.ofRidz,
                                  style: AppTextStyles.link.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          onTap: () async {
                            if (loginInFormKey.value.currentState!.validate()) {
                              await userStoreProvider().requestCode(
                                  '${selectedCountry.value.callingCode}${mobileNumber.text}');
                            }
                          },
                          isLoading: userStoreProvider().isVerifying,
                          borderRadius: 16,
                          text: AppStrings.login,
                          color: Theme.of(context).colorScheme.primary,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(AppRadius.common)),
                                    gradient: Styles
                                        .COLOR_PRIMARY_LINEAR_GRADIENT_LOGIN_SCREEN_LEFT),
                              ),
                            ),
                            Text(
                              '   ${AppStrings.orContinueWith}   ',
                              style: AppTextStyles.link.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer),
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(AppRadius.common)),
                                    gradient: Styles
                                        .COLOR_PRIMARY_LINEAR_GRADIENT_LOGIN_SCREEN_RIGHT),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: BackgroundWithShadowContainer(
                                onTap: () {
                                  NavigationService().navigateTo(
                                      LoginWithEmailScreen.routeNamed);
                                },
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryFixedVariant
                                    .withValues(alpha: 0.25),
                                shadowColor:
                                    Theme.of(context).colorScheme.secondary,
                                childWidget: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomImageView(
                                      imagePath: Assets.icMail,
                                      height: 25,
                                      width: 25,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: BackgroundWithShadowContainer(
                                onTap: () {
                                  userStoreProvider().signInWithGoogle();
                                },
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryFixedVariant
                                    .withValues(alpha: 0.25),
                                shadowColor:
                                    Theme.of(context).colorScheme.secondary,
                                childWidget: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomImageView(
                                      imagePath: Assets.icGoogle,
                                      height: 25,
                                      width: 25,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
