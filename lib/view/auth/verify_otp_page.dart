import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/create_profile/create_profile.dart';
import 'package:smart_auth/smart_auth.dart';
import '../../models/contracts/login_contract.dart';

class VerifyOTPScreen extends HookWidget {
  const VerifyOTPScreen({super.key});

  static const String routeNamed = 'VerifyOTPScreen';

  @override
  Widget build(BuildContext context) {
    final otpController = useTextEditingController();
    final timer = useState<Timer?>(null);
    final start = useState(60);
    final enableResend = useState(false);
    // final enableSubmit = useState(false);
    final recipient = userStoreProvider().recipient!;
    final smartAuth = useMemoized(() => SmartAuth());

    Future<void> verifyOtp() async {
      final res = await userStoreProvider().login(LoginContract(
        recipient: userStoreProvider().recipient!,
        otp: otpController.text,
      ));
      if (userStoreProvider().loggedInUser != null) {
        if (res.isNewUser) {
          NavigationService().pushNameAndRemoveUntil(CreateProfile.routeNamed);
        } else {
          NavigationService().pushNameAndRemoveUntil(MainPage.routeNamed);
        }
      } else {
        if (context.mounted) {
          showCustomDialog(
            context: context,
            title: 'Verification failed!',
            message: 'Please try again...',
          );
        }
      }
    }

    String? extractOtp(String message) {
      final regex = RegExp(r'Your OTP is: (\d{4})');
      final match = regex.firstMatch(message);
      return match?.group(1);
    }

    Future<void> listenForSms() async {
      if (!Platform.isIOS) {
        await smartAuth.getSmsCode().then((value) {
          if (value.succeed) {
            final code = extractOtp(value.code ?? '');
            if (code != null) {
              otpController.text = code;
              verifyOtp();
            }
          }
        });
      }
    }

    useEffect(() {
      void startTimer() {
        timer.value = Timer.periodic(
          const Duration(seconds: 1),
          (Timer t) {
            if (start.value == 0) {
              enableResend.value = true;
              t.cancel();
            } else {
              start.value--;
            }
          },
        );
      }

      startTimer();

      // Start listening for SMS
      if (!Platform.isIOS) {
        listenForSms();
      }

      return () {
        otpController.dispose();
        timer.value?.cancel();
        smartAuth.removeSmsListener();
      };
    }, []);

    void resetTimer() {
      start.value = 60;
      enableResend.value = false;
      timer.value?.cancel();
      timer.value = Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) {
          if (start.value == 0) {
            enableResend.value = true;
            t.cancel();
          } else {
            start.value--;
          }
        },
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: AppPadding.containerHorizontal40,
              child: Stack(
                children: [
                  SizedBox(
                    height: SizeConfig.screenHeight,
                    width: SizeConfig.screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Text(
                          AppStrings.verification,
                          style: AppTextStyles.style23W600.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.enterYourOTPToConfirmYourNumber,
                          style: AppTextStyles.style15white.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: OTPField(
                            controller: otpController,
                            onCompleted: verifyOtp,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.didNotReceiveCode,
                              style: AppTextStyles.style12W600.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            TextButton(
                              style: const ButtonStyle(
                                padding:
                                    WidgetStatePropertyAll(EdgeInsets.zero),
                              ),
                              onPressed: enableResend.value
                                  ? () async {
                                      await userStoreProvider()
                                          .requestCode(recipient);
                                      if (!context.mounted) return;
                                      resetTimer();
                                      if (Theme.of(context).platform !=
                                          TargetPlatform.iOS) {
                                        listenForSms();
                                      }
                                    }
                                  : null,
                              child: Text(
                                AppStrings.resendAgain,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              '${start.value} sec',
                              style: AppTextStyles.style12W600.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Visibility(
                      visible: userStoreProvider().isLoginLoading,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
