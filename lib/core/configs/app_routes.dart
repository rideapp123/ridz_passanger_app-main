import 'package:flutter/material.dart';
import 'package:ridzs_passenger_app/view/auth/login_with_email.dart';
import 'package:ridzs_passenger_app/view/auth/verify_otp_page.dart';
import 'package:ridzs_passenger_app/view/cancel_trip/cancel_trip.dart';
import 'package:ridzs_passenger_app/view/create_profile/create_profile.dart';
import 'package:ridzs_passenger_app/view/faq_screen.dart';
import 'package:ridzs_passenger_app/view/home/widget/add_new_card.dart';
import 'package:ridzs_passenger_app/view/home/widget/drawer_main.dart';
import 'package:ridzs_passenger_app/view/invite_friends/invite_friends.dart';
import 'package:ridzs_passenger_app/view/legal/legal.dart';
import 'package:ridzs_passenger_app/view/my_rewards/ad_watch_screen.dart';
import 'package:ridzs_passenger_app/view/my_rewards/my_rewards.dart';
import 'package:ridzs_passenger_app/view/my_wallet/add_topup_wallet_screen.dart';
import 'package:ridzs_passenger_app/view/my_wallet/my_wallet.dart';
import 'package:ridzs_passenger_app/view/notifications/notifications.dart';
import 'package:ridzs_passenger_app/view/payments/payments.dart';
import 'package:ridzs_passenger_app/view/payments/payment_recovery_screen.dart';
import 'package:ridzs_passenger_app/view/profile/edit_profile_screen.dart';
import 'package:ridzs_passenger_app/view/profile/profile.dart';
import 'package:ridzs_passenger_app/view/promo_codes/promo_codes.dart';
import 'package:ridzs_passenger_app/view/rate_driver/rate_driver.dart';
import 'package:ridzs_passenger_app/view/settings/settings.dart';
import 'package:ridzs_passenger_app/view/terms_and_condition_screen.dart';
import 'package:ridzs_passenger_app/view/trip_history/trip_history.dart';
import 'package:ridzs_passenger_app/view/trip_history/ride_trace_screen.dart';
import 'package:ridzs_passenger_app/view/welcome/welcome_screen.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart'
    as ride_model;

import '../../view/auth/login_page.dart';
import '../../view/home/main_page.dart';
import '../../view/splash/splash_screen.dart';
import '../../widgets/loaders/loading_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (context) {
      return switch (settings.name) {
        SplashScreen.routeNamed => const SplashScreen(),
        LoginPage.routeNamed => const LoginPage(),
        MainPage.routeNamed => const MainPage(),
        CreateProfile.routeNamed => const CreateProfile(),
        Profile.routeNamed => const Profile(),
        CancelTrip.routeNamed => CancelTrip(),
        Legal.routeNamed => const Legal(),
        Notifications.routeNamed => const Notifications(),
        Payments.routeNamed => const Payments(),
        NavigationDrawerMain.routeNamed => const NavigationDrawerMain(),
        VerifyOTPScreen.routeNamed => const VerifyOTPScreen(),
        RateDriver.routeNamed => const RateDriver(),
        PromoCodes.routeNamed => const PromoCodes(),
        TripHistory.routeNamed => const TripHistory(),
        RideTraceScreen.routeNamed => RideTraceScreen(
            ride: ((settings.arguments as Map<String, dynamic>?)?['ride']
                    as ride_model.Ride?) ??
                ride_model.Ride.unknown(),
          ),
        Settings.routeNamed => const Settings(),
        MyRewards.routeNamed => const MyRewards(),
        PaymentRecoveryScreen.routeNamed => PaymentRecoveryScreen(
            ride: ((settings.arguments as Map<String, dynamic>?)?['ride']
                    as ride_model.Ride?) ??
                ride_model.Ride.unknown(),
          ),
        AdWatchScreen.routeNamed => AdWatchScreen(
            rideId: (settings.arguments as Map<String, dynamic>?)?['rideId']
                as String?,
          ),
        WelcomeScreen.routeNamed => const WelcomeScreen(),
        InviteFriends.routeNamed => const InviteFriends(),
        LoginWithEmailScreen.routeNamed => const LoginWithEmailScreen(),
        MyWallet.routeNamed => const MyWallet(),
        AddNewCard.routeNamed => const AddNewCard(),
        AddTopUpWalletScreen.routeName => const AddTopUpWalletScreen(),
        TermsAndConditionScreen.routeNamed => const TermsAndConditionScreen(),
        LoadingPage.routeNamed => const LoadingPage(),
        EditProfileScreen.routeNamed => const EditProfileScreen(),
        FAQScreen.routeNamed => const FAQScreen(),
        _ => const MainPage(),
      };
    },
  );
}
