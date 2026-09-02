import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class AddNewCard extends HookWidget {
  static const routeNamed = 'AddNewCard';
  const AddNewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final cardNumber = useState('');
    final name = useState('');
    final cardNumberController = useTextEditingController();
    final cvvController = useTextEditingController();
    final expiryDateController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final userStore = userStoreProvider();
    // final cardDetails = useState<CardFieldInputDetails?>(null);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const TitleRowWidget(
                text: 'Add New Card',
              ),

              //
              Expanded(
                child: SingleChildScrollView(
                  padding: AppPadding.scaffold,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //
                      Container(
                        height: SizeConfig.screenHeight * 0.26,
                        width: SizeConfig.screenWidth,
                        padding: AppPadding.containerHorizontal30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                                image: AssetImage(Assets.cardBG),
                                fit: BoxFit.cover)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: SizeConfig.screenHeight * 0.048,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.appName,
                                  style: AppTextStyles.style19W600.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright),
                                ),
                                Text(
                                  AppStrings.logo,
                                  style: AppTextStyles.style19W600.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceBright),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: SizeConfig.screenHeight * 0.036,
                            ),
                            Text(
                              formattedCardNumber(cardNumber: cardNumber.value),
                              style: AppTextStyles.style15W600.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceBright),
                            ),
                            SizedBox(
                              height: SizeConfig.screenHeight * 0.040,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.cardHolderName,
                                      style: AppTextStyles.style12w400.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                    Text(
                                      maskString(name.value),
                                      style: AppTextStyles.style12w400.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.expiryDate,
                                      style: AppTextStyles.style12w400.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                    Text(
                                      '**** / ****',
                                      style: AppTextStyles.style12w400.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                  ],
                                ),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      height: 34,
                                      width: 34,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceBright
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    Positioned(
                                        left: -14,
                                        child: Container(
                                          height: 34,
                                          width: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceBright,
                                          ),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      customTextFormField(
                        controller: nameController,
                        inputTextColor:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        label: AppStrings.name,
                        hintText: 'Enter your name',
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

                      const SizedBox(height: 24),

                      customTextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardNumberInputFormatter(),
                          LengthLimitingTextInputFormatter(19),
                        ],
                        customValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Card Number is required';
                          }

                          final cardNumber =
                              value.replaceAll(RegExp(r'\D'), '');

                          if (cardNumber.length < 12 ||
                              cardNumber.length > 19) {
                            return 'Invalid card number length';
                          }

                          if (!_isValidCardNumber(cardNumber)) {
                            return 'Invalid card number';
                          }
                          return null;
                        },
                        textInputType: TextInputType.number,
                        controller: cardNumberController,
                        onChanged: (value) {
                          cardNumber.value = value;
                        },
                        inputTextColor:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        label: AppStrings.cardNumber,
                        hintText: '0000 0000 0000 0000',
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: customTextFormField(
                              textInputType: TextInputType.number,
                              suffix: IconButton(
                                onPressed: null,
                                icon: CustomImageView(
                                  imagePath: Assets.icCalendar,
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              customValidator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Expiry date is required';
                                }

                                if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                                    .hasMatch(value)) {
                                  return 'Invalid format. Use MM/YY';
                                }

                                final parts = value.split('/');
                                final month = int.tryParse(parts[0]);
                                final year = int.tryParse(parts[1]);

                                if (month == null || year == null) {
                                  return 'Invalid date';
                                }

                                final now = DateTime.now();
                                final fourDigitYear = 2000 + year;
                                final expiryDate =
                                    DateTime(fourDigitYear, month + 1);

                                if (expiryDate.isBefore(now)) {
                                  return 'Card expired';
                                }

                                return null;
                              },
                              controller: expiryDateController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                CardExpiryDateInputFormatter(),
                              ],
                              inputTextColor: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                              label: AppStrings.expiryDate,
                              hintText: 'MM/YY',
                            ),
                          ),
                          const SizedBox(width: 10),

                          //
                          Expanded(
                            child: customTextFormField(
                              controller: cvvController,
                              textInputType: TextInputType.number,
                              inputTextColor: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                              label: AppStrings.cvv,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(3),
                              ],
                              hintText: '000',
                              customValidator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'CVV is required';
                                }
                                if (value.length == 3 || value.length == 4) {
                                  return null;
                                } else {
                                  return 'Invalid CVV';
                                }
                                // return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // CardField(
                      //   decoration: InputDecoration(
                      //     floatingLabelStyle: const TextStyle(
                      //       color: Colors.black,
                      //     ),
                      //     isDense: true,
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: const BorderRadius.all(
                      //           Radius.circular(AppRadius.common10)),
                      //       borderSide: BorderSide(
                      //         color: Theme.of(context)
                      //             .colorScheme
                      //             .onTertiaryContainer,
                      //       ),
                      //     ),
                      //     fillColor:
                      //         Theme.of(context).colorScheme.secondary,
                      //     focusedBorder: DecoratedInputBorder(
                      //       child: OutlineInputBorder(
                      //         borderSide: BorderSide(
                      //             color: Theme.of(context)
                      //                 .colorScheme
                      //                 .onTertiaryContainer,
                      //             width: 2),
                      //         borderRadius: Styles.textFieldBorderRadius,
                      //       ),
                      //       shadow: const BoxShadow(
                      //         color: Colors.transparent,
                      //       ),
                      //     ),
                      //     errorBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //           color: Theme.of(context).colorScheme.error,
                      //           width: 2),
                      //       borderRadius: Styles.textFieldBorderRadius,
                      //     ),
                      //     focusedErrorBorder: const OutlineInputBorder(
                      //       borderRadius: Styles.textFieldBorderRadius,
                      //       borderSide: BorderSide(
                      //         color: Colors.red,
                      //         width: 2,
                      //       ),
                      //     ),
                      //     hintText: 'Card Details',
                      //     hintStyle: TextStyle(
                      //       color: Theme.of(context)
                      //           .colorScheme
                      //           .onTertiaryContainer,
                      //       fontSize: 14,
                      //     ),
                      //     labelStyle: TextStyle(
                      //       color: Theme.of(context)
                      //           .colorScheme
                      //           .onTertiaryContainer,
                      //       fontSize: 14,
                      //     ),
                      //     label: Text(
                      //       'Card Details',
                      //       style: TextStyle(
                      //         fontSize: 14,
                      //         color: Theme.of(context)
                      //             .colorScheme
                      //             .onTertiaryContainer,
                      //       ),
                      //     ),
                      //   ),
                      //   style: TextStyle(
                      //       color: Theme.of(context).colorScheme.tertiary),
                      //   onCardChanged: (card) {
                      //     if (card != null) {
                      //       cardDetails.value = card;
                      //     }
                      //   },
                      // ),

                      SizedBox(height: SizeConfig.screenHeight * 0.14),
                    ],
                  ),
                ),
              ),

              Observer(
                builder: (context) {
                  final isLoading = userStore.isAddingCard;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.screenWidth * 0.04,
                    ),
                    child: CustomButton(
                      isLoading: isLoading,
                      height: 50,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          userStore.addCard(
                            cardNumber: cardNumberController.text,
                            cvv: cvvController.text,
                            cardHolderName: nameController.text,
                            expiryDate: expiryDateController.text,
                          );
                        }
                      },
                      text: AppStrings.addNewCard,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidCardNumber(String input) {
    int sum = 0;
    bool alternate = false;

    for (int i = input.length - 1; i >= 0; i--) {
      int digit = int.parse(input[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}

class CardExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
