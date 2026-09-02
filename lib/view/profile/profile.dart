import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/home/widget/add_new_card.dart';

import 'package:ridzs_passenger_app/view/profile/widget/card_widget.dart';
import 'package:ridzs_passenger_app/view/profile/widget/user_additional_info_view.dart';
import 'package:ridzs_passenger_app/view/profile/widget/user_card_widget.dart';
import 'package:ridzs_passenger_app/widgets/dialogs/app_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Profile extends HookWidget {
  static const String routeNamed = 'Profile';

  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = userStoreProvider();

    useEffect(() {
      userStore.getCard();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Observer(builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TitleRowWidget(text: AppStrings.myProfile),

              //
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.screenWidth * 0.04,
                  ),
                  child: Column(
                    children: [
                      //
                      const UserProfileCard(),

                      const SizedBox(height: 14),

                      const UserAdditionalInfoView(),

                      const SizedBox(height: 20),

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
                            child: Text(
                              'Add card',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.01),

                      Skeletonizer(
                        enabled: userStore.isCardLoading,
                        containersColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                            effect: ShimmerEffect(
                          baseColor:
                              Theme.of(context).colorScheme.tertiaryFixed,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: userStore.cardList?.cards?.length ?? 0,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, index) => SizedBox(
                            height: SizeConfig.screenHeight * 0.01,
                          ),
                          itemBuilder: (_, index) {
                            final cardDetail =
                                (userStore.cardList?.cards ?? [])[index];
                            return CardWidget(
                              cardDetail: cardDetail,
                              onRemoveCard: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (_) {
                                    return AppDialog(
                                      title: 'Are you sure?',
                                      subTitle:
                                          'Do you want to remove this card?',
                                      actionButtonTitle: 'Remove',
                                      icon: Assets.deleteIc,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      onYesPressed: () {
                                        NavigationService().pop(true);
                                      },
                                    );
                                  },
                                );
                                if (result == null) return;

                                if (result) {
                                  userStore.deleteCard(cardDetail.id!);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: ColoredBox(
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: EdgeInsets.only(
            right: SizeConfig.screenWidth * 0.04,
            left: SizeConfig.screenWidth * 0.04,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //
                CustomButton(
                  imageIcon: true,
                  iconPath: Assets.logoutIc,
                  iconHeight: 24,
                  iconWidth: 24,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AppDialog(
                          onYesPressed: () {
                            userStoreProvider().logoutUser(ignoreApiCall: true);
                          },
                          subTitle: AppStrings.doYouWantToLogout,
                          title: AppStrings.notice,
                          actionButtonTitle: 'Logout',
                          color: Theme.of(context).colorScheme.primary,
                          icon: Assets.logoutIc,
                        );
                      },
                    );
                  },
                  text: AppStrings.logout,
                  shadowColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                  showShadow: false,
                  textColor: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(
                  height: 10,
                ),

                CustomButton(
                  imageIcon: true,
                  iconPath: Assets.deleteIc,
                  iconHeight: 24,
                  iconWidth: 24,
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
                          color: Theme.of(context).colorScheme.onError,
                          icon: Assets.deleteIc,
                        );
                      },
                    );
                  },
                  shadowColor:
                      Theme.of(context).colorScheme.onError.withValues(alpha: .2),
                  showShadow: false,
                  text: AppStrings.deleteAccount,
                  textColor: Theme.of(context).colorScheme.onError,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
