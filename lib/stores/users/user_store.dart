import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:mobx/mobx.dart';
import 'package:ridzs_passenger_app/core/constants/toast_constants.dart';
import 'package:ridzs_passenger_app/core/enums/analytic_event.dart';
import 'package:ridzs_passenger_app/core/enums/user/auth_provider_type.dart';
import 'package:ridzs_passenger_app/core/services/analytics_service.dart';
import 'package:ridzs_passenger_app/core/services/firebase_service.dart';
import 'package:ridzs_passenger_app/core/services/google_auth_service.dart';
import 'package:ridzs_passenger_app/core/services/preferences_service.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/core/theme/app_theme.dart';
import 'package:ridzs_passenger_app/models/common/user/user.dart';
import 'package:ridzs_passenger_app/models/contracts/login_contract.dart';
import 'package:ridzs_passenger_app/models/contracts/user_details_update_contract.dart';
import 'package:ridzs_passenger_app/models/payment/wallet_response_model.dart';
import 'package:ridzs_passenger_app/models/promocode/all_promocode_response_model.dart';
import 'package:ridzs_passenger_app/models/response/payment/get_card_response.dart'
    as card;
import 'package:ridzs_passenger_app/services/auth_service.dart';
import 'package:ridzs_passenger_app/services/payment_service.dart';
import 'package:ridzs_passenger_app/services/promocode_service.dart';
import 'package:ridzs_passenger_app/services/user_service.dart';
import 'package:ridzs_passenger_app/view/auth/verify_otp_page.dart';
import 'package:ridzs_passenger_app/widgets/dialogs/failed_dialog.dart';
import 'package:ridzs_passenger_app/widgets/loaders/loader.dart';
import 'package:ridzs_passenger_app/widgets/loaders/loading_page.dart';

import '../../core/services/navigation_service.dart';
import '../../models/payment/transaction_response_model.dart';
import '../../models/response/user/login_response.dart';
import '../../models/response/user/me_response.dart';
import '../../view/home/main_page.dart';
import '../map/map_store.dart';
part 'user_store.g.dart';

class UserStore = UserStoreBase with _$UserStore;

UserStore userStoreProvider({bool listen = false}) {
  return Provider.of(NavigationService.navigatorKey.currentContext!,
      listen: listen);
}

abstract class UserStoreBase with Store {
  @observable
  ObservableMap<String, User> userCollection = ObservableMap<String, User>();

  @observable
  ObservableList<String> searchUserIds = ObservableList<String>();

  @observable
  User? loggedInUser;

  @observable
  bool isLoginLoading = false;

  @observable
  bool isImageUploading = false;

  @observable
  bool isError = false;

  @observable
  String? errorMessage;

  @observable
  String? recipient;

  @observable
  bool isVerifying = false;

  @observable
  bool isListLoading = false;

  @observable
  bool isCardLoading = false;

  @observable
  ThemeMode themeMode = ThemeMode.system;

  @action
  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    log('Saving theme mode: $themeMode');
    AppTheme.setThemeMode(mode);
  }

  @action
  Future<void> getSavedTheme() async {
    final theme = await AppTheme.themeMode;
    log('Saved theme mode: $theme');
    setThemeMode(theme);
  }

  @observable
  card.GetCardResponse? cardList;

  @action
  void setListLoading(bool isLoading) => isListLoading = isLoading;

  @action
  void setCardLoading(bool isLoading) => isCardLoading = isLoading;

  @action
  void setLoggedInUser(User? user) {
    loggedInUser = user;
    if (user != null) {
      addUsers([user]);
    }
    setIsLoginLoading(false);
  }

  @action
  void setRecipient(String recipient) => this.recipient = recipient;

  @action
  void setIsVerifying(bool isVerifying) => this.isVerifying = isVerifying;

  @action
  void setIsLoginLoading(bool isLoading) => isLoginLoading = isLoading;

  @action
  void setIsImageUploading(bool isLoading) => isImageUploading = isLoading;

  @action
  void setIsError(bool error) => isError = error;

  @action
  void setErrorMessage(String? message) => errorMessage = message;

  @action
  void addUsers(List<User> users, [bool addSearchIds = false]) {
    for (final user in users) {
      userCollection[user.id] = user;
      if (addSearchIds && !searchUserIds.contains(user.id)) {
        searchUserIds.add(user.id);
      }
    }
  }

  @action
  void clearSearchUsersId() => searchUserIds.clear();

  List<User> get searchUsers =>
      searchUserIds.map((e) => userCollection[e]).whereType<User>().toList();

  List<User> get users => userCollection.values.toList();

  User? getUser(String id) => userCollection[id];

  @action
  Future<void> registerFCMToken() async {
    final fcmToken = await FirebaseService().getToken();
    if (fcmToken != null) {
      try {
        final res = await AuthService.sendFCMToken(fcmToken);
        if (kDebugMode) {
          if (res.success) {
            debugPrint('FCM TOKEN: $fcmToken');
            ToastService.show(AppToastMessages.fcmTokenRegisterSuccess);
          } else {
            ToastService.show(AppToastMessages.fcmTokenRegisterFailure);
          }
        }
      } catch (err) {
        debugPrint('FCM Token Registration Error: $err');
      }
    }
  }

  @action
  Future<void> onboardUser() async {
    await PreferencesService.setOnboardingStatus('a');
    await getMe();
  }

  @observable
  MeResponse? meResponse;

  @action
  Future<void> getMe() async {
    // final currentUser = loggedInUser;
    // if (currentUser != null) {
    //   AnalyticService().logEvent(AnalyticEventType.login, {
    //     'user_id': currentUser.id,
    //     'recipient': (currentUser.isMobileVerified ?? false)
    //         ? currentUser.mobileNumber
    //         : currentUser.email,
    //   });

    //   NavigationService().pushNameAndRemoveUntil(WelcomeScreen.routeNamed);
    //   return;
    // }

    final token = await PreferencesService.getAccessToken();
    if (token == null || token.isEmpty) {
      debugPrint('No token found');
      NavigationService().replaceWith(LoadingPage.routeNamed);
      return;
    }

    setIsLoginLoading(true);
    try {
      // Uncomment and implement the following lines when AuthService.getMe() is available
      final response = await AuthService.getMe();
      meResponse = response;
      setLoggedInUser(response.user);
      AnalyticService().logEvent(AnalyticEventType.login, {
        'user_id': response.user.id,
        'email': response.user.email,
      });
      debugPrint('Logged in user: ${response.user.username}');
      mapStoreProvider().initialize();
      // unawaited(userStoreProvider().getCard());
      unawaited(mapStoreProvider().getPrices());
      NavigationService().pushNameAndRemoveUntil(MainPage.routeNamed);
    } catch (err) {
      debugPrint('Error in getMe: $err');
      NavigationService().replaceWith(LoadingPage.routeNamed);
    } finally {
      setIsLoginLoading(false);
    }
  }

  @action
  Future<void> getMeMainPage() async {
    // final currentUser = loggedInUser;
    // if (currentUser != null) {
    //   AnalyticService().logEvent(AnalyticEventType.login, {
    //     'user_id': currentUser.id,
    //     'recipient': (currentUser.isMobileVerified ?? false)
    //         ? currentUser.mobileNumber
    //         : currentUser.email,
    //   });

    //   NavigationService().pushNameAndRemoveUntil(WelcomeScreen.routeNamed);
    //   return;
    // }

    final token = await PreferencesService.getAccessToken();
    if (token == null || token.isEmpty) {
      debugPrint('No token found');
      NavigationService().replaceWith(LoadingPage.routeNamed);
      return;
    }

    setIsLoginLoading(true);
    try {
      // Uncomment and implement the following lines when AuthService.getMe() is available
      final response = await AuthService.getMe();
      meResponse = response;
      setLoggedInUser(response.user);
      AnalyticService().logEvent(AnalyticEventType.login, {
        'user_id': response.user.id,
        'email': response.user.email,
      });
      debugPrint('Logged in user: ${response.user.username}');
      mapStoreProvider().initialize();
      // unawaited(userStoreProvider().getCard());
      unawaited(mapStoreProvider().getPrices());
    } catch (err) {
      debugPrint('Error in getMe: $err');
      NavigationService().replaceWith(LoadingPage.routeNamed);
    } finally {
      setIsLoginLoading(false);
    }
  }

  @action
  Future<LoginResponse> login(LoginContract payload) async {
    setIsLoginLoading(true);
    try {
      final res = await AuthService.login(payload);
      await PreferencesService.setAccessToken(res.token);
      setLoggedInUser(res.user);

      AnalyticService().logEvent(AnalyticEventType.login, {
        'user_id': res.user.id,
        'recipient': res.user.email ?? res.user.mobileNumber,
      });
      return res;
    } catch (e) {
      debugPrint('Login error: $e');
      setIsLoginLoading(false);
      showCustomDialog(
        context: NavigationService.navigatorKey.currentContext!,
        title: 'Verification failed!',
        message: '$e\nPlease try again...',
      );
      rethrow;
    } finally {
      setIsLoginLoading(false);
    }
  }

  @action
  Future<void> requestCode(String recipient) async {
    setIsVerifying(true);
    try {
      Loader.showLoader();
      final res = await AuthService.requestCode(recipient);
      if (!res.success) {
        setIsError(true);
        setErrorMessage(res.error);
        ToastService.show('Error sending OTP, Please try again!');
        return;
      }
      setRecipient(recipient);
      NavigationService().navigateTo(VerifyOTPScreen.routeNamed);
      ToastService.show('OTP sent successfully');
    } catch (e) {
      debugPrint('Request code error: $e');
      rethrow;
    } finally {
      Loader.hideLoader();
      setIsVerifying(false);
    }
  }

  @action
  Future<void> updateFCMToken() async {
    try {
      await UserService().updateFCMToken();
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  @action
  Future<void> logoutUser({bool ignoreApiCall = false}) async {
    if (!ignoreApiCall) {
      await AuthService.logOut();
    }
    await PreferencesService.removeAccessToken();

    if (loggedInUser?.authType == AuthProviderType.google) {
      await GoogleAuthService().signOut();
    }
    setLoggedInUser(null);

    ToastService.show('Logged out');
    NavigationService().pushNameAndRemoveUntil(LoadingPage.routeNamed);
  }

  @action
  Future<void> updateUser(UserDetailsUpdateContract contract) async {
    setIsLoginLoading(true);
    try {
      await AuthService.updateProfile(contract);
      await getMeMainPage();
      setIsError(false);
    } catch (e) {
      debugPrint('Update user error: $e');
      ToastService.show('Error updating profile');
      setIsError(true);
      setErrorMessage(e.toString());
      throw Exception('Failed to update profile');
    } finally {
      setIsLoginLoading(false);
    }
  }

  @action
  Future<String> uploadImage(String imagePath) async {
    setIsLoginLoading(true);
    try {
      final image = await AuthService.uploadImage(imagePath);
      if (image.isEmpty) {
        ToastService.show('Error uploading image');
        throw Exception('Failed to upload image');
      }
      return image;
    } catch (e) {
      debugPrint('Upload image error: $e');
      ToastService.show('Error uploading image');
      throw Exception('Failed to upload image');
    } finally {
      setIsLoginLoading(false);
    }
  }

  @action
  Future<void> signInWithGoogle() async {
    final idToken = await GoogleAuthService().signInWithGoogle();
    if (idToken != null) {
      try {
        final res = await AuthService.loginWithGoogle(idToken);
        setLoggedInUser(res.user);
        await PreferencesService.setAccessToken(res.token);
        AnalyticService().logEvent(AnalyticEventType.login, {
          'user_id': res.user.id,
          'recipient': res.user.email,
        });
        NavigationService().pushNameAndRemoveUntil(MainPage.routeNamed);
      } catch (e) {
        debugPrint('Sign in with Google error: $e');
        ToastService.show('Error signing in with Google');
      }
    }
  }

  @observable
  bool isAddingCard = false;

  @action
  Future<void> addCard({
    required String cardNumber,
    required String cvv,
    required String cardHolderName,
    required String expiryDate,
  }) async {
    isAddingCard = true;
    try {
      // final cardParams = CardDetails(
      //   number: cardNumber,
      //   expirationMonth: int.parse(expiryParts[0]),
      //   expirationYear: int.parse(expiryParts[1]),
      //   cvc: cvv,
      // );
      final res = await PaymentService.initStripe();
      final clientSecret = res['clientSecret'];

      final setupIntentResult = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: userStoreProvider().loggedInUser!.email,
              name: cardHolderName,
            ),
          ),
        ),
      );

      final addRes = await PaymentService.addCard(setupIntentResult);
      NavigationService().pop();
      getCard();
      ToastService.show(addRes['message'] ?? '');
      if (kDebugMode) {
        print('addRes --> $addRes');
      }
    } catch (e) {
      debugPrint('Error adding in new card: $e');
      ToastService.show('Error adding in new card');
    } finally {
      isAddingCard = false;
    }
  }

  @action
  Future<void> getCard() async {
    setCardLoading(true);
    try {
      final res = await PaymentService.getCards();
      cardList = res;
      log('Length --> ${cardList?.cards?.length ?? 00}');
    } catch (e) {
      debugPrint('Get Card Api Getting Error --> ${e.toString()}');
      cardList = null;
      setCardLoading(false);
      // ToastService.show('something want to wrong');
    } finally {
      setCardLoading(false);
    }
  }

  @action
  Future<void> deleteCard(String cardId) async {
    setCardLoading(true);
    try {
      await PaymentService.deleteCard(cardId);
      await getCard();
    } catch (e) {
      debugPrint('Error deleting card: $e');
      ToastService.show('Error deleting card');
    } finally {
      setCardLoading(false);
    }
  }

  @action
  Future<bool> makeDirectPayment(
    num amount,
  ) async {
    try {
      log('Amount: $amount');
      // final clientId = await PaymentService.initStripe();
      final paymentRes = await initializePayment(amount);

      // final clientSecret = clientId['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Ridz',
          customerId: paymentRes['customer'],
          customerEphemeralKeySecret: paymentRes['ephemeralKey'],
          paymentIntentClientSecret: paymentRes['paymentIntent'],
          allowsDelayedPaymentMethods: false,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeError catch (e) {
      log('Error making payment: $e');
      ToastService.show(e.message);
      return false;
    } catch (e, st) {
      log('Error making payment: $e');
      log('Error making payment: $st');
      ToastService.show('Error making payment');
      return false;
    } finally {
      isPaymentLoading = false;
    }
  }

  @observable
  bool isPaymentLoading = false;

  @observable
  bool isWalletLoading = false;

  @observable
  Balance walletBalance = Balance.unknown();

  @action
  Future<Map<String, dynamic>> initializePayment(num amount) async {
    try {
      isPaymentLoading = true;
      final result = await PaymentService.initializePayment(amount);
      isPaymentLoading = false;
      return result;
    } catch (e) {
      log('Error initializing payment: $e');
      ToastService.show('Error initializing payment');
      isPaymentLoading = false;
      return {};
    }
  }

  @observable
  bool isAddingAmount = false;

  @action
  Future<void> addWalletAmount(num amount) async {
    try {
      isAddingAmount = true;
      final paymentRes = await initializePayment(amount);

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Ridz',
          customerId: paymentRes['customer'],
          customerEphemeralKeySecret: paymentRes['ephemeralKey'],
          paymentIntentClientSecret: paymentRes['paymentIntent'],
          allowsDelayedPaymentMethods: false,
        ),
      );

      // Present the payment sheet and get the result
      await Stripe.instance.presentPaymentSheet();

      // Retrieve the PaymentIntent to get the paymentMethodId
      final paymentIntent = await Stripe.instance
          .retrievePaymentIntent(paymentRes['paymentIntent']);

      final paymentMethodId = paymentIntent.paymentMethodId;

      log('PaymentMethodId: $paymentMethodId');

      // log('Payment successful, adding wallet amount ${sheet?.toJson()}');
      if (paymentMethodId == null) {
        ToastService.show('Failed to add amount to wallet');
        isAddingAmount = false;
        return;
      }

      await UserService().addWalletAmount(paymentMethodId, amount);
      ToastService.show('Wallet amount added successfully');
      transactionPageNo = 1;
      getWallet();
      getTransactionList();
    } catch (e) {
      log('Error adding wallet amount: $e');
      ToastService.show('Error adding wallet amount');
      isAddingAmount = false;
    } finally {
      isAddingAmount = false;
    }
  }

  @action
  Future<void> getWallet() async {
    try {
      isWalletLoading = true;
      final result = await PaymentService.getWalletBalance();
      if (result == null) return;
      walletBalance = result;
      isWalletLoading = false;
    } catch (e) {
      log('Error getting wallet balance: $e');
      ToastService.show('Error getting wallet balance');
      isWalletLoading = false;
    } finally {
      isWalletLoading = false;
    }
  }

  @observable
  bool isTransactionLoading = false;

  @observable
  bool loadMoreData = false;

  @observable
  int transactionPageNo = 1;

  @observable
  List<Transaction> transactionList = [];

  @action
  Future<void> getTransactionList() async {
    try {
      isTransactionLoading = true;
      final result = await PaymentService.getUserTransaction(transactionPageNo);
      if (transactionPageNo == 1) {
        transactionList.clear();
      }

      if (result.isNotEmpty) {
        transactionPageNo++;
        loadMoreData = true;
        transactionList.addAll(result);
      } else {
        loadMoreData = false;
      }
    } catch (e) {
      log('Error getting transaction list: $e');
      ToastService.show('Error getting transaction list');
    } finally {
      isTransactionLoading = false;
    }
  }

  @observable
  bool isPromocodeLoading = false;

  @observable
  List<Bonuses> promocodeList = [];

  @action
  Future<void> getAllPromocode() async {
    try {
      isPromocodeLoading = true;
      final response = await PromoCodeService().getAllPromocode();
      promocodeList = [];
      if (response.isNotEmpty) {
        promocodeList = response;
      } else {
        ToastService.show('No promocode available');
      }
    } catch (e) {
      log('Error getting promocode: $e');
      ToastService.show('Error getting promocode');
    } finally {
      isPromocodeLoading = false;
    }
  }
}
