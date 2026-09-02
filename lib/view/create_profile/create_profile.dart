import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/models/common/user/card.dart' as card;
import '../../models/contracts/user_details_update_contract.dart';

class CreateProfile extends HookWidget {
  static const String routeNamed = 'CreateProfile';

  const CreateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = userStoreProvider().loggedInUser;
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
    final nameController =
        useState(useTextEditingController(text: user?.username ?? ''));
    final emailController =
        useState(useTextEditingController(text: user?.email ?? ''));
    final mobileController =
        useState(useTextEditingController(text: user?.mobileNumber ?? ''));
    final cardNumber = useState('');
    final name = useState('');
    final cardNumberController = useTextEditingController();
    final cardHolderController = useTextEditingController();
    final cvvController = useTextEditingController();
    final expiryDateController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final cardFormKey = useMemoized(() => GlobalKey<FormState>());
    final themeColor = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        child: Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          decoration: BoxDecoration(color: themeColor.primary),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: AppPadding.scaffoldWithTop,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Spacer(),
                    Text(
                      AppStrings.createProfile,
                      style: AppTextStyles.style23W600
                          .copyWith(color: themeColor.secondary),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        NavigationService().pushNameAndRemoveUntil(
                          MainPage.routeNamed,
                        );
                      },
                      child: Text(
                        AppStrings.skip,
                        style: AppTextStyles.style12W600
                            .copyWith(color: themeColor.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.03),
              Container(
                height: SizeConfig.screenHeight * 0.84,
                width: SizeConfig.screenWidth,
                decoration: BoxDecoration(
                  color: themeColor.secondary,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Padding(
                  padding: AppPadding.scaffold,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //
                              SizedBox(height: SizeConfig.screenHeight * 0.02),
                              Text(
                                AppStrings.generalDetails,
                                style: AppTextStyles.style15white,
                              ),
                              SizedBox(height: SizeConfig.screenHeight * 0.03),
                              customTextFormField(
                                controller: nameController.value,
                                inputTextColor: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                                label: AppStrings.name,
                                hintText: 'Andrew Ainsley',
                                onChanged: (value) {
                                  name.value = value;
                                },
                                customValidator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Name is required';
                                  }
                                  return null;
                                },
                              ),
                              if ((user?.isEmailVerified ?? false))
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.03),
                              if ((user?.isEmailVerified ?? false))
                                customTextFormField(
                                  readOnly: true,
                                  controller: emailController.value,
                                  inputTextColor: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer,
                                  label: AppStrings.email,
                                  textInputType: TextInputType.emailAddress,
                                  hintText: AppStrings.enterYourMail,
                                  onChanged: (value) {
                                    name.value = value;
                                  },
                                  customValidator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    return null;
                                  },
                                ),
                              if ((user?.isMobileVerified ?? false))
                                SizedBox(
                                    height: SizeConfig.screenHeight * 0.03),
                              if ((user?.isMobileVerified ?? false))
                                customTextFormField(
                                  controller: mobileController.value,
                                  inputTextColor: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer,
                                  // inputFormatters: [
                                  //   PhoneInputFormatter(
                                  //     shouldCorrectNumber: true,
                                  //     allowEndlessPhone: true,
                                  //     defaultCountryCode:
                                  //     selectedCountry.value.countryCode,
                                  //   ),
                                  //   FilteringTextInputFormatter.digitsOnly,
                                  //   LengthLimitingTextInputFormatter(
                                  //       selectedCountry.value.example.length),
                                  // ],
                                  // textInputType: TextInputType.phone,
                                  // customValidator: (value) {
                                  //   if (mobileController.text.isEmpty) {
                                  //     return 'Please enter your mobile number';
                                  //   } else if (mobileController.text.length !=
                                  //       selectedCountry.value.example.length) {
                                  //     return 'Please enter your mobile number in the correct format';
                                  //   }
                                  //   return null;
                                  // },
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
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        appBarFontSize: 20,
                                        appBarFontStyle: FontStyle.normal,
                                        appBarFontWeight: FontWeight.bold,
                                        appBarTextColour: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        appBarTextCenterAlign: true,
                                        backgroundColour: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        backIcon: Icons.arrow_back,
                                        backIconColour: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        countryFontStyle: FontStyle.normal,
                                        countryFontWeight: FontWeight.bold,
                                        countryTextColour: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        countryTitleSize: 16,
                                        dividerColour: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        searchBarAutofocus: true,
                                        searchBarIcon: Icons.search,
                                        searchBarBackgroundColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        searchBarBorderColor: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        searchBarBorderWidth: 2,
                                        searchBarOuterBackgroundColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        searchBarTextColor: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        searchBarHintColor: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        countryTheme: const CountryThemeData(
                                          appBarBorderRadius: 10,
                                        ),
                                        showSearchBox: true,
                                      );
                                    },
                                    child: SizedBox(
                                      width: SizeConfig.screenWidth * 0.29,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(width: 5),
                                          Text(
                                              selectedCountry
                                                      .value.flagEmojiText ??
                                                  '',
                                              style: AppTextStyles.style23W500
                                                  .copyWith(
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
                                              style: AppTextStyles.style15w400
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary)),
                                          const SizedBox(width: 5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  hintText: selectedCountry.value.example,
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: SizeConfig.screenHeight * 0.03),
                        //
                        Observer(builder: (context) {
                          return CustomButton(
                            height: 50,
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                await userStoreProvider().updateUser(
                                  UserDetailsUpdateContract(
                                    username: nameController.value.text,
                                    email: emailController.value.text,
                                    mobileNumber: mobileController.value.text,
                                  ),
                                );

                                if (userStoreProvider().isError == false) {
                                  NavigationService().pushNameAndRemoveUntil(
                                    MainPage.routeNamed,
                                  );
                                }
                              }
                            },
                            text: 'Update',
                            isLoading: userStoreProvider().isLoginLoading,
                          );
                        }),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.cardDetails,
                          style: AppTextStyles.style15white,
                        ),
                        const SizedBox(height: 24),

                        Form(
                          key: cardFormKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //
                              customTextFormField(
                                controller: cardHolderController,
                                inputTextColor: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                                label: AppStrings.cardHolderName,
                                hintText: 'Andrew Ainsley',
                                onChanged: (value) {
                                  name.value = value;
                                },
                                customValidator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Card Holder Name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              customTextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CardNumberInputFormatter(),
                                ],
                                maxLength: 19,
                                customValidator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Card Number is required';
                                  }
                                  return null;
                                },
                                textInputType: TextInputType.number,
                                controller: cardNumberController,
                                onChanged: (value) {
                                  cardNumber.value = value;
                                },
                                inputTextColor: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                                label: AppStrings.cardNumber,
                                hintText: '2672 4738 7837 7285',
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: customTextFormField(
                                      // readOnly: true,
                                      inputFormatters: [DateInputFormatter()],
                                      textInputType: TextInputType.number,
                                      suffix: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // InkWell(
                                          //     onTap: () {
                                          //       showDialog(
                                          //         barrierColor:
                                          //             Theme.of(context)
                                          //                 .colorScheme
                                          //                 .secondary,
                                          //         context: context,
                                          //         builder:
                                          //             (BuildContext context) {
                                          //           return DatePickerDialogBox(
                                          //             selectedDate: (value) {
                                          //               expiryDateController
                                          //                       .text =
                                          //                   DateFormat('MM/yy')
                                          //                       .format(value);
                                          //             },
                                          //           );
                                          //         },
                                          //       );
                                          //     },
                                          //     child: CustomImageView(
                                          //       imagePath: Assets.icCalendar,
                                          //       height: 20,
                                          //       width: 20,
                                          //     )),
                                        ],
                                      ),
                                      customValidator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Expiry Date is required';
                                        }
                                        return null;
                                      },
                                      controller: expiryDateController,
                                      inputTextColor: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer,
                                      label: AppStrings.expiryDate,
                                      hintText: AppStrings.expiryDate,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: customTextFormField(
                                      textInputType: TextInputType.number,
                                      controller: cvvController,
                                      inputTextColor: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer,
                                      label: AppStrings.cvv,
                                      hintText: '699',
                                      customValidator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'CVV is required';
                                        }
                                        if (value.length == 3 ||
                                            value.length == 4) {
                                          return null; // CVV is valid
                                        } else {
                                          return 'Invalid CVV';
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                        ),

                        Observer(builder: (context) {
                          return CustomButton(
                            height: 50,
                            onTap: () async {
                              if (cardFormKey.currentState!.validate()) {
                                await userStoreProvider().updateUser(
                                  UserDetailsUpdateContract(
                                    username: nameController.value.text,
                                    email: emailController.value.text,
                                    mobileNumber: mobileController.value.text,
                                    card: card.CardModel(
                                      holderName: nameController.value.text,
                                      cardNumber: cardNumber.value,
                                      expiryDate: expiryDateController.text,
                                      cvv: cvvController.text,
                                    ),
                                  ),
                                );

                                if (userStoreProvider().isError == false) {
                                  NavigationService().pushNameAndRemoveUntil(
                                    MainPage.routeNamed,
                                  );
                                }
                              }
                            },
                            text: AppStrings.addNewCard,
                            isLoading: userStoreProvider().isLoginLoading,
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
