import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/constants/extension.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/view/home/widget/add_new_card.dart';
import 'package:ridzs_passenger_app/view/profile/widget/card_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddTopUpWalletScreen extends HookWidget {
  static const String routeName = '/add_topup_wallet';
  const AddTopUpWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final amounts = ['200', '500', '1000'];
    final selectedAmount = useState('');
    final customTextController = useTextEditingController();
    final selectedPayment = useState<int?>(null);
    final userStore = userStoreProvider();

    useEffect(() {
      userStore.getCard();
      return null;
    }, []);

    //
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: Column(
          children: [
            //
            const TitleRowWidget(text: 'Top up'),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //

                    Text(
                      'Choose or enter the amount to be added',
                      style: AppTextStyles.style15W600.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: .3),
                    ),

                    const SizedBox(height: 16),

                    //
                    Row(
                      children: [
                        //
                        ...List.generate(
                          amounts.length,
                          (i) {
                            return Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  selectedAmount.value = amounts[i];
                                  customTextController.clear();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: selectedAmount.value == amounts[i]
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '\$${amounts[i]}',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.style12W500.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        Expanded(
                          flex: 3,
                          child: customTextFormField(
                            hintText: '\$ 20',
                            label: 'Custom',
                            onTap: () {
                              selectedAmount.value = '';
                            },
                            textInputType: TextInputType.number,
                            controller: customTextController,
                          ),
                        ),
                      ].addHSpacing(10),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Payment Methods',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            NavigationService()
                                .navigateTo(AddNewCard.routeNamed);
                          },
                          child: const Text(
                            'Add new payment',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff3478FF),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.015),

                    Observer(
                      builder: (context) {
                        final cardList = userStore.cardList?.cards ?? [];

                        if (!userStore.isCardLoading && cardList.isEmpty) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                AppStrings.noCards,
                                style: AppTextStyles.style23W600.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          );
                        }

                        return Expanded(
                          child: Skeletonizer(
                            enabled: userStore.isCardLoading,
                            containersColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                                effect: ShimmerEffect(
                              baseColor:
                                  Theme.of(context).colorScheme.tertiaryFixed,
                            ),
                            child: ListView.separated(
                              itemCount: cardList.length,
                              shrinkWrap: true,
                              separatorBuilder: (context, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final cardDetail = cardList[index];
                                return GestureDetector(
                                  onTap: () {
                                    selectedPayment.value = index;
                                  },
                                  child: CardWidget(
                                    cardDetail: cardDetail,
                                    isSelectableTile: true,
                                    isSelected: selectedPayment.value == index,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Observer(builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                ),
                child: CustomButton(
                  text: 'Add Amount',
                  isLoading: userStore.isAddingAmount,
                  onTap: () async {
                    if (userStore.isAddingAmount) return;
                    final amount = selectedAmount.value.isNotEmpty
                        ? selectedAmount.value
                        : customTextController.text;

                    if (amount.isEmpty) {
                      ToastService.show('Please enter an amount to add.');
                      return;
                    }

                    await userStore.addWalletAmount(int.parse(amount));

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
