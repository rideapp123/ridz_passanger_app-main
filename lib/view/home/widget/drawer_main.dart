import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/faq_screen.dart';

import 'package:ridzs_passenger_app/view/my_wallet/my_wallet.dart';

import '../../../models/common/user/user.dart';
import '../../rate_driver/widget/star_widget.dart';

class NavigationDrawerMain extends StatelessWidget {
  static const String routeNamed = 'NavigationDrawerMain';

  const NavigationDrawerMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        bottom: false,
        child: Observer(
          builder: (context) {
            final user = userStoreProvider().meResponse?.user;
            return Column(
              children: <Widget>[
                const SizedBox(height: 8),
                _buildProfileSection(context, user),
                const SizedBox(height: 10),
                _buildDivider(context),
                _buildDrawerListTiles(context),
                const Spacer(),
                _buildDivider(context),
                _buildFooterSection(context),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    User? user,
  ) {
    return InkWell(
      onTap: () {
        NavigationService().navigateTo(Profile.routeNamed);
      },
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildProfileImage(context, user),
          const SizedBox(width: 10),
          _buildProfileDetails(context, user),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        _buildUsername(context, user),
        const SizedBox(height: 6),
        // _buildLocation(context),
        _buildRating(context),
      ],
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    User? user,
  ) {
    final user = userStoreProvider().meResponse?.user;

    return SizedBox(
      height: SizeConfig.screenHeight * 0.09,
      width: SizeConfig.screenHeight * 0.09,
      child: ((user?.profilePicture ?? '').isEmpty)
          ? Container(
              height: SizeConfig.screenHeight * 0.09,
              width: SizeConfig.screenHeight * 0.09,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: SizeConfig.screenHeight * 0.05,
                  color: Colors.white,
                ),
              ),
            )
          : Builder(
              builder: (context) {
                debugPrint('Drawer profile picture URL: ${user?.profilePicture}');
                return ClipOval(
                  child: CustomImageView(
                    url: user?.profilePicture,
                    fit: BoxFit.cover,
                    height: SizeConfig.screenHeight * 0.09,
                    width: SizeConfig.screenHeight * 0.09,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildUsername(BuildContext context, User? user) {
    return Observer(
      builder: (context) => Text(
        user?.username ?? '',
        style: AppTextStyles.style15W600.copyWith(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Widget _buildLocation(BuildContext context, User? user) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       //
  //       CustomImageView(
  //         imagePath: Assets.icLocation,
  //         height: 14,
  //         width: 14,
  //         color: Theme.of(context).colorScheme.secondary,
  //       ),

  //       const SizedBox(width: 6),

  //       Text(
  //         'Address',
  //         style: AppTextStyles.style12W500.copyWith(
  //           color: Theme.of(context).colorScheme.surfaceContainer,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildRating(BuildContext context) {
    return Row(
      children: [
        const SingleStar(
          rating: 4.65,
          starSize: 14,
        ),
        const SizedBox(width: 6),
        Text(
          '4.65',
          style: AppTextStyles.style12W500.copyWith(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        )
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return const Divider(
      height: 2,
      // color: Theme.of(context).colorScheme.tertiaryContainer,
      color: Color(0xffD5D5D5),
    );
  }

  Widget _buildDrawerListTiles(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: Column(
        children: [
          DrawerListTile(
            iconPath: Assets.profileIc,
            title: 'My Profile',
            onTap: () {
              NavigationService().navigateTo(Profile.routeNamed);
            },
          ),
          DrawerListTile(
            iconPath: Assets.paymentIc,
            title: AppStrings.payments,
            onTap: () {
              NavigationService().navigateTo(Payments.routeNamed);
            },
          ),
          DrawerListTile(
            iconPath: Assets.rideHistoryIc,
            title: AppStrings.rideHistory,
            onTap: () {
              NavigationService().navigateTo(TripHistory.routeNamed);
            },
          ),
          DrawerListTile(
            iconPath: Assets.inviteFriendIc,
            title: AppStrings.inviteFriends,
            onTap: () {
              NavigationService().navigateTo(InviteFriends.routeNamed);
            },
          ),
          DrawerListTile(
            iconPath: Assets.notificationIc,
            title: AppStrings.notifications,
            onTap: () {
              NavigationService().navigateTo(Notifications.routeNamed);
            },
          ),
          DrawerListTile(
            iconPath: Assets.promoCodeIc,
            title: AppStrings.promoCode,
            onTap: () {
              NavigationService().navigateTo(PromoCodes.routeNamed);
            },
          ),
          DrawerListTile(
            iconPath: Assets.rewardIc,
            title: AppStrings.rewards,
            onTap: () {
              NavigationService().navigateTo(MyRewards.routeNamed);
            },
          ),
          DrawerListTile(
            iconPath: Assets.walletIc,
            title: AppStrings.myWallet,
            onTap: () {
              NavigationService().navigateTo(MyWallet.routeNamed);
            },
          ),
          // DrawerListTile(
          //   iconPath: Assets.legalIc,
          //   title: AppStrings.legal,
          //   onTap: () {
          //     NavigationService().navigateTo(Legal.routeNamed);
          //   },
          // ),
          DrawerListTile(
            iconPath: Assets.generalSettingsIc,
            title: AppStrings.settings,
            onTap: () {
              NavigationService().navigateTo(Settings.routeNamed);
            },
          ),
          DrawerListTile(
            iconPath: Assets.helpIc,
            title: 'FAQ',
            onTap: () {
              NavigationService().navigateTo(
                FAQScreen.routeNamed,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 20),
      child: Row(
        children: [
          CustomImageView(
            imagePath: Assets.icSteering,
            height: 20,
            width: 20,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppStrings.driveWith,
                  style: AppTextStyles.style15white.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                TextSpan(
                  text: AppStrings.appName,
                  style: AppTextStyles.style15white.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends HookWidget {
  final String iconPath;
  final String title;
  final VoidCallback onTap;

  const DrawerListTile({
    super.key,
    required this.iconPath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: CustomImageView(
        width: 18,
        height: 18,
        svgPath: iconPath,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      title: Text(
        title,
        style: AppTextStyles.style15white.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
