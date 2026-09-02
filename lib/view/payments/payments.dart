import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/home/widget/add_new_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../profile/widget/card_widget.dart';

class Payments extends HookWidget {
  static const String routeNamed = 'Payments';

  const Payments({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedPayment = useState<int?>(null);
    final userStore = useMemoized(() => UserStore());

    useEffect(() {
      userStore.getCard();
      return null;
    }, []);

    //
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TitleRowWidget(
              text: AppStrings.payments,
            ),

            //
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
              ),
              child: Row(
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
                      NavigationService().navigateTo(AddNewCard.routeNamed);
                    },
                    child: const Text(
                      'Add Card',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff3478FF),
                      ),
                    ),
                  ),
                ],
              ),
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
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: Skeletonizer(
                    enabled: userStore.isCardLoading,
                    containersColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                    effect: ShimmerEffect(
                      baseColor: Theme.of(context).colorScheme.tertiaryFixed,
                    ),
                    child: ListView.separated(
                      itemCount: cardList.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.screenWidth * 0.04,
                      ),
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          right: SizeConfig.screenWidth * 0.04,
          left: SizeConfig.screenWidth * 0.04,
          bottom: Platform.isIOS
              ? SizeConfig.screenHeight * 0.03
              : SizeConfig.screenHeight * 0.01,
        ),
        child: CustomButton(
          text: 'Continue',
          onTap: () {},
        ),
      ),
    );
  }
}
