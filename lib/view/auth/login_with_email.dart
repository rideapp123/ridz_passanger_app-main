import 'package:ridzs_passenger_app/view/legal/passenger_legal_links.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class LoginWithEmailScreen extends HookWidget {
  const LoginWithEmailScreen({super.key});

  static const String routeNamed = 'LoginWithEmailScreen';

  @override
  Widget build(BuildContext context) {
    final emailFocusNode = useFocusNode();
    final emailController = useTextEditingController();
    final loginEmailInFormKey = useRef(GlobalKey<FormState>());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: CommonIconButton(
          icon: Icons.arrow_back,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Form(
            key: loginEmailInFormKey.value,
            child: Padding(
              padding: AppPadding.containerHorizontal40,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConfig.screenHeight * 0.16),
                    Text(
                      AppStrings.logInWithEmail,
                      style: AppTextStyles.style23W600.copyWith(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    customTextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputType: TextInputType.emailAddress,
                      customValidator: emailValidator,
                      controller: emailController,
                      focusNode: emailFocusNode,
                      inputTextColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      label: AppStrings.email,
                      hintText: AppStrings.enterYourMail,
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.05),
                    const Center(child: PassengerLegalLinks()),
                    SizedBox(height: SizeConfig.screenHeight * 0.04),
                    CustomButton(
                      onTap: () async {
                        if (loginEmailInFormKey.value.currentState!
                            .validate()) {
                          await userStoreProvider()
                              .requestCode(emailController.text);
                        }
                      },
                      borderRadius: 16,
                      isLoading: userStoreProvider().isVerifying,
                      text: AppStrings.login,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
