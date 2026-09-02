import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PromoCodes extends HookWidget {
  static const String routeNamed = 'PromoCodes';

  const PromoCodes({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedRadio = useState(0);
    final themeColor = Theme.of(context).colorScheme;
    final userStore = userStoreProvider();

    useEffect(() {
      userStore.getAllPromocode();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const TitleRowWidget(text: AppStrings.promoCode),

            //
            Observer(builder: (context) {
              if (!userStore.isPromocodeLoading &&
                  userStore.promocodeList.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      'No promo codes available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: themeColor.tertiary,
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: Skeletonizer(
                  enabled: userStore.isPromocodeLoading,
                  containersColor: themeColor.surfaceContainerHigh,
                  effect: ShimmerEffect(
                    baseColor: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  child: ListView.separated(
                    itemCount: userStore.promocodeList.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 10,
                        color: themeColor.outlineVariant.withValues(alpha: .2),
                      );
                    },
                    itemBuilder: (context, index) {
                      final promocodeData = userStore.promocodeList[index];
                      if (userStore.isPromocodeLoading) {
                        return const Card(
                          child: ListTile(
                            title: Text('This is a promo code'),
                            subtitle: Text('This is a description'),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            selectedRadio.value = index;
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: themeColor.surfaceContainer
                                      .withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomImageView(
                                      width: 26,
                                      height: 26,
                                      imagePath: Assets.icPromoCode,
                                      color: themeColor.surfaceContainer,
                                    ),
                                  ],
                                ),
                              ),

                              //
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      promocodeData.code ?? 'N/A',
                                      style: AppTextStyles.style16W600.copyWith(
                                        color: themeColor.tertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      promocodeData.description ??
                                          'No description',
                                      style: AppTextStyles.style12W500.copyWith(
                                        color: themeColor.tertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      promocodeData.endDate != null
                                          ? 'Valid till: ${DateFormat('dd MMM, yyy').format(DateTime.parse(promocodeData.endDate!))}'
                                          : 'No expiry date',
                                      style: AppTextStyles.style16W600.copyWith(
                                        color: themeColor.onSecondaryContainer,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
